package C4::Circulation::Issues; #asummes C4/Circulation/Issues

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Circulation::Main;
use C4::Circulation::Borrower;
use C4::Scan;
use C4::Stats;
use C4::Print;
use C4::Format;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use Newt qw();
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&Issue &formatitem);
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


sub Issue  {
    my ($env) = @_;
    my $dbh=&C4Connect;
    #clear help
    helptext('');
    #clearscreen();
    my $done;
    my ($items,$items2,$amountdue);
    $env->{'sysarea'} = "Issues";
    $done = "Issues";
    while ($done eq "Issues") {
      my ($bornum,$issuesallowed,$borrower,$reason) = &findborrower($env,$dbh);
      #C4::Circulation::Borrowers
      if ($reason ne "") {
        $done = $reason;
      } else {
        $env->{'bornum'} = $bornum;
        $env->{'bcard'}  = $borrower->{'cardnumber'};
	#deal with alternative loans
        #now check items 
        ($items,$items2)=
	  C4::Circulation::Main::pastitems($env,$bornum,$dbh); #from Circulation.pm
        $done = "No";
        my $it2p=0;
        while ($done eq 'No'){
          ($done,$items2,$it2p) =
             &processitems($env,$bornum,$borrower,$items,
	     $items2,$it2p,$amountdue);
        }    
        #debug_msg("","after processitems done = $done");
      }
      #debug_msg($env,"after borrd $done");
    }   
    $dbh->disconnect;
    return ($done);
}    


sub processitems {
  #process a users items
   my ($env,$bornum,$borrower,$items,$items2,$it2p,$amountdue)=@_;
   my $dbh=&C4Connect;  
#  my $amountdue = 0;  
   my ($itemnum,$reason) = 
     issuewindow($env,'Issues',$items,$items2,$borrower,fmtdec($env,$amountdue,"32"));
   if ($itemnum ne ""){
      my ($item,$charge,$datedue) = &issueitem($env,$dbh,$itemnum,$bornum,$items);
      if ($datedue ne "") {
         my $line = formatitem($env,$item,$datedue,$charge);
	 #$datedue." ".$item->{'title'}.", ".$item->{'author'};
	 #my $iclass =  $item->{'itemtype'};
	 #if ($item->{'dewey'} > 0) {
	 #  $iclass = $iclass.$item->{'dewey'}.$item->{'subclass'};
	 #};
	 #my $llen = 65 - length($iclass);
	 #my $line = fmtstr($env,$line,"L".$llen);
	 #my $line = $line." $iclass ";
         #my $line = $line.fmtdec($env,$charge,"22"); 		  
         #$items2->[$it2p] = $datedue." ".
         #  fmtstr($env,$item->{'title'},"L55")." ".fmtdec($env,$charge,"22");
         $items2->[$it2p] = $line;
	 $it2p++;
         $amountdue += $charge;
      }  
   }
   $dbh->disconnect;
   #check to see if more books to process for this user
   my @done;
   if ($reason eq 'Finished user'){
      remoteprint($env,$items2,$borrower);
      @done = ("Issues");
   } elsif ($reason eq "Print"){
      remoteprint($env,$items2,$borrower);
      @done = ("No",$items2,$it2p);
   } else {
      if ($reason ne 'Finished issues'){
         #return No to let them know that we wish to process more Items for borrower
         @done = ("No",$items2,$it2p);
      } else  {
         @done = ("Circ");
      }
   }
   #debug_msg($env, "return from issues $done[0]"); 
   return @done;
}

sub formatitem {
   my ($env,$item,$datedue,$charge) = @_;
   my $line = $datedue." ".$item->{'title'}.", ".$item->{'author'};
   my $iclass =  $item->{'itemtype'};
   if ($item->{'dewey'} > 0) {
     $iclass = $iclass.$item->{'dewey'}.$item->{'subclass'};
   };
   my $llen = 65 - length($iclass);
   my $line = fmtstr($env,$line,"L".$llen);
   my $line = $line." $iclass ";
   my $line = $line.fmtdec($env,$charge,"22");
   return $line;
}   
	 
