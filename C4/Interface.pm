package C4::Interface; #asummes C4/Interface

#uses Newt
use C4::Format;
use strict;
#use Newt qw(:keys :exits :anchors :flags :colorsets :entry :fd :grid :macros
#:textbox);

use Newt qw(NEWT_ANCHOR_LEFT NEWT_FLAG_SCROLL 
NEWT_KEY_F1 NEWT_KEY_F2 NEWT_KEY_F3
NEWT_KEY_F4 NEWT_KEY_F5 NEWT_KEY_F6 
NEWT_KEY_F7 NEWT_KEY_F8 NEWT_KEY_F9
NEWT_KEY_F10 NEWT_KEY_F11 NEWT_KEY_F12
NEWT_FLAG_RETURNEXIT NEWT_EXIT_HOTKEY NEWT_FLAG_WRAP NEWT_FLAG_MULTIPLE 
NEWT_FLAG_HIDDEN NEWT_ANCHOR_TOP NEWT_ANCHOR_RIGHT NEWT_FLAG_BORDER );
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&dialog &startint &endint &output &clearscreen &pause &helptext
&textbox &menu &issuewindow &msg_yn &borrower_dialog &debug_msg &error_msg
&selborrower &returnwindow &logondialog &borrowerwindow &titlepanel);
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
  Newt::SetSuspendCallback(\&suspend_cb);
  my ($env,$msg)=@_;
  Newt::Init();
  Newt::Cls();
  #Newt::PushHelpLine('F11 QUIT');
  #Newt::PushHelpLine('F2 Issues');
  #Newt::PushHelpLine('F3 Returns');   
  Newt::DrawRootText(0,0,$msg);
}

sub menu {
  my ($type,$title,@items)=@_;
  if ($type eq 'console'){
    my ($reason,$data)=menu2($title,@items); 
    return($reason,$data);
    # end of menu
  } 
}

