#!/usr/bin/perl
#script to provide intranet (librarian) advanced search facility
#modified 9/11/1999 by chris@katipo.co.nz
#adding an extra comment to play with CVS (Si, 19/11/99)

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;

my $env;
my $input = new CGI;
print $input->header;
#print $input->dump;
my $blah;
my %search;
#build hash of users input


my $keyword=$input->param('keyword');
#$keyword=~ s/'/\'/g;
$search{'keyword'}=$keyword;

my @results;
my $offset=$input->param('offset');
if ($offset eq ''){
  $offset=0;
}
my $num=$input->param('num');
if ($num eq ''){
  $num=10;
}
print startpage();
print startmenu('opac');
print mkheadr(1,'Opac Search Results');
print center();
my $count;
my @results;

($count,@results)=&OpacSearch(\$blah,'loose',\%search,$num,$offset);

print "You searched on <b>$keyword</b>";

print " $count results found";
my $offset2=$num+$offset;
my $disp=$offset+1;
print "<br> Results $disp to $offset2 displayed";
print mktablehdr;

print mktablerow(4,'#99cccc','<b>TITLE</b>','<b>AUTHOR</b>','<b>COUNT</b>',bold('LOCATION'));

my $count2=@results;
my $i=0;
my $colour=1;
while ($i < $count2){
    my @stuff=split('\t',$results[$i]);
    my $title2=$stuff[1];
    $title2=~ s/ /%20/g;

      $stuff[1]=mklink("/cgi-bin/koha/detail.pl?bib=$stuff[2]&title=$title2&type=opac",$stuff[1]);
      my $word=$stuff[0];
      $word=~ s/ //g;
      $word=~ s/\,/\,%20/g;
      $word=~ s/\n//g;
      my $url="/cgi-bin/koha/search.pl?author=$word&type=opac";
      $stuff[0]=mklink($url,$stuff[0]);
      my ($count,$lcount,$nacount,$fcount,$scount)=itemcount($env,$stuff[2]);
      $stuff[3]=$count;
      if ($nacount > 0){
        $stuff[4]=$stuff[4]."On Loan $nacount";
      }
      if ($lcount > 0){
        $stuff[4]=$stuff[4]."L$lcount";
      }
      if ($fcount > 0){
        $stuff[4]=$stuff[4]."F$fcount";
      }
      if ($scount > 0){
        $stuff[4]=$stuff[4]."S$scount";
      }
    if ($colour == 1){
      print mktablerow(4,'#efe5ef',$stuff[1],$stuff[0],$stuff[3],$stuff[4]);
      $colour=0;
    } else{
      print mktablerow(4,'white',$stuff[1],$stuff[0],$stuff[3],$stuff[4]);
      $colour=1;
    }
    $i++;
}
$offset=$num+$offset;
print mktablerow(4,'#99cccc',' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp;');
print mktableft();
if ($offset < $count){
    my $search="num=$num&offset=$offset&keyword=$keyword";
    my $stuff=mklink("/cgi-bin/koha/opac-search.pl?$search",'Next');
    print $stuff;
}

print endcenter();
print endmenu('opac');
print endpage();