sub issueitem{
   my ($env,$dbh,$itemnum,$bornum,$items)=@_;
   $itemnum=uc $itemnum;
   my $canissue = 1;
   ##  my ($itemnum,$reason)=&scanbook();
   my $query="Select * from items,biblio,biblioitems where (barcode='$itemnum') and
      (items.biblionumber=biblio.biblionumber) and
      (items.biblioitemnumber=biblioitems.biblioitemnumber) ";
   my $item;
   my $charge;
   my $datedue;
   my $sth=$dbh->prepare($query);  
   $sth->execute;
   if ($item=$sth->fetchrow_hashref) {
     $sth->finish;
     #check if item is restricted
     if ($item->{'restricted'} == 1 ){
       error_msg($env,"Restricted Item");
       #check borrowers status to take out restricted items
       # if borrower allowed {
       #  $canissue = 1
       # } else {
       #  $canissue = 0
       # }
     } 
     #check if item is on issue already
     if ($canissue == 1) {
       my $currbor = &C4::Circulation::Main::previousissue($env,$item->{'itemnumber'},$dbh,$bornum);
       if ($currbor ne "") {$canissue = 0;};
     } 
     if ($canissue == 1) {
       #check reserve
       my $resbor;
       $resbor = &C4::Circulation::Main::checkreserve($env,$dbh,$item->{'itemnumber'});    
       if ($resbor ne "") {$canissue = 0;};
     }
     #if charge deal with it
        
     if ($canissue == 1) {
       $charge = calc_charges($env,$dbh,$item->{'itemnumber'},$bornum);
     }
     if ($canissue == 1) {
       #now mark as issued
       $datedue=&updateissues($env,$item->{'itemnumber'},$item->{'biblioitemnumber'},$dbh,$bornum);        
       #debug_msg("","date $datedue");
       &UpdateStats($env,$env->{'branchcode'},'issue');
     } else {
       debug_msg($env,"can't issue");
     }  
   } else {
     error_msg($env,"$itemnum not found - rescan");
   }
   $sth->finish;
   debug_msg($env,"date $datedue");
   return($item,$charge,$datedue);
}

sub updateissues{
  # issue the book
  my ($env,$itemno,$bitno,$dbh,$bornum)=@_;
  my $loanlength=21;
  my $query="Select *  from biblioitems,itemtypes
  where (biblioitems.biblioitemnumber='$bitno') 
  and (biblioitems.itemtype = itemtypes.itemtype)";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  if (my $data=$sth->fetchrow_hashref) {
    $loanlength = $data->{'loanlength'}
  }
  $sth->finish;
  my $ti = time;
  my $datedue = time + ($loanlength * 86400);
  my @datearr = localtime($datedue);
  my $dateduef = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  $query = "Insert into issues (borrowernumber,itemnumber, date_due,branchcode)
  values ($bornum,$itemno,'$dateduef','$env->{'branchcode'}')";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($datedue);
  my $dateret=$datearr[3]."-".($datearr[4]+1)."-".(1900+$datearr[5]);
  debug_msg($env,"returning $dateret");
  return($dateret);
}

sub calc_charges {
  # calculate charges due
  my ($env, $dbh, $itemno, $bornum)=@_;
  my $charge=0;
  my $item_type;
  my $q1 = "select itemtypes.itemtype,rentalcharge from items,biblioitems,itemtypes
    where (items.itemnumber ='$itemno')
    and (biblioitems.biblioitemnumber = items.biblioitemnumber)
    and (biblioitems.itemtype = itemtypes.itemtype)";
  my $sth1= $dbh->prepare($q1);
  $sth1->execute;
  if (my $data1=$sth1->fetchrow_hashref) {
     $item_type = $data1->{'itemtype'};
     $charge = $data1->{'rentalcharge'};
     my $q2 = "select rentaldiscount from borrowers,categoryitem 
        where (borrowers.borrowernumber = '$bornum') 
        and (borrowers.categorycode = categoryitem.categorycode)
        and (categoryitem.itemtype = '$item_type')";
     my $sth2=$dbh->prepare($q2);
     $sth2->execute;
     if (my $data2=$sth2->fetchrow_hashref) {
        my $discount = $data2->{'rentaldiscount'};
	$charge = ($charge *(100 - $discount)) / 100;
     }
     $sth2->{'finish'};
  }   
  $sth1->finish;
  return ($charge);
}

END { }       # module clean-up code here (global destructor)
