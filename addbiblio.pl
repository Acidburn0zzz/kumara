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

$inputs{'Title'}="text\t";
$inputs{'Unititle'}="text\t";
$inputs{'Notes'}="textarea\t";
$inputs{'Author'}="text\t";
$inputs{'Serial'}="radio\tYes\tNo";
$inputs{'Series Title'}="text\t";
$inputs{'type'}="hidden\tbiblio";
print mkform('/cgi-bin/kumara/insertdata.pl',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
