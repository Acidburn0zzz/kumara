package C4::Interface; #asummes C4/Interface

#uses newt

use strict;
use Curses;
use Curses::Widgets;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&userdialog &resultout);
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

sub userdialog{
 #create a dialog
 my ($type,$text)=@_;
 if ($type eq 'console'){
   my ($mwh, $dwh); 
   my ($colours); 
   $mwh = new Curses; 
   $colours = has_colors(); 
   noecho(); 
   cbreak(); 
   halfdelay(10); 
   $mwh->keypad(1);
   init_colours();
   main_win($mwh);
   $dwh = $mwh->subwin(8, $COLS - 2, 1, 1);
   grab_key($mwh);
   my $input=&input($mwh,$text);
   endwin();
   return($input);
  }
 
}

sub resultout{
  #outputsome results
  my ($type,$results)=@_;
  if ($type eq 'console'){
   my ($mwh, $dwh); 
   my ($colours); 
   $mwh = new Curses; 
   $colours = has_colors(); 
   noecho(); 
   cbreak(); 
   halfdelay(10); 
   $mwh->keypad(1);
   init_colours();
   main_win($mwh);
   $dwh = $mwh->subwin(8, $COLS - 2, 1, 1);
   dialog($results,'red',$dwh,$mwh);
   grab_key($mwh); 
   endwin();
  }
}

sub main_win {
  my ($mwh)=@_;
  $mwh->erase();        
  # This function selects a few common colours for the  foreground colour 
  select_colour(\$mwh, 'red');
  $mwh->box(ACS_VLINE, ACS_HLINE);        
  $mwh->attrset(0);                
  $mwh->standout();                        
  $mwh->addstr(0, 1, "Welcome to the Kumara Issues Screen");             
  $mwh->standend();
  
}              

sub dialog {
  my ($text, $colour,$dwh,$mwh) = @_;
  my (@lines) = split(/\n/, $text);        
  my ($i, $j, $line);                  
  for ($i = 1; $i < 7; $i++) {     
    if (defined ($lines[$i -1])) {                                
      $line = $lines[$i -1] . "\n";
    } else {                        
      $line ="\n";                                          
    }
  $dwh->addstr($i, 2, $line);                
  }                                
  select_colour(\$dwh,$colour);                                         
  $dwh->box(ACS_VLINE, ACS_HLINE);
  $dwh->attrset(0);        
  touchwin($mwh);                
  $mwh->refresh();                        
}        

sub input{
  my ($mwh,$text)=@_;
  my ($text, $content) = txt_field(   'window'               => \$mwh, 
  'title'   =>$text,                  
  'xpos' => 1,     
  'ypos'               => 9, 
  'lines'              => 5,                             
  'cols'               => $COLS - 4,                     
  'content'    => ' ',                                   
  'border' =>'green');
  return($content);
}

sub grab_key {
  my ($mwh)=@_;
  my ($key) = -1;                                       
  while ($key eq -1) {  
    $key= $mwh->getch();                  
  }                                       
  
  return $key;  
}  


END { }       # module clean-up code here (global destructor)
