#!/usr/bin/perl

#script to guide user thru adding a new borrower entry
#written 22/11/99

use strict;
#use C4::Search;
use CGI;
use C4::Output;
use C4::Database;

my $input = new CGI;
print $input->header;
print startpage();
print startmenu();
my %inputs;
my $catlist=makelist("categories","categorycode","description");
$inputs{'cardnumber'}="text\t";
$inputs{'surname'}="text\t";
$inputs{'firstname'}="text\t";
$inputs{'othernames'}="text\t";
$inputs{'initials'}="text\t";
$inputs{'streetaddress'}="text\t";
$inputs{'suburb'}="text\t";
$inputs{'city'}="text\t";
$inputs{'phone'}="text\t";
$inputs{'emailaddress'}="text\t";
$inputs{'faxnumber'}="text\t";
$inputs{'altstreetaddress'}="text\t";
$inputs{'altsuburb'}="text\t";
$inputs{'altcity'}="text\t";
$inputs{'altphone'}="text\t";
$inputs{'categorycode'}="select".$catlist;
$inputs{'dateofbirth'}="text\t";
$inputs{'contactname'}="text\t";
$inputs{'borrowernotes'}="textarea\t";
$inputs{'type'}="hidden\tborrowers";
print mkform('/cgi-bin/kumara/insertdata.pl',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
