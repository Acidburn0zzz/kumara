#!/usr/bin/perl

#script to display info about acquisitions
#written by chris@katipo.co.nz 31/01/2000

use C4::Acquisitions;
use C4::Output;
use CGI;
my $input=new CGI;
print $input->header();
my $num=$input->param('num');
my $offset=$input->param('offset');
my ($count,$data)=getorders($num,$offset);
#print $data->[0]->{'ordernumber'};
#print $count;

print startpage;
print mktablehdr;

#$count=100;
for (my$i=0;$i<$count;$i++){
#  print "$data->[$i]->{'ordernumber'}<br>";
   print mktablerow(7,'white',bold('Ordernumber'),bold('Biblionumber'),bold('Title'),
  bold('Requisitioned by'),bold('date entered'),bold('Authorised by'),bold('BooksellerID'));
  print mktablerow(7,'white',mklink("orderbreakdown.pl?id=$data->[$i]->{'ordernumber'}",
  $data->[$i]->{'ordernumber'}),$data->[$i]->{'biblionumber'},
  $data->[$i]->{'title'},$data->[$i]->{'requisitionedby'},
  $data->[$i]->{'entrydate'},$data->[$i]->{'authorisedby'},
  mklink("/cgi-bin/koha/booksellers.pl?id=$data->[$i]->{'booksellerid'}",$data->[$i]->{'booksellerid'}));
  print mktablerow(7,'white',"<b>Deliverydays:</b>$data->[$i]->{'deliverydays'}",
  "<b>Followupdays:</b>$data->[$i]->{'followupdays'}",
  "<b>Date Printed:</b>$data->[$i]->{'dateprinted'}","<b>Quantity:</b>$data->[$i]->{'quantity'}",
  "<b>Currency:</b>$data->[$i]->{'currency'}","<b>listprice:</b>$data->[$i]->{'listprice'}",
  "<b>totalamount:</b>$data->[$i]->{'totalamount'}");
  print mktablerow(7,'white',"<b>Date Recieved:</b>$data->[$i]->{'daterecieved'}",
  "<b>Invoicenumber:</b>$data->[$i]->{'booksellerinvoicenumber'}",
  "<b>Freight:</b>$data->[$i]->{'freight'}","<b>Unitprice:</b>$data->[$i]->{'unitprice'}",
  "<b>Quantity Recieved:</b>$data->[$i]->{'quantityrecieved'}",
  "<b>Source:</b>$data->[$i]->{'source'}","<b.>Cancelled by:</b>$data->[$i]->{'canceledby'}");
  print mktablerow(7,'white',"<b>Damaged:</b>$data->[$i]->{'quantityreceiveddamage'}",
  "<b>notes:</b>$data->[$i]->{'notes'}","<b>Supplier ref:</b>$data->[$i]->{'supplierreference'}",
  "<b>Purcahse order:</b>$data->[$i]->{'purchaseordernumber'}",
  "<b>Subscription:</b>$data->[$i]->{'subscription'}","<b>From:</b>$data->[$i]->{'subscriptionfrom'}",
  "<b>To:</b>$data->[$i]->{'subscriptionto'}");
  print mktablerow();
}
print mktableft;
$num=$num+$offset;

print "<a href=acqorders.pl?num=$num&offset=$offset>More</a>";

print endpage;
