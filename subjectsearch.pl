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
my $env;
my $subject=$input->param('subject');
#my $title=$input->param('title');

my @items=subsearch(\$blah,$subject);
#print @items;
my $count=@items;
my $i=0;
print center();
print mktablehdr;
print mktablerow(4,'#99cc33',bold('TITLE'),bold('AUTHOR'),bold('COUNT'),bold('LOCATION'),"/images/background-mem.gif"); 
my $colour=1;
while ($i < $count){
  my @results=split('\t',$items[$i]);
  $results[0]=mklink("/cgi-bin/kumara/detail.pl?bib=$results[2]",$results[0]);
  my $word=$results[1];
  $word=~ s/ //g;
  $word=~ s/\,/\,%20/;
  $results[1]=mklink("/cgi-bin/kumara/search.pl?author=$word",$results[1]);
  my ($count,$lcount,$nacount,$fcount,$scount)=itemcount($env,$results[2]);                                                                     
  $results[3]=$count;                                                                                                                           
  if ($nacount > 0){                                                                                                                          
    $results[4]=$results[4]."On Loan 1";                                                                                                          
  }                                                                                                                                           
  if ($lcount > 0){                                                                                                                           
    $results[4]=$results[4]." L$lcount";                                                                                                          
  }                                                                                                                                           
  if ($fcount > 0){                                                                                                                           
    $results[4]=$results[4]." F$fcount";                                                                                                          
  }                                                                                                                                           
  if ($scount > 0){                                                                                                                           
    $results[4]=$results[4]." S$scount";                                                                                                          
  }             
  if ($colour == 1){                                                                          
    print mktablerow(4,'#ffffcc',$results[0],$results[1],$results[3],$results[4]);                                        
    $colour=0;                                                                   
  } else{                                                                        
    print mktablerow(4,'white',$results[0],$results[1],$results[3],$results[4]);                                     
    $colour=1;                                                                                
  }
   $i++;
}
print endcenter();
print mktableft();
print endmenu();
print endpage();
