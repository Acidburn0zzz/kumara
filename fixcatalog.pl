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
$sth=$dbh->prepare("Select * from catalogueentry where entrytype = 't' or entrytype='st'");
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  $data->{'selection'}=$data->{'catalogueentry'};
  while ( my ($key, $value) = each %stop) {
    $data->{'selection'}=~ s/ $value / /gi;
    $data->{'selection'}=~ s/ $value$//gi;
    $data->{'selection'}=~ s/^$value //gi;
  }
  $data->{'selection'}=~ s/\'//g;
  $data->{'catalogueentry'}=~ s/\'/\\\'/g;
  my $sth2=$dbh->prepare("Update catalogueentry set selection='$data->{'selection'}' where
  entrytype='$data->{'entrytype'}' and catalogueentry='$data->{'catalogueentry'}'");
  $sth2->execute;
  $sth2->finish;
}



$dbh->disconnect;
