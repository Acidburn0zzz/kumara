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
print "<a href=request.pl?bib=$bib><img height=42  WIDTH=187 BORDER=0 src=\"/images/place-request.gif\" align=right border=0></a>";
print mkheadr(3,'Items');




my $title=$input->param('title');


my @items=ItemInfo(\$blah,$bib,$title);
#print @items;
my $count=@items;
my $i=0;
print center();
print mktablehdr;
if ($type eq 'opac'){
  print mktablerow(7,$main,'Title','Itemtype','Class','Location','DateDue','Lastseen','Barcode'); 
} else {
  print mktablerow(7,$main,'Title','Itemtype','Class','Location','DateDue','Lastseen','Barcode',"/images/background-mem.gif"); 
}
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
    print mktablerow(7,$secondary,$results[0],$results[6],$results[4],$results[3],$results[2],$results[7],$results[1]);                                        
    $colour=0;                                                                                
  } else{                                                                                     
    print mktablerow(7,'white',$results[0],$results[6],$results[4],$results[3],$results[2],$results[7],$results[1]);                                          
    $colour=1;                                                                                
  }
   $i++;
}
print endcenter();
print mktableft();
print endmenu($type);
print endpage();
