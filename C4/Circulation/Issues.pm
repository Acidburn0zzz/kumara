package C4::Circulation; #asummes C4/Circulation/Issues

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;
use C4::Interface;
use C4::Circulation;
use C4::Scan;
use C4::Stats;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&Issue);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);
	
# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();
		    
# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();
	
# all file-scoped lexicals must be created before
# the functions below that use them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();
			    
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;


sub Issue  {
  my (%env) = @_;
  my $dbh=&C4Connect;
  #clear help
  helptext('');
  clearscreen();
  #get borrowerbarcode from scanner
  my ($borcode,$reason)=&scanborrower();
#  output(1,1,$borcode);
  my $sth=$dbh->prepare("Select * from borrowers where cardnumber='$borcode'");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  my $bornum=$borrower->{'borrowernumber'};
  $sth->finish;
  while ($bornum eq ''){
    #If borrower not found enter loop until borrower is found
    output(1,1,"Borrower not found, please rescan or reenter borrower code");
    ($borcode,$reason)=&scanborrower();
    $sth=$dbh->prepare("Select * from borrowers where cardnumber='$borcode'");
    $sth->execute;
    $borrower=$sth->fetchrow_hashref;
    $bornum=$borrower->{'borrowernumber'};
    $sth->finish;
    
   } 
    my $borrowers=join(' ',($borrower->{'title'},$borrower->{'firstname'},
    $borrower->{'surname'}));
    output(1,1,$borrowers);
    #process borrower traps (could be function)
    #check first GNA trap (no address this is the 22nd item in the table)
    if ($borrower->{'gonenoaddress'} == 1){
      #got to membership update and update member info
      output(20,1,"Borrower has no address");
      pause();
    }
    #check if member has a card reported as lost
    if ($borrower->{'lost'} ==1){
      #update member info
      output(20,1,"Borrower has lost card");
    }
    #check the notes field if notes exist display them
    if ($borrower->{'borrowernotes'} ne ''){
      #display notes
      #deal with notes as issue_process.doc
      output(20,1,$borrower->{'borrowernotes'});
    }
    #check if borrower has overdue items
    #call overdue checker
    &checkoverdues(\%env,$bornum,$dbh);
    #check amountowing
    my $amount=checkaccount(\%env,$bornum,$dbh);    #from C4::Accounts
    #check if borrower has any items waiting
    &checkwaiting;
    #deal with any money still owing
#    output(30,1,$amount);
    if ($amount > 0){
      &reconcileaccount(\%env,$dbh,$bornum,$amount);
    }
    #deal with alternative loans
    #now check items 
    clearscreen();
    my $items=pastitems(\%env,$bornum,$dbh);
    my $items2;
    my $done;
    my $row2=5;
    ($done,$items2,$row2)=&processitems(\%env,$bornum,$borrower,$items,$items2,$row2);
    while ($done eq 'No'){
      ($done,$items2,$row2)=&processitems(\%env,$bornum,$borrower,$items,$items2,$row2);
    }    
    $dbh->disconnect;  
    if ($done ne 'Circ'){
      Issue(\%env);
    }
    if ($done ne 'Quit'){
      return($done);
    }
}    

sub processitems {
  #process a users items
#  clearscreen();
#  output(1,1,"Processing Items");
  helptext("F11 Ends processing for current borrower  F10 ends issues");
  my (%env,$bornum,$borrower,$items,$items2,$row2)=@_;
  my $dbh=&C4Connect;  
  my $row=5;
#  my $count=$$items;
  my $i=0;
  while ($items->[$i]){
    output (1,$row,$items->[$i]);
    $i++;
    $row++;
  }
  #my ($itemnum,$reason)=issuewindow(\%env,'Issues',$items,$items2,$borrower,"Borrower barcode");
#  $itemnum=uc $itemnum;
  my ($itemnum,$reason)=&scanbook();
  my $query="Select * from items,biblio where barcode = '$itemnum' and items.biblionumber=biblio.biblionumber";
  my $sth=$dbh->prepare($query);  
  $sth->execute;
  my $item=$sth->fetchrow_hashref;  
  $items2=$item;
  $sth->finish;
  #check if item is restricted
  if ($item->{'restricted'} == 1 ){
    output(20,1,"whoop whoop restricted");
    #check borrowers status to take out restricted items
    # if borrower allowed {
    #  book issued
    # } else {
    #  next item
    # }
  } else {
    #check if item is on issue already
    my $currbor = &previousissue(\%env,$item->{'itemnumber'},$dbh,$bornum);
    #check reserve
    &checkreserve;
    #if charge deal with it
    #now mark as issued
    &updateissues(%env,$item->{'itemnumber'},$item->{'biblioitemnumber'},$dbh,$bornum);
    my $branch;
    &UpdateStats(%env,$branch,'issue');
    output(40,$row2,$item->{'title'});
    $row2++;
  }
  $dbh->disconnect;
  #check to see if more books to process for this user
  if ($reason eq 'Finished user'){
    return('New borrower');
  } else {
    if ($reason ne 'Finished issues'){
      #return No to let them no that we wish to process more Items for borrower
      return('No',$items2,$row2);
    } else  {
      return('Circ');
    }
  }
}

sub updateissues{
  # issue the book
   my (%env,$itemno,$bitno,$dbh,$bornum)=@_;
   my $loanlength=21;
   my $query="Select loanlength from biblioitems,itemtypes
   where (biblioitems.biblioitemnumber='$bitno') 
   and (biblioitems.itemtype = itemtypes.itemtype)";
#   print "\n$query\n";
   my $sth=$dbh->prepare($query);
   $sth->execute;
   if (my $data=$sth->fetchrow_hashref) {
      $loanlength = $data->{'loanlength'}
   }
   $sth->finish;
   # this ought to also insert the branch, but doen't do so yet.
   $query = "Insert into issues (borrowernumber,itemnumber,date_due)
   values ($bornum,$itemno,datetime('now'::abstime)+$loanlength)";
   my $sth=$dbh->prepare($query);
#   print "\n$query\n";
   $sth->execute;
   $sth->finish;
}

END { }       # module clean-up code here (global destructor)
