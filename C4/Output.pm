package C4::Output; #asummes C4/Output

#package to deal with marking up output

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&startpage &endpage &mktablehdr &mktableft &mktablerow);
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
 
sub startpage{
  my $string="<html><body bgcolor=white>\n";
  return($string);
}

sub startmenu{
}

sub endmenu{
}

sub mktablehdr {
  my $string="<table cellpadding=0 cellspacing=2 border=0>\n";
  return($string);
}

sub mktablerow {
  my ($cols,@data)=@_;
  my $i=0;
  my $string="<tr valign=top>";
  while ($i <$cols){
    $string=$string."<td>$data[$i]</td>";
    $i++;
  }
  $string=$string."</tr>\n";
  return($string);
}

sub mktableft {
  my $string="</table>\n";
  return($string);
}

sub endpage{
  my $string="</body></html>\n";
  return($string);
}
    
END { }       # module clean-up code here (global destructor)
    
