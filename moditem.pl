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
my $itemnum=$input->param('item');

#my ($analytictitle)=analytic($biblionumber,'t');
#my ($analyticauthor)=analytic($biblionumber,'a');
print startpage();
print startmenu();
my %inputs;



#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type
#$inputs{'Author'}="text\t$data->{'author'}\t0";
#$inputs{'Title'}="text\t$data->{'title'}\t1";
my $dewey = $data->{'dewey'};                                                      
$dewey =~ s/0+$//;                                                                 
if ($dewey eq "000.") { $dewey = "";};                                             
if ($dewey < 10){$dewey='00'.$dewey;}                                              
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}                               
if ($dewey <= 0){                                                                  
  $dewey='';                                                                       
} 
$dewey=~ s/\.$//;
#$inputs{'Barcode'}="text\t\$item->{'barcode'}\t0";
$inputs{'Class'}="text\t$data->{'classification'}$dewey$data->{'subclass'}\t2";
$inputs{'Item Type'}="text\t$data->{'itemtype'}\t3";
#$inputs{'Subject'}="textarea\t$sub\t4";
#$inputs{'Publisher'}="text\t$data->{'publishercode'}\t5";
$inputs{'Copyright date'}="text\t$data->{'copyrightdate'}\t6";
$inputs{'ISBN'}="text\t$data->{'isbn'}\t7";
#$inputs{'Publication Year'}="text\t$data->{'publicationyear'}\t8";
$inputs{'Pages'}="text\t$data->{'pages'}\t9";
$inputs{'Illustrations'}="text\t$data->{'illustration'}\t10";
#$inputs{'Series Title'}="text\t$data->{'seriestitle'}\t11";
#$inputs{'Additional Author'}="text\t$additional\t12";
#$inputs{'Subtitle'}="text\t$subtitle->[0]->{'subtitle'}\t13";
#$inputs{'Unititle'}="text\t$data->{'unititle'}\t14";
#$inputs{'Notes'}="textarea\t$data->{'notes'}\t15";
$inputs{'Serial'}="text\t$data->{'serial'}\t16";
$inputs{'Volume'}="text\t$data->{'volumeddesc'}\t17";
#$inputs{'Analytic author'}="text\t\t18";
#$inputs{'Analytic title'}="text\t\t19";

$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}\t20";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}\t21";
$inputs{'itemnumber'}="hidden\t$itemnum\t22";

print mkform3('updatebibitem.pl',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
