package C4::Interface::AccountsCDK; #asummes C4/Interface/AccountsCDK

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
  my $titlepanel = titlepanel($env,$env->{'sysarea'},"Money Owing");
  my @borinfo;
  my $reason;
  $borinfo[0]  = "$borrower->{'cardnumber'}";
  $borinfo[1] = "$borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'} ";
  $borinfo[2] = "$borrower->{'streetaddress'}, $borrower->{'city'}";
  $borinfo[3] = "<R>Total Due:  </B>".fmtdec($env,$amountowing,"52");
  my $borpanel = 
  new Cdk::Label ('Message' =>\@borinfo, 'Ypos'=>4, 'Xpos'=>"RIGHT");
  $borpanel->draw();
  my $acctlist = new Cdk::Scroll ('Title'=>"Outstanding Items",
      'List'=>\@$accountlines,'Height'=>12,'Width'=>30,
      'Xpos'=>1,'Ypos'=>10);
  $acctlist->draw();
  my $amountentry = new Cdk::Entry('Label'=>"Amount:  ",
     'Max'=>"10",'Width'=>"10",
     'Xpos'=>"1",'Ypos'=>"4",
     'Type'=>"INT");
  $amountentry->set('Value'=>$amountowing);
  my $amount =$amountentry->activate();
                                                                
  debug_msg($env,"accounts $amount");
  
  if (!defined $amount) {
     $reason="Finished user";
  }
  return($amount,$reason);
}


END { }       # module clean-up code here (global destructor)
