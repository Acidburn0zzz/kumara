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
$inputs{'cardnumber'}   ="1\ttext\t";
$inputs{'surname'}      ="2\ttext\t";
$inputs{'firstname'}    ="3\ttext\t";
$inputs{'othernames'}   ="4\ttext\t";
$inputs{'initials'}     ="5\ttext\t";
$inputs{'streetaddress'}="6\ttext\t";
$inputs{'suburb'}       ="7\ttext\t";
$inputs{'city'}         ="8\ttext\t";
$inputs{'phone'}        ="9\ttext\t";
$inputs{'emailaddress'} ="10\ttext\t";
$inputs{'faxnumber'}    ="11\ttext\t";
$inputs{'altstreetaddress'}="12\ttext\t";
$inputs{'altsuburb'}    ="13\ttext\t";
$inputs{'altcity'}      ="14\ttext\t";
$inputs{'altphone'}     ="15\ttext\t";
$inputs{'categorycode'} ="16\tselect".$catlist;
$inputs{'dateofbirth'}  ="17\ttext\t";
$inputs{'contactname'}  ="18\ttext\t";
$inputs{'borrowernotes'}="19\ttextarea\t";
$inputs{'type'}         ="20\thidden\tborrowers";
print mkform2('/cgi-bin/kumara/insertdata.pl',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
