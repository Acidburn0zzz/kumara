package C4::Circulation::Fines; #asummes C4/Circulation/Fines

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&Getoverdues &CalcFine &BorType &UpdateFine);
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


sub Getoverdues{
  my $dbh=C4Connect;
  my $query="Select * from issues where date_due < now() and returndate is
  NULL order by borrowernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
#  print @results;
  return($i,\@results);  
}

sub CalcFine {
  my ($itemnumber,$bortype,$difference)=@_;
  my $dbh=C4Connect;
  my $query="Select * from items,biblioitems,itemtypes,categoryitem where items.itemnumber=$itemnumber
  and items.biblioitemnumber=biblioitems.biblioitemnumber and
biblioitems.itemtype=itemtypes.itemtype and
categoryitem.itemtype=itemtypes.itemtype and
categoryitem.categorycode='$bortype'";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  my $amount=0;
  if ($difference >= $data->{'startcharge'}){
      if ($data->{'chargeperiod'} != 0){
        my $temp=$difference % $data->{'chargeperiod'};
        $difference=$difference - $temp;
        $amount=($difference / $data->{'chargeperiod'}) * $data->{'fine'};
      }
  }
  $dbh->disconnect;
  return($amount);
}

sub UpdateFine {
  my ($itemnum,$bornum,$amount)=@_;
  my $dbh=C4Connect;
  my $query="Select * from accountlines where itemnumber=$itemnum and
borrowernumber=$bornum and accounttype='FU'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  if (my $data=$sth->fetchrow_hashref){
    print "in accounts ...";
    if ($data->{'amount'} != $amount){
      print "updating";
      my $diff=$amount - $data->{'amount'};
      my $out=$data->{'amountoutstanding'}+$diff;
      my $query2="update accountlines set date=now(), amount=$amount,
      amountoutstanding=$out where accountno=$data->{'accountno'}";
      my $sth2=$dbh->prepare($query2);
      $sth2->execute;
      $sth2->finish;
      
    } else {
      print "no update needed $data->{'amount'}"
    }
  } else {
    print "not in account";
    my $query2="Select max(accountno) from accountlines";
    my $sth3=$dbh->prepare($query2);
    $sth3->execute;
    my @accountno=$sth3->fetchrow_array;
    $sth3->finish;
    $accountno[0]++;
    $query2="Insert into accountlines
    (borrowernumber,itemnumber,date,amount,
    description,accounttype,amountoutstanding,accountno) values
    ($bornum,$itemnum,now(),$amount,'Overdue Item','FU',
    $amount,$accountno[0])";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute;
    $sth2->finish;
  }
  $sth->finish;
  $dbh->disconnect;
}

sub BorType {
  my ($borrowernumber)=@_;
  my $dbh=C4Connect;
  my $query="Select borrowers.categorycode,description from borrowers,categories where 
  borrowernumber=$borrowernumber and
borrowers.categorycode=categories.categorycode";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}


END { }       # module clean-up code here (global destructor)
  
    
