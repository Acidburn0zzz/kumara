#!/usr/bin/perl

#script to modify/delete items
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;
my $barcode=$input->param('item');
$barcode=uc $barcode;
my $data=itemdata($barcode);


print startpage();
print startmenu();
my %inputs;

#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type

$inputs{'ISBN'}="text\t$data->{'isbn'}";
$inputs{'Barcode'}="text\t$data->{'barcode'}";
$inputs{'Price'}="text\t$data->{'price'}";
$inputs{'dateaccessioned'}="text\t$data->{'dateaccessioned'}";
$inputs{'dewey'}="text\t$data->{'dewey'}";
$inputs{'classification'}="text\t$data->{'classification'}";
$inputs{'subclass'}="text\t$data->{'subclass'}";
$inputs{'itemtype'}="text\t$data->{'itemtype'}";

#$inputs{'Author'}='';
#$inputs{'Series Title'}='';
print mkform('wah',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
