#!/usr/bin/perl

#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;
my $bibitemnum=$input->param('bibitem');
my $data=bibitemdata($bibitemnum);


print startpage();
print startmenu();
my %inputs;

#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type
$inputs{'Author'}="text\t$data->{'author'}";
$inputs{'Title'}="text\t$data->{'title'}";
$inputs{'Unititle'}="text\t$data->{'unititle'}";
$inputs{'Notes'}="textarea\t$data->{'notes'}";
$inputs{'Serial'}="text\t$data->{'serial'}";
$inputs{'Series Title'}="text\t$data->{'seriestitle'}";
$inputs{'Copyright'}="text\t$data->{'copyrightdate'}";
#$inputs{'Volume'}="text\t$data->{'volume'}";
#$inputs{'Number'}="text\t$data->{'number'}";
$inputs{'Classification'}="text\t$data->{'classification'}";
$inputs{'Item Type'}="text\t$data->{'itemtype'}";
$inputs{'ISBN'}="text\t$data->{'isbn'}";
$inputs{'Dewey'}="text\t$data->{'dewey'}";
$inputs{'Sub Class'}="text\t$data->{'subclass'}";
$inputs{'Publication Year'}="text\t$data->{'publicationyear'}";
$inputs{'Volume'}="text\t$data->{'volumedesc'}";
$inputs{'Illustrations'}="text\t$data->{'illustration'}";
$inputs{'Pages'}="text\t$data->{'pages'}";
$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}";
print mkform('updatebiblio.pl',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
