package C4::Accounts; #asummes C4/Accounts

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Interface;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&checkaccount &reconcileaccount);
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



sub checkaccount  {
  #take borrower number
  #check accounts and list amounts owing
  my ($bornumber,$dbh)=@_;
  my $sth=$dbh->prepare("Select * from accountlines where
  borrowernumber=$bornumber");
  $sth->execute;
  my $total=0;
  while (my $data=$sth->fetchrow_hashref){
    $total=$total+$data->{'amountoutstanding'};
  }
  $sth->finish;
  if ($total > 0){
    output(1,2,"borrower owes $total");
    if ($total > 5){
      reconcileaccount($dbh,$bornumber,$total);
    }
  }
  return($total);
}    

sub reconcileaccount {
  #print put money owing give person opportunity to pay it off
  my ($dbh,$bornumber,$total)=@_;
  #get borrower information
  my $sth=$dbh->prepare("Select * from accountlines where 
  borrowernumber=$bornumber");   
  $sth->execute;     
  #display account information
  &clearscreen();
  &helptext('F11 quits');
  output(20,0,"Accounts");
  my $row=4;
  my $i=0;
  my $text;
  output (1,2,"Account Info");
  output (1,3,"Item\tDate\tDescription\tAmount");
  while (my $data=$sth->fetchrow_hashref){
    my $line=$i+1;
    my $amount=0+$data->{'amountoutstanding'};
    $text="$line\t$data->{'date'}\t$data->{'description'}\t$amount";
    output (1,$row,$text);
    $row++;
    $i++;
  }
  $text="Borrower owes \$$total";
  output (1,$row,$text);
  #get amount paid and update database
  my ($data,$reason)=&dialog("Amount to pay");
#  &updateaccounts($bornumber,$dbh,$data);
  #Check if the boorower still owes
#  $total=&checkaccount($bornumber,$dbh);
  return($total);

}

sub updateaccounts{
  #here we update both the accountoffsets and the account lines
  my ($bornumber,$dbh,$data)=@_;
  
}
			
END { }       # module clean-up code here (global destructor)
