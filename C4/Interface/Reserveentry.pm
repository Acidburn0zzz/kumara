package C4::Interface::Reserveentry; #asummes C4/Interface/Reserveentry

#uses Newt
use C4::Format;
use C4::Interface;
use strict;
#use Newt qw(:keys :exits :anchors :flags :colorsets :entry :fd :grid :macros
#:textbox);

use Newt qw(
NEWT_KEY_F1 NEWT_KEY_F2 NEWT_KEY_F3
NEWT_KEY_F4 NEWT_KEY_F5 NEWT_KEY_F6
NEWT_KEY_F7 NEWT_KEY_F8 NEWT_KEY_F9
NEWT_KEY_F10 NEWT_KEY_F11 NEWT_KEY_F12
NEWT_EXIT_HOTKEY 
NEWT_FLAG_RETURNEXIT NEWT_FLAG_WRAP  NEWT_ENTRY_SCROLL 
NEWT_FLAG_MULTIPLE NEWT_FLAG_BORDER NEWT_FLAG_SCROLL
NEWT_ANCHOR_TOP NEWT_ANCHOR_LEFT NEWT_ANCHOR_RIGHT);
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&FindBiblioScreen &SelectBiblio &MakeReserveScreen);
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
    debug_msg($env,$stuff);
    $reason=$stuff;
  } else {
    $i = 0;
    while ($i < $numflds) {
      $responses[$i] =$entries[$i]->Get();
      $i++;
    }
  } 
  debug_msg($env,"r $reason");
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
  my $result;
  my $i = 0;
  while ($i < $no_ents) {
    $biblist->Add(@$entries[$i]);
    $i++;
  }
  $panel->Add(0,0,$biblist);
  Newt::PushHelpLine('F11 Menu:  F2 Issues:  F3 Returns:  F4 Reserves');
  $panel->AddHotKey(NEWT_KEY_F2);
  $panel->AddHotKey(NEWT_KEY_F3);
  $panel->AddHotKey(NEWT_KEY_F4);
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F12);
  my ($reason, $data) = $panel->Run();
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
    $result = $biblist->Get();
  }  
  return($reason,$result);
}

sub MakeReserveScreen {
  my ($env,$bibliorec,$bitems,$branches) = @_;
  debug_msg($env,"make reserv");
  my $panel    = Newt::Panel(1,4);
  my $itemlist = Newt::Listbox(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT | NEWT_FLAG_MULTIPLE);
  my $brlist   = Newt::Listbox(6,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT |
NEWT_FLAG_MULTIPLE);
  my $book = fmtstr($env,$bibliorec->{'title'},"L60");
  my $auth = substr($bibliorec->{'author'},0,20);
  substr($book,(60-length($auth)-2),length($auth)+2) = "  ".$auth;
  my $i = 0;
  my %bitx;
  my @answers;
  my $numbit   = @$bitems;
   debug_msg($env,"items = $numbit");
  while ($i < $numbit) {   
    my $bitline = @$bitems[$i];
    my @blarr = split("\t",$bitline);
    my $line = @blarr[1]." ".@blarr[2];
    if (@blarr[3] > 0) {
      my $line = $line.@blarr[3];
    }
    my $line = $line.@blarr[4]." ".@blarr[5];
    $line = fmtstr($env,$line,"L40");
    $bitx{$line} = @blarr[0];  
    $itemlist->Add($line);
    $i++;
  }
  my $numbrch  = @$branches;
  $i = 0;
   debug_msg($env,"items = $numbrch");
     
  while ($i < $numbrch) {
    $brlist->Add(@$branches[$i]);
    $i++;
  }
  my $panel2   = Newt::Panel(1,10);
  my $panel3   = Newt::Panel(2,1); 
  my $panel4   = Newt::Panel(1,10);
  my $panel5   = Newt::Panel(1,5);
  my $bentry   = Newt::Entry(10, NEWT_ANCHOR_LEFT);
  my $constraint = Newt::HRadiogroup('Any   ', 'Only  ', 'Except');
  $panel->Add(0,0,$panel2);
  $panel->Add(0,1,Newt::Label(" "));
  $panel->Add(0,2,$panel3);
  $panel2->Add(0,0,Newt::Label($book));
  $panel3->Add(0,0,$panel4,NEWT_ANCHOR_TOP);
  $panel3->Add(1,0,$panel5,NEWT_ANCHOR_RIGHT);
  $panel4->Add(0,0,Newt::Label("Borrower"),NEWT_ANCHOR_LEFT);
  $panel4->Add(0,1,$bentry, NEWT_ANCHOR_LEFT);
  $panel4->Add(0,2,Newt::Label(" "),NEWT_ANCHOR_LEFT);
  $panel4->Add(0,3,Newt::Label("Collect at "), NEWT_ANCHOR_LEFT);
  $panel4->Add(0,4,$brlist,NEWT_ANCHOR_LEFT);
  $panel5->Add(0,0,Newt::Label("Constraints"), NEWT_ANCHOR_RIGHT);
  $panel5->Add(0,1,$constraint,NEWT_ANCHOR_RIGHT);
  $panel5->Add(0,2,Newt::Label(" "));
  $panel5->Add(0,3,$itemlist,NEWT_ANCHOR_RIGHT);
  Newt::PushHelpLine('F11 Menu:  F2 Issues:  F3 Returns:  F4 Reserves');
  $panel->AddHotKey(NEWT_KEY_F2);
  $panel->AddHotKey(NEWT_KEY_F3);
  $panel->AddHotKey(NEWT_KEY_F4);
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F12);
  my ($reason, $data) = $panel->Run();
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
    debug_msg($env,$stuff);
    $reason = $stuff;
  } else {
    $reason = "";
    @answers[0] = $bentry->Get();
    my @brline = split(" ",$brlist->Get());
    @answers[1] = @brline[0];
    @answers[2] = $constraint->Get();
    @answers[3] = $bitx{$itemlist->Get()};
    debug_msg($env,"$answers[0] $answers[1] $answers[2] $answers[3]");
  }
  return ($stuff,@answers);
}
END { }       # module clean-up code here (global destructor)
