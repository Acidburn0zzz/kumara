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
  my $bornum=getmax('borrowers','borrowernumber');
  my $num=$bornum->{'max'};
  $num++;
  $data{'borrowernumber'}=$num;
  $data{'branchcode'}="L";
}  
&sqlinsert($data{'type'},%data);
