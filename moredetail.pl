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
#whether it is called from the opac of the intranet
my $type=$input->param('type');
#setup colours
my $main;
my $secondary;
if ($type eq 'opac'){
  $main='#99cccc';
  $secondary='#efe5ef';
} else {
  $main='#cccc99';
  $secondary='#ffffcc';
}
print startpage();
print startmenu($type);
my $blah;

my $bib=$input->param('bib');
my $title=$input->param('title');


my @items=ItemInfo(\$blah,$bib,$title);
#print @items;
my $count=@items;
my $i=0;
print center();
print mktablehdr;
print mktablerow(5,$main,'Title','Barcode','DateDue','Location','Dewey'); 
my $colour=1;
while ($i < $count){
  my @results=split('\t',$items[$i]);
  if ($type ne 'opac'){
    $results[0]=mklink("/cgi-bin/koha/moredetail.pl?item=$results[5]",$results[0]);
  }
  if ($results[2] eq ''){
    $results[2]='Available';
  }
  if ($colour == 1){                                                                          
    print mktablerow(5,$secondary,$results[0],$results[1],$results[2],$results[3],$results[4]);                                        
    $colour=0;                                                                                
  } else{                                                                                     
    print mktablerow(5,'white',$results[0],$results[1],$results[2],$results[3],$results[4]);                                          
    $colour=1;                                                                                
  }
   $i++;
}
print endcenter();
print mktableft();
print endmenu($type);
print endpage();
