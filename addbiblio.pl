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

$inputs{'title'}="text\t";
$inputs{'unititle'}="text\t";
$inputs{'notes'}="textarea\t";
$inputs{'author'}="text\t";
$inputs{'serial'}="radio\tYes\tNo";
$inputs{'seriestitle'}="text\t";
$inputs{'type'}="hidden\tbiblio";
print mkform('/cgi-bin/kumara/insertdata.pl',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
