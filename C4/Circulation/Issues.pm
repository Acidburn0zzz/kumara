package C4::Circulation; #asummes C4/Circulation/Issues

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;
use C4::Interface;
use C4::Circulation;
use C4::Circulation::Borrower;
use C4::Scan;
use C4::Stats;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use Newt qw();
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&Issue);
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
    clearscreen();
    my ($bornum,$issuesallowed,$borrower,$reason) = &findborrower($env,$dbh);
    #deal with alternative loans
    #now check items 
    clearscreen();
    my ($items,$items2)=pastitems($env,$bornum,$dbh); #from Circulation.pm
    my $done = "No";
    my $row2=5;
    my $it2p=0;
    while ($done eq 'No'){
      ($done,$items2,$row2,$it2p) =&processitems($env,$bornum,$borrower,$items,$items2,$row2,$it2p);
    }    
    $dbh->disconnect;  
    if ($done ne 'Circ'){
      Issue($env);
    }
    if ($done ne 'Quit'){
      return($done);
    }
}    


sub processitems {
  #process a users items
#  clearscreen();
#  output(1,1,"Processing Items");
   helptext("F11 Ends processing for current borrower  F10 ends issues");
   my ($env,$bornum,$borrower,$items,$items2,$row2,$it2p)=@_;
   my $dbh=&C4Connect;  
   my $row=5;
#  my $count=$$items;
   my $i=0;
   my $amountdue = 0;
   my ($itemnum,$reason) = issuewindow($env,'Issues',$items,$items2,$borrower,
      fmtdec($env,$amountdue,"$32"));
   if ($itemnum ne ""){
      my ($item,$charge) = &issueitem($env,$dbh,$itemnum,$bornum,$items);
      if ($item) {
        $items2->[$it2p] = 
    	(fmtstr($env,$item->{'title'},"L30")." ".fmtdec($env,$charge,"22")); 	
        $row2++;	     
	$it2p++;
	$amountdue += $charge;
      }  
   }
   $dbh->disconnect;
   #check to see if more books to process for this user
   if ($reason eq 'Finished user'){
      return('New borrower');
   } else {
      if ($reason ne 'Finished issues'){
         #return No to let them know that we wish to process more Items for borrower
         return('No',$items2,$row2,$it2p);
      } else  {
         return('Circ');
      }
   }
}

sub issueitem{
   my ($env,$dbh,$itemnum,$bornum,$items)=@_;
   $itemnum=uc $itemnum;
   my $canissue = 1;
   ##  my ($itemnum,$reason)=&scanbook();
   my $query="Select * from items,biblio where (barcode='$itemnum') and
      (items.biblionumber=biblio.biblionumber)";
   my $item;
   my $charge;
   my $sth=$dbh->prepare($query);  
   $sth->execute;
   if ($item=$sth->fetchrow_hashref) {
     $sth->finish;
     #check if item is restricted
     if ($item->{'restricted'} == 1 ){
      error_msg($env,"Restricted Item");
      #output(20,1,"whoop whoop restricted");
      #check borrowers status to take out restricted items
      # if borrower allowed {
      #  $canissue = 1
      # } else {
      #  $canissue = 0
      # }
     } else {
       #check if item is on issue already
       my $currbor = &previousissue($env,$item->{'itemnumber'},$dbh,$bornum);
       #check reserve
       debug_msg($env,"before check reserve");
       my $resbor = &checkreserve($env,$dbh,$item->{'itemnumber'});    
       debug_msg($env,"after check reserve");
       #if charge deal with it
     }   
     if ($canissue == 1) {
       $charge = calc_charges($env,$dbh,$item->{'itemnumber'},$bornum);
              debug_msg($env,"after charge");
     }
     if ($canissue == 1) {
       #now mark as issued
       &updateissues($env,$item->{'itemnumber'},$item->{'biblioitemnumber'},$dbh,$bornum)
       &UpdateStats($env,$env->{'branchcode'},'issue');
     }
   } else {
     error_msg($env,"$itemnum not found - rescan");
   }  
   return($item,$charge);
}

sub updateissues{
  # issue the book
  my ($env,$itemno,$bitno,$dbh,$bornum)=@_;
  my $loanlength=21;
  debug_msg($env,"loan length");
  my $query="Select *  from biblioitems,itemtypes
  where (biblioitems.biblioitemnumber='$bitno') 
  and (biblioitems.itemtype = itemtypes.itemtype)";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  if (my $data=$sth->fetchrow_hashref) {
    $loanlength = $data->{'loanlength'}
  }
  $sth->finish;
  debug_msg($env,"issue");
  my $datedue = time + $loanlength;
  my @datearr = localtime($datedue);
  my $dateduef = (1900+$datearr[5])."-".$datearr[4]."-".$datearr[3];
  $query = "Insert into issues (borrowernumber,itemnumber, date_due,branchcode)
  values
  ($bornum,$itemno,'$dateduef','$env->{'branchcode'}')";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
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
        and (borrower.categorycode = categories.categorycode)
        and (categoryitem.itemtype = '$item_type')";
     my $sth2=$dbh->prepare($q2);
     $sth2->execute;
     if (my $data2=$sth2->fetchrow_hashref) {
        my $discount = $data2->{'rentaldiscount'};
	$charge = ($charge * $discount) / 100;
     }
     $sth2->{'finish'};
  }   
  $sth1->{'finish'};
  return ($charge);
}

END { }       # module clean-up code here (global destructor)
