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
  #get borrowerbarcode from scanner
  my $borcode=&scanborrower;
#  print $bornum;
# debug
#  resultout('console',$borcode);
  my $dbh=&C4Connect;  
  my $sth=$dbh->prepare("Select * from borrowers where cardnumber='$borcode'");
  $sth->execute;
  my @borrower=$sth->fetchrow_array;
  my $bornum=$borrower[0];
#  print @borrower;
#  die;
  if ($bornum eq ''){
    #borrower not found
    &resultout('console',"Borrower not found");
  }
  $sth->finish;
  #process borrower traps (could be function)
  #check first GNA trap (no address this is the 22nd item in the table)
  if ($borrower[21] == 1){
    #got to membership update and update member info
     &resultout('console',"Whoop whoop no address");
  }
  #check if member has a card reported as lost
  if ($borrower[22] ==1){
    #updae member info
    &resultout('console'"Whoop whoop lost card");
  }
  #check the notes field if notes exist display them
  if ($borrower[26] ne ''){
    #display notes
    #deal with notes as issue_process.doc
    &resultout ('console',"$borrower[26]");
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
    &reconcileaccount($bornum,$dbh);
  }
  #deal with alternative loans
  #now check items
  &processitems;
  $dbh->disconnect;
  return (@borrower);
}    

sub processitems { 
  my ($bornum)=@_;
  my $itemnum=&scanbook;
  my $dbh=&C4Connect;  
  my $sth=$dbh->prepare("Select * from items where barcode = '$itemnum'");
  $sth->execute;
  my @item=$sth->fetchrow_array;  
  print $itemnum,"\n",$item[0],"\n";
  $sth->finish;
  #check if item is restricted
  if ($item[23] ==1 ){
    print "whoop whoop restricted\n";
    #check borrowers status to take out restricted items
    # if borrower allowed {
    #  book issued
    # } else {
    #  next item
    # }
  }
  #check if item is on issue already
  my $status=&previousissue($item[0],$dbh,$bornum);
  if ($status eq 'out'){
    #book is already out, deal with it
    #if its out to another deal with it
    #if its out the person ask if they want to renew it etc
    print "book is out";
  }
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
  my ($itemnum,$dbh)=@_;
  my $sth=$dbh->prepare("Select firstname,surname,issues.borrowernumber
  from issues,borrowers where 
  issues.itemnumber='$itemnum' and
  issues.borrowernumber=borrowers.borrowernumber");
  $sth->execute;
  my @borrower=$sth->fetchrow_array;
  $sth->finish;
  if ($borrower[0] ne ''){
    print "book is issued to borrower $borrower[0] $borrower[1] borrowernumber
    $borrower[2]\n";
    return("out");
  } 
}

sub checkreserve{
}
sub checkwaiting{

}

sub scanbook {
  #scan barcode
#  my $number='L01781778';  
  my $number=&userdialog('console','Please enter a book barcode');
  return ($number);
}

sub scanborrower {
  #scan barcode
#  my $number='L01781778';  
  my $number=&userdialog('console','Please enter a borrower barcode');
  return ($number);
}


END { }       # module clean-up code here (global destructor)
