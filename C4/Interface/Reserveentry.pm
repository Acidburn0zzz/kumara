package C4::Interface::Reserveentry; #asummes C4/Interface/Reserveentry

#uses Newt
use C4::Format;
use C4::Interface;
use strict;
#use Newt qw(:keys :exits :anchors :flags :colorsets :entry :fd :grid :macros
#:textbox);

use Newt qw(NEWT_ANCHOR_LEFT NEWT_FLAG_SCROLL 
NEWT_KEY_F1 NEWT_KEY_F2 NEWT_KEY_F3
NEWT_KEY_F4 NEWT_KEY_F5 NEWT_KEY_F6
NEWT_KEY_F7 NEWT_KEY_F8 NEWT_KEY_F9
NEWT_KEY_F10 NEWT_KEY_F11 NEWT_KEY_F12
NEWT_FLAG_RETURNEXIT NEWT_EXIT_HOTKEY NEWT_FLAG_WRAP NEWT_FLAG_MULTIPLE 
NEWT_ANCHOR_TOP NEWT_ANCHOR_RIGHT NEWT_FLAG_BORDER);
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&FindBiblioScreen &SelectBiblio);
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

sub FindBiblioScreen {
  my ($env,$title,$numflds,$flds,$fldlns)=@_;
  my $panel  = Newt::Panel(2,($numflds*2)+2,$title);
  my @labels;
  my @entries;
  my @dlabs;
  my $i = 0;
  my $r = 0;
  while ($i < $numflds) { 
    @labels[$i]  = Newt::Label(@$flds[$i].": ");
    @dlabs[$i]   = Newt::Label(" ");
    $panel->Add(0,$r,@labels[$i],NEWT_ANCHOR_RIGHT);
    $panel->Add(0,$r+1,@dlabs[$i],NEWT_ANCHOR_RIGHT);      
    @entries[$i] = Newt::Entry(@$fldlns[$i],NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
    $panel->Add(1,$r,@entries[$i],NEWT_ANCHOR_LEFT);
    $i++;
    $r = $r+2;
  }  
  Newt::PushHelpLine('F11 Menu:  F2 Issues:  F3 Returns:  F4 Reserves');
  $panel->AddHotKey(NEWT_KEY_F2);
  $panel->AddHotKey(NEWT_KEY_F3);
  $panel->AddHotKey(NEWT_KEY_F4);
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F12);
  my ($reason,$data)=$panel->Run();
  debug_msg($env,"got it");
  my @responses;
  if ($reason eq NEWT_EXIT_HOTKEY) {   
    if ($data eq NEWT_KEY_F11) {    
      $stuff="Circ";  
    } elsif ($data eq NEWT_KEY_F2) {
      $stuff="Returns";
    } elsif ($data eq NEWT_KEY_F3) {
      $stuff="Issues";
    } elsif ($data eq NEWT_KEY_F4) {	
      $stuff="Reserves";
    } elsif ($data eq NEWT_KEY_F12) {
      $stuff="Quit"
    }    
    $reason=$stuff;
  } else {
    $i = 0;
    while ($i < $numflds) {
      $responses[$i] =$entries[$i]->Get();
      $i++;
    }
  }  
  clearscreen;
  return($reason,@responses);
}

sub SelectBiblio {
  my ($env,$count,$entries) = @_;
  my $panel  = Newt::Panel(2,2,"Select Title");
#  my $biblist = Newt::Listbox(15,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $biblist = Newt::Listbox(15,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT | NEWT_FLAG_MULTIPLE);
  my $no_ents = @$entries;
  debug_msg($env,"$no_ents entries");
  my $i = 0;
  while ($i < $no_ents) {
    $biblist->Add(@$entries[$i]);
    $i++;
  }
  $panel->Add(0,0,$biblist);
  my ($reason, $data) = $panel->Run();
  my $result = $biblist->Get();
  debug_msg($env,$result);
  return ($reason,$result);
}
END { }       # module clean-up code here (global destructor)
