package C4::Interface; #asummes C4/Interface

#uses Newt

use strict;
#use Newt qw(:keys :exits :anchors :flags :colorsets :entry :fd :grid :macros
#:textbox);

use Newt qw(NEWT_ANCHOR_LEFT NEWT_FLAG_SCROLL NEWT_KEY_F11 NEWT_KEY_F10
NEWT_KEY_F1 NEWT_KEY_F2 NEWT_KEY_F4 NEWT_KEY_F5 NEWT_KEY_F9 NEWT_KEY_F12
NEWT_FLAG_RETURNEXIT NEWT_EXIT_HOTKEY NEWT_FLAG_WRAP NEWT_FLAG_MULTIPLE 
NEWT_ANCHOR_TOP NEWT_ANCHOR_RIGHT NEWT_FLAG_BORDER);
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&dialog &startint &endint &output &clearscreen &pause &helptext
&textbox &menu &issuewindow &msg_yn &borrower_dialog &debug_msg &error_msg
&selborrower &fmtstr &fmtdec &returnwindow);
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
sub suspend_cb {
  Newt::Suspend();
  kill STOP => $$;
  Newt::Resume();
}
      
sub startint {
  Newt::SetSuspendCallback(\&suspend_cb,'t');
  my ($env,$msg)=@_;
  Newt::Init();
  Newt::Cls();
  Newt::PushHelpLine('F11 escapes');
  Newt::DrawRootText(0,0,$msg);
}

sub menu {
  my ($type,$title,@items)=@_;
  if ($type eq 'console'){
#  my ($reason,$data)=list($title,@items);
  my ($reason,$data)=menu2($title,@items);
 
  return($reason,$data);
  # end of menu
  } 
}

sub menu2 {
  my ($title,@items)=@_;
  my $numitems=@items;
  my $panel = Newt::Panel(1, 4, $title);
  my $b0 = Newt::Button(fmtstr("",@items[0],"C30"));
  my $b1 = Newt::Button(fmtstr("",@items[1],"C30"));
  my $b2 = Newt::Button(fmtstr("",@items[2],"C30"));
  $b0->Tag(@items[0]);
  $b1->Tag(@items[1]);
  $b2->Tag(@items[2]);
       
  $panel->Add(0,0,$b0);
  $panel->Add(0,1,$b1);
  $panel->Add(0,2,$b2);
  $panel->AddHotKey(NEWT_KEY_F11);
  my ($reason,$data)=$panel->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {
    if ($data eq NEWT_KEY_F11) {
       $stuff="Quit";
    }
  } else {
    $stuff = $data->Tag();  
  }
  return($reason,$stuff);
  # end of menu2
}
  
sub clearscreen{
  Newt::Cls();
}

sub pause {
  Newt::WaitForKey();
}


sub output {
  my($left,$top,$msg)=@_;
  Newt::DrawRootText($left,$top,$msg);
}

sub textbox {
  my ($width,$height,$text,$title,$top,$left)=@_;
  my $panel = Newt::Panel(70, 4, "$title",$top,$left);
  my $box = Newt::Textbox($width,$height, NEWT_FLAG_SCROLL |
  NEWT_FLAG_RETURNEXIT | NEWT_FLAG_WRAP,$text);
  $panel->Add(0,0,$box,NEWT_ANCHOR_LEFT);
  $panel->AddHotKey(NEWT_KEY_F11);
  my ($reason,$data)=$panel->Draw();
}

sub helptext {
  my ($text)=@_;
  Newt::PushHelpLine($text);
}

sub list {
  my ($title,@items)=@_;
  my $numitems=@items;
  my $panel = Newt::Panel(1, 4, $title);
  my $li = Newt::Listbox($numitems,NEWT_FLAG_RETURNEXIT |  NEWT_FLAG_MULTIPLE);
  $li->Add(@items);
  $panel->Add(0,0,$li,NEWT_ANCHOR_TOP);
  $panel->AddHotKey(NEWT_KEY_F11);
  my ($reason,$data)=$panel->Run();
#  if ($reason eq NEWT_EXIT_HOTKEY) {   
#    if ($data eq NEWT_KEY_F11) {  
#        $reason="Quit";         
#    } my $numitems=@items;
  my @stuff=$li->Get();
  $data=$stuff[0];
  return($reason,$data);
  # end of list
}


