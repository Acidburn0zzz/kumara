package C4::Circulation; #asummes C4/Circulation

#package to deal with circulation 

use strict;
require Exporter;
use DBI;
use C4::Database;

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
  $sth=$bh->prepare("Select * from items where itemnumber = $itemnum);
  my @item=$sth->fetchrow_array;
  $sth->finish;
  $dbh->disconnect;
  return (@data);
}    


			
END { }       # module clean-up code here (global destructor)
