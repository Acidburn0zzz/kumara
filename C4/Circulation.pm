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
  Issue();
  &endint();
}

sub Issue  {
  my $dbh=&C4Connect;  
  #get borrowerbarcode from scanner
  my $borcode=&scanborrower();
  my $sth=$dbh->prepare("Select * from borrowers where cardnumber='$borcode'");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  my $bornum=$borrower->{'borrowernumber'};
  $sth->finish;
  if ($bornum eq ''){
    #borrower not found
   } else {  
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
    &checkoverdues($bornum);
    #check amountowing
    my $amount=checkaccount($bornum,$dbh);    #from C4::Accounts
    #check if borrower has any items waiting
    &checkwaiting;
    #deal with any money still owing
    if ($amount > 0){
#      &reconcileaccount($dbh,$bornum);
    }
    #deal with alternative loans
    #now check items 
    &processitems($bornum);
    $dbh->disconnect;
  }
#    return (@borrower);
 
}    

sub processitems { 
  my ($bornum,$interface)=@_;
  my $itemnum=&scanbook($interface);
  my $dbh=&C4Connect;  
  my $sth=$dbh->prepare("Select * from items where barcode = '$itemnum'");
  $sth->execute;
  my $item=$sth->fetchrow_hashref;  
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
  }
  #check if item is on issue already
  &previousissue($item->{'itemnumber'},$dbh,$bornum,$interface);
  #check reserve
  &checkreserve;
  #if charge deal with it
  #now mark as issued
  &updateissues;
  $dbh->disconnect;
}

sub updateissues{
}
sub checkoverdues{
  #pop up list of overdue books if some are overdue
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
      output(1,20,"Book is marked as issue to curent borrower");
    } else {
      my $text="book is issued to borrower $borrower->{'firstname'}
      $borrower->{'surname'} borrowernumber $borrower->{'borrowernumber'}";    
      output(1,20,$text);
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
  my $number=dialog("Book Barcode:");
  return ($number);
}

sub scanborrower {
  my ($interface)=@_;
  #scan barcode
#  my $number='V00126643';  
  my $number=&dialog("Borrower Barcode:");
  return ($number);
}


END { }       # module clean-up code here (global destructor)
