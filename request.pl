#!/usr/bin/perl

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::Reserves2;

my $input = new CGI;
print $input->header;


#setup colours
print startpage();
print startmenu();
my $blah;
my $bib=$input->param('bib');
my $dat=bibdata($bib);
my ($count,$reserves)=FindReserves($bib);
#print $count;
#print $input->dump;


print <<printend

<FONT SIZE=6><em>Requesting: <a href=biblio.html>$dat->{'title'}</a> ($dat->{'author'})</em></FONT><P>
<p>
<form action="placerequest.pl" method=post>
<INPUT TYPE="image" name="submit"  VALUE="request" height=42  WIDTH=187 BORDER=0 src="/images/place-request.gif" align=right >
<input type=hidden name=biblio value=$bib>
<input type=hidden name=type value=str8>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left >

<!----------------BIBLIO RESERVE TABLE-------------->

<p align=right>

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Rank</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Member</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Date</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pickup</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
</TR>
<tr VALIGN=TOP  >
<TD><select name=rank-request>
printend
;
$count++;
my $i;
for ($i=1;$i<$count;$i++){
  print "<option value=$i>$i\n";
}
print "<option value=$i selected>$i\n";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$year=$year+1900;
$mon++;
my $date="$mday/$mon/$year";
print <<printend
</select>
</td>
<TD><input type=text size=20 name=member></td>
<TD>$date</td>
<TD><select name=pickup>
<option value=L>Levin
<option value=F>Foxton
<option value=S>Shannon
</select>
</td>
<td><input type=checkbox name=request value=any>Next Available, <br>(or choose from list below)</td>
</tr>


</table>
</p>


<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Item Type</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Classification</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Volume</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Number</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Copyright</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pubdate</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Copies</b></TD>
</TR>
printend
;
my $blah;
my @data=ItemInfo(\$blah,$bib);
my $count2=@data;
for ($i=0;$i<$count2;$i++){
  my @stuff=split('\t',$data[$i]);
  print "<tr VALIGN=TOP  >
  <TD><input type=checkbox name=reqbib value=$stuff[8]>
  <input type=hidden name=biblioitem value=$stuff[8]>
  </td>
  <TD>$stuff[6]</td>
  <TD>$stuff[4]
  </td>																								
  <td></td>
  <td></td>
  <td></td>
  <td></td>
  <td>$stuff[1], $stuff[2] </td>
  </tr>";
}
print <<printend
</table>
</p>
<form>
<p>&nbsp; </p>
<!-----------MODIFY EXISTING REQUESTS----------------->

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=6><B>MODIFY EXISTING REQUESTS </b></TD>
</TR>
<form action=placerequest.pl method=post>
<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Rank</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Member</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Date</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pickup</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Change To</b></TD>
</TR>
printend
;
$count--;

for ($i=0;$i<$count;$i++){
my $bor=$reserves->[$i]{'firstname'}."%20".$reserves->[$i]{'surname'};
$bor=~ s/ /%20/g;
my @temp=split('-',$reserves->[$i]{'reservedate'});
$date="$temp[2]/$temp[1]/$temp[0]";
print "<tr VALIGN=TOP  >
<TD><select name=rank-request>
<option value=1>1
<option value=2>2
<option value=3>3
<option value=\"\">Del
</select>
</td>
<TD><a href=/cgi-bin/koha/member.pl?member=$bor>$reserves->[$i]{'firstname'} $reserves->[$i]{'surname'}</a></td>
<TD>$date</td>
<TD><select name=pickup>
<option value=levin>Levin
<option value=foxton>Foxton
<option value=Shannon>Shannon
</select>
</td>
<TD>Next Available</td>
<TD><select name=itemtype>
<option value=next>Next Available
<option value=change>Change Selection
<option value=nc >No Change
</select>
</td>
</tr>
";
}
print <<printend


<tr VALIGN=TOP  >

<TD colspan=6 align=right>
Delete a request by selcting "del" from the rank list.

<INPUT TYPE="image" name="submit"  VALUE="request" height=42  WIDTH=64 BORDER=0 src="/images/ok.gif"></td>


</tr>


</table>
<P>

<br>




</form>
printend
;

print endmenu();
print endpage();
