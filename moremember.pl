#!/usr/bin/perl

#script to do a borrower enquiery/brin up borrower details etc
#written 20/12/99 by chris@katipo.co.nz

use strict;
use C4::Output;
use CGI;
use C4::Search;
use Date::Manip;

my $input = new CGI;
my $bornum=$input->param('bornum');

print $input->header;
#start the page and read in includes
print startpage();
print startmenu('member');
my $data=borrdata('',$bornum);
print <<printend


<FONT SIZE=6><em>$data->{'othernames'} $data->{'surname'}</em></FONT><P>
<p>


<form action=/cgi-bin/kumara/member.pl method=post>

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left>

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>MEMBERSHIP RECORD</TD></TR>


<tr VALIGN=TOP  >
	
<TD>
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/modify-mem.gif"> 
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/delete-mem.gif"> 		
<INPUT TYPE="image" name="submit"  VALUE="modify" height=42  WIDTH=120 BORDER=0 src="/images/add-child.gif"> 		
<br>
<FONT SIZE=2  face="arial, helvetica">$data->{'title'} $data->{'othernames'}  $data->{'surname'} ($data->{'firstname'}, RL)<p>
Membership Number: $data->{'borrowernumber'}<BR>
Card Number: $data->{'cardnumber'}<BR>
Membership: $data->{'categorycode'}<BR>
Area: $data->{'Area'}<BR>
Fee:$30/year, Paid<BR>
Joined: $data->{'dateenrolled'},  Expires: <BR>
Joining Branch: Levin<P>
Ethnicity: $data->{'ethnicity'}, $data->{'ethnotes'}<BR>
DoB: $data->{'dateofbirth'}<BR>
Sex: $data->{'sex'}<P>
Postal Address: $data->{'streetaddress'}, $data->{'city'}<BR>
Home Address: $data->{'streetaddress'}, $data->{'city'}<BR>
Phone (Home): $data->{'phone'}<BR>
Phone (Daytime): $data->{'dayphone'}<BR>
Fax: $data->{'faxumber'}<BR>
E-mail: <a href="mailto:$data->{'emailaddress'}">$data->{'emailaddress'}</a><P>
Alternative Contact:$data->{'contactname'}<BR>
Phone: $data->{'contphone'}<BR>
Relationship: $data->{'contrelationship'}<BR>
Notes: $data->{'contnotes'}<P>
Guarantees: <A HREF="sam.html">Guarantor goes here</a><P>

General Notes: <A HREF="popbox.html" onclick="messenger(200,250,'Form that lets you add to and delete notes.'); return false">
$data->{'borrowernotes'}</a>
</TD>
</TR>
</TABLE>
</FORM>
<img src="/images/holder.gif" width=16 height=800 align=left>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=3><B>FINES & CHARGES</TD></TR>
printend
;
my %bor;
$bor{'borrowernumber'}=$bornum;
my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);
for (my$i=0;$i<$numaccts;$i++){
if ($accts->[$i]{'accounttype'} ne 'Pay'){
  my $amount= $accts->[$i]{'amountoutstanding'} + 0.00;
  print "<tr VALIGN=TOP  >";
  my $item=" &nbsp; ";
  if ($accts->[$i]{'accounttype'} ne 'Res'){
    #get item data
    #$item=
  }
  print "<TD>$item</td>";
  print "<TD>$accts->[$i]{'description'}</td>
  <TD>$amount</td>
  </tr>";
}
}
print <<printend

<tr VALIGN=TOP  >
<TD colspan=3 align=right>
<nobr>
<a href=rachey-account.html><img height=42  WIDTH=187 BORDER=0 src="/images/view-account.gif"></a>
<a href=rachey-pay.html><img height=42  WIDTH=187 BORDER=0 src="/images/pay-fines.gif"></a></nobr>
</td>

</tr>


</table>

<p>
<form action="renewscript.pl">
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=5><B>ITEMS CURRENTLY ON ISSUE</b></TD>
</TR>

<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Title</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Due</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Charges</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Status</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Renew</b></TD>
</TR>
printend
;
my ($count,$issue)=borrissues($bornum);
my $today=ParseDate('today');
for (my $i=0;$i<$count;$i++){
  print "<tr VALIGN=TOP  >
  <TD><font color=red></font>$issue->[$i]{'title'}</td>
  <TD>$issue->[$i]{'date_due'}</td>
  <TD></td>";
  my $datedue=ParseDate($issue->[$i]{'date_due'});
  if ($datedue < $today){
    print "<td>Overdue</td>";
  } else {
    print "<td> &nbsp; </td>";
  }
  print "<TD><input type=radio name=\"renew_item_123\" value=y>Y
  <input type=radio name=\"renew_item_$issue->[$i]{'itemnumber'}\" value=n>N</td>
  </tr>
";
}
print <<printend

<tr VALIGN=TOP  >
<TD colspan=5 align=right>
<INPUT TYPE="image" name="submit"  VALUE="update" height=42  WIDTH=187 BORDER=0 src="/images/update-renewals.gif">
</td>

</tr>


</table>


<P>

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=5><B>ITEMS REQUESTED</b></TD>
</TR>

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Title</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Requested</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Due</b></TD>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Charges</b></TD>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Remove</b></TD>
</TR>


<tr VALIGN=TOP  >

<TD><a href="link to biblio record with all requests">Fish of the NZ</a></td>
<TD>2/12/99</td>
<TD>6/12/99</td>
<TD>$2</td>

<TD><input type=radio name="remove-request_123" value=y>Y
<input type=radio name="remove-request_123" value=n>N</td>

																																																																														        </tr>
																																																																															
																																																																															
																																																																															
																																																																															
																																																																															<tr VALIGN=TOP  >
																																																																															
																																																																															        <TD colspan=5 align=right>
																																																																																<INPUT TYPE="image" name="submit"  VALUE="update" height=42  WIDTH=187 BORDER=0 src="/images/cancel-requests.gif"></td>
																																																																																
																																																																																        </tr>
																																																																																	
																																																																																	
																																																																																	</table>
																																																																																	
																																																																																	<p align=right>
																																																																																	
																																																																																	<a href=rachey-reading.html><img height=42  WIDTH=187 BORDER=0 src="/images/reading-record.gif"></a>
																																																																																	</p>




printend
;


print endmenu('member');
print endpage();