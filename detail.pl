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
print "<a href=request.pl?bib=$bib><img height=42  WIDTH=120 BORDER=0 src=\"/images/requests.gif\" align=right border=0></a>";
print mkheadr(3,$title);


my @items=ItemInfo(\$blah,$bib,$title);
my $dat=bibdata($bib);
my $count=@items;
print <<printend

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width="220">

<!-----------------BIBLIO RECORD TABLE--------->



<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>BIBLIO RECORD</TD></TR>


<tr VALIGN=TOP  >
<TD>
<br>
<FONT SIZE=2  face="arial, helvetica">
Biblio Number: $bib<br>
Author: $dat->{'author'}<br>
Title: $title<br>
Copyright:$dat->{'copyrightdate'}<br>
Subtitle: $dat->{'subtitle'}<br>
Unititle: $dat->{'unititle'}<br>
Notes: $dat->{'notes'}<br>
Serial: $dat->{'serial'}<br>
Seriestitle: $dat->{'seriestitle'}<br>
Subject: $dat->{'subject'}<br>
Groups: $dat->{'classification'}<br>
Total Number of Items: $count
<p>
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/modify-mem.gif"> 
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
  print mktablerow(6,$main,'Itemtype','Class','Location','DateDue','Lastseen','Barcode'); 
} else {
  print mktablerow(6,$main,'Itemtype','Class','Location','DateDue','Lastseen','Barcode',"/images/background-mem.gif"); 
}
my $colour=1;
while ($i < $count){
  my @results=split('\t',$items[$i]);
  if ($type ne 'opac'){
    $results[1]=mklink("/cgi-bin/koha/moredetail.pl?item=$results[5]",$results[1]);
  }
  if ($results[2] eq ''){
    $results[2]='Available';
  }
  if ($colour == 1){                                                                          
    print mktablerow(6,$secondary,$results[6],$results[4],$results[3],$results[2],$results[7],$results[1]);                                        
    $colour=0;                                                                                
  } else{                                                                                     
    print mktablerow(6,'white',$results[6],$results[4],$results[3],$results[2],$results[7],$results[1]);                                          
    $colour=1;                                                                                
  }
   $i++;
}
print endcenter();
print mktableft();
print endmenu($type);
print endpage();
