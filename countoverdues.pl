#!/usr/bin/perl

#script to keep total of number of issues;

use C4::Output;
use C4::Circulation::Fines;
use CGI;

my $input=new CGI;
print $input->header;
my ($count,@data)=Getoverdues();
print $count;
print $data[0]->{'date_due'};