sub menu2 {
  my ($title,@items)=@_;
  my $numitems=@items;
  my $panel = Newt::Panel(1, $numitems+1, $title);
  my @buttons;
  my $i=0;
  while ($i < $numitems) {
    $buttons[$i] =  Newt::Button(fmtstr("",@items[$i],"C20"),1);
    $buttons[$i]->Tag(@items[$i]);
    $panel->Add(0,$i,$buttons[$i]);
    $i++;
  }
  Newt::PushHelpLine('F11 QUIT:  F2 Issues:  F3 Returns:  F4 Reserves');
  $panel->AddHotKey(NEWT_KEY_F2);
  $panel->AddHotKey(NEWT_KEY_F3);
  $panel->AddHotKey(NEWT_KEY_F4);
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F12);
  my ($reason,$data)=$panel->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {
    #debug_msg("","hot ");
    if ($data eq NEWT_KEY_F11) {
       $stuff="Quit";
    } elsif ($data eq NEWT_KEY_F3) {
       $stuff="Returns";
    } elsif ($data eq NEWT_KEY_F2) {
       $stuff="Issues";	      
    } elsif ($data eq NEWT_KEY_F4) {
       $stuff="Reserves";
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
  Newt::Refresh() ;
}

sub helptext {
  my ($text)=@_;
  Newt::PushHelpLine($text);
}

#sub list {
#  my ($title,@items)=@_;
#  my $numitems=@items;
#  my $panel = Newt::Panel(1, 4, $title);
#  my $li = Newt::Listbox($numitems,NEWT_FLAG_RETURNEXIT |  NEWT_FLAG_MULTIPLE);
#  $li->Add(@items);
#  $panel->Add(0,0,$li,NEWT_ANCHOR_TOP);
#  $panel->AddHotKey(NEWT_KEY_F11);
#  my ($reason,$data)=$panel->Run();
#  my @stuff=$li->Get();
#  $data=$stuff[0];
#  return($reason,$data);
  # end of list
#}

sub titlepanel{
  my ($env,$title,$title2)=@_;
  my $header = fmtstr($env,$title,"L30").fmtstr($env,$title2,"R30");
  my $panel = Newt::Panel(1,1,$header);
  my $padding = Newt::Label(" "x76);
  $panel->Add(0,0,$padding);
  $panel->Move(1,1);
  $panel->Draw();
  Newt::Refresh();
  }

sub selborrower {
  my ($env,$dbh,$borrows,$bornums)=@_;
  my $panel = Newt::Panel(1, 4, "Select Borrower");
  my $numbors = @$borrows;
  if ($numbors>15) {
    $numbors = 15;
  }
  my $li = Newt::Listbox($numbors, NEWT_FLAG_MULTIPLE | NEWT_FLAG_RETURNEXIT);
  $li->Add(@$borrows);
  my $bdata;
#  my $butt = Newt::Button("Okay");
  $panel->Add(0,0,$li,NEWT_ANCHOR_TOP);
#  $panel->Add(0,1,$butt,NEWT_ANCHOR_TOP);
  $panel->AddHotKey(NEWT_KEY_F11);
  my ($reason,$data)=$panel->Run();
  my @stuff=$li->Get();
  #debug_msg("",@stuff[0]);
  my $data=(0,9,$stuff[0]);
  my $borrnum = substr($data,0,9);
  return($borrnum);
  # end of selborrower
}

sub returnwindow {
  my ($env,$title,$item,$items,$borrower,$amountowing)=@_;
  my $panel    = Newt::Panel(1,4,$title);
  my $panel2   = Newt::Panel(3,2,"");
  my $entry    = Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $accchk   = Newt::Checkbox("Accumulate", " ", " NY");
  my $la1      = Newt::Label("Total Amount");
  my $fee      = Newt::Label(fmtdec($env,$amountowing,"$32"));
  my $l1       = Newt::Label("Returned"); 
  my $li1      = Newt::Listbox(13,NEWT_FLAG_SCROLL | NEWT_FLAG_BORDER);
  my $i = 0;
  while ($items->[$i]) {
    $li1->Add($items->[$i]);
    $i++;
  }
  $panel2->Add(0,0,$entry,NEWT_ANCHOR_LEFT);
  $panel2->Add(1,0,$accchk,NEWT_ANCHOR_LEFT);
  $panel2->Add(2,0,$la1,NEWT_ANCHOR_RIGHT);
  $panel2->Add(2,1,$fee,NEWT_ANCHOR_RIGHT);
  $panel->Add(0,0,$panel2,NEWT_ANCHOR_LEFT);
  $panel->Add(0,1,$l1,NEWT_ANCHOR_LEFT);
  $panel->Add(0,2,$li1,NEWT_ANCHOR_LEFT);
  Newt::PushHelpLine('F11 QUIT F10 Menu F2 Issues F3 Returns');
  $panel->AddHotKey(NEWT_KEY_F2);
  $panel->AddHotKey(NEWT_KEY_F3);
  $panel->AddHotKey(NEWT_KEY_F10);
  $panel->AddHotKey(NEWT_KEY_F11);
  my ($reason,$data)=$panel->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {
    # debug_msg($env, "Hotkey");
    if ($data eq NEWT_KEY_F11){
       $reason="Quit";
     } elsif ($data eq NEWT_KEY_F10) {
       $reason="Circ";
     } elsif ($data eq NEWT_KEY_F2) {
      $reason="Issues";
     } elsif ($data eq NEWT_KEY_F3) {
       $reason="Returns";
     }
  } else {
    # debug_msg($env, "Not Hot");  
    $stuff=$entry->Get();
    $reason="";
  }
  #debug_msg($env, "reas $reason");
  #debug_msg($env, "stuff $stuff");  
  return($reason,$stuff);
}

sub borrowerwindow {
  my ($env,$borrower)=@_;
  my $bt1=Newt::Button("Modify Borrower");
  $bt1->Tag("Modify");
  my $bt2=Newt::Button("New borrower");
  $bt2->Tag("New");
  my $label=Newt::Label("Borrower");
  my $l1=Newt::Label("$borrower->{'firstname'} $borrower->{'surname'}");
  my $l2=Newt::Label("Street Address: $borrower->{'streetaddress'}");
  my $l3=Newt::Label("Suburb: $borrower->{'suburb'}");
  my $l4=Newt::Label("City: $borrower->{'city'}");
  my $l5=Newt::Label("Email: $borrower->{'email'}");
  my $l6=Newt::Label("No Adress: $borrower->{'gonenoaddress'}");
  my $l7=Newt::Label("Lost Card: $borrower->{'lost'}");
  my $l8=Newt::Label("Debarred: $borrower->{'debarred'}");
  my $panel=Newt::Panel(10,10,'Borrower');
  $panel->Add(0,0,$label);
  $panel->Add(0,1,$l1);
  $panel->Add(0,2,$l2);
  $panel->Add(0,3,$l3);
  $panel->Add(0,4,$l4);
  $panel->Add(0,5,$l5);
  $panel->Add(0,6,$l6);
  $panel->Add(0,7,$l7);
  $panel->Add(0,8,$l8);
  $panel->Add(0,9,$bt1);
  $panel->Add(1,9,$bt2);  
  my ($reason,$data)=$panel->Run();
  $stuff=$data->Tag();
# debug_msg("",$stuff);
  return($reason,$stuff);
}  
  
sub issuewindow {
  my ($env,$title,$items1,$items2,$borrower,$amountowing)=@_;
  my $entry=Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label("Book");
  my $panel = Newt::Panel(10,10, $title);
  my $panel1 = Newt::Panel(10,10);
  my $panel2 = Newt::Panel(10,10);
  $panel->Add(0,0,$panel1);
  $panel->Add(0,1,$panel2);
  
  my $l1  = Newt::Label("Previous");
  my $l2  = Newt::Label("Current");
  my $l3  = Newt::Label("Borrower Info");
  my $l4  = Newt::Label("Total Due");
  my $amt = Newt::Label($amountowing);
  my $b0  = Newt::Label("$borrower->{'cardnumber'}");
  my $b1  = Newt::Label("$borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'} ");
  my $b2  = Newt::Label("$borrower->{'streetaddres'}");
  my $b3  = Newt::Label("$borrower->{'city'}");
  # my $li1 = Newt::Listbox(10,NEWT_FLAG_SCROLL | NEWT_FLAG_BORDER );
  # my $li2 = Newt::Listbox(10,NEWT_FLAG_SCROLL | NEWT_FLAG_BORDER );
  my $li1 = Newt::Listbox(5,NEWT_FLAG_SCROLL );
  my $li2 = Newt::Listbox(5,NEWT_FLAG_SCROLL );
  #my $li3 = Newt::Listbox(5, NEWT_FLAG_RETURNEXIT | NEWT_FLAG_MULTIPLE);
  my $i = 0;
  while ($items1->[$i]) {
    $li1->Add($items1->[$i]);
    $i++;
  }
  $i = 0;
  while ($items2->[$i]) {
    #my $fitem = fmtstr("",$items2->[$i],"L29");
    my $fitem = fmtstr("",$items2->[$i],"L72");
    #$li2->Add($items2->[$i]); 
    $li2->Add($fitem);
    $i++;
  }  
  $panel->AddHotKey(NEWT_KEY_F11);
  $panel->AddHotKey(NEWT_KEY_F10);
  $panel->AddHotKey(NEWT_KEY_F8);
  $panel1->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel1->Add(0,0,$entry,NEWT_ANCHOR_LEFT,0,0,30);
  $panel1->Add(0,1,$l3,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,1,$l4,NEWT_ANCHOR_RIGHT);
#  $panel1->Add(1,2,$amt,NEWT_ANCHOR_RIGHT);
  $panel1->Add(0,2,$b0,NEWT_ANCHOR_LEFT);
  $panel1->Add(0,3,$b1,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,2,$amt,NEWT_ANCHOR_RIGHT);
  $panel1->Add(0,4,$b2,NEWT_ANCHOR_LEFT);
  $panel1->Add(0,5,$b3,NEWT_ANCHOR_LEFT);  
  $panel2->Add(0,0,$l2,NEWT_ANCHOR_LEFT);
  $panel2->Add(0,1,$li2,NEWT_ANCHOR_LEFT);  
  $panel2->Add(0,2,$l1,NEWT_ANCHOR_LEFT);
  $panel2->Add(0,3,$li1,NEWT_ANCHOR_LEFT);
  # $panel2->Add(0,6,$l1,NEWT_ANCHOR_LEFT);
  # $panel2->Add(0,7,$li1,NEWT_ANCHOR_LEFT);
  # $panel2->Add(1,6,$l2,NEWT_ANCHOR_RIGHT);
  # $panel2->Add(1,7,$li2,NEWT_ANCHOR_RIGHT);
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
    if ($data eq NEWT_KEY_F8){
      $reason="Print"
    }
    
  }
  debug_msg("",$reason);
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

sub logondialog {
   my ($env,$title,$branches)=@_;
   my $entry1=Newt::Entry(10,NEWT_FLAG_SCROLL  | NEWT_FLAG_RETURNEXIT);
   my $label1=Newt::Label("User Name");  
   my $label2=Newt::Label("Password");
   my $entry2=Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT | NEWT_FLAG_HIDDEN);       
   my $panel1=Newt::Panel(2,1,$title);
   my $panel2=Newt::Panel(1,5,''); 
   my $listbx=Newt::Listbox(12, NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT | NEWT_FLAG_MULTIPLE | NEWT_FLAG_BORDER );
   #my $listbx=Newt::Listbox(12, NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT |  NEWT_FLAG_BORDER );
   $panel1->AddHotKey(NEWT_KEY_F11);
   $panel1->AddHotKey(NEWT_KEY_F10);   
   $panel1->Add(0,0,$panel2,NEWT_ANCHOR_TOP); 
   $panel1->Add(1,0,$listbx,NEWT_ANCHOR_LEFT);   
   $panel2->Add(0,0,$label1,NEWT_ANCHOR_LEFT);
   $panel2->Add(0,1,$entry1,NEWT_ANCHOR_LEFT);
   $panel2->Add(0,2,$label2,NEWT_ANCHOR_LEFT);
   $panel2->Add(0,3,$entry2,NEWT_ANCHOR_LEFT);
   $listbx->Add(@$branches);	
   my ($reason,$data)=$panel1->Run();
   my ($username) = $entry1->Get();
   my ($password) = $entry2->Get();
   my @stuff  = $listbx->Get();
   #my $stuff = $listbx->Get();
   #my $branch=$stuff;
   my ($branch)   = $stuff[0];
   #debug_msg($branch);
   if ($reason eq NEWT_EXIT_HOTKEY) {
      if ($data eq NEWT_KEY_F11) {
	 $reason="Cancelled Input ";
      }
      if ($data eq NEWT_KEY_F12){
         $reason="Quit";
      }
   }
   return($reason,$username,$password,$branch);
}
									  
