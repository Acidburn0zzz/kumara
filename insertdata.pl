#!/usr/bin/perl

#script to insert data into the database
#needs authentication, only used for adding new biblios etc
# written 9/11/99 by chris@katipo.co.nz

use CGI;
use C4::Database;
use C4::Input;
use Date::Manip;
use strict;

my $input= new CGI;
print $input->header;
print $input->dump;

#get all the data into a hash
my @names=$input->param;
my %data;
my $keyfld;
my $keyval;
my $problems;
my $env;
foreach my $key (@names){
  $data{$key}=$input->param($key);
}
my $dbh=C4Connect;
my $query="Select * from borrowers where borrowernumber=$data{'borrowernumber'}";
my $sth=$dbh->prepare($query);
$sth->execute;
if (my $data=$sth->fetchrow_hashref){
  $query="update borrowers set title='$data{'title'}',expiry='$data{'expiry'}',
  cardnumber='$data{'cardnumber'}',sex='$data{'sex'}',ethnicnotes='$data{'ethnicnotes'}',
  address='$data{'address'},faxnumber='$data{'faxnumber'},firstname='$data{'firstname'}',
  altnotes='$data{'altnotes'}',dateofbirth='$data{'dateofbirth'}'
  where borrowernumber=$data{'borrowernumber'}";
  print $query;
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
}else{
}

$sth->finish;
$dbh->disconnect;
