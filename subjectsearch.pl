#!/usr/bin/perl

#script to display detailed information
#written 8/11/99

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;
print startpage();
print startmenu();
my $blah;

my $subject=$input->param('subject');
#my $title=$input->param('title');

my @items=subsearch(\$blah,$subject);
#print @items;
my $count=@items;
my $i=0;
print center();
print mktablehdr;
print mktablerow(2,'#cccc99','Title','Author'); 
my $colour=1;
while ($i < $count){
  my @results=split('\t',$items[$i]);
  $results[0]=mklink("/cgi-bin/kumara/detail.pl?bib=$results[2]",$results[0]);
  my $word=$results[1];
  $word=~ s/ //g;
  $word=~ s/\,/\,%20/;
  $results[1]=mklink("/cgi-bin/kumara/search.pl?author=$word",$results[1]);
  if ($colour == 1){                                                                          
    print mktablerow(2,'#ffffcc',@results);                                        
    $colour=0;                                                                                
  } else{                                                                                     
    print mktablerow(2,'white',@results);                                          
    $colour=1;                                                                                
  }
   $i++;
}
print endcenter();
print mktableft();
print endmenu();
print endpage();
