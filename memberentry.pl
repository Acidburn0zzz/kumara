#!/usr/bin/perl

#script to set up screen for modification of borrower details
#written 20/12/99 by chris@katipo.co.nz

use strict;
use C4::Output;
use CGI;
use C4::Search;


my $input = new CGI;
my $member=$input->param('bornum');
my $type=$input->param('type');

print $input->header;
print startpage();
print startmenu('member');

if ($type ne 'Add'){
  print mkheadr(1,'Update Member Details');
} else {
  print mkheadr(1,'Add New Member');
}
my $data=borrdata('',$member);
print <<printend
<form action=/cgi-bin/koha/newmember.pl method=post>

<input type=hidden name=type value="borrowers">
<input type=hidden name=borrowernumber="$member">
<input type=hidden name=updtype value="M">


<table border=0 cellspacing=0 cellpadding=5 >


<tr valign=top><td  COLSPAN=2><input type=reset value="Clear all Fields"></td><td  COLSPAN=3   ALIGN=RIGHT ><font size=4 face='arial,helvetica'>
Member# $member,   Card Number* <input type=text name=cardnumber size=10 value="$data->{'cardnumber'}"><br>
</td></tr>


<tr valign=top  ><td  COLSPAN=3 background="/images/background-mem.gif">
<B>MEMBER PERSONAL DETAILS</b></td> <td  COLSPAN=2  ALIGN=RIGHT background="/images/background-mem.gif">
* <input type="radio" name="sex" value="f"
printend
;
if ($data->{'sex'} eq 'F'){
  print " checked";
}
print <<printend
>F  
<input type="radio" name="sex" value="m"
printend
;
if ($data->{'sex'} eq 'M'){
  print " checked";
}
print <<printend
>M
&nbsp; &nbsp;  <B>Date of Birth</B> (dd/mm/yy)
<input type=text name=dateofbirth size=10 value="$data->{'dateofbirth'}">
</td></tr>
<tr valign=top bgcolor=white>
<td><SELECT NAME="title" SIZE="1">
<OPTION value=" ">
<OPTION value=Miss
printend
;
if ($data->{'title'} eq 'Miss'){
  print " Selected";
}
print ">Miss
<OPTION value=Mrs";
if ($data->{'title'} eq 'Mrs'){
  print " Selected";
}
print ">Mrs
<OPTION value=Ms";
if ($data->{'title'} eq 'Ms'){
  print " Selected";
}
print ">Ms
<OPTION value=Mr";
if ($data->{'title'} eq 'Mr'){
  print " Selected";
}
print ">Mr
<OPTION value=Dr";
if ($data->{'title'} eq 'Dr'){
  print " Selected";
}
print ">Dr
<OPTION value=Sir";
if ($data->{'title'} eq 'Sir'){
  print " Selected";
}
print <<printend
>Sir
</SELECT>
</td>

<td><input type=text name=initials size=5 value="$data->{'initials'}"></td>
<td><input type=text name=firstname size=20 value="$data->{'firstname'}"></td>
<td><input type=text name=surname size=20 value="$data->{'surname'}"></td>
<td><input type=text name=othernames size=20 value="$data->{'othernames'}"></td></tr>
<tr valign=top bgcolor=white>
<td><FONT SIZE=2>Title</FONT></td>
<td><FONT SIZE=2>Initials</FONT></td>
<td><FONT SIZE=2>Given Names*</FONT></td>
<td><FONT SIZE=2>Surname*</FONT></td>
<td><FONT SIZE=2>Prefered Name</FONT></td>
</tr>

<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor=white>
<td colspan=2><SELECT NAME="ethnicity" SIZE="1">
<OPTION value=" ">
<OPTION value=european>European/Pakeha
<OPTION value=maori>Maori
<OPTION value=asian>Asian
<OPTION value=pi>Pacific Island
<OPTION value=other>Other - please specify-->
</SELECT>
</td>
<td colspan=2><input type=text name=ethnicnotes size=40 ></td>
<td> <select name=categorycode>
<option value="A"
printend
;
if ($data->{'categorycode'} eq 'A'){
  print " Selected";
}
print ">Adult
<option value=B";
if ($data->{'categorycode'} eq 'B'){
  print " Selected";
}
print ">Homebound
<option value=P";
if ($data->{'categorycode'} eq 'P'){
  print " Selected";
}
print ">Privileged
<option value=E";
if ($data->{'categorycode'} eq 'E'){
  print " Selected";
}
print ">Senior Citizen
<option value=W";
if ($data->{'categorycode'} eq 'W'){
  print " Selected";
}
print ">Staff
<option value=I";
if ($data->{'categorycode'} eq 'I'){
  print " Selected";
}
print ">Institution
<option value=C";
if ($data->{'categorycode'} eq 'C'){
  print " Selected";
}
print ">Child
<option value=L";
if ($data->{'categorycode'} eq 'L'){
  print " Selected";
}
print ">Library
<option value=F";
if ($data->{'categorycode'} eq 'F'){
  print " Selected";
}
print ">Family";
print <<printend
</select>
</td>
</tr>																																													
<tr valign=top bgcolor=white>
<td colspan=2><FONT SIZE=2>Ethnicity</FONT></td>
<td colspan=2><FONT SIZE=2>Ethnicity Notes</FONT></td>
<td><FONT SIZE=2>Membership Category*</FONT></td>
</tr>
<tr><td>&nbsp; </TD></TR>

