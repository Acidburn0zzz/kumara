package C4::Reserves; #asummes C4/Reserves

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Format;
use C4::Interface;
use C4::Interface::Reserveentry;
use C4::Search;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&EnterReserves);
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

sub EnterReserves{
  my ($env)=@_;
  my @flds = ("Barcode","Title","Keywords","Author","Subject","ISBN");
  my ($itemnumber,$title,$keyword,$author,$subject,$isbn) =
     FindBiblioScreen($env,"Reserves",@flds);
  my %search;
  $search{'title'}= $title;
  $search{'keyword'}=$keyword;
  $search{'author'}=$author;
  $search{'subject'}=$subject;
  $search{'item'}=$itemnumber;
  $search{'isbn'}=$isbn;
  my @results;
  my $count;
  my $num = 30;
  my $offset = 0;
  if ($itemnumber ne '' || $isbn ne ''){
    ($count,@results)=&CatSearch($env,'precise',\%search,$num,$offset);
  } else {
    if ($subject ne ''){
      ($count,@results)=&CatSearch($env,'subject',\%search,$num,$offset);
    } else {
      if ($keyword ne ''){
        ($count,@results)=&KeywordSearch($env,'intra',\%search,$num,$offset);
      } else {
        ($count,@results)=&CatSearch($env,'loose',\%search,$num,$offset);
      }
    }
  }
  my $biblionumber  =  SelectBiblio($env,$count,@results);
  debug_msg($env,$biblionumber);
}

			
END { }       # module clean-up code here (global destructor)
