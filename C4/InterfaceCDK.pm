package C4::InterfaceCDK; #asummes C4/InterfaceCDK

#uses Newt
use C4::Format;
use strict;
use Cdk;
use Date::Manip;
use C4::Accounts;
use C4::Circulation::Renewals;
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
&borrbind &borrfill &preeborr &borrowerbox &brmenu &prmenu);
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
  @header[0] = fmtstr($env,$title,"L26");
  @header[0] = @header[0].fmtstr($env,$env->{'branchname'},"C20");
  @header[0] = @header[0].fmtstr($env,$title2,"R26");
  my $label = new Cdk::Label ('Message' =>\@header,
     'Ypos'=>0);
  $label->draw();
  return $label;
  }

sub msg_yn {
  my ($env,$text1,$text2)=@_;
  # Cdk::init();
  # Create the dialog buttons.
  my @buttons = ("Yes", "No");
  my @mesg = ("<C>$text1", "<C>$text2");
  # Create the dialog object.
  my $dialog = new Cdk::Dialog ('Message' => \@mesg, 'Buttons' => \@buttons);
  my $resp = $dialog->activate();
  my $response = "Y";
  if ($resp == 1) {
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


sub brmenu {
  my ($env,$brrecs)=@_;
  $env->{'sysarea'}="Menu";
  my $titlebar=titlepanel($env,"Library System","Select branch");
  my @mitems;
  my $x = 0;
  while (@$brrecs[$x] ne "") {
    my $brrec =@$brrecs[$x]; 
    $mitems[$x]=fmtstr($env,$brrec->{'branchcode'},"L6");
    $mitems[$x]=$mitems[$x].fmtstr($env,$brrec->{'branchname'},"L20");
    $x++;
  }  
  my $menu = new Cdk::Scroll ('Title'=>"  ",
      'List'=>\@mitems,
      'Height'=> 16,
      'Width'=> 30);
  # Activate the object.         
  my ($menuItem) = $menu->activate();
  # Check the results.
  if (defined $menuItem) {      
    my $brrec = @$brrecs[$menuItem];
    $env->{'branchcode'} = $brrec->{'branchcode'};
    $env->{'branchname'} = $brrec->{'branchname'};
  }
  return();
  
}

sub prmenu {
  my ($env,$prrecs)=@_;
  $env->{'sysarea'}="Menu";
  my $titlebar=titlepanel($env,"Library System","Select printer");
  my @mitems;
  my $x = 0;
  while (@$prrecs[$x] ne "") {
    my $prrec =@$prrecs[$x]; 
    $mitems[$x]=fmtstr($env,$prrec->{'printername'},"L20");
    $x++;
  }  
  my $menu = new Cdk::Scroll ('Title'=>"  ",
      'List'=>\@mitems,
      'Height'=> 16,
      'Width'=> 30);
  # Activate the object.         
  my ($menuItem) = $menu->activate();
  # Check the results.
  if (defined $menuItem) {      
    my $prrec = @$prrecs[$menuItem];
    $env->{'queue'} = $prrec->{'printqueue'};
    $env->{'printtype'} = $prrec->{'printtype'};
  }
  return();
  
}


sub borrower_dialog {
  my ($env)=@_;
  my $result;
  my $borrower;
  my $book;
  my @coltitles = ("Borrower","Item");
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
  my ($env,$title,$dbh,$items1,$items2,$borrower,$amountowing,$odues)=@_;
  my @functs=("Due Date","Renewals","Payments","Current","Previous");
  my $titlepanel = titlepanel($env,"Issues","Issue an Item");
  my $scroll2 = new Cdk::Scroll ('Title'=>"Previous Issues",
    'List'=>\@$items1,'Height'=> 8,'Width'=>78,'Ypos'=>18);
  my $scroll1 = new Cdk::Scroll ('Title'=>"Current Issues",
    'List'=>\@$items2,'Height'=> 8,'Width'=>78,'Ypos'=>9);
  my $funcmenu = new Cdk::Scroll ('Title'=>"",
    'List'=>\@functs,'Height'=>5,'Width'=>12,'Ypos'=>3,'Xpos'=>28);
  my $loanlength = new Cdk::Entry('Label'=>"Due Date:      ",
    'Max'=>"30",'Width'=>"11",
    'Xpos'=>0,'Ypos'=>5,'Type'=>"UMIXED");
  my $x = 0;
  while ($x < length($env->{'loanlength'})) {
     $loanlength->inject('Input'=>substr($env->{'loanlength'},$x,1));
     $x++;
  }
  my $borrbox = borrowerbox($env,$borrower,$amountowing);
  my $entryBox = new Cdk::Entry('Label'=>"Item Barcode:  ",
     'Max'=>"11",'Width'=>"11",
     'Xpos'=>"0",'Ypos'=>3,'Type'=>"UMIXED");
  $scroll2->draw();
  $scroll1->draw();
  $funcmenu->draw();
  $loanlength->draw(); 
  $borrbox->draw();   
  #$env->{'loanlength'} = "";
  #debug_msg($env,"clear len");
  my $x;
  my $barcode;
  $entryBox->preProcess ('Function' => 
    sub{prebook(@_,$env,$dbh,$funcmenu,$entryBox,$loanlength,
    $scroll1,$scroll2,$borrower,$amountowing,$odues);});
  $barcode = $entryBox->activate();
  my $reason;
  if (!defined $barcode) {
    $reason="Finished user"
  }
  $borrbox->erase();
  $entryBox->erase();
  $scroll2->erase();
  $scroll1->erase();
  $funcmenu->erase();
  $loanlength->erase(); 
  #debug_msg($env,"exiting");    
  return $barcode,$reason;
}  
sub actfmenu {
  my ($env,$dbh,$funcmenu,$entryBox,$loanlength,$scroll1,
    $scroll2,$borrower,$amountowing,$odues) = @_;
  my $funct =  $funcmenu->activate();
  if (!defined $funct) {
  } elsif ($funct == 0 ) {
    actloanlength ($env,$entryBox,$loanlength,$scroll1,$scroll2);
  } elsif ($funct == 1 ) { 
    $entryBox->erase();
    $scroll1->erase();
    $scroll2->erase();
    $loanlength->erase();
    $funcmenu->erase();
    #debug_msg($env,"");
    C4::Circulation::Renewals::bulkrenew($env,$dbh,
      $borrower->{'borrowernumber'},$amountowing,$borrower,$odues);
    #debug_msg($env,"");
    Cdk::refreshCdkScreen();
  } elsif ($funct == 2 ) {
    $entryBox->erase();
    $scroll1->erase();
    $scroll2->erase();
    $loanlength->erase();
    $funcmenu->erase();
    C4::Accounts::reconcileaccount($env,$dbh,$borrower->{'borrowernumber'},
    $amountowing,$borrower,$odues);
    Cdk::refreshCdkScreen();
  } elsif ($funct == 3 ) {
    actscroll1 ($env,$entryBox,$loanlength,$scroll1,$scroll2);
  } elsif ($funct == 4 ) {
    actscroll2 ($env,$entryBox,$loanlength,$scroll1,$scroll2);
  }
}  
sub actscroll1 {
  my ($env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
  $scroll1->activate();
  return 1;
}
sub actscroll2 {
  my ($env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
  $scroll2->activate();
  return 1;
}
sub actloanlength {
  my ($env,$entryBox,$loanlength,$scroll1,$scroll2) = @_;
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
	my $fdate = substr($date,0,4).'-'.substr($date,4,2).'-'.substr($date,6,2);
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
  my ($input,$env,$dbh,$funcmenu,$entryBox,$loanlength,
    $scroll1,$scroll2,$borrower,$amountowing,$odues)= @_;
  if ($input eq $key_tab) {    
    actfmenu ($env,$dbh,$funcmenu,$entryBox,$loanlength,$scroll1,
       $scroll2,$borrower,$amountowing,$odues);
    return 0;
  }
  return 1;
}
	  						  
sub borrowerbox {
  my ($env,$borrower,$amountowing,$odues) = @_;
  my @borrinfo;
  my $amountowing = fmtdec($env,$amountowing,"42");
  #debug_msg($env,"borrbox");
  debug_msg($env,"$amountowing");
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
  my ($env,$title,$item,$items,$borrower,$amountowing,$odues,$dbh)=@_;
  #debug_msg($env,$borrower);
  my $titlepanel = titlepanel($env,"Returns","Scan Item");
  my @functs=("Payments","Renewal");
  my $funcmenu = new Cdk::Scroll ('Title'=>"",
     'List'=>\@functs,'Height'=>5,'Width'=>12,'Ypos'=>3,'Xpos'=>16);
  my $returnlist = new Cdk::Scroll ('Title'=>"Items Returned",
     'List'=>\@$items,'Height'=> 12,'Width'=>74,'Ypos'=>10,'Xpos'=>1);
  $returnlist->draw();
  $funcmenu->draw();
  my $borrbox;
  if ($borrower->{'cardnumber'} ne "") {    
    $borrbox = borrowerbox($env,$borrower,$amountowing);  
    $borrbox->draw();
  }
  my $bookentry  =  new Cdk::Entry('Label'=>" ",
     'Max'=>"11",'Width'=>"11",
     'Xpos'=>"2",'Ypos'=>"3",'Title'=>"Item Barcode",
     'Type'=>"UMIXED");
  $bookentry->preProcess ('Function' =>sub{preretbook(@_,$env,$dbh,
     $funcmenu,$bookentry,$borrower,$amountowing,$odues);});
  my $barcode = $bookentry->activate();
  my $reason;
  if (!defined $barcode) {
    $barcode="";
    $reason="Circ";
    $bookentry->erase();
    $funcmenu->erase();
    if ($borrbox ne "") {$borrbox->erase();}
  } else {
    $reason="";
  }
  return($reason,$barcode);
  }

sub preretbook {
  my ($input,$env,$dbh,$funcmenu,$bookentry,$borrower,$amountowing,$odues)= @_;
  if ($input eq $key_tab) {
    actrfmenu ($env,$dbh,$funcmenu,$bookentry,$borrower,$amountowing,$odues);
    return 0;
  }
  return 1;
  }

sub actrfmenu {
  my ($env,$dbh,$funcmenu,$bookentry,$borrower,$amountowing,$odues) = @_;
  my $funct =  $funcmenu->activate();
  #debug_msg($env,"funtion $funct");
  if (!defined $funct) {
  } elsif ($funct == 1 ) {
    if ($borrower->{'borrowernumber'} ne "") {
       C4::Circulation::Renewals::bulkrenew($env,$dbh,
       $borrower->{'borrowernumber'},$amountowing,$borrower,$odues);
       Cdk::refreshCdkScreen();
    }
  } elsif ($funct == 0 ) {
    if ($borrower->{'borrowernumber'} ne "") {
       C4::Accounts::reconcileaccount($env,$dbh,$borrower->{'borrowernumber'},
       $amountowing,$borrower,$odues);
       Cdk::refreshCdkScreen();
    }
  } 
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


