#!/usr/bin/perl

#script to keep total of number of issues;

use C4::Output;
use C4::Stats;
use CGI;

my $input=new CGI;
print $input->header;
my $count=TotalPaid('today');
$count=$count*-1;
print $count;
