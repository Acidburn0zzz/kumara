#!/usr/bin/perl

#wrriten 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details

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


  
print $input->header;
print startpage();
print startmenu('member');
print <<printend
<FONT SIZE=6><em>Account for $data->{'firstname'} $data->{'surname'}</em></FONT><P>
<center>
<p>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=4><B>FINES & CHARGES</TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=4><B>CALCULATE</TD>
</TR>


printend
;
for (my $i=0;$i<$numaccts;$i++){
$accts->[$i]{'amount'}+=0.00;
$accts->[$i]{'amountoutstanding'}+=0.00;
print <<printend
<tr VALIGN=TOP  >
<td>$accts->[$i]{'date'}</td>
<TD>$accts->[$i]{'description'}
printend
;
if ($accts->[$i]{'accounttype'} ne 'F' && $accts->[$i]{'accounttype'} ne 'FU'){
  print "$accts->[$i]{'title'}";
}
print <<printend
</td>
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



</form>
</table>






<br clear=all>
<p> &nbsp; </p>

printend
;
print endmenu('member');
print endpage();

