package C4::InterfaceCDK; #asummes C4/InterfaceCDK

#uses Newt
use C4::Format;
use C4::Interface::Funkeys;
use strict;
use Cdk;
use Date::Manip;
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
&borrbind &borrfill &preeborr &borrowerbox);
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
  @header[0] = fmtstr($env,$title,"L36").fmtstr($env,$title2,"R36");
  my $label = new Cdk::Label ('Message' =>\@header,
     'Ypos'=>0);
  $label->draw();
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
  if ($env->{'telnet'} eq "Y") {
    popupLabel (["Debug </R>$text"]);
  } else {
    print "****DEBUG $text****";
  }  
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
  #Cdk::raw();
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
  my ($env,$title,$items1,$items2,$borrower,$amountowing,$odues)=@_;
  my $titlepanel = titlepanel($env,"Issues","Issue a book");
  my $scroll2 = new Cdk::Scroll ('Title'=>"Previous Issues",
    'List'=>\@$items1,'Height'=> 8,'Width'=>78,'Ypos'=>18);
  my $scroll1 = new Cdk::Scroll ('Title'=>"Current Issues",
    'List'=>\@$items2,'Height'=> 8,'Width'=>78,'Ypos'=>9);
  my $loanlength = new Cdk::Entry('Label'=>"Due Date:      ",
    'Max'=>"30",'Width'=>"11",
    'Xpos'=>0,'Ypos'=>5,'Type'=>"UMIXED");
  my $x = 0;
  while ($x < length($env->{'loanlength'})) {
     $loanlength->inject('Input'=>substr($env->{'loanlength'},$x,1));
     $x++;
  }
  my $borrbox = borrowerbox($env,$borrower,$amountowing);
  my $entryBox = new Cdk::Entry('Label'=>"Book Barcode:  ",
     'Max'=>"11",'Width'=>"11",
     'Xpos'=>"0",'Ypos'=>3,'Type'=>"UMIXED");
  $scroll2->draw();
  $scroll1->draw(); 
  $loanlength->draw(); 
  $borrbox->draw();   
  #$env->{'loanlength'} = "";
  #debug_msg($env,"clear len");
  my $x;
  my $barcode;
  $entryBox->preProcess ('Function' => 
    sub{prebook(@_,$env,$entryBox,$loanlength,$scroll1,$scroll2);});
  $barcode = $entryBox->activate();
  my $reason;
  if (!defined $barcode) {
    $reason="Finished user"
  }
  $borrbox->erase();
  $entryBox->erase();
  $scroll2->erase();
  $scroll1->erase();
  $loanlength->erase(); 
  #debug_msg($env,"exiting");    
  return $barcode,$reason;
}  
sub actscroll1 {
  my ($env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
  $scroll1->preProcess ('Function' =>
    sub{prescroll1(@_,$env,$entryBox,$loanlength,$scroll1,$scroll2);});
  $scroll1->activate();
  return 1;
}
sub actscroll2 {
  my ($env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
  $scroll2->preProcess ('Function' =>
    sub{prescroll2(@_,$env,$entryBox,$loanlength,$scroll1,$scroll2);});
  $scroll2->activate();
  return 1;
}
sub actloanlength {
  my ($env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
  $loanlength->preProcess ('Function' =>
    sub{preloanlen(@_,$env,$entryBox,$loanlength,$scroll1,$scroll2);});
  my $validdate = "N";
  while ($validdate eq "N") {
    my $loanlength = $loanlength->activate();
    if (!defined $loanlength) {
      $env->{'loanlength'} = "";
      $validdate = "Y";
    } elsif ($loanlength eq "") {
      $env->{'loanlength'} = "";
      $validdate = "Y";
    } else {    
      my $date = ParseDate($loanlength);
      if ( $date > ParseDate('today')){
        $validdate="Y";
	my $fdate = substr($date,0,4).'-'.substr($date,4,2).'-'.substr($date,4,2);
	#debug_msg($env,"$date $fdate");
        $env->{'loanlength'} = $fdate;
      } else { 
        error_msg($env,"Invalid date"); 
      }
    }
  }  
  return;
}

sub prebook {
  my ($input,$env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
  if ($input eq $key_tab) {    
    actloanlength($env,$entryBox,$loanlength,$scroll1,$scroll2);
    return 0;
  }
  return 1;
}

sub prescroll1 {
  my ($input,$env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
  if ($input eq $key_tab) {    
    actscroll2($env,$entryBox,$loanlength,$scroll1,$scroll2);
    return 0;	
  }
  return 1;
}

sub prescroll2 {
  my ($input,$env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
  return 1;
}

sub preloanlen {
  my ($input,$env,$entryBox,$loanlength,$scroll1,$scroll2) = @_; 
  if ($input eq $key_tab) {                  
    actscroll1($env,$entryBox,$loanlength,$scroll1,$scroll2);
    return 0;
  }                                     
  return 1;                                                 
}
	  						  
sub borrowerbox {
  my ($env,$borrower,$amountowing,$odues) = @_;
  my @borrinfo;
  #debug_msg($env,"borrbox");
  my $line = "$borrower->{'cardnumber'} ";
  $line = $line."$borrower->{'surname'}, ";
  $line = $line."$borrower->{'title'} $borrower->{'firstname'}";
  $borrinfo[0]=$line;
  $line = "$borrower->{'streetaddress'}, $borrower->{'city'}";
  $borrinfo[1]=$line;
  $line = "";  
  if ($borrower->{'gonenoaddress'} == 1) {
    $line = $line." </R>GNA<!R>";
  }
  if ($borrower->{'lost'} == 1) {
    $line = $line." </R>LOST<!R>";
  }
  if ($odues > 0) {
    $line = $line." </R>ODUE<!R>";
  }	
  if ($borrower->{'borrowernotes'} ne "" ) {
    $line = $line." </R>NOTES<!R>";
  }
  if ($amountowing > 0) {
    #$amountowing=fmtdec($env,$amountowing);
    $line = $line." </B>\$$amountowing";
  }
  $borrinfo[2]=$line;
  if ($borrower->{'borrowernotes'} ne "" ) {
    $borrinfo[3]=substr($borrower->{'borrowernotes'},0,40);     
  }
  my $borrbox = new Cdk::Label ('Message' =>\@borrinfo,
    'Ypos'=>3, 'Xpos'=>"RIGHT");
  return $borrbox;
}

sub returnwindow {
  my ($env,$title,$item,$items,$borrower,$amountowing)=@_;
  #debug_msg($env,$borrower);
  my $titlepanel = titlepanel($env,"Returns","Scan book");
  my $returnlist = new Cdk::Scroll ('Title'=>"Items Returned",
     'List'=>\@$items,'Height'=> 12,'Width'=>74,'Ypos'=>10,'Xpos'=>1);
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


