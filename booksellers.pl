#!/usr/bin/perl

#script to display info about acquisitions
#written by chris@katipo.co.nz 31/01/2000

use C4::Acquisitions;
use C4::Output;
use CGI;
my $input=new CGI;
print $input->header();
my $id=$input->param('id');
my $bookseller=bookseller($id);
print startpage;
print mktablehdr;

print mktablerow(7,'white',"<b>Id</b>:$bookseller->{'id'}",
"<b>Name:</b>$bookseller->{'name'}","<b>Address</b>
$bookseller->{'address1'}<br>
$bookseller->{'address2'}<br>
$bookseller->{'address3'}<br>
$bookseller->{'address4'}<br>","<b>Phone:</b>$bookseller->{'phone'}",
"<b>Account:</b>$bookseller->{'accountnumber'}","<b>Other supplier</b>
$bookseller->{'othersupplier'}",
"<b>currency</b>:$bookseller->{'currency'}"
);
print mktablerow(7,'white',"<b>Delivery Days:</b>$bookseller->{'delvierydays'}",
"<b>Follow up</b>:$bookseller->{'followupdays'}","<b> Follow ups cancel:</b>$bookseller->{'followupscancel'}",
"<b>Speciality:</b>$booksller->{'speciality'}","<b>Fax</b>:$bookseller->{'fax'}",
"<b>Notes:</b>$bookseller->{'notes'}","<b>Email</b>$bookseller->{'email'}");
print mktablerow(2,'white',"<b>url:</b>$bookseller->{'url'}","<b>Rep:</b>$bookseller->{'rep'}");
print mktableft;
print endpage;
