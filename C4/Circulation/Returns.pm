package C4::Circulation; #assumes C4/Circulation/Returns

#package to deal with Returns
#written 3/11/99 by olwen@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;
use C4::Interface;
use C4::Circulation;
use C4::Scan;
use C4::Stats;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&returnrecord &calc_odues &Returns);
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

sub Returns {
  my ($env)=@_;
  my $dbh=&C4Connect;  
  my @items;
  @items[0]=" "x50;
  my $reason;
  my $item;
  my $reason;
  my $borrower;
  my $itemno;
  my $itemrec;
  my $bornum;
  my $amt_owing;
  until (($reason eq "Circ") || ($reason eq "Quit")) {
    ($reason,$item) =  returnwindow($env,"Enter Returns",$item,\@items,$borrower,$amt_owing);
    if (($reason ne "Circ") && ($reason ne "Quit")) {
      ($reason,$bornum,$borrower,$itemno,$itemrec,$amt_owing) = checkissue($env,$dbh,$item);
      if (($reason ne "") && ($reason ne "Circ")  && ($reason ne "Quit")) {
        if ($reason eq "Returned") {
	my $fmtitem = fmtstr($env,$itemrec->{'title'},"L50");
           unshift @items,$fmtitem;
	  
	} else {
          error_msg($env,$reason);
	}
      }
    }
  }
  $dbh->disconnect;
  return($reason);
  }
  
sub checkissue {
  my ($env,$dbh, $item) = @_;
  my $reason='Circ';
  my $bornum;
  my $borrower;
  my $itemno;
  my $itemrec;
  my $amt_owing;
  $item = uc $item;
  my $query = "select * from items where barcode = '$item'";
  my $sth=$dbh->prepare($query); 
  $sth->execute;
  if ($itemrec=$sth->fetchrow_hashref) {
     $sth->finish;
     $query = "select * from issues where
       (itemnumber='$itemrec->{'itemnumber'}') and (returndate is null)";
     my $sth=$dbh->prepare($query);
     $sth->execute;
     if (my $issuerec=$sth->fetchrow_hashref) {
     $sth->finish;
     $query = "select * from borrowers where
     (borrowernumber = '$issuerec->{'borrowernumber'}')";
     my $sth= $dbh->prepare($query);
     $sth->execute;
     $borrower = $sth->fetchrow_hashref;
     $bornum = $issuerec->{'borrowernumber'};
     $itemno = $issuerec->{'itemnumber'};
     $amt_owing = returnrecord($env,$dbh,$bornum,$itemno);     
     $reason = "Returned";    
     } else {
       $sth->finish;
       $reason = "Item not issued";
     }       
  } else {
     $sth->finish;
     $reason = "Item not found";
  }   
  return ($reason,$bornum,$borrower,$itemno,$itemrec,$amt_owing);
  # end checkissue
  }
  
sub returnrecord {
  # mark items as returned
  my ($env,$dbh,$bornum,$itemno)=@_;
  my $amt_owing = calc_odues($env,$dbh,$bornum,$itemno);
  my @datearr = localtime(time);
  my $dateret = (1900+$datearr[5])."-".$datearr[4]."-".$datearr[3];
  my $query = "update issues set returndate = '$dateret', branchcode ='$env->{'branchcode'}' where 
    (borrowernumber = '$bornum') and (itemnumber = '$itemno') 
    and (returndate is null)";  
  my $sth = $dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  UpdateStats($env,'branch','return','0');
  return($amt_owing);
}

sub calc_odues {
  # calculate overdue fees
  my ($env,$dbh,$bornum,$itemno)=@_;
  my $amt_owing;
  return($amt_owing);
}  

END { }       # module clean-up code here (global destructor)
