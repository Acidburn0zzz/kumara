package C4::Interface; #asummes C4/Interface

#uses Term::Slang

use strict;
use Term::Slang;
use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&userdialog &output &heading &startint &endint &getinput &alert);
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

sub startint {
  my ($type,$area,$menu,$functions,$msg)=@_;
  if ($type eq 'console'){
    my $sl=Term::Slang->new;
    $sl->init_smg;
    $sl->SLang_init_tty(-1,0,1);
    $sl->smg_init_smg;
    $sl->SLkp_init;
    my ($s_rows,$s_cols) = $sl->SLtt_get_screen_size;
    
    my @colors = qw(
            black red green brown blue magenta cyan lightgray gray brightred
	    brightgreen yello brightblue brightmagenta brightcyan white
    );
    my $num_colors = scalar @colors;		    
    init_colors($sl,$num_colors,@colors);
    heading('console',$sl,$msg);      
    menu_loop($sl,$menu,$functions);
    quit($sl);

  } 
}

sub heading {
  my ($type,$sl,$msg)=@_;
   $sl->smg_cls;	
   my $color;            
   my $dr = 5;                    
   my $dc = 16;         
   my $r  = 0; 
   my $c  = 20;                                           
   $sl->smg_set_color(4);  
   $sl->SLsmg_set_char_set(1);          
   $sl->SLsmg_fill_region($r + 1, $c + 1, $dr - 2, $dc - 2, 'a');          
   $sl->SLsmg_set_char_set(0); 
   $sl->smg_set_color(0);         
   $sl->smg_gotorc($r + $dr/2, $c + 2);                 
   $sl->smg_write_string($msg);      
   $sl->smg_draw_box($r, $c, $dr, $dc);
   $sl->smg_refresh; 
}

sub quit {
        my($sl)=@_;
        $sl->SLang_reset_tty;
	$sl->smg_reset_smg;
	exit;
}

sub print_menu {
  #prints a menu, takes list of items in menu as parameter
        my ($sl,$names)=@_;
	$sl->SLsig_block_signals;
	#$sl->smg_cls;	
	my $row = 6;
	my $i   = 1;   	
        for my $name (@$names) {
	   $sl->smg_gotorc($row, 3);
	   $sl->smg_write_string("$i $name");
	   $row++;
	   $i++;
        }
	$row = 5;
	$sl->smg_gotorc($row,1);
	$sl->smg_write_string('Choose number:');
	
	$sl->smg_refresh;
	$sl->SLsig_unblock_signals;

}

sub output {
  my ($type,$string,$interface,$row)=@_;
  if ($type eq 'console'){
    #print "here";
    $interface->smg_gotorc($row, 1);
    $interface->smg_write_string("$string");
    $interface->smg_refresh;
    $interface->SLsig_unblock_signals;
  }
}

sub alert {
  my ($type,$string,$interface)=@_;
  my $row=23;
  if ($type eq 'console'){
    $interface->smg_set_color(4);
    $interface->smg_gotorc($row, 25);
    $interface->smg_write_string("$string");
    $interface->smg_refresh;
    $interface->SLsig_unblock_signals;
    $interface->smg_set_color(0);
  }
}

sub menu_loop {
        my ($sl,$names,$functions)=@_;
	if ($sl eq ''){
	  print "eh";
	} else {
        print_menu($sl,$names);	
	while (1) {
	  my $ch = chr $sl->SLkp_getkey; 
	  if ($$functions[$ch]) {
	    &{$$functions[$ch]}($sl);
	  } elsif ($ch eq '\r') {
	    next;
	  } else {
	    $sl->SLtt_beep;
	  }
	  $sl->smg_cls;	
	  print_menu($sl,$names);
        }
	}
}
sub init_colors {
   my ($sl,$num_colors,@colors)=@_;
        for(my $i = 0; $i < $num_colors; $i++) {
	  $sl->SLtt_set_color($i+1,'','black',$colors[$i]);
	}
}

sub getinput {
  my ($sl,$row)=@_;
  $sl->smg_gotorc($row, 1);
  my $input;
  my $ch = chr $sl->SLkp_getkey;
  while ($ch !~ /\r/){
     $sl->smg_write_string("$ch");  
     $sl->smg_refresh;                
     $sl->SLsig_unblock_signals;
     $input=$input.$ch;
     $ch = chr $sl->SLkp_getkey;
  }
  return($input);
}
  
END { }       # module clean-up code here (global destructor)
