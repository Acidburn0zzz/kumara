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
my $bi=$input->param('bi');
my $data=bibitemdata($bi);

my (@items)=itemissues($bi);
#print @items;
my $count=@items;

my $i=0;
print center();

print <<printend
<br>
<a href=request.html><img src=/images/requests.gif width=120 height=42 border=0 align=right border=0></a>
<FONT SIZE=6><em>$data->{'title'} ($data->{'author'})</em></FONT><P>
<p>
<form >
<!-------------------BIBLIO ITEM------------>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left>
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif" ><B>$data->{'biblioitemnumber'} GROUP - $data->{'description'} </b> </TD>
</TR>
<tr VALIGN=TOP  >
<TD width=210 >
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/modify-mem.gif"> 
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/delete-mem.gif"> 
<br>
<FONT SIZE=2  face="arial, helvetica">
Biblionumber:$bib<br>
Item Type:$data->{'itemtype'}<br>
Loan Length: $data->{'loanlength'}<br>
Rental Charge: $data->{'rentalscharge'}<br>
Classification:$data->{'classification'}$data->{'dewey'}$data->{'subclass'}<br>
ISBN: $data->{'isbn'}<br>
Publisher: <br>
Place:<br>
Date:$data->{'publicationdate'}<br>
Pages:$data->{'pages'}<br>
Illus:$data->{'illus'}<br>
No. of Items:$count
</font>
</TD>
</tr>
</table>
printend
;

for (my $i=0;$i<$count;$i++){
print <<printend
<img src="/images/holder.gif" width=16 height=250 align=left>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width=220 >				
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>BARCODE $items[$i]->{'barcode'}</b></TD>
</TR>
<tr VALIGN=TOP  >
<TD width=220 >
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/modify-mem.gif"> 
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/delete-mem.gif"> 
<br>
<FONT SIZE=2  face="arial, helvetica">
Due Date: $items[$i]->{'date_due'}<br>
Member: $items[$i]->{'card'}<br>
Last seen: $items[$i]->{'datalastseen'}<br>
No. issues: $items[$i]->{'issues'}<br>
No. Reserves: $items[$i]->{'reserves'}<br>
Notes: $items[$i]->{'itemnotes'}
</font>
</TD>
</tr>
</table>
printend
;
}
print <<printend
<p>
</form>
printend
;


print endcenter();

print endmenu($type);
print endpage();
