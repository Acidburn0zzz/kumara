package C4::Interface; #asummes C4/Interface

#uses newt

use strict;
use Newt qw(:anchors :macros);
require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&userdialog);
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

sub userdialog{
 #create a dialog
 my ($type,$text)=@_;
 if ($type eq 'console'){
    &newtdialog($text);
 }
}

sub newtdialog {
  my ($text)=@_;
  Newt::Init();
  Newt::Cls();
  Newt::DrawRootText(0, 0, "Get Item barcode");
  my $label = Newt::Label($text);
  my $width=10;
  my $flags="oi";
  my $entry = Newt::Entry($width, $flags);
  my $main = Newt::Panel(1,2, 'Barcode')
  ->Add(0, 0, $entry, NEWT_ANCHOR_LEFT, 0, 0, 0, 1)
  ->Run(); 
  my $data= $entry->Get();
  Newt::Finished; 
  return($data);
}
			
END { }       # module clean-up code here (global destructor)
