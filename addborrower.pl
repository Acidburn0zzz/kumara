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
$inputs{'cardnumber'}   ="1\tCard Number\ttext\t";
$inputs{'surname'}      ="2\tSurname\ttext\t";
$inputs{'firstname'}    ="3\tFirst Name\ttext\t";
$inputs{'othernames'}   ="4\tOther Names\ttext\t";
$inputs{'initials'}     ="5\tInitials\ttext\t";
$inputs{'streetaddress'}="6\tAddress\ttext\t";
$inputs{'suburb'}       ="7\tArea\ttext\t";
$inputs{'city'}         ="8\tTown\ttext\t";
$inputs{'phone'}        ="9\tTelephone\ttext\t";
$inputs{'emailaddress'} ="10\tEmail\ttext\t";
$inputs{'faxnumber'}    ="11\tFax Number\ttext\t";
$inputs{'altstreetaddress'}="12\tAlt Address\ttext\t";
$inputs{'altsuburb'}    ="13\tAlt Areat\ttext\t";
$inputs{'altcity'}      ="14\tAlt Town\ttext\t";
$inputs{'altphone'}     ="15\tAlt Phone\ttext\t";
$inputs{'categorycode'} ="16\tCategory\tselect".$catlist;
$inputs{'dateofbirth'}  ="17\tDate of Birth\ttext\t";
$inputs{'contactname'}  ="18\tContact Name\text\t";
$inputs{'borrowernotes'}="19\tNotes\ttextarea\t";
$inputs{'type'}         ="20\t\thidden\tborrowers";
print mkform2('/cgi-bin/kumara/insertdata.pl',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
