package C4::Interface::FlagsCDK; #asummes C4/Interface/FlagsCDK

#uses Newt
use C4::Format;
use C4::InterfaceCDK;
use strict;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&trapscreen &trapsnotes);
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


  
sub trapscreen {
  my ($env,$bornum,$borrower,$amount,$traps_set)=@_;
  my $titlepanel = titlepanel($env,$env->{'sysarea'},"Borrower Flags");
  my @borinfo;
  #debug_msg($env,"owwing = $amount");
  my $borpanel = borrowerbox($env,$borrower,$amount);
  $borpanel->draw();
  my $hght = @$traps_set+4;
  my $flagsset = new Cdk::Scroll ('Title'=>"Act On Flag",
      'List'=>\@$traps_set,'Height'=>$hght,'Width'=>15,
      'Xpos'=>4,'Ypos'=>3);
  my $act =$flagsset->activate();                                                               
  my $action;
  if (!defined $act) {
    $action = "NONE";
  } else {
    $action = @$traps_set[$act];
  }   
  return($action);
}

sub trapsnotes {
  my ($env,$bornum,$borrower,$amount) = @_;
  my $titlepanel = titlepanel($env,$env->{'sysarea'},"Borrower Notes");
  my $borpanel = borrowerbox($env,$borrower,$amount);
  $borpanel->draw();
  my $notesbox = new Cdk::Mentry ('Label'=>"Notes:  ",
    'Width'=>40,'Prows'=>10,'Lrows'=>30,
    'Lpos'=>"Top",'Xpos'=>"RIGHT",'Ypos'=>10);
  my $ln = length($borrower->{'borrowernotes'});
  my $x = 0;
  while ($x < $ln) {
    my $y = substr($borrower->{'borrowernotes'},$x,1);
    $notesbox->inject('Input'=>$y);
    $x++;
  }
  my $notes =  $notesbox->activate();
  if (!defined $notes) { 
    $notes = $borrower->{'borrowernotes'}; 
  }
  return $notes;
}

END { }       # module clean-up code here (global destructor)
