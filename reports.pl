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
print startmenu('issue');
my @data;
if ($type eq 'search'){
 @data=statsreport('search','something');  
}
if ($type eq 'issue'){
 @data=statsreport('issue','today');
}

print mkheadr(1,"$type reports");
print @data;

print endmenu('issue');
print endpage();