sub selborrower {
  my ($env,$dbh,@borrows,@bornums)=@_;
  my $panel = Newt::Panel(1, 4, "Select Borrower");
  my $numbors = @borrows;
  if ($numbors>15) {
    $numbors = 15;
  }
  my $li = Newt::Listbox($numbors, NEWT_FLAG_MULTIPLE );
  $li->Add(@borrows);
  my $bdata;
  my $butt = Newt::Button("Okay");
  $panel->Add(0,0,$li,NEWT_ANCHOR_TOP);
  $panel->Add(0,1,$butt,NEWT_ANCHOR_TOP);
  $panel->AddHotKey(NEWT_KEY_F11);
  my ($reason,$data)=$panel->Run();
  my @stuff=$li->Get();
  debug_msg("",@stuff[0]);
  my $data=$stuff[0];
  if ($data ne "") {
     my $bornum = substr($data,0,9);
     my $query = "select * from borrowers where cardnumber = '$bornum'";
     my $sth = $dbh->prepare($query);
     $sth->execute;
     if ($bdata =$sth->fetchrow_hashref) {
       $data = $bdata->{'borrowernumber'}; 
     }
  }   
  return($data,$bdata);
  # end of selborrower
}

sub returnwindow {
  my ($env,$title,$item,$items,$borrower,$amountowing)=@_;
  my $panel    = Newt::Panel(5,10,$title);
  my $entry    = Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $accchk   = Newt::Checkbox("Accumulate", " ", " NY");
  my $la1      = Newt::Label("Total Amount");
  my $fee      = Newt::Label(fmtdec($env,$amountowing,"$32"));
  my $l1       = Newt::Label("Returned"); 
  my $li1      = Newt::Listbox(15,NEWT_FLAG_SCROLL | NEWT_FLAG_BORDER);
  my $i = 0;
  while ($items->[$i]) {
    $li1->Add($items->[$i]);
    $i++;
  }
  $panel->Add(0,0,$entry,NEWT_ANCHOR_TOP);
  $panel->Add(0,1,$accchk,NEWT_ANCHOR_TOP);
  $panel->Add(1,0,$la1);
  $panel->Add(2,0,$fee);
  $panel->Add(1,1,$l1);
  $panel->Add(2,1,$li1);
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F10);
  my ($reason,$data)=$panel->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {
    if ($data eq NEWT_KEY_F11) {
      $reason="Circ";
    }
    if ($data eq NEWT_KEY_F12){
      $reason="Quit"
    }
  }
  my $stuff=$entry->Get();
  return($reason,$stuff);
}
  
  
sub issuewindow {
  my ($env,$title,$items1,$items2,$borrower,$amountowing)=@_;
  my $entry=Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label("Book");
  my $panel = Newt::Panel(50,25, $title,5,5);
  my $l1  = Newt::Label("Previous");
  my $l2  = Newt::Label("Current");
  my $l3  = Newt::Label("Borrower Info");
  my $l4  = Newt::Label("Total Due");
  my $amt = Newt::Label($amountowing);
  my $b1  = Newt::Label("$borrower->{title} $borrower->{'firstname'}");
  my $b2  = Newt::Label("$borrower->{'streetaddres'}");
  my $b3  = Newt::Label("$borrower->{'city'}");
  my $li1 = Newt::Listbox(15,NEWT_FLAG_SCROLL | NEWT_FLAG_BORDER );
  my $li2 = Newt::Listbox(15,NEWT_FLAG_SCROLL | NEWT_FLAG_BORDER );
  #my $li3 = Newt::Listbox(5, NEWT_FLAG_RETURNEXIT | NEWT_FLAG_MULTIPLE);
  my $i = 0;
  while ($items1->[$i]) {
    $li1->Add($items1->[$i]);
    $i++;
  }
  $i = 0;
  while ($items2->[$i]) {
    $li2->Add($items2->[$i]); 
    $i++;
  }  
  # $li3->Add("$borrower->{title} $borrower->{'firstname'}","$borrower->{'streetaddres'}",
  # "$borrower->{'city'}");
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F10);
  $panel->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel->Add(0,0,$entry,NEWT_ANCHOR_LEFT,0,0,45);
  $panel->Add(0,1,$l3,NEWT_ANCHOR_LEFT);
  $panel->Add(1,1,$l4,NEWT_ANCHOR_RIGHT);
  $panel->Add(1,2,$amt,NEWT_ANCHOR_RIGHT);
  $panel->Add(0,2,$b1,NEWT_ANCHOR_LEFT);
  $panel->Add(1,2,$amt,NEWT_ANCHOR_RIGHT);
  $panel->Add(0,3,$b2,NEWT_ANCHOR_LEFT);
  $panel->Add(0,4,$b3,NEWT_ANCHOR_LEFT);  
  $panel->Add(0,5,$l1,NEWT_ANCHOR_LEFT);
  $panel->Add(0,6,$li1,NEWT_ANCHOR_LEFT);  
  $panel->Add(1,5,$l2,NEWT_ANCHOR_RIGHT);
  $panel->Add(1,6,$li2,NEWT_ANCHOR_RIGHT);  
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
  }
