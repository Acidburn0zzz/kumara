package C4::InterfaceCDK; #asummes C4/InterfaceCDK

#uses Newt
use C4::Format;
use C4::Interface::Funkeys;
use strict;
use Cdk;
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&dialog &startint &endint &output &clearscreen &pause &helptext
&textbox &menu &issuewindow &msg_yn &borrower_dialog &debug_msg &error_msg
&selborrower &returnwindow &logondialog &borrowerwindow &titlepanel
&borrbind &borrfill &preeborr);
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
my $lastval = chr(18);
#my $lastval = "?";			    
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;
sub suspend_cb {

}
      
sub startint {
  my ($env,$msg)=@_;
  Cdk::init();
}

sub menu {
  my ($env,$type,$title,@items)=@_;
  $env->{'sysarea'}="Menu";
  my $titlebar=titlepanel($env,"Library System","Main Menu");
  my $reason;
  my $data;
  my @mitems;
  my $x = 0;
  while ($items[$x] ne "") {
    $mitems[$x]="<C>".$items[$x];
    $x++;
  }  
  if ($type eq 'console'){
    my $menucnt = @items;
    my $menu = new Cdk::Scroll ('Title'=>"  ",
      'List'=>\@mitems,
      'Height'=> $menucnt+4,
      'Width'=> 26);
    # Activate the object.         
    my ($menuItem) = $menu->activate();
    # Check the results.
    if (!defined $menuItem) {      
      $data = "Quit";
    }
    else { 
      $data = $items[$menuItem];
    }
  }
  return($reason,$data);
  # end of menu
  
}

  
sub clearscreen { 
}

sub pause {
 
}

sub output {
  my($left,$top,$msg)=@_;
  my @outm;
  $outm[0]=$msg;
  my $output = new Cdk::Label ('Message' =>\@outm,
    'Ypos'=>$top, 'Xpos'=>$left, 'Box'=>0);
  $output->draw();
  return $output;
}

sub helptext {
  my ($text)=@_;
  my $helptext = output(1,24,$text);
  return $helptext;
}


sub titlepanel{
  my ($env,$title,$title2)=@_;
  my @header;
  #debug_msg($env,$title);
  @header[0] = fmtstr($env,$title,"L36").fmtstr($env,$title2,"R36");
  my $label = new Cdk::Label ('Message' =>\@header,
     'Ypos'=>0);
  $label->draw();
  #debug_msg($env,$title2);
  return $label;
  }

sub msg_yn {
  my ($text1,$text2)=@_;
  # Cdk::init();
  # Create the dialog buttons.
  my @buttons = ("Yes", "No");
  my @mesg = ("<C>$text1", "<C>$text2");
  # Create the dialog object.
  my $dialog = new Cdk::Dialog ('Message' => \@mesg, 'Buttons' => \@buttons);
  my $resp = $dialog->activate();
  my $response = "Y";
  if ($resp = "1") {
     $response = "N";
  }
  return $response;
}

sub debug_msg {
  my ($env,$text)=@_;
  popupLabel (["Debug </R>$text"]);
  return();
}

sub error_msg {
  my ($env,$text)=@_;
  popupLabel (["<C>Error </R>$text"]);
  return();
}

sub endint {
  Cdk::end();
}

sub borrower_dialog {
  my ($env)=@_;
  my $result;
  my $borrower;
  my $book;
  my @coltitles = ("Borrower","Book");
  my @rowtitles = (" ");
  my @coltypes  = ("UMIXED","UMIXED");
  my @colwidths = (12,12);
  #Cdk::refreshCdkScreen();
  Cdk::raw();
  my $matrix = new Cdk::Matrix (
     'ColTitles'=> \@coltitles,
     'RowTitles'=> \@rowtitles, 
     'ColWidths'=> \@colwidths,
     'ColTypes'=>  \@coltypes,
     'Vrows'=>     1, 
     'Vcols'=>     2);
  borrbind($env,$matrix);
  $matrix->draw();
  my ($rows,$cols,$info) = $matrix->activate();
  debug_msg($env,$info->[0][0]);
  debug_msg($env,$info->[0][1]);
  
  if ((!defined $rows) && ($info->[0][0] eq "")) { 
    $result = "Circ";
  } else {
    $borrower = $info->[0][0];
    $book     = $info->[0][1];
  }
  $matrix->erase();
  return ($borrower,$result,$book);
}

sub selborrower {
  my ($env,$dbh,$borrows,$bornums)=@_;
  my $result;
  my $label = "Select a borrower";
  my $scroll = new Cdk::Scroll ('Title'=>$label,
    'List'=>\@$borrows,'Height'=>15,'Width'=>60);
  my $returnValue = $scroll->activate ();
  if (!defined $returnValue) {
    #$result = "Circ";
  } else {  
    $result = substr(@$borrows[$returnValue],0,9);
  }
  return $result;
}

