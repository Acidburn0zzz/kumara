#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

use C4::Acquisitions;
use C4::Output;
use CGI;
use strict;

my $input=new CGI;
print $input->header();
my $user=$input->remote_user;
my $id=$input->param('id');
my ($count,@booksellers)=bookseller($id);
print startpage;

print startmenu('acquisitions');


my $basket=newbasket();
my $date=localtime(time);
print <<printend


<div align=right>
Our Reference: HLT-$basket<br>
Authorsed By: $user<br>
$date
</div>
<FONT SIZE=6><em>Shopping Basket For: <a href=whitcoulls.html>
$booksellers[0]->{'name'}</a></em></FONT><br>
Ph: $booksellers[0]->{'phone'}, Fax: $booksellers[0]->{'fax'},
$booksellers[0]->{'address1'}, $booksellers[0]->{'address2'}, 
$booksellers[0]->{'address3'}, $booksellers[0]->{'address4'}


<p>
<FORM ACTION="/cgi-bin/koha/acqui/newbasket2.pl" method=post>
<input type=hidden name=id value="$id">
<input type=hidden name=basket value="$basket">
<b> Search Keyword, Title or Author: </b><INPUT TYPE="text"  SIZE="25"   NAME="search"> 

</form>



<br clear=all>
<DL>
<dt><b>DELIVERY ADDRESS: </b></dt>
<dd><b>Horowhenua Library Trust</b><br>
10 Bath St<br>
Levin<br>
New Zealand<p>

Ph: +64-6-368 1953<br>
Email: <a href="mailto:ruth\@levin.library.org.nz">ruth\@levin.library.org.nz</a>

</dl>


printend
;

print endmenu('acquisitions');

print endpage;