#  Newt::Finished();
  my $stuff=$entry->Get();
  return($stuff,$reason);
}


sub dialog {
  my ($name)=@_;
  my $entry=Newt::Entry(20,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label($name);
  my $panel1=Newt::Panel(2,4,$name);
  $panel1->AddHotKey(NEWT_KEY_F11);
  $panel1->AddHotKey(NEWT_KEY_F10);
  $panel1->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,0,$entry,NEWT_ANCHOR_LEFT);
  my ($reason,$data)=$panel1->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {   
    if ($data eq NEWT_KEY_F11) {  
        $reason="Finished user";         
    }
    if ($data eq NEWT_KEY_F10) {  
        $reason="Finished issues";         
    }
    if ($data eq NEWT_KEY_F12){
      $reason="Quit";
    }
  }
#  Newt::Finished();
  my $stuff=$entry->Get();
  return($stuff,$reason);
}


sub borrower_dialog {
  my ($env)=@_;
  my $name = "Borrower";
  my $entry=Newt::Entry(20,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label($name);
  my $entry2=Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label2=Newt::Label(" Book: ");
  my $panel1=Newt::Panel(4,4,$name,1,1);
  $panel1->AddHotKey(NEWT_KEY_F11);
  $panel1->AddHotKey(NEWT_KEY_F10);  
  $panel1->AddHotKey(NEWT_KEY_F9);
  $panel1->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,0,$entry,NEWT_ANCHOR_LEFT);
  $panel1->Add(2,0,$label2,NEWT_ANCHOR_LEFT);
  $panel1->Add(3,0,$entry2,NEWT_ANCHOR_LEFT);
  my ($reason,$data)=$panel1->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {   
    if ($data eq NEWT_KEY_F11) {  
      $reason="Circ";         
    }
    if ($data eq NEWT_KEY_F10) {  
      $reason="Finished issues";         
    }
    if ($data eq NEWT_KEY_F12){
      $reason="Quit";
    }
    if ($data eq NEWT_KEY_F9) {
    }
  }
#  Newt::Finished();
  my $stuff=$entry->Get();
  my $stuff2=$entry2->Get();
  return($stuff,$reason,$stuff2);
}

sub msg_yn {
  my ($text1,$text2)=@_;
  Newt::Bell();
  my $panel1=Newt::Panel(4,4,"");
  my $label1=Newt::Label($text1);
  my $label2=Newt::Label($text2);
  my $bpanel=Newt::Panel(2,4,"");
  my $ybutt=Newt::Button("Yes");
  my $nbutt=Newt::Button("No");
  $ybutt->Tag("Y");
  $nbutt->Tag("N");
  $bpanel->Add(0,0,$ybutt,NEWT_ANCHOR_LEFT);
  $bpanel->Add(1,0,$nbutt,NEWT_ANCHOR_RIGHT);
  $panel1->Add(0,0,$label1,NEWT_ANCHOR_TOP);
  $panel1->Add(0,1,$label2,NEWT_ANCHOR_TOP);
  $panel1->Add(0,2,$bpanel,NEWT_ANCHOR_TOP);
  my ($reason,$data) =$panel1->Run();
  my $ans = $data->Tag();
  return($ans);
}


