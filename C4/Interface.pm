package C4::Interface; #asummes C4/Interface

#uses Newt

use strict;
use Newt qw(NEWT_ANCHOR_LEFT NEWT_FLAG_SCROLL NEWT_KEY_F11);
use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&dialog &startint &endint &output);
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
  Newt::PushHelpLine();
  Newt::DrawRootText(0,0,$msg);
#  Newt::Finished();
}

sub output {
  my($left,$top,$msg)=@_;
  Newt::DrawRootText($left,$top,$msg);
}

sub dialog {
  my ($name)=@_;
  my $entry=Newt::Entry(20,NEWT_FLAG_SCROLL);
  my $label=Newt::Label($name);
  my $ok=Newt::Button("Ok",0);
  my $panel1=Newt::Panel(2,4,$name);
  $panel1->AddHotKey(NEWT_KEY_F11);
  $panel1->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,0,$entry,NEWT_ANCHOR_LEFT);
#  $panel1->Add(1,2,$ok,NEWT_ANCHOR_LEFT);
  my ($reason,$data)=$panel1->Run();
#  Newt::Finished();
  my $stuff=$entry->Get();
  return($stuff);
}

sub endint {
  Newt::Finished();
}
END { }       # module clean-up code here (global destructor)
