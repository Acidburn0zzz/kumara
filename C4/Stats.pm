package C4::Stats; #asummes C4/Stats

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
@EXPORT = qw(&UpdateStats &statsreport &Count &Overdues &TotalOwing);
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

sub UpdateStats {
  #module to insert stats data into stats table
  my ($env,$branch,$type,$amount)=@_;
  my $dbh=C4Connect();
  my $sth=$dbh->prepare("Insert into statistics (datetime,branch,type) values
  (datetime('now'::abstime),'$branch','$type')");
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub statsreport {
  #module to return a list of stats for a given day,time,branch type
  #or to return search stats
  my ($type,$time)=@_;
  my @data;
#  print "here";
  if ($type eq 'issue'){
    @data=issuesrep($time);
  }
  return(@data);
}

sub issuesrep {
  my ($time)=@_;
  my $dbh=C4Connect;
  my $query="Select * from statistics";
  if ($time eq 'today'){
    $query=$query." where type='issue' and datetime
    >=datetime('yesterday'::date)";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'datetime'}\t$data->{'branch'}";
    $i++;
  }
  $sth->finish;
#  print $query;
  $dbh->disconnect;
  return(@results);

}

sub Count {
  my ($type,$time)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from statistics where type='$type'";
  if ($time eq 'today'){
    $query=$query." and datetime
    >=datetime('yesterday'::date)";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
#  print $query;
  $dbh->disconnect;
  return($data->{'count'});
}

sub Overdues{
  my $dbh=C4Connect;
  my $query="Select count(*) from issues where datetime(date_due::date) > datetime('yesterday'::date)";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($count->{'count'});  
}

sub TotalOwing{
  my ($type)=@_;
  my $dbh=C4Connect;
  my $query="Select sum(amountoutstanding) from accountlines";
  if ($type eq 'fine'){
    $query=$query." where accounttype='F'";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
   my $total=$sth->fetchrow_hashref;
   $sth->finish;
  $dbh->disconnect; 
  return($total->{'sum'});
}

END { }       # module clean-up code here (global destructor)
  
    
