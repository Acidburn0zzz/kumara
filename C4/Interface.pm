package C4::Interface; #asummes C4/Interface

#uses Newt

use strict;
use Newt qw(:keys :exits :anchors :flags :colorsets :entry :fd :grid :macros
:textbox);
#use Newt qw(NEWT_ANCHOR_LEFT NEWT_FLAG_SCROLL NEWT_KEY_F11 NEWT_KEY_F10
#NEWT_KEY_F1 NEWT_KEY_F2 NEWT_KEY_F4 NEWT_KEY_F5 NEWT_KEY_F9 NEWT_KEY_F12
#NEWT_FLAG_RETURNEXIT NEWT_EXIT_HOTKEY NEWT_FLAG_WRAP NEWT_FLAG_MULTIPLE);
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&dialog &startint &endint &output &clearscreen &pause &helptext
&textbox &menu &issuewindow &msg_yn &borrower_dialog &debug_msg &error_msg);
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
sub suspend_cb {
  Newt::Suspend();
  kill STOP => $$;
  Newt::Resume();
}
      
sub startint {
  Newt::SetSuspendCallback(\&suspend_cb);
  my ($env,$msg)=@_;
  Newt::Init();
  Newt::Cls();
  Newt::PushHelpLine('F11 escapes');
  Newt::DrawRootText(0,0,$msg);
}

sub menu {
  my ($type,$title,@items)=@_;
  if ($type eq 'console'){
    my ($reason,$data)=list($title,@items);
    return($reason,$data);
  } 
}

sub clearscreen{
  Newt::Cls();
}

sub pause {
  Newt::WaitForKey();
}


sub output {
  my($left,$top,$msg)=@_;
  Newt::DrawRootText($left,$top,$msg);
}

sub textbox {
  my ($width,$height,$text,$title,$top,$left)=@_;
  my $panel = Newt::Panel(70, 4, "$title",$top,$left);
  my $box = Newt::Textbox($width,$height, NEWT_FLAG_SCROLL |
  NEWT_FLAG_RETURNEXIT | NEWT_FLAG_WRAP,$text);
  $panel->Add(0,0,$box,NEWT_ANCHOR_LEFT);
  $panel->AddHotKey(NEWT_KEY_F11);
  my ($reason,$data)=$panel->Draw();
}

sub helptext {
  my ($text)=@_;
  Newt::PushHelpLine($text);
}

sub list {
  my ($title,@items)=@_;
  my $numitems=@items;
  my $panel = Newt::Panel(1, 4, $title);
  my $li = Newt::Listbox($numitems,NEWT_FLAG_RETURNEXIT |  NEWT_FLAG_MULTIPLE);
  $li->Add(@items);
  $panel->Add(0,0,$li,NEWT_ANCHOR_TOP);
  $panel->AddHotKey(NEWT_KEY_F11);
  my ($reason,$data)=$panel->Run();
#  if ($reason eq NEWT_EXIT_HOTKEY) {   
#    if ($data eq NEWT_KEY_F11) {  
#        $reason="Quit";         
#    }
#  }
  my @stuff=$li->Get();
    $data=$stuff[0];
  return($reason,$data);
}

sub issuewindow {
  my ($env,$title,$items1,$items2,$borrower,$name)=@_;
  my $entry=Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label("Book");
  my $panel = Newt::Panel(50,25, $title,5,5);
  my $l1  = Newt::Label("Previous");
  my $l2  = Newt::Label("Current");
  my $l3  = Newt::Label("Borrower Info");
 # my $li1 = Newt::Listbox(10,
 #   NEWT_FLAG_RETURNEXIT | NEWT_FLAG_MULTIPLE | NEWT_FLAG_SCROLL);
  my $li1 = Newt::Listbox(10,NEWT_FLAG_SCROLL);
  my $li2 = Newt::Listbox(10,
    NEWT_FLAG_RETURNEXIT | NEWT_FLAG_MULTIPLE | NEWT_FLAG_SCROLL);
  my $li3 = Newt::Listbox(5, NEWT_FLAG_RETURNEXIT | NEWT_FLAG_MULTIPLE);
  my $i = 0;
  while ($items1->[$i]) {
    $li1->Add($items1->[$i]);
    $i++;
  }
  # $li2->Add($items2->{'title'});
  $i = 0;
  while ($items2->[$i]) {
    $li2->Add($items2->[$i]); 
    $i++;
  }  
  $li3->Add("$borrower->{title} $borrower->{'firstname'}","$borrower->{'streetaddres'}",
  "$borrower->{'city'}");
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F10);
  $panel->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel->Add(0,0,$entry,NEWT_ANCHOR_LEFT,0,0,45);
  $panel->Add(0,1,$l3,NEWT_ANCHOR_LEFT);
  $panel->Add(0,2,$li3,NEWT_ANCHOR_LEFT);  
  $panel->Add(0,3,$l1,NEWT_ANCHOR_LEFT);
  $panel->Add(0,4,$li1,NEWT_ANCHOR_LEFT);  
  $panel->Add(1,3,$l2,NEWT_ANCHOR_RIGHT);
  $panel->Add(1,4,$li2,NEWT_ANCHOR_RIGHT);  
 
  my ($reason,$data)=$panel->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {   
    if ($data eq NEWT_KEY_F11) {  
        $reason="Finished user";         
    }
    if ($data eq NEWT_KEY_F10) {  
        $reason="Finished issues";         
    }
    if ($data eq NEWT_KEY_F12){
      $reason="Quit"
    }
  }