<tr valign=top bgcolor="99cc33" ><td  COLSPAN=5 background="/images/background-mem.gif">
<B>MEMBER ADDRESS</b></td></tr>
<tr valign=top bgcolor=white>
<td  COLSPAN=3><input type=text name=address size=40 value="$data->{'streetaddress'}">
<td><input type=text name=city size=20 value="$data->{'city'}"></td>
<td>
<SELECT NAME="area" SIZE="1">
<OPTION value=L
printend
;
if ($data->{'area'} eq 'L'){
  print " Selected";
}
print ">L - Levin
<OPTION value=F";
if ($data->{'area'} eq 'F'){
  print " Selected";
}
print ">F - Foxton
<OPTION value=S";
if ($data->{'area'} eq 'S'){
  print " Selected";
}
print ">S - Shannon
<OPTION value=H";
if ($data->{'area'} eq 'H'){
  print " Selected";
}
print ">H - Horowhenua
<OPTION value=K";
if ($data->{'area'} eq 'K'){
  print " Selected";
}
print ">K - Kapiti
<OPTION value=O";
if ($data->{'area'} eq 'O'){
  print " Selected";
}
print ">O - Out of District
<OPTION value=X";
if ($data->{'area'} eq 'X'){
  print " Selected";
}
print ">X - Temporary Visitor
<OPTION value=Z";
if ($data->{'area'} eq 'Z'){
  print " Selected";
}
print <<printend
>Z - Interloan Libraries
</SELECT></td></tr>
<tr valign=top bgcolor=white>
<td  COLSPAN=3><FONT SIZE=2>Postal Address*</FONT></td>
<td><FONT SIZE=2>Town*</FONT></td>
<td><FONT SIZE=2>Area</FONT></td>
</tr>
<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor=white>

<td  COLSPAN=3><input type=text name=streetaddress size=40 value="$data->{'physstreetaddress'}"></td>
<td><input type=text name=streetcity size=20 value="$data->{'physcity'}"></td>
</tr>
</tr>
<tr valign=top bgcolor=white>

<td  COLSPAN=3><FONT SIZE=2>Street Address if different</FONT></td>
<td><FONT SIZE=2>Town</FONT></td>
</tr>
<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor="99cc33"  ><td  COLSPAN=5  background="/images/background-mem.gif">
<B>MEMBER CONTACT DETAILS</b></td></tr>


<tr valign=top bgcolor=white>
<td   COLSPAN=2 ><input type=text name=phone size=20 value="$data->{'phone'}"></td>
<td><input type=text name=phoneday size=20 value="$data->{'workphone'}"></td>
<td><input type=text name=faxnumber size=20 value="$data->{'faxnumber'}"></td>
<td><input type=text name=emailaddress size=20 value="$data->{'emailaddress'}"></td></tr>

<tr valign=top bgcolor=white>
<td   COLSPAN=2 ><FONT SIZE=2>Phone (Home)</td>
<td><FONT SIZE=2>Phone (day)</td>
<td><FONT SIZE=2>Fax</td>
<td><FONT SIZE=2>Email</td></tr>
<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor="99cc33"  ><td  COLSPAN=5  background="/images/background-mem.gif">
<B>ALTERNATE CONTACT DETAILS</b> </td></tr>

<tr valign=top bgcolor=white>
<td   COLSPAN=3 ><input type=text name=contactname size=40 value="$data->{'contactname'}"></td>
<td><input type=text name=altphone size=20 value="$data->{'altphone'}"></td>
<td><select name=altrelationship size=1>
<option value="workplace">Workplace
<option value="relative">Relative
<option value="friend">Friend
<option value="neighbour">Neighbour
</select></td></tr>

<tr valign=top bgcolor=white>
<td   COLSPAN=3 ><FONT SIZE=2>Name*</td>
<td><FONT SIZE=2>Phone</td>
<td><FONT SIZE=2>Relationship*</td></tr>



<tr><td>&nbsp; </TD></TR>


<tr valign=top bgcolor=white>

<td><FONT SIZE=2>Notes</font></td>
<td  COLSPAN=4><textarea name=altnotes wrap=physical cols=70 rows=3></textarea></td></tr>
</tr>


<tr><td>&nbsp; </TD></TR>


<tr valign=top bgcolor="99cc33"  >

<td  COLSPAN=5  background="/images/background-mem.gif"><B>LIBRARY USE</B></td>
</tr>


<tr valign=top >

<td><FONT SIZE=2>Notes</font></td>
<td  COLSPAN=4><textarea name=borrowernotes wrap=physical cols=70 rows=3>$data->{'borrowernotes'}</textarea></td></tr>
<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor=white><td  COLSPAN=5 align=right >

<A HREF="confirmation.html"><img src="/images/button-add-member.gif"  WIDTH=188  HEIGHT=44  ALT="Add New Member" border=0 ></a></td>
<td  align=right><input type=submit><BR></td></tr>
</TABLE>
</table>
																																																													</form>
																																																													
																																																													

printend
;
print endmenu('member');
print endpage();
