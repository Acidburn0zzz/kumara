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
  my ($bornumber,$dbh,$interface)=@_;
  my $sth=$dbh->prepare("Select * from accountlines where
  borrowernumber=$bornumber");
  $sth->execute;
  my $total=0;
  while (my @data=$sth->fetchrow_array){
    $total=$total+$data[8];
  }
  $sth->finish;
  if ($total > 0){
    &resultout('console',"borrower owes $total",$interface);
    if ($total > 5){
      reconcileaccount;
    }
  }
  return($total);
}    

sub reconcileaccount {

}
			
END { }       # module clean-up code here (global destructor)
