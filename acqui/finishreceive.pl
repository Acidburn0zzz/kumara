#!/usr/bin/perl

#script to add a new item and to mark orders as received
#written 1/3/00 by chris@katipo.co.nz

use C4::Output;
use C4::Acquisitions;
use CGI;

my $input=new CGI;
#print $input->header;

my $user=$input->remote_user;
#print $input->dump;
my $biblio=$input->param('biblio');
my $ordnum=$input->param('ordnum');
my $quantrec=$input->param('quantityrec');
my $cost=$input->param('cost');
my $invoiceno=$input->param('invoice');
my $id=$input->param('id');
my $bibitemno=$input->param('biblioitemnum');
my $replacement=$input->param('rrp');
my $branch=$input->param('branch');
my $bookfund=$input->param('bookfund');
my $itemtype=$input->param('format');
my $isbn=$input->param('ISBN');
my $series=$input->param('Series');
my $bookseller=$input->param('bookseller');
$id=$bookseller;
my $title=$input->param('title');
my $author=$input->param('author');
my $copyright=$input->param('copyright');

if ($quantrec != 0){
  $cost=$cost / $quantrec;
}

my $gst=$input->param('gst');
my $freight=$input->param('freight');
my $volinf=$input->param('volinf');
if ($volinf ne ''){
#  print "$bibitemno";
  $class="Periodical";
  $bibitemno=newbiblioitem($biblio,$itemtype,$isbn,$volinf,$class);
#  print "here $bibitemno";
}
receiveorder($biblio,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight);
modbiblio($biblio,$title,$author,$copyright,$series);
modbibitem($bibitemno,$itemtype,$isbn,'','',$class,'','','','',$volinf,'','');
my $barcode=$input->param('barcode');
my @barcodes;
if ($barcode =~ /\,/){
  @barcodes=split(',',$barcode);
}elsif ($barcode =~ /\|/){
  @barcodes=split('|',$barcode);
} else {
  $barcodes[0]=$barcode;
}
makeitems($quantrec,$bibitemno,$biblio,$replacement,$cost,$bookseller,$branch,@barcodes);
if ($itemtype ne 'PER'){
  print $input->redirect("/cgi-bin/koha/acqui/receive.pl?invoice=$invoiceno&id=$id&freight=$freight&gst=$gst");
} else {
  print $input->redirect("/acquisitions/");
}
