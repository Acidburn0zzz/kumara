package C4::Circmain; #asummes C4/Circulation

#package to deal with circulation 

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Circulation::Main;
use C4::Circulation::Issues;
use C4::Circulation::Returns;
use C4::Circulation::Renewals;
use C4::Circulation::Borrower;
use C4::Reserves;
use C4::InterfaceCDK;
use C4::Security;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&Start_circ);
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

sub Start_circ{
  my ($env)=@_;
  #connect to database
  #start interface
  &startint($env,'Circulation');
  getbranch($env);
  my $donext = 'Circ';
  my $reason;
  my $data;
  while ($donext ne 'Quit') {
    if ($donext  eq "Circ") {
      #&startint($env,'Circulation');
      clearscreen();
      #
      #($reason,$data) = menu($env,'console','Circulation', 
      #  ('Issues','Returns','Borrower Enquiries','Reserves','Log In'));
      ($reason,$data) = menu($env,'console','Circulation', 
        ('Issues','Returns','Select Branch'));
      #debug_msg($env,"data = $data");
      #my $response = msg_yn("data",$data);
      #debug_msg($env,"Resp $response");
      #&endint($env);
    } else {
      $data = $donext;
    }
    if ($data eq 'Issues') {  
      #&startint($env,'Circulation');
      $donext=Issue($env); #C4::Circulation::Issues 
      #debug_msg("","do next $donext");
      #&endint($env);         
    } elsif ($data eq 'Returns') {
      #&startint($env,'Circulation');
      $donext=Returns($env); #C4::Circulation::Returns 
      #&endint($env);
    } elsif ($data eq "Select Branch") {
      getbranch($env);
    } elsif ($data eq 'Borrower Enquiries') {
      #&startint($env,'Circulation');     
#  $donext=Borenq($env); #C4::Circulation::Borrower - conversion
      #&endint($env);
    } elsif ($data eq 'Reserves'){
      $donext=EnterReserves($env); #C4::Reserves 
    } elsif ($data eq 'Log In') {
#      &endint($env); - conversion
#      &Login($env);   #C4::Security - conversion
#      &startint($env,'Circulation'); - conversion
    } elsif ($data eq 'Quit') { 
      $donext = $data;
    }
    #debug_msg($env,"donext -  $donext");
  }
  &endint($env)  
}


END { }       # module clean-up code here (global destructor)
