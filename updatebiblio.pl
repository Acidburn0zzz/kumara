#!/usr/bin/perl

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;

my $input= new CGI;
#print $input->header;
#print $input->dump;


my $title=checkinp($input->param('Title'));
my $author=checkinp($input->param('Author'));
my $bibnum=checkinp($input->param('bibnum'));
my $copyright=checkinp($input->param('Copyright'));
my $seriestitle=checkinp($input->param('Series'));
my $serial=checkinp($input->param('Serial'));
my $unititle=checkinp($input->param('Unititle'));
my $notes=checkinp($input->param('Notes'));

modbiblio($bibnum,$title,$author,$copyright,$seriestitle,$serial,$unititle,$notes);

my $bibitemnum=checkinp($input->param('bibitemnum'));
my $itemtype=checkinp($input->param('Item'));
my $isbn=checkinp($input->param('ISBN'));
my $publishercode=checkinp($input->param('Publisher'));
my $publicationdate=checkinp($input->param('Publication'));
my $class=checkinp($input->param('Class'));
my $classification;
my $dewey;
my $subclass;
if ($itemtype ne 'NF'){
  $classification=$class;
}
if ($class =~/[0-9]+/){
   print $class;
   $dewey= $class;
   $dewey=~ s/[a-z]+//gi;
   my @temp=split(/[0-9]+\.[0-9]+/,$class);
   $classification=$temp[0];
   $subclass=$temp[1];
}else{
  $dewey='';
}
my $illus=checkinp($input->param('Illustrations'));
my $pages=checkinp($input->param('Pages'));
my $volumeddesc=checkinp($input->param('Volume'));
modbibitem($bibitemnum,$itemtype,$isbn,$publishercode,$publicationdate,$classification,$dewey,$subclass,$illus,$pages,$volumeddesc);

my $subtitle=checkinp($input->param('Subtitle'));
modsubtitle($bibnum,$subtitle);

my $subject=checkinp($input->param('Subject'));
$subject=uc $subject;
my @sub=split(/\|/,$subject);
#print @sub;
#

my $addauthor=checkinp($input->param('Additional'));
modaddauthor($bibnum,$addauthor);


my $error=modsubject($bibnum,@sub);
if ($error ne ''){
  print $input->header();
#  print $input->dump;
  print $error;
} else {
  print $input->redirect("detail.pl?type=intra&bib=$bibnum");
}

sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}