#  Newt::Finished();
  my $stuff=$entry->Get();
  return($stuff,$reason);
}


sub dialog {
  my ($name)=@_;
  my $entry=Newt::Entry(20,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label($name);
  my $panel1=Newt::Panel(2,4,$name);
  $panel1->AddHotKey(NEWT_KEY_F11);
  $panel1->AddHotKey(NEWT_KEY_F10);
  $panel1->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,0,$entry,NEWT_ANCHOR_LEFT);
  my ($reason,$data)=$panel1->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {   
    if ($data eq NEWT_KEY_F11) {  
        $reason="Finished user";         
    }
    if ($data eq NEWT_KEY_F10) {  
        $reason="Finished issues";         
    }
    if ($data eq NEWT_KEY_F12){
      $reason="Quit";
    }
  }
#  Newt::Finished();
  my $stuff=$entry->Get();
  return($stuff,$reason);
}


sub borrower_dialog {
  my ($env)=@_;
  my $name = "Borrower";
  my $entry=Newt::Entry(20,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label($name);
  my $entry2=Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label2=Newt::Label(" Book: ");
  my $panel1=Newt::Panel(4,4,$name,1,1);
  $panel1->AddHotKey(NEWT_KEY_F11);
  $panel1->AddHotKey(NEWT_KEY_F10);  
  $panel1->AddHotKey(NEWT_KEY_F9);
  $panel1->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,0,$entry,NEWT_ANCHOR_LEFT);
  $panel1->Add(2,0,$label2,NEWT_ANCHOR_LEFT);
  $panel1->Add(3,0,$entry2,NEWT_ANCHOR_LEFT);
  my ($reason,$data)=$panel1->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {   
    if ($data eq NEWT_KEY_F11) {  
      $reason="Finished user";         
    }
    if ($data eq NEWT_KEY_F10) {  
      $reason="Finished issues";         
    }
    if ($data eq NEWT_KEY_F12){
      $reason="Quit";
    }
    if ($data eq NEWT_KEY_F9) {
    }
  }
#  Newt::Finished();
  my $stuff=$entry->Get();
  my $stuff2=$entry2->Get();
  return($stuff,$reason,$stuff2);
}

sub msg_yn {
  my ($text1,$text2)=@_;
  Newt::Bell();
  my $panel1=Newt::Panel(4,4,"");
  my $label1=Newt::Label($text1);
  my $label2=Newt::Label($text2);
  my $bpanel=Newt::Panel(2,4,"");
  my $ybutt=Newt::Button("Yes");
  my $nbutt=Newt::Button("No");
  $bpanel->Add(0,0,$ybutt,NEWT_ANCHOR_LEFT);
  $bpanel->Add(1,0,$nbutt,NEWT_ANCHOR_RIGHT);
  $panel1->Add(0,0,$label1,NEWT_ANCHOR_TOP);
  $panel1->Add(0,1,$label2,NEWT_ANCHOR_TOP);
  $panel1->Add(0,2,$bpanel,NEWT_ANCHOR_TOP);
  my ($reason,$data) =$panel1->Run();
  return($reason);
}


sub debug_msg {
  my ($env,$text)=@_;
  my $panel1=Newt::Panel(4,4,"*** D E B U G ***");
  my $label1=Newt::Label($text);
  my $butt=Newt::Button("Okay");
  $panel1->Add(0,0,$label1,NEWT_ANCHOR_TOP);
  $panel1->Add(0,1,$butt,NEWT_ANCHOR_TOP);
  my ($reason,$data) =$panel1->Run();
  return();
}

sub error_msg {
  my ($env,$text)=@_;
  my $panel1=Newt::Panel(4,4,"!!ERROR!!");
  my $label1=Newt::Label($text);
  my $butt=Newt::Button("Okay");
  $panel1->Add(0,0,$label1,NEWT_ANCHOR_TOP);
  $panel1->Add(0,1,$butt,NEWT_ANCHOR_TOP);
  my ($reason,$data) =$panel1->Run();
  return();
}

sub endint {
  Newt::Finished();
}
END { }       # module clean-up code here (global destructor)
