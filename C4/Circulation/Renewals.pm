package C4::Circulation; #assumes C4/Circulation/Renewals

#package to deal with Renewals
#written 7/11/99 by olwen@katipo.co.nz

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
@EXPORT = qw(&renewstatus $renewbook);
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
  }   
    
  my $amt_owing = calc_odues($env,$dbh,$bornum,$itemno);
  return($renewokay);    
}


sub renewbook {
  # mark book as renewed
  my ($env,$dbh,$bornum,$itemno)=@_;
  return();
}

END { }       # module clean-up code here (global destructor)
