#!/usr/bin/perl

#script to guide user thru adding a new biblio entry
#written 8/11/99

use strict;
#use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;
print startpage();
print startmenu();
my %inputs;

$inputs{'Title'}='';
$inputs{'Unititle'}='';
$inputs{'Notes'}='';
$inputs{'Author'}='';
$inputs{'Series Title'}='';
print mkform('wah',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
