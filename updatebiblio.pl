#!/usr/bin/perl

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;

my $input= new CGI;
print $input->header;
print $input->dump;

my $title=$input->param('Title');
my $author=$input->param('Author');
my $bibnum=$input->param('bibnum');
my $copyright=$input->param('Copyright');
my $seriestitle=$input->param('Series');
my $serial=$input->param('Serial');
my $unititle=$input->param('Unititle');
my $notes=$input->param('Notes');

modbiblio($bibnum,$title,$author,$copyright,$seriestitle,$serial,$unititle,$notes);

my $bibitemnum=$input->param('bibitemnum');
my $itemtype=$input->param('Item');
my $isbn=$input->param('ISBN');
my $publishercode=$input->param('Publisher');
my $publicationdate=$input->param('Publication');
my $class=$input->param('Class');
my $classification;
my $dewey;
my $subclass;
if ($itemtype eq 'PER'){
  $classification=$class;
}
if ($class =~/0-9/){
}else{
  $dewey='';
}
my $illus=$input->param('Illustrations');
my $pages=$input->param('Pages');
my $volumeddesc=$input->param('Volume');
modbibitem($bibitemnum,$itemtype,$isbn,$publishercode,$publicationdate,$classification,$dewey,$subclass,$illus,$pages,$volumeddesc);

my $subtitle=$input->param('Subtitle');
modsubtitle($bibnum,$subtitle);

my $subject=$input->param('Subject');
my @sub=split(/\|/,$subject);
#print @sub;
#
modsubject($bibnum,@sub);

print $input->redirect("detail.pl?type=intra&bib=$bibnum");
