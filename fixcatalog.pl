#!/usr/bin/perl

use C4::Database;
use strict;

my $dbh=C4Connect;

my $sth=$dbh->prepare("Select * from stopwords");
$sth->execute;
my %stop;
while (my $data=$sth->fetchrow_hashref){
  $stop{$data->{'word'}}=$data->{'word'};
}
$sth->finish;
while (my $da=<STDIN>){
  chomp $da;
  my @temp=split('\t',$da);
#  if ($temp[1] =~ /t/){
    my $dat=$temp[0];
#    print "hey";
    while ( my ($key, $value) = each %stop) {
      $dat=~ s/ $value / /gi;
      $dat=~ s/ $value$//gi;
      $dat=~ s/^$value //gi;
    }
    $dat=~ s/\'//g;
    print "$temp[0]\t$temp[1]\t \t \t \t$dat\n";
#  } else {
#    print $da,"\n";
#    print $temp[1],"\n";
#  }
}

$dbh->disconnect;
