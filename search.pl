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
my $title=$input->param('title');
$search{'title'}=$title;
my $keyword=$input->param('keyword');
$search{'keyword'}=$keyword;
my $author=$input->param('author');
$search{'author'}=$author;
my $subject=$input->param('subject');
$search{'subject'}=$subject;
my $itemnumber=$input->param('item');
$search{'item'}=$itemnumber;
my $isbn=$input->param('isbn');
$search{'isbn'}=$isbn;
my $datebefore=$input->param('date-before');
$search{'date-before'};
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
print startmenu();
print mkheadr(1,'Catalogue Search Results');
print center();
my $count;
my @results;
if ($itemnumber ne '' || $isbn ne ''){
    ($count,@results)=&CatSearch(\$blah,'precise',\%search,$num,$offset);
} else {
  if ($subject ne ''){
    ($count,@results)=&CatSearch(\$blah,'subject',\%search,$num,$offset);
  } else {
    if ($keyword ne ''){
#      print "hey";
      ($count,@results)=&KeywordSearch(\$blah,'intra',\%search,$num,$offset);
    } else {
      ($count,@results)=&CatSearch(\$blah,'loose',\%search,$num,$offset);
#            print "hey";
    }
  }
}
print "You searched on ";
while ( my ($key, $value) = each %search) {                                 
  if ($value ne ''){
    print bold("$key $value,");
  }                          
}
print " $count results found";
my $offset2=$num+$offset;
print "<br> Results $offset to $offset2 displayed";
print mktablehdr;
if ($subject ne ''){
  print mktablerow(1,'#cccc99','<b>SUBJECT</b>');
} else {
  print mktablerow(4,'#cccc99','<b>TITLE</b>','<b>AUTHOR</b>','<b>ITEM COUNT</b>',' &nbsp;');
}
my $count2=@results;
my $i=0;
my $colour=1;
while ($i < $count2){
    my @stuff=split('\t',$results[$i]);
    my $title2=$stuff[1];
    $title2=~ s/ /%20/g;
    if ($subject eq ''){
      $stuff[1]=mklink("/cgi-bin/kumara/detail.pl?bib=$stuff[0]&title=$title2",$stuff[1]);
      my $word=$stuff[2];
      $word=~ s/ //g;
      $word=~ s/\,/\,%20/g;
      $word=~ s/\n//g;
      my $url="/cgi-bin/kumara/search.pl?author=$word&type=a";
      $stuff[2]=mklink($url,$stuff[2]);
      my ($count,$lcount,$nacount,$fcount,$scount)=itemcount($env,$stuff[0]);
      $stuff[3]=$count;
      if ($nacount > 0){
        $stuff[4]=$stuff[4]."N/A=$nacount";
      }
      if ($lcount > 0){
        $stuff[4]=$stuff[4]."L=$lcount";
      }
      if ($fcount > 0){
        $stuff[4]=$stuff[4]."F=$fcount";
      }
      if ($scount > 0){
        $stuff[4]=$stuff[4]."S=$scount";
      }
    } else {
      my $word=$stuff[1];
      $word=~ s/ /%20/g;
      $stuff[1]=mklink("/cgi-bin/kumara/subjectsearch.pl?subject=$word",$stuff[1]);
    }
    if ($colour == 1){
      print mktablerow(4,'#ffffcc',$stuff[1],$stuff[2],$stuff[3],$stuff[4]);
      $colour=0;
    } else{
      print mktablerow(4,'white',$stuff[1],$stuff[2],$stuff[3],$stuff[4]);
      $colour=1;
    }
    $i++;
}
$offset=$num+$offset;
print mktablerow(4,'#cccc99',' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp;');
print mktableft();
if ($offset < $count){
    my $search="num=$num&offset=$offset";
    if ($subject ne ''){
      $subject=~ s/ /%20/g;
      $search=$search."&subject=$subject";
    }
    if ($title ne ''){
      $title=~ s/ /%20/g;
      $search=$search."&title=$title";
    }
    if ($author ne ''){
      $author=~ s/ /%20/g;
      $search=$search."&author=$author";
    }
    if ($keyword ne ''){
      $keyword=~ s/ /%20/g;
      $search=$search."&keyword=$keyword";
    }
    
    my $stuff=mklink("/cgi-bin/kumara/search.pl?$search",'More');
    print $stuff;
}

print endcenter();
print endmenu();
print endpage();
