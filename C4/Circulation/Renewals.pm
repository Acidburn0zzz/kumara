package C4::Circulation::Renewals; #assumes C4/Circulation/Renewals

#package to deal with Renewals
#written 7/11/99 by olwen@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Format;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Interface::RenewalsCDK;
use C4::Search;
use C4::Scan;
use C4::Stats;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&renewstatus &renewbook &bulkrenew);
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


sub Return  {
  
}    

sub renewstatus {
  # check renewal status
  my ($env,$dbh,$bornum,$itemno)=@_;
  my $renews = 1;
  my $renewokay = 0;
  my $q1 = "select * from issues 
    where (borrowernumber = '$bornum')
    and (itemnumber = '$itemno') 
    and returndate is null";
  my $sth1 = $dbh->prepare($q1);
  $sth1->execute;
  if (my $data1 = $sth1->fetchrow_hashref) {
    my $q2 = "select renewalsallowed from items,biblioitems,itemtypes
       where (items.itemnumber = '$itemno')
       and (items.biblioitemnumber = biblioitems.biblioitemnumber) 
       and (biblioitems.itemtype = itemtypes.itemtype)";
    my $sth2 = $dbh->prepare($q2);
    $sth2->execute;     
    if (my $data2=$sth2->fetchrow_hashref) {
      $renews = $data2->{'renewalsallowed'};
    }
    if ($renews > $data1->{'renewals'}) {
      $renewokay = 1;
    }
    $sth2->finish;
  }   
  $sth1->finish;
  #  my $amt_owing = calc_odues($env,$dbh,$bornum,$itemno);
  return($renewokay);    
}


sub renewbook {
  # mark book as renewed
  my ($env,$dbh,$bornum,$itemno,$datedue)=@_;
  if ($datedue eq "" ) {    
    #debug_msg($env, "getting date");
    my $loanlength=21;
    my $query= "Select * from biblioitems,items,itemtypes
       where (items.itemnumber = '$itemno')
       and (biblioitems.biblioitemnumber = items.biblioitemnumber)
       and (biblioitems.itemtype = itemtypes.itemtype)";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    if (my $data=$sth->fetchrow_hashref) {
      $loanlength = $data->{'loanlength'}
    }
    #C4::InterfaceCDK::debug_msg($env,$loanlength);
    $sth->finish;
    my $ti = time;
    my $datedu = time + ($loanlength * 86400);
    my @datearr = localtime($datedu);
    $datedue = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  }
  my $issquery = "select * from issues where borrowernumber='$bornum' and
    itemnumber='$itemno' and returndate is null";
  my $sth=$dbh->prepare($issquery);
  $sth->execute;
  my $issuedata=$sth->fetchrow_hashref;
  $sth->finish;
  my $renews = $issuedata->{'renewals'} +1;
  #debug_msg($env,"renewing $datedue");
  my $updquery = "update issues 
    set date_due = '$datedue', renewals = '$renews'
    where borrowernumber='$bornum' and
    itemnumber='$itemno' and returndate is null";
  my $sth=$dbh->prepare($updquery);
  $sth->execute;
  $sth->finish;
  return();
}

sub bulkrenew {
  my ($env,$dbh,$bornum,$amount,$borrower,$odues) = @_;
  my $query = "select * from issues 
    where borrowernumber = '$bornum' and returndate is null order by date_due";
  my $sth = $dbh->prepare($query);
  $sth->execute();
  my @items;
  my @issues;
  my @renewdef;
  my $x;
  my @barcodes;
  while (my $issrec = $sth->fetchrow_hashref) {
     my $itemdata = C4::Search::itemnodata($env,$dbh,$issrec->{'itemnumber'});
     my $line = $issrec->{'date_due'}." ";
     my $line = $line.fmtdec($env,$issrec->{'renewals'},"20")." ";
     my $line = $line.$itemdata->{'barcode'}." ".$itemdata->{'title'};
     $items[$x] = $line;
     #debug_msg($env,$line);
     $issues[$x] = $issrec;
     $barcodes[$x] = $itemdata->{'barcode'};
     my $rdef = 1;
     if ($issrec->{'renewals'} > 0) {
       $rdef = 0;
     }
     $renewdef[$x] = $rdef;
     $x++;
  }  
  if ($x < 1) { 
     #C4::InterfaceCDK::debug_msg($env,"no issues");
     return;
  }   
  my $renews = C4::Interface::RenewalsCDK::renew_window($env,\@items,$borrower,$amount,$odues);
  my $isscnt = $x;
  $x =0;
  my $y = 0;
  my @renew_errors = "";
  while ($x < $isscnt) {
    
    if (@$renews[$x] == 1) {
      my $issrec = $issues[$x];
      renewbook($env,$dbh,$issrec->{'borrowernumber'},$issrec->{'itemnumber'},"");
    }  
    $x++;
  }
  $sth->finish();
  #if ($barcodes[0] ne "") {
  #  my $errmsg = join(@barcodes,",");
  #  if ($barcodes[1] eq "") {
  #    $errmsg = $errmsg." has";
  #  } else {
  #    $errmsg = $errmsg." have";
  #  }
  #  $errmsg = $errmsg." been renewed before";
  #  C4::InterfaceCDK::error_msg($env,$errmsg);
  #}
}
END { }       # module clean-up code here (global destructor)
