#!/usr/bin/perl

#script to guide user thru adding/modifying a borrower entry
#written 22/11/99

use strict;
#use C4::Search;
use CGI;
use C4::Output;
use C4::Database;
my $input = new CGI;
print $input->header;
my $data;
my $cardnumber;
my $action=$input->param('act');
if ($action eq "M") {
  my $cardnumber =$input->param('item');
  $cardnumber =uc $cardnumber;
  $data=borrdata($cardnumber);
  if ($data->{borrowernumber} eq "") {
    $action = "A";
  }
}  
print startpage();
print startmenu();
print "Action $action<br>";
print "Cardnumber  $cardnumber<br>";
my %inputs;
my $catlist=makelist("categories","categorycode","description");
$inputs{'cardnumber'}   ="1\tR\tCard Number\ttext\t$data->{'cardnumber'}";
$inputs{'surname'}      ="2\tR\tSurname\ttext\t$data->{'surname'}";
$inputs{'firstname'}    ="3\tR\tFirst Name\ttext\t$data->{'firstname'}";
$inputs{'othernames'}   ="4\t\tOther Names\ttext\t$data->{'othernames'}";
$inputs{'initials'}     ="5\t\tInitials\ttext\t$data->{'initials'}";
$inputs{'streetaddress'}="6\tR\tAddress\ttext\t$data->{'streetaddress'}";
$inputs{'suburb'}       ="7\t\tArea\ttext\t$data->{'suburb'}";
$inputs{'city'}         ="8\t\tTown\ttext\t$data->{'city'}";
$inputs{'phone'}        ="9\tR\tTelephone\ttext\t$data->{'phone'}";
$inputs{'emailaddress'} ="10\t\tEmail\ttext\t$data->{'emailaddress'}";
$inputs{'faxnumber'}    ="11\t\tFax Number\ttext\t$data->{'faxnumber'}";
$inputs{'altstreetaddress'}="12\tR\tAlt Address\ttext\t$data->{'altstreetaddress'}";
$inputs{'altsuburb'}    ="13\t\tAlt Areat\ttext\t$data->{'altsuburb'}";
$inputs{'altcity'}      ="14\t\tAlt Town\ttext\t$data->{'altcity'}";
$inputs{'altphone'}     ="15\tR\tAlt Phone\ttext\t$data->{'altphone'}";
$inputs{'categorycode'} ="16\t\tCategory\tselect\t$data->{'categorycode'}".$catlist;
$inputs{'dateofbirth'}  ="17\t\tDate of Birth\ttext\t$data->{'dateofbirth'}";
$inputs{'contactname'}  ="18\tR\tContact Name\ttext\t$data->{'contactname'}";
$inputs{'borrowernotes'}="19\t\tNotes\ttextarea\t$data->{'borrowernotes'}";
$inputs{'type'}         ="20\t\t\thidden\tborrowers";
$inputs{'updtype'}      ="I";
if ($action eq "M") {
  $inputs{'updtype'} = "M";
  $inputs{'borrowernumber'} ="20\t\t\thidden\t$data->{'borrowernumber'}";
}  
print mkform2('/cgi-bin/kumara/insertdata.pl',%inputs);
#print mktablehdr();
#print mktableft();
print endmenu();
print endpage();
