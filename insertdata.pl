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
