package C4::Circulation; #asummes C4/Circulation

#package to deal with circulation 

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;

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
  my ($bornum,$itemnum)=@_;
  my $dbh=&C4Connect;  
  my $sth=$dbh->prepare("Select * from borrowers where borrowernumber=$bornum");
  $sth->execute;
  my @borrower=$sth->fetchrow_array;
  $sth->finish;
  #process borrower traps (could be function)
  #check first GNA trap (no address this is the 22nd item in the table)
  if ($borrower[21] == 1){
    #got to membership update and update member info
    print "Whoop whoop no address\n";
  }
  #check if member has a card reported as lost
  if ($borrower[22] ==1){
    #updae member info
    print "Whoop whoop lost card\n";
  }
  #check the notes field if notes exist display them
  if ($borrower[26] ne ''){
    #display notes
    #deal with notes as issue_process.doc
    print "$borrower[26]\n";
  }
  #check if borrower has overdue items
  #call overdue checker
  &checkoverdues($borrnum);
  #check amountowing
  &checkaccount($borrnum)
  $sth=$dbh->prepare("Select * from items where itemnumber = $itemnum");
  $sth->execute;
  my @item=$sth->fetchrow_array;
  $sth->finish;
  $dbh->disconnect;
  return (@borrower);
}    

sub checkoverdues{
  #pop up list of overdue books if some are overdue
}

			
END { }       # module clean-up code here (global destructor)
