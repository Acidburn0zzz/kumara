#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

use C4::Acquisitions;
use C4::Output;
use C4::Search;
use CGI;
use strict;

my $input=new CGI;
print $input->header();
my $id=$input->param('id');
my $title=$input->param('title');
my $author=$input->param('author');
my $copyright=$input->param('copyright');
my ($count,@booksellers)=bookseller($id);
my $ordnum=$input->param('ordnum');
my $biblio=$input->param('biblio');
my $data;
if ($ordnum eq ''){
  $ordnum=newordernum;
  $data=bibdata($biblio);
  if ($data->{'title'} eq ''){
    $data->{'title'}=$title;
    $data->{'author'}=$author;
    $data->{'copyrightdate'}=$copyright;
  }
}else {
  $data=getsingleorder($ordnum);
  $biblio=$data->{'biblionumber'};
} 

print startpage;

print startmenu('acquisitions');


my $basket=$input->param('basket');
print <<printend


<script language="javascript" type="text/javascript">

<!--

function update(f){
  //collect values
  quantity=f.quantity.value
  discount=f.discount.value
  listinc=parseInt(f.listinc.value)
  currency=f.currency.value
  applygst=parseInt(f.applygst.value)
  listprice=f.list_price.value
  //  rrp=f.rrp.value
  //  ecost=f.ecost.value  //budgetted cost
  //  GST=f.GST.value
  //  total=f.total.value  
  //make useful constants out of the above  
  exchangerate=f.elements[currency].value      //get exchange rate  
  gst_on=(!listinc && applygst);
  //do real stuff  
  rrp=listprice*exchangerate;
  ecost=rrp*(100-discount)/100
  GST=0;
  if (gst_on){
    rrp=rrp*1.125;
    GST=ecost*0.125
  }
  
  total=(ecost+GST)*quantity
  
  
  f.rrp.value=display(rrp)
  f.ecost.value=display(ecost)
  f.GST.value=display(GST)
  f.total.value=display(total)
  
}
								      


function messenger(X,Y,etc){
win=window.open("","mess","height="+X+",width="+Y+",screenX=150,screenY=0");
win.focus();
win.document.close();
win.document.write("<body link='#333333' bgcolor='#ffffff' text='#000000'><font size=2><p><br>");
win.document.write(etc);
win.document.write("<center><form><input type=button onclick='self.close()' value=Close></form></center>");
win.document.write("</font></body></html>");
}
//-->

</script>
<form action=/cgi-bin/koha/acqui/addorder.pl method=post name=frusin>
printend
;

if ($biblio eq ''){
  print "<input type=hidden name=existing value=no>";
}
print <<printend
<!--$title-->
<input type=hidden name=ordnum value=$ordnum>
<input type=hidden name=basket value=$basket>
<input type=hidden name=supplier value=$id>
<input type=hidden name=biblio value=$biblio>
<input type=hidden name=bibitemnum value=$data->{'biblioitemnumber'}>
<input type=hidden name=oldtype value=$data->{'itemtype'}>
<input type=hidden name=discount value=$booksellers[0]->{'discount'}>
<input type=hidden name=listinc value=$booksellers[0]->{'listincgst'}>
<input type=hidden name=currency value=$booksellers[0]->{'listprice'}>
<input type=hidden name=applygst value=$booksellers[0]->{'gstreg'}>
printend
;
my ($count2,$currencies)=getcurrencies;
for (my $i=0;$i<$count2;$i++){
  print "<input type=hidden name=\"$currencies->[$i]->{'currency'}\" value=$currencies->[0]->{'rate'}>";
}

