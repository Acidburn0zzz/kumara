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
if ($type ne 'opac'){
  print "<a href=request.pl?bib=$bib><img height=42  WIDTH=120 BORDER=0 src=\"/images/requests.gif\" align=right border=0></a>";
}


my @items=ItemInfo(\$blah,$bib,$title);
my $dat=bibdata($bib);
my $count=@items;
my @temp=split('\t',$items[0]);
print mkheadr(3,"$dat->{'title'} ($dat->{'author'}) $temp[4]");
print <<printend

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width="220">

<!-----------------BIBLIO RECORD TABLE--------->



<TR VALIGN=TOP>

<td  bgcolor="$main" 
printend
;
if ($type ne 'opac'){
 print "background=\"/images/background-mem.gif\"";
}
print <<printend
><B>BIBLIO RECORD $bib</TD></TR>


<tr VALIGN=TOP  >
<TD>
<br>
<FONT SIZE=2  face="arial, helvetica">
printend
;
if ($type ne 'opac'){
print <<printend
Subtitle: $dat->{'subtitle'}<br>
Author: $dat->{'author'}<br>
Additional Author: <br>
Seriestitle: $dat->{'seriestitle'}<br>
Subject: $dat->{'subject'}<br>
Copyright:$dat->{'copyrightdate'}<br>
Notes: $dat->{'notes'}<br>
Unititle: $dat->{'unititle'}<br>
Analytical Author: <br>
Analytical Title: <br>
Serial: $dat->{'serial'}<br>
Total Number of Items: $count
<p>
printend
;
}
else {
if ($dat->{'subtitle'} ne ''){
  print "Subtitle: $dat->{'subtitle'}<br>";
}
if ($dat->{'author'} ne ''){
  print "Author: $dat->{'author'}<br>";
}
#Additional Author: <br>
if ($dat->{'seriestitle'} ne ''){
  print "Seriestitle: $dat->{'seriestitle'}<br>";
}
if ($dat->{'subject'} ne ''){
  print "Subject: $dat->{'subject'}<br>";
}
if ($dat->{'copyrightdate'} ne ''){
  print "Copyright:$dat->{'copyrightdate'}<br>";
}
if ($dat->{'notes'} ne ''){
  print "Notes: $dat->{'notes'}<br>";
}
if ($dat->{'unititle'} ne ''){
  print "Unititle: $dat->{'unititle'}<br>";
}
#Analytical Author: <br>
#Analytical Title: <br>
if ($dat->{'serial'} ne '0'){
 print "Serial: Yes<br>";
}
print "Total Number of Items: $count
<p>
";

}
if ($type ne 'opac'){
  print "<INPUT TYPE=\"image\" name=\"submit\"  VALUE=\"modify\" height=42  WIDTH=93 BORDER=0 src=\"/images/modify-mem.gif\">"; 
}
print <<printend
</font></TD>
</TR>

</TABLE>
<img src="/images/holder.gif" width=16 height=250 align=left>

printend
;


#print @items;

my $i=0;
print center();
print mktablehdr;
if ($type eq 'opac'){
  print mktablerow(5,$main,'Itemtype','Class','Branch','DateDue','Lastseen'); 
} else {
  print mktablerow(6,$main,'Itemtype','Class','Location','DateDue','Lastseen','Barcode',"/images/background-mem.gif"); 
}
my $colour=1;
while ($i < $count){
  my @results=split('\t',$items[$i]);
  if ($type ne 'opac'){
    $results[1]=mklink("/cgi-bin/koha/moredetail.pl?item=$results[5]&bib=$bib&bi=$results[8]",$results[1]);
  }
  if ($results[2] eq ''){
    $results[2]='Available';
  }
  if ($colour == 1){
    if ($type ne 'opac'){
      print mktablerow(6,$secondary,$results[6],$results[4],$results[3],$results[2],$results[7],$results[1]);
    } else {
       $results[6]=ItemType($results[6]);
       print mktablerow(5,$secondary,$results[6],$results[4],$results[3],$results[2],$results[7]);
    } 
    $colour=0;                                                                                
  } else{                                                                                     
    if ($type ne 'opac'){
      print mktablerow(6,'white',$results[6],$results[4],$results[3],$results[2],$results[7],$results[1]);                                          
    } else {
      $results[6]=ItemType($results[6]);
      print mktablerow(5,'white',$results[6],$results[4],$results[3],$results[2],$results[7]);                                          
    }
    $colour=1;                                                                                
  }
   $i++;
}
print endcenter();
print mktableft();
print "<br clear=all>";
print endmenu($type);
print endpage();
