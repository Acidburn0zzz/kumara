#!/usr/bin/perl

#script to insert data into the database
#needs authentication, only used for adding new biblios etc
# written 9/11/99 by chris@katipo.co.nz

use CGI;
use C4::Database;
use strict;

my $input= new CGI;
print $input->header;
print $input->dump;

#get all the data into a hash
my @names=$input->param;
my %data;
my $problems;
foreach my $key (@names){
  $data{$key}=$input->param($key);
}
if ($data{'type'} eq 'biblio'){
  $data{'serial'}=~ s/No/0/;
  $data{'serial'}=~ s/Yes/1/;
  my $bibnum=getmax('biblio','biblionumber');
  my $num=$bibnum->{'max'};
  $num++;
  $data{'biblionumber'}=$num;
} elsif ($data{'type'} eq 'borrowers') {
  # required fields
  my @reqflds = ("cardnumber","surname","firstname",
    "streetaddress","phone","altstreetaddress","altphone","dateofbirth","contactname");       
  $problems = checkflds(\@reqflds,\%data); 
  if ($updtype eq "M") {
    $keyfld = "borrowernumber";
  } else {
    my $bornum=getmax('borrowers','borrowernumber');
    my $num=$bornum->{'max'};
    $num++;
    $data{'borrowernumber'}=$num;
    $data{'branchcode'}="L";
  }
}
if {$updtype eq "M"}
  &sqlupdate($data{'type'},$keyfld,$data{keyfld},%data);
} else {  
  &sqlinsert($data{'type'},%data);
}

