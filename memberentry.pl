#!/usr/bin/perl

#script to set up screen for modification of borrower details
#written 20/12/99 by chris@katipo.co.nz

use strict;
use C4::Output;
use CGI;
use C4::Search;


my $input = new CGI;
my $member=$input->param('bornum');

print $input->header;
print startpage();
print startmenu('member');
print mkheadr(1,'Update Member Details');


print mktablehdr;

print mktableft;
print endmenu('member');
print endpage();
