package C4::Interface; #asummes C4/Interface

#uses Newt

use strict;
use Newt qw(NEWT_ANCHOR_LEFT NEWT_FLAG_SCROLL NEWT_KEY_F11
NEWT_FLAG_RETURNEXIT NEWT_EXIT_HOTKEY NEWT_FLAG_WRAP);
use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&dialog &startint &endint &output &clearscreen &pause &helptext
&list &textbox);
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
  my ($msg)=@_;
  Newt::Init();
  Newt::Cls();
  Newt::PushHelpLine('F11 escapes');
  Newt::DrawRootText(0,0,$msg);
#  Newt::Finished();
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
  my (@items)=@_;
  my $numitems=@items;
  my $panel = Newt::Panel(70, 4, "");
  my $li = Newt::Listbox($numitems, NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  $li->Add(@items);
  $panel->Add(0,0,$li,NEWT_ANCHOR_LEFT);
  $panel->AddHotKey(NEWT_KEY_F11);
   my ($reason,$data)=$panel->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {   
    if ($data eq NEWT_KEY_F11) {  
        $reason="Quit";         
    }
  }
  my $stuff=$li->Get();
  return($stuff,$reason);
}



sub dialog {
  my ($name)=@_;
  my $entry=Newt::Entry(20,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label($name);
  my $panel1=Newt::Panel(2,4,$name);
  $panel1->AddHotKey(NEWT_KEY_F11);
  $panel1->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,0,$entry,NEWT_ANCHOR_LEFT);
  my ($reason,$data)=$panel1->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {   
    if ($data eq NEWT_KEY_F11) {  
        $reason="Quit";         
    }
  }
#  Newt::Finished();
  my $stuff=$entry->Get();
  return($stuff,$reason);
}

sub endint {
  Newt::Finished();
}
END { }       # module clean-up code here (global destructor)
