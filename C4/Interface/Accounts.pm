package C4::Interface::Accounts; #asummes C4/Interface/Accounts

#uses Newt
use C4::Format;
use C4::Interface;
use strict;
#use Newt qw(:keys :exits :anchors :flags :colorsets :entry :fd :grid :macros
#:textbox);

use Newt qw(NEWT_ANCHOR_LEFT NEWT_FLAG_SCROLL NEWT_KEY_F11 NEWT_KEY_F10
NEWT_KEY_F1 NEWT_KEY_F2 NEWT_KEY_F4 NEWT_KEY_F5 NEWT_KEY_F8 NEWT_KEY_F9 NEWT_KEY_F12
NEWT_FLAG_RETURNEXIT NEWT_EXIT_HOTKEY NEWT_FLAG_WRAP NEWT_FLAG_MULTIPLE 
NEWT_ANCHOR_TOP NEWT_ANCHOR_RIGHT NEWT_FLAG_BORDER);
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&accountsdialog);
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


  
sub accountsdialog {
  my ($env,$title,$borrower,$accountlines,$amountowing)=@_;
  my $panel  = Newt::Panel(1,2,$title);
  my $panel2 = Newt::Panel(2,6,"");
  my $entry  = Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $lab1   = Newt::Label("Amount");
  my $lab2   = Newt::Label("Total Due");
  my $amt    = Newt::Label($amountowing);   
  my $lab3   = Newt::Label("Account Items");
  my $lab4   = Newt::Label("Borrower Info");
  my $bor0  = Newt::Label("$borrower->{'cardnumber'}");
  my $bor1  = Newt::Label("$borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'} ");
  my $bor2  = Newt::Label("$borrower->{'streetaddres'},");
  my $bor3  = Newt::Label("$borrower->{'city'}");
  my $list1 = Newt::Listbox(10,NEWT_FLAG_SCROLL | NEWT_FLAG_BORDER );
  my $i = 0;
  while ($accountlines->[$i]) {
    $list1->Add($accountlines->[$i]);
    $i++;
  }
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F10);
  $panel->AddHotKey(NEWT_KEY_F8);
  $panel->Add(0,0,$panel2,NEWT_ANCHOR_TOP);
  $panel2->Add(0,0,$lab1,NEWT_ANCHOR_LEFT);
  $panel2->Add(0,1,$entry,NEWT_ANCHOR_LEFT);
  $panel2->Add(0,2,$lab2,NEWT_ANCHOR_LEFT);
  $panel2->Add(0,3,$amt,NEWT_ANCHOR_LEFT);
  $panel2->Add(0,4,$lab3,NEWT_ANCHOR_LEFT);
  $panel2->Add(1,0,$lab4,NEWT_ANCHOR_LEFT);
  $panel2->Add(1,1,$bor0,NEWT_ANCHOR_LEFT);
  $panel2->Add(1,2,$bor1,NEWT_ANCHOR_LEFT);
  $panel2->Add(1,3,$bor2,NEWT_ANCHOR_LEFT);
  $panel2->Add(1,4,$bor3,NEWT_ANCHOR_LEFT);
  $panel->Add(0,1,$list1,NEWT_ANCHOR_LEFT);
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
    if ($data eq NEWT_KEY_F8){
      $reason="Print"
    }
    
  }
  debug_msg("",$reason);
#  Newt::Finished();
  my $stuff=$entry->Get();
  return($stuff,$reason);
}


END { }       # module clean-up code here (global destructor)
