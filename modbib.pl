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
my $title=$input->param('title');
my $data=bibdata($title);


print startpage();
print startmenu();
my %inputs;

#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type

$inputs{'title'}="text\t$data->{'title'}";
$inputs{'unititle'}="text\t$data->{'unititle'}";
$inputs{'notes'}="textarea\t$data->{'notes'}";
#$inputs{'dateaccessioned'}="text\t$data->{'dateaccessioned'}";
#$inputs{'dewey'}="text\t$data->{'dewey'}";
#$inputs{'classification'}="text\t$data->{'classification'}";
#$inputs{'subclass'}="text\t$data->{'subclass'}";
#$inputs{'itemtype'}="text\t$data->{'itemtype'}";

$inputs{'Author'}="text\t$data->{'author'}";
$inputs{'Series Title'}="text\t$data->{'seriestitle'}";
print mkform('wah',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