sub issuewindow {
  my ($env,$title,$items1,$items2,$borrower,$amountowing)=@_;
  my $titlepanel = titlepanel($env,"Issues","Issue a book");
  my $scroll2 = new Cdk::Scroll ('Title'=>"Previous Issues",
    'List'=>\@$items1,'Height'=> 8,'Width'=>78,'Ypos'=>18);
  $scroll2->draw();
  my $scroll1 = new Cdk::Scroll ('Title'=>"Current Issues",
    'List'=>\@$items2,'Height'=> 8,'Width'=>78,'Ypos'=>9);
  $scroll1->draw();
  my $borrbox = borrowerbox($env,$borrower,$amountowing);
  my @borrinfo;
  $borrbox->draw();    
  my $entryBox = new Cdk::Entry('Label'=>"Book Barcode:  ",
     'Max'=>"11",'Width'=>"11",
     'Xpos'=>"0",'Ypos'=>"4",
     'Type'=>"UMIXED");
  my $x;
  my $barcode;
  $entryBox->bind('Key'=>"KEY_TAB",'Function'=>sub {$x = act($scroll1);});
  $scroll1->bind('Key'=>"KEY_TAB",'Function'=>sub {$x = act($scroll2);});
  $scroll2->bind('Key'=>"KEY_TAB",'Function'=>sub {
      $x = act($entryBox);
      return $x;});  
  $entryBox->bind('Key'=>"KEY_BTAB",'Function'=>sub {$x = act($scroll2);});
  $scroll1->bind('Key'=>"KEY_BTAB",'Function'=>sub { 
      $x = act($entryBox);
      return $x;});
  $scroll2->bind('Key'=>"KEY_BTAB",'Function'=>sub {$x = act($scroll1);});
  $barcode = $entryBox->activate();
  my $reason;
  if (!defined $barcode) {
    $reason="Finished user"
  }
  $borrbox->erase();
  $entryBox->erase();
  $scroll2->erase();
  $scroll1->erase();
   
  debug_msg($env,"exiting");
    
  return $barcode,$reason;
}  

sub borrowerbox {
  my ($env,$borrower,$amountowing) = @_;
  my @borrinfo;
  $borrinfo[0]="$borrower->{'cardnumber'} ".
     "$borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'}";
  $borrinfo[1]="$borrower->{'streetaddress'}, $borrower->{'city'}";
  $borrinfo[2]="<R>Amount Owing</B> $amountowing";
  my $borrbox = new Cdk::Label ('Message' =>\@borrinfo,
     'Ypos'=>4, 'Xpos'=>"RIGHT");
  return $borrbox;
}

sub returnwindow {
  my ($env,$title,$item,$items,$borrower,$amountowing)=@_;
  #debug_msg($env,$borrower);
  my $titlepanel = titlepanel($env,"Returns","Scan book");
  my $returnlist = new Cdk::Scroll ('Title'=>"Items Returned",
     'List'=>\@$items,'Height'=> 12,'Width'=>60,'Ypos'=>10,'Xpos'=>1);
  $returnlist->draw();
  my $borrbox;
  if ($borrower-{'cardnumber'} ne "") {    
    $borrbox = borrowerbox($env,$borrower,$amountowing);  
    $borrbox->draw();
  }
  my $bookentry  =  new Cdk::Entry('Label'=>"Book Barcode:  ",
     'Max'=>"11",'Width'=>"11",
     'Xpos'=>"1",'Ypos'=>"4",
     'Type'=>"UMIXED");
  my $barcode = $bookentry->activate();
  my $reason;
  if (!defined $barcode) {
    $barcode="";
    $reason="Circ";
  } else {
    $reason="";
  }
  return($reason,$barcode);
  }
				    
sub act {
  my ($obj) = @_;
  my $ans = $obj->activate();
  return $ans;
  }

sub borrbind {
  my ($env,$entry) = @_; 
  my $lastborr = $env->{"bcard"};
  $entry->preProcess ('Function' => sub {preborr (@_, $env,$entry);});
}

sub preborr {
  my ($input,$env, $entry) = @_;
  if ($input eq $lastval) {
    borfill($env,$entry);
    return 0;
  }
  return 1;
}  
  
  
sub borfill {
  my ($env,$entry) = @_;
  #debug_msg("","hi there");
  my $lastborr = $env->{"bcard"};
  my $i = 1;
  $entry->inject('Input'=>$lastborr);
  while ($i < 9) {
    $entry->inject('Input'=>substr($lastborr,$i,1));
    $i++;
  }
   
}
			       
END { }       # module clean-up code here (global destructor)


