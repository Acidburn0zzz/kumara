#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

use C4::Acquisitions;
use C4::Output;
use CGI;
use strict;

my $input=new CGI;
print $input->header();
my $basket=$input->param('basket');
my ($count,@results)=basket($basket);
print startpage;

print startmenu('acquisitions');

print $count;

print <<printend
<div align=right>
Our Reference: $basket<br>
Authorsed By: $results[0]->{'authorisedby'}<br>
$results[0]->{'entrydate'}
</div>
<FONT SIZE=6><em>Shopping Basket For: <a href=whitcoulls.html>Whitcoulls New Zealand Ltd</a> </em></FONT>




<CENTER>

<FORM ACTION="/cgi-bin/koha/search.pl">
<b>Search ISBN, Title or Author:</b> <INPUT TYPE="text"  SIZE="25"   NAME="recieve">
</form>
<p>
<FORM ACTION="/cgi-bin/koha/acquire.pl">
<table border=0 cellspacing=0 cellpadding=5>
<tr valign=top bgcolor=#99cc33>
<td background="/images/background-mem.gif"><b>ORDER</b></td>
<td background="/images/background-mem.gif"><b>ISBN</b></td>
<td background="/images/background-mem.gif"><b>TITLE</b></td>
<td background="/images/background-mem.gif"><b>AUTHOR</b></td>
<td background="/images/background-mem.gif"><b>RRP</b></td><td background="/images/background-mem.gif"><b>\$EST</b></td><td background="/images/background-mem.gif"><b>QUANTITY</b></td><td background="/images/background-mem.gif"><b>TOTAL</b></td></tr>
printend
;
for (my $i=0;$i<$count;$i++){
print <<printend

<tr valign=top bgcolor=#ffffcc>
<td>11234</td>
<td>0-85574-930-X</td>
<td><a href="item.html">A dinner of herbs</a></td>
<td>Cookson, Catherine</td>
<td>\$<input type=text name=rrp size=6 value=19.95></td>
<td>\$<input type=text name=eup size=6 value=16.95></td>
<td><input type=text name=quantity size=6 value=1></td>
<td>\$<input type=text name=total size=10 value=16.95></td>

</tr>

								
printend
;

print <<printend
<tr valign=top bgcolor=white>

<td colspan=6 rowspan=3  bgcolor=#cccc99  background="/images/background-mem.gif">
<b>HELP</b><br>
To cancel an order, just change the quantity to 0 and click "save changes".<br>
To change any of the catalogue or accounting information attached to an order,  click on the title.<br>
To add new orders to this supplier, start with a search. </td> 
<td><b>SubTotal</b></td>
<td>\$<input type=text name=subtotal size=10></td>
</tr>
<tr valign=top bgcolor=white>
<td><b>GST</b></td>
<td>\$<input type=text name=gst size=10></td>

</tr>

<tr valign=top bgcolor=white>


<td><b>TOTAL</b></td>
<td>\$<input type=text name=grandtotal size=10></td>

</tr>

<tr valign=top bgcolor=white>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td colspan=3><input type=image  name=submit src=/images/save-changes.gif border=0 width=187 height=42 align=right></td>

</tr>




</table>
</CENTER>

<b><font color=red>NOTES TO LIBRARY AND PROGRAMMERS</FONT></B>
<BR>
Again a bunch of questions here that you may have already answered elsewhere - but I couldn't spot it. 
Is GST charged on overseas orders?  
<br>
Is GST usually include in the RRP, and thus the Estimated price? Or do your suppliers quote ex GST


printend
;

print endmenu('acquisitions');

print endpage;
