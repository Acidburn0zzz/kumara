package C4::Interface::RenewalsCDK; #asummes C4/Interface/RenewalsCDK

#uses Newt
use strict;
use Cdk;
use C4::Format;
use C4::InterfaceCDK;
use Date::Manip;
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(renew_window);
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
# the functions below that se them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

#defining keystrokes used for screens
my $lastval = chr(18);
my $key_tab  = chr(9);
my $key_ctla = chr(1);
my $key_ctlb = chr(2);
my $key_ctlc = chr(3);
my $key_ctld = chr(4);
my $key_ctle = chr(5);
my $key_ctlf = chr(6);
my $key_ctlg = chr(7);
my $key_ctlh = chr(8);
my $key_ctli = chr(9);
my $key_ctlj = chr(10);
my $key_ctlk = chr(11);
my $key_ctll = chr(12);
my $key_ctlm = chr(13);
my $key_ctln = chr(14);
my $key_ctlo = chr(15);
my $key_ctlp = chr(16);
my $key_ctlq = chr(17);
my $key_ctlr = chr(18);
my $key_ctls = chr(19);
my $key_ctlt = chr(20);
my $key_ctlu = chr(21);
my $key_ctlv = chr(22);
my $key_ctlw = chr(23);
my $key_ctlx = chr(24);
my $key_ctly = chr(25);
my $key_ctlz = chr(26);
my $lastval = $key_ctlr;

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;

sub renew_window {
  my ($env,$issueditems,$borrower,$amountowing,$odues)=@_;
  my $titlepanel = C4::InterfaceCDK::titlepanel($env,$env->{'sysarea'},"Renewals");
  my @sel = ("N ","Y ");
  my $issuelist = new Cdk::Selection ('Title'=>"Renew items",
    'List'=>\@$issueditems,'Choices'=>\@sel,
    'Height'=> 14,'Width'=>78,'Ypos'=>8);
  my $x = 0;
  my $borrbox = C4::InterfaceCDK::borrowerbox($env,$borrower,$amountowing);
  $borrbox->draw();
  my @renews = $issuelist->activate();
  $issuelist->erase();
  undef $titlepanel;
  undef $issuelist;
  undef $borrbox;
  return \@renews;
}  
			       
END { }       # module clean-up code here (global destructor)


