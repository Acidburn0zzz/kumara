#!/usr/bin/perl

#script to show list of budgets and bookfunds
#written 4/2/00 by chris@katipo.co.nz
#called as an include by the acquisitions index page

use C4::Acquisitions;

print <<printend

<TABLE  width="40%"  cellspacing=0 cellpadding=5 border=1 >
<FORM ACTION="/cgi-bin/koha/search.pl">
<TR VALIGN=TOP>
<TD  bgcolor="99cc33" background="/images/background-mem.gif" colspan=2><b>BUDGETS AND BOOKFUNDS</b></TD></TR>
<TR VALIGN=TOP>
<TD colspan=2><table>


<tr><td>
<b>Budgets</B></TD> <TD><b>Total</B></TD> <TD><b>Spent</B></TD><TD><b>Comtd</B></TD><TD><b>Avail</B></TD></TR>



<tr><td>
<A HREF="total-budget-1.html">Fund Name</a> </TD> <TD>$10 000</TD> <TD>$6000</TD><TD>$3000</TD><TD>$1000</TD></TR>

<tr><td>
<A HREF="total-budget-2.html">Children</a> </TD> <TD>$10 000</TD> <TD>$6000</TD><TD>$3000</TD><TD>$1000</TD></TR>

<tr><td>
<A HREF="total-budget-3.html">Maori</a> </TD> <TD>$10 000</TD> <TD>$6000</TD><TD>$3000</TD><TD>$1000</TD></TR>

<tr><td>
<A HREF="total-budget-4.html">Talking Books</a> </TD> <TD>$10 000</TD> <TD>$6000</TD><TD>$3000</TD><TD>$1000</TD></TR>

<tr><td>
<A HREF="total-budget-5.html">etc</a> </TD> <TD>$10 000</TD> <TD>$6000</TD><TD>$3000</TD><TD>$1000</TD></TR>

<tr><td>
<A HREF="total-budget-6.html">fund name</a> </TD> <TD>$10 000</TD> <TD>$6000</TD><TD>$3000</TD><TD>$1000</TD></TR>
<tr><td colspan=5>
<hr size=1 noshade></TD></TR>

<tr><td>
<A HREF="total.html">Total</a> </TD> <TD>$60 000</TD> <TD>$36000</TD><TD>$18000</TD><TD>$6000</TD></TR>

</table><br>
Use your reload button [ctrl + r] to get the most recent figures.
Committed figures are approximate only, as exchange rates will affect the amount actually paid.

</TD></TR>
</form>
</table>

printend
;