sub debug_msg {
  my ($env,$text)=@_;
  my $panel1=Newt::Panel(4,4,"*** D E B U G ***");
  my $label1=Newt::Label($text);
  my $butt=Newt::Button("Okay");
  $panel1->Add(0,0,$label1,NEWT_ANCHOR_TOP);
  $panel1->Add(0,1,$butt,NEWT_ANCHOR_TOP);
  my ($reason,$data) =$panel1->Run();
  return();
}

sub error_msg {
  my ($env,$text)=@_;
  my $panel1=Newt::Panel(4,4,"!!ERROR!!");
  my $label1=Newt::Label($text);
  my $butt=Newt::Button("Okay");
  $panel1->Add(0,0,$label1,NEWT_ANCHOR_TOP);
  $panel1->Add(0,1,$butt,NEWT_ANCHOR_TOP);
  my ($reason,$data) =$panel1->Run();
  return();
}

sub fmtstr {
  # format (space pad) a string
  # $fmt is Ln.. or Rn.. where n is the length
  my ($env,$strg,$fmt)=@_;
  my $align = substr($fmt,0,1);
  my $lenst = substr($fmt,1,length($fmt)-1);
  if ($align eq"R" ) {
     $strg = substr((" "x$lenst).$strg,0-$lenst,$lenst);
  } elsif  ($align eq "C" ) {
     $strg = 
       substr((" "x(($lenst/2)-(length($strg)/2))).$strg.(" "x$lenst),0,$lenst);
  } else {
     $strg = substr($strg.(" "x$lenst),0,$lenst);
  } 
  return ($strg);
}

sub fmtdec {
  # format a decimal
  # $fmt is [$][,]n[m]
  my ($env,$numb,$fmt)=@_;
  my $curr = substr($fmt,0,1);
  if ($curr eq "\$") {
    $fmt = substr($fmt,1,length($fmt)-1);
  };
  my $comma = substr($fmt,0,1);
  if ($comma eq ",") {
    $fmt = substr($fmt,1,length($fmt)-1);
  };
  my $right;
  my $left = substr($fmt,0,1);
  if (length($fmt) == 1) {
    $right = 0;
  } else {
    $right = substr($fmt,1,1);
  }
  my $fnumb = "";
  my $tempint = "";
  my $tempdec = "";
  if (index($numb,".") == 0 ){
     $tempint = 0;
     $tempdec = substr($numb,1,length($numb)-1); 
  } else {
     if (index($numb,".") > 0) {
       my $decpl = index($numb,".");
       $tempint = substr($numb,0,$decpl);
       $tempdec = substr($numb,$decpl+1,length($numb)-1-$decpl);
     } else {
       $tempint = $numb;
       $tempdec = 0;
     }
     if ($comma eq ",") {
        while (length($tempdec) > 3) {
           $fnumb = ",".substr($tempint,-3,3).$fnumb;
	   substr($tempint,-3,3) = "";
	}
	$fnumb = substr($tempint,-3,3).$fnumb;
     }
  }
  if ($curr eq "\$") {
     $fnumb = fmtstr($env,$curr.$fnumb,"R".$left+1);
  } else {
     if ($left==0) {
        $fnumb = "";
     } else {
        $fnumb = fmtstr($env,$fnumb,"R".$left);
     }
  }   
  if ($right > 0) {
     $tempdec = $tempdec.("0"x$right);
     $tempdec = substr($tempdec,0,$right);
     $fnumb = $fnumb.".".$tempdec;
  }
  return ($fnumb);
}
 

sub endint {
  Newt::Finished();
}
END { }       # module clean-up code here (global destructor)