print <<printend;
<a href=basket.pl?basket=$basket><img src=/images/view-basket.gif width=187 heigth=42 border=0 align=right alt="View Basket"></a> 
<FONT SIZE=6><em>$ordnum - Order Details </em></FONT><br>
Shopping Basket For: $booksellers[0]->{'name'}
<P>
<CENTER>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width="40%">
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>CATALOGUE DETAILS</B></td></tr>
<TR VALIGN=TOP>
<TD><b>Title *</b></td>
<td><input type=text size=20 name=title value="$data->{'title'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Author</td>
<td><input type=text size=20 name=author value="$data->{'author'}" >
</td>
</tr>
<TR VALIGN=TOP>
<TD>Copyright Date</td>
<td><input type=text size=20 name=copyright value="$data->{'copyrightdate'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD><A HREF="popbox.html" onclick="messenger(600,300,'ITEMTYPES<BR>ART = Art Print<BR>BCD = CD-ROM from book<BR>CAS = Cassette<BR>CD = Compact disc (WN)<BR>F = Free Fiction<BR>FVID = Free video<BR>FYA = Young Adult Fiction<BR>GWB = Get Well Bag<BR>HCVF = Horowhenua Collection Vertical File<BR>IL = Interloan<BR>JCF = Junior Castle Fiction<BR>JCNF = Junior Castle Non-fiction<BR>JF = Junior Fiction<BR>JHC = Junior Horowhenua Collection VF<BR>JIG = Jigsaw puzzle<BR>JK = Junior Kermit<BR>JNF = Junior Non-Fiction<BR>JPB = Junior Paperbacks<BR>JPC = Junior Picture Book<BR>JPER = Junior Periodical<BR>JREF = Junior Reference<BR>JVF = Junior Vertical File<BR>LP = Large Print<BR>MAP = Map<BR>NF = Adult NonFiction<BR>NFLP = NonFiction LargePrint<BR>NGA = Nga Pukapuka<BR>PAY = Pay Collection<BR>PB = Pamphlet Box<BR>PER = Periodical<BR>PHOT = Photograph<BR>POS = Junior Poster<BR>REF = Adult Reference<BR>ROM = CD-Rom<BR>STF = Stack Fiction<BR>STJ = Stack Junior<BR>STLP = Stack Large Print<BR>STNF = Stack Non-fiction<BR>TB = Talking Book<BR>TREF = Taonga<BR>VF = Vertical File<BR>VID = Video'); return false"><b>Format *</b></A></td>
<td><input type=text size=20 name=format value=$data->{'itemtype'}>
</td>
</tr>
<TR VALIGN=TOP>
<TD>ISBN</td>
<td><input type=text size=20 name=ISBN value=$data->{'isbn'}>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Series</td>
<td><input type=text size=20 name=Series value="$data->{'seriestitle'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Branch</td>
<td><select name=branch size=1>
printend
;
my ($count2,@branches)=branches;
for (my $i=0;$i<$count2;$i++){
  print "<option value=$branches[$i]->{'branchcode'}";
  if ($data->{'branchcode'} == $branches[$i]->{'branchcode'}){
    print " Selected";
  }
  print ">$branches[$i]->{'branchname'}";
}

print <<printend
</select>
</td>
</tr>
<TR VALIGN=TOP  bgcolor=#ffffcc>
<TD >Item Barcode</td>
<td><input type=text size=20 name=barcode>
</td>
</tr>
</table>
<img src="/images/holder.gif" width=32 height=250 align=left>
<table border=1 cellspacing=0 cellpadding=5 width="40%">
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>ACCOUNTING DETAILS</B></td></tr>
<TR VALIGN=TOP>
<TD>Quantity</td>
<td><input type=text size=20 name=quantity value="$data->{'quantity'}" onchange='update(this.form)' >
</td>
</tr>
<TR VALIGN=TOP>
<TD>Bookfund</td>
<td><select name=bookfund size=1>
printend
;

my ($count2,@bookfund)=bookfunds;
for (my $i=0;$i<$count2;$i++){
  print "<option value=$bookfund[$i]->{'bookfundid'}";
  if ($data->{'bookfundid'} == $bookfund[$i]->{'bookfundid'}){
    print " Selected";
  }
  print ">$bookfund[$i]->{'bookfundname'}";
}

print <<printend
</select>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Suppliers List Price</td>
<td><input type=text size=20 name=list_price value="$data->{'listprice'}" onchange='update(this.form)'>
</tr>
<TR VALIGN=TOP>
<TD>Replacement Cost <br>
<FONT SIZE=2>(NZ\$ inc GST)</td>
<td><input type=text size=20 name=rrp value="" onchange='update(this.form)'>
</tr>
<TR VALIGN=TOP>
<TD>
Budgeted Cost<BR>
<FONT SIZE=2>(NZ\$ ex GST, inc discount)</FONT> </td>
<td><input type=text size=20 name=ecost value="" onchange='update(this.form)'>
</td>
</tr>
<TR VALIGN=TOP>
<TD>
Budgeted GST</td>
<td><input type=text size=20 name=GST value="" onchange='update(this.form)'>
</td>
</tr>
<TR VALIGN=TOP>
<TD><B>
BUDGETED TOTAL</B></td>
<td><input type=text size=20 name=total value="" onchange='update(this.form)'>
</td>
</tr>
<TR VALIGN=TOP  bgcolor=#ffffcc>
<TD>Actual Cost</td>
<td><input type=text size=20 name=cost>
</td>
</tr>
<TR VALIGN=TOP  bgcolor=#ffffcc>
<TD>Invoice Number *</td>
<td><input type=text size=20 name=invoice >
<TR VALIGN=TOP>
<TD>Notes</td>
<td><input type=text size=20 name=notes value="$data->{'notes'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD colspan=2>
<input type=image  name=submit src=/images/add-order.gif border=0 width=187 height=42 align=right>
</td>
</tr>
</table>
</form>
</center>
<B>HELP</B><br>
<UL>
<LI>If ordering more than one copy of an item you will be prompted to  choose additional bookfunds, and put in additional barcodes at the next screen<P>
<LI><B>Bold</B> fields must be filled in to create a new bibilo and item.<p>
<LI>Shaded fields can be used to do a "quick" recieve, when items have been purchased locally or gifted. In this case the quantity "ordered" will also  be entered into the database as the quantity recieved.
</UL>

<p> &nbsp; </p>
printend
;

print endmenu('acquisitions');

print endpage;
