package C4::Interface::Funkeys; #asummes C4/Interface/Funkeys
#uses Newt
use strict;
#use Newt qw(:keys :exits :anchors :flags :colorsets :entry :fd :grid :macros
#:textbox);

use Newt qw(NEWT_KEY_F1 NEWT_KEY_F2 NEWT_KEY_F3 
            NEWT_KEY_F4 NEWT_KEY_F5 NEWT_KEY_F6
	    NEWT_KEY_F7 NEWT_KEY_F8 NEWT_KEY_F9 
	    NEWT_KEY_F10 NEWT_KEY_F11 NEWT_KEY_F12
	    NEWT_EXIT_HOTKEY);

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(setupkeys checkkeys);
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


  
sub setupkeys {
  my ($env,$panel)=@_;
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F12);
  my $helpline = "";
  my @fkeys;
  if ($env->{'sysarea'} = "Menu") {
     $panel->AddHotKey(NEWT_KEY_F2);
     $panel->AddHotKey(NEWT_KEY_F3);
     $panel->AddHotKey(NEWT_KEY_F4);
     $helpline = "F2 Issues:  F3 Returns:  F4 Reserves:  F11 Menu:  F12 Quit";
  }
  return $helpline;
}


sub checkkeys {
  my ($env,$reason,$data)=@_;
  my $resp;
  if ($reason eq NEWT_EXIT_HOTKEY) {
      if ($data eq NEWT_KEY_F12) {
        $resp="Quit";
      } elsif ($data eq NEWT_KEY_F11) {
         $resp="Circ";
      } elsif ($data eq NEWT_KEY_F3) {
         $resp="Returns";
      } elsif ($data eq NEWT_KEY_F2) {
         $resp="Issues";
      } elsif ($data eq NEWT_KEY_F4) {
         $resp="Reserves";
      }						       
   }
   return $resp;
}   
END { }       # module clean-up code here (global destructor)
