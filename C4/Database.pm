package C4::Database; #asummes C4/Database

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&C4Connect &sqlinsert);
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



sub C4Connect  {
  my $dbname="c4"; 
  my $dbh = DBI->connect("dbi:Pg:dbname=$dbname", "chris", "");

  return $dbh;
}    

sub sqlinsert {
  my ($table,%data)=@_;
  my $dbh=C4Connect;
  my $query="INSERT INTO $table \(";
  while (my ($key,$value) = each %data){
    if ($key ne 'type'){
      $query=$query."$key,";
    }
  }
  $query=$query." VALUES (";
  while (my ($key,$value) = each %data){
    if ($key ne 'type'){
      $query=$query."$value,";
    }
  }
  $query=~ s/\,$/\)/;
  print $query;
  $dbh->disconnect;
}

END { }       # module clean-up code here (global destructor)