sub borrower_dialog {
  my ($env)=@_;
  my $name = "Borrower";
  my $entry=Newt::Entry(20,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label=Newt::Label($name);
  my $entry2=Newt::Entry(10,NEWT_FLAG_SCROLL | NEWT_FLAG_RETURNEXIT);
  my $label2=Newt::Label(" Book: ");
  my $panel1=Newt::Panel(4,4,$name,1,1);
  $panel1->AddHotKey(NEWT_KEY_F2);
  $panel1->AddHotKey(NEWT_KEY_F3);
  $panel1->AddHotKey(NEWT_KEY_F4); 
  $panel1->AddHotKey(NEWT_KEY_F11);
  $panel1->Add(0,0,$label,NEWT_ANCHOR_LEFT);
  $panel1->Add(1,0,$entry,NEWT_ANCHOR_LEFT);
  $panel1->Add(2,0,$label2,NEWT_ANCHOR_LEFT);
  $panel1->Add(3,0,$entry2,NEWT_ANCHOR_LEFT);
  Newt::PushHelpLine('F11 QUIT: F2 Issues: F3 Returns: F4 Reserves');
    
  my ($reason,$data)=$panel1->Run();
  if ($reason eq NEWT_EXIT_HOTKEY) {
    #debug_msg("","hot ");
    if ($data eq NEWT_KEY_F3) {
      $reason="Returns";
    } elsif ($data eq NEWT_KEY_F2) {
      $reason="Issues";
    } elsif ($data eq NEWT_KEY_F4) {
      $reason="Reserves";
    } elsif ($data eq NEWT_KEY_F11) {  
      $reason="Circ";         
    } elsif ($data eq NEWT_KEY_F12){
      $reason="Quit";
    }
  } else {
    $reason = "";
  }
  # debug_msg($env,"Re $reason");
  # Newt::Finished();
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
  my $panel1=Newt::Panel(1,2,"*** D E B U G ***");
  my $label1=Newt::Label($text);
  my $butt=Newt::Button("Okay",1);
  $panel1->Add(0,0,$label1,NEWT_ANCHOR_TOP);
  $panel1->Add(0,1,$butt,NEWT_ANCHOR_TOP);
  $panel1->Move(1,20);
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
  $panel1->DESTROY();
  return();
}

sub endint {
  Newt::Finished();
}
END { }       # module clean-up code here (global destructor)
