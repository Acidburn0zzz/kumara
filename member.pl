#!/usr/bin/perl

#script to do a borrower enquiery/brin up borrower details etc
#written 20/12/99 by chris@katipo.co.nz

use strict;
use C4::Output;
use CGI;

my $input = new CGI;
print $input->header;
print startpage();
print startmenu('member');
print endmenu('member');
print endpage();
