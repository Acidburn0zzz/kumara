#!/usr/bin/perl

#script to display reports
#written 8/11/99

use strict;
use CGI;
use C4::Output;
use C4::Stats;

my $input = new CGI;
print $input->header;
my $type=$input->param('type');
print startpage();
print startmenu();
if ($type eq 'search'){
 my $data=updatestats('search','something');  
}
if ($type eq


print endmenu();
print endpage();
