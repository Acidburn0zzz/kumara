#!/usr/bin/perl

#script to show amount paid today;

use C4::Output;
use C4::Stats;
use CGI;

my $input=new CGI;
print $input->header;
my $count=TotalPaid('today');
$count=$count*-1;
print $count;
