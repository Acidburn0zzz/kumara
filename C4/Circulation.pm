package C4::Circulation; #asummes C4/Circulation

#package to deal with circulation 

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;
use C4::Interface;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&Start_circ &Issue);
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

sub Start_circ{
  #connect to database
  #start interface
  startint('Circulation');
  my ($reason,$data)=menu('console','Circulation',('Issues','Returns','Borrower Enquiries'));
  my $donext;
  if ($data eq 'Issues'){  
    $donext=Issue();
  } else {
    &endint();
  }
  if ($donext eq 'Circ'){
    Start_circ();
  } else {
    &endint();
  }
}

sub Issue  {
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
    }
    #check if member has a card reported as lost
    if ($borrower->{'lost'} ==1){
      #updae member info
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
    &checkoverdues($bornum,$dbh);
    #check amountowing
    my $amount=checkaccount($bornum,$dbh);    #from C4::Accounts
    #check if borrower has any items waiting
    &checkwaiting;
    #deal with any money still owing
#    output(30,1,$amount);
    if ($amount > 0){
      &reconcileaccount($dbh,$bornum,$amount);
    }
    #deal with alternative loans
    #now check items 
    #print borrower info on screen
    clearscreen();
    my $text="$borrower->{'title'} $borrower->{'firstname'} $borrower->{'lastname'}";
    output(0,2,$text);
    output(0,3,$borrower->{'streetaddress'});
    output(0,4,$borrower->{'city'});
    my $done=&processitems($bornum);
    while ($done eq 'No'){
      $done=&processitems($bornum);
    }    
    $dbh->disconnect;  
    if ($done ne 'Circ'){
      Issue();
    }
    if ($done ne 'Quit'){
      return($done);
    }
}    

sub processitems {
  #process a uses items
#  clearscreen();
  output(1,1,"Processing Items");
  helptext("F11 Ends processing for current borrower  F10 ends issues");
  my ($bornum)=@_;
  my ($itemnum,$reason)=&scanbook();
  my $dbh=&C4Connect;  
  my $query="Select * from items,biblio where barcode = '$itemnum' and items.biblionumber=biblio.biblionumber";
  my $sth=$dbh->prepare($query);  
  $sth->execute;
  my $item=$sth->fetchrow_hashref;  
  #output item info
  output(0,6,$item->{'title'});
  output(0,7,$item->{'author'});
#  output(0,30,$query);
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
    &previousissue($item->{'itemnumber'},$dbh,$bornum);
    #check reserve
    &checkreserve;
    #if charge deal with it
    #now mark as issued
   &updateissues($item->{'itemnumber'},$item->{'biblioitemnumber'},$dbh,$bornum);
  }
  $dbh->disconnect;
  #check to see if more books to process for this user
  if ($reason eq 'Finished user'){
    return('New borrower');
  } else {
    if ($reason ne 'Finished issues'){
      #return No to let them no that we wish to process more Items for borrower
      return('No');
    } else  {
      return('Circ');
    }
  }
}

sub updateissues{
  # issue the book
   my ($itemno,$bitno,$dbh,$bornum)=@_;
   my $loanlength=21;
   my $query="Select loanlength from biblioitems,itemtypes
   where (biblioitems.biblioitemnumber='$bitno') 
   and (biblioitems.itemtype = itemtypes.itemtype)";
   print "\n$query\n";
   my $ow = getc;
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
   print "\n$query\n";
   my $ow = getc;
   $sth->execute;
   $sth->finish;
}

sub checkoverdues{
  #checks whether a borrower has overdue items
  my ($bornum,$dbh)=@_;
  my $sth=$dbh->prepare("Select * from issues,items,biblio where
borrowernumber=$bornum and issues.itemnumber=items.itemnumber and
items.biblionumber=biblio.biblionumber");
  $sth->execute;
  my $row=1;
  my $col=40;
  while (my $data=$sth->fetchrow_hashref){
    output($row,$col,$data->{'title'});
    $row++;
  }
  $sth->finish;
}

sub previousissue {
  my ($itemnum,$dbh,$bornum)=@_;
  my $sth=$dbh->prepare("Select firstname,surname,issues.borrowernumber
  from issues,borrowers where 
  issues.itemnumber='$itemnum' and
  issues.borrowernumber=borrowers.borrowernumber");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  $sth->finish;
  if ($borrower->{'borrowernumber'} ne ''){
    if ($bornum eq $borrower->{'borrowernumber'}){
      output(1,24,"Book is marked as issue to curent borrower");
    } else {
      my $text="book is issued to borrower $borrower->{'firstname'} $borrower->{'surname'} borrowernumber $borrower->{'borrowernumber'}";    
      output(1,24,$text);
    }
  } 
}

sub checkreserve{
}
sub checkwaiting{

}

sub scanbook {
  my ($interface)=@_;
  #scan barcode
#  my $number='L01781778';  
  my ($number,$reason)=dialog("Book Barcode:");
  $number=uc $number;
  return ($number,$reason);
}

sub scanborrower {
  my ($interface)=@_;
  #scan barcode
#  my $number='V00126643';  
  my ($number,$reason)=&dialog("Borrower Barcode:");
  $number=uc $number;
  return ($number,$reason);
}


END { }       # module clean-up code here (global destructor)
