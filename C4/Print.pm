package C4::Print; #asummes C4/Print.pm

use strict;
require Exporter;
use C4::InterfaceCDK;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&remoteprint);
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

sub remoteprint {
  my ($env,$items,$borrower)=@_;
  #debug_msg($env,"In print");
  my $file=time;
  open (FILE,">/tmp/$file");
  my $i=0;
  print FILE "$borrower->{'cardnumber'}\n$borrower->{'firstname'} $borrower->{'surname'}\n";
  while ($items->[$i]){
    print FILE "$items->[$i]\n";
    $i++;
  }
  close FILE;
  system("lpr /tmp/$file");
}

END { }       # module clean-up code here (global destructor)
  
    
