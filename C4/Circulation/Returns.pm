package C4::Circulation; #assumes C4/Circulation/Returns

#package to deal with Returns
#written 3/11/99 by olwen@katipo.co.nz

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
@EXPORT = qw(&markreturned);
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


sub Return  {
  
}    

sub markreturned {
  # mark items
  my ($env,$dbh,$item,$bo)=@_;
  my $query = "update issues 
  set returnwhere   
  
}


END { }       # module clean-up code here (global destructor)
