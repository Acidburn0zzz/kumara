#!/usr/bin/perl

#wrriten 11/1/2000 by chris@katipo.oc.nz
#part of the koha library system, script to facilitate paying off fines

use strict;
use C4::Output;
use CGI;
use C4::Search;
my $input=new CGI;


my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);


#get account details
my %bor;
$bor{'borrowernumber'}=$bornum;                            
my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);   

my @names=$input->param;
my %inp;
my $check=0;
for (my $i=0;$i<@names;$i++){
  my$temp=$input->param($names[$i]);
  if ($temp eq 'wo'){
    $inp{$names[$i]}=$temp;
    $check=1;
  }
}
if ($check ==0){
  
print $input->header;
print startpage();
print startmenu('member');
print <<printend
<FONT SIZE=6><em>Pay Fines for $data->{'firstname'} $data->{'surname'}</em></FONT><P>
<center>
<p>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=4><B>FINES & CHARGES</TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=4><B>CALCULATE</TD>
</TR>
<form action=/cgi-bin/koha/pay.pl method=post>

printend
;
for (my $i=0;$i<$numaccts;$i++){
print <<printend
<tr VALIGN=TOP  >
<TD><input type=radio name=payfine$i value=no checked>Unpaid
<input type=radio name=payfine$i value=yes>Pay
<input type=radio name=payfine$i value=wo>Writeoff
<input type=hidden name=bornum value=$bornum>

</td>
<TD>$accts->[$i]{'description'}</td>
<TD>$accts->[$i]{'accounttype'}</td>
<td>$accts->[$i]{'amount'}</td>
<TD>$accts->[$i]{'amountoutstanding'}</td>

</tr>
printend
;
}
print <<printend
<tr VALIGN=TOP  >
<TD></td>
<TD colspan=2><b>Total Due</b></td>

<TD><b>$total</b></td>

</tr>



<tr VALIGN=TOP  >
<TD></td>
<TD colspan=3><b>AMOUNT PAID</b></td>
<TD><input type=text name=total value="" SIZE=7></td>
</tr>
<tr VALIGN=TOP  >
<TD colspan=5 align=right>
<INPUT TYPE="image" name="submit"  VALUE="pay" height=42  WIDTH=187 BORDER=0 src="/images/pay-fines.gif"></td>
</tr>
</form>
</table>






<br clear=all>
<p> &nbsp; </p>

printend
;
print endmenu('member');
print endpage();

} else {
  print $input->redirect("/cgi-bin/koha/sec/writeoff.pl");
}
