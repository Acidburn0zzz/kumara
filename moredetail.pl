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

my $dewey = $data->{'dewey'};                                                  
$dewey =~ s/0+$//;                                                             
if ($dewey eq "000.") { $dewey = "";};                                         
if ($dewey < 10){$dewey='00'.$dewey;}                                          
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}                           
if ($dewey <= 0){
  $dewey='';                                                                   
}               
$dewey=~ s/\.$//;
print <<printend
<br>
<a href=/cgi-bin/koha/request.pl?bib=$bib><img src=/images/requests.gif width=120 height=42 border=0 align=right border=0></a>
<FONT SIZE=6><em><a href=/cgi-bin/koha/detail.pl?bib=$bib&type=intra>$data->{'title'} ($data->{'author'})</a></em></FONT><P>
<p>
<form action=/cgi-bin/koha/modbibitem.pl>
<input type=hidden name=bibitem value=$bi>
<!-------------------BIBLIO ITEM------------>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left>
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif" ><B>$data->{'biblioitemnumber'} GROUP - $data->{'description'} </b> </TD>
</TR>
<tr VALIGN=TOP  >
<TD width=210 >
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/modify-mem.gif"> 
<INPUT TYPE="image" name="submit"  VALUE="delete" height=42  WIDTH=93 BORDER=0 src="/images/delete-mem.gif"> 
<br>
<FONT SIZE=2  face="arial, helvetica">
<b>Biblionumber:</b> $bib<br>
<b>Item Type:</b> $data->{'itemtype'}<br>
<b>Loan Length:</b> $data->{'loanlength'}<br>
<b>Rental Charge:</b> $data->{'rentalcharge'}<br>
<b>Classification:</b> $data->{'classification'}$dewey$data->{'subclass'}<br>
<b>ISBN:</b> $data->{'isbn'}<br>
<b>Publisher:</b> $data->{'publishercode'} <br>
<b>Place:</b><br>
<b>Date:</b> $data->{'publicationdate'}<br>
<b>Volume:</b> $data->{'volumeddesc'}<br>
<b>Pages:</b> $data->{'pages'}<br>
<b>Illus:</b> $data->{'illus'}<br>
<b>Size:</b> $data->{'size'}<br>
<b>Notes:</b> $data->{'notes'}<br>
<b>No. of Items:</b> $count
</font>
</TD>
</tr>
</table>
</form>
printend
;

for (my $i=0;$i<$count;$i++){
print <<printend
<img src="/images/holder.gif" width=16 height=300 align=left>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width=220 >				
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>BARCODE $items[$i]->{'barcode'}</b></TD>
</TR>
<tr VALIGN=TOP  >
<TD width=220 >
<form action=/cgi-bin/koha/moditem.pl method=post>
<input type=hidden name=bibitem value=$bi>
<input type=hidden name=item value=$items[$i]->{'itemnumber'}>
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/modify-mem.gif"> 
<INPUT TYPE="image" name="delete"  VALUE="delete" height=42  WIDTH=93 BORDER=0 src="/images/delete-mem.gif"> 
<br>
printend
;
$items[$i]->{'itemlost'}=~ s/0/No/;
$items[$i]->{'itemlost'}=~ s/1/Yes/;
$items[$i]->{'withdrawn'}=~ s/0/No/;
$items[$i]->{'withdrawn'}=~ s/1/Yes/;
$items[$i]->{'replacementprice'}+=0.00;
my $year=substr($items[$i]->{'timestamp0'},0,4);
my $mon=substr($items[$i]->{'timestamp0'},4,2);
my $day=substr($items[$i]->{'timestamp0'},6,2);
$items[$i]->{'timestamp0'}="$day/$mon/$year";
my @temp=split('-',$items[$i]->{'dateaccessioned'});
$items[$i]->{'dateaccessioned'}="$temp[2]/$temp[1]/$temp[0]";
@temp=split('-',$items[$i]->{'datelastseen'});
$items[$i]->{'datelastseen'}="$temp[2]/$temp[1]/$temp[0]";
print <<printend
<FONT SIZE=2  face="arial, helvetica">
<b>Home Branch:</b> $items[$i]->{'homebranch'}<br>
<b>Last seen:</b> $items[$i]->{'datelastseen'}<br>
<b>Last borrowed:</b> $items[$i]->{'timestamp0'}<br>
<b>Currently on issue to:</b> <a href=/cgi-bin/koha/moremember.pl?bornum=$items[$i]->{'borrower0'}>$items[$i]->{'card0'}</a><br>
<b>Last Borrower 1:</b> $items[$i]->{'card'}<br>
<b>Last Borrower 2:</b> $items[$i]->{'card1'}<br>
<b>Current Branch:</b> $items[$i]->{'holdingbranch'}<br>
<b>Replacement Price:</b> $items[$i]->{'replacementprice'}<br>
<b>Item lost:</b> $items[$i]->{'itemlost'}<br>
<b>paid by:</b><br>
<b>Notes:</b> $items[$i]->{'itemnotes'}<br>
<b>Renewals:</b> $items[$i]->{'renewals'}<br>
<b>Accession Date: $items[$i]->{'dateaccessioned'}<br>
<b>Cancelled: $items[$i]->{'withdrawn'}<br>
<b>Total Issues:</b> $items[$i]->{'issues'}<br>
<b>Group Number:</b> $bi <br>
<b>Biblio number:</b> $bib <br>



</font>
</TD>
</tr>
</table>
</form>
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
