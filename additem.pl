#!/usr/bin/perl

#script to guide user thru adding a new item entry
#written 8/11/99
# modified 9/11/99 by chris@katipo.co.nz

use strict;

#use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;
print startpage();
print startmenu();
my %inputs;

#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type

$inputs{'ISBN'}="text\t";
$inputs{'Barcode'}="text\t";
$inputs{'Price'}="text\t";
#$inputs{'Author'}='';
#$inputs{'Series Title'}='';
print mkform('wah',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
