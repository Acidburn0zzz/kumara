#!/usr/bin/perl

#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisitions;

my $input = new CGI;
print $input->header;
my $bibitemnum=$input->param('bibitem');
my $data=bibitemdata($bibitemnum);
my $itemnum=$input->param('item');
my $item=itemnodata('blah','',$itemnum);
#my ($analytictitle)=analytic($biblionumber,'t');
#my ($analyticauthor)=analytic($biblionumber,'a');
print startpage();
print startmenu();
my %inputs;



#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type
#$inputs{'Author'}="text\t$data->{'author'}\t0";
#$inputs{'Title'}="text\t$data->{'title'}\t1";
my $dewey = $data->{'dewey'};                                                      
$dewey =~ s/0+$//;                                                                 
if ($dewey eq "000.") { $dewey = "";};                                             
if ($dewey < 10){$dewey='00'.$dewey;}                                              
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}                               
if ($dewey <= 0){                                                                  
  $dewey='';                                                                       
} 
$dewey=~ s/\.$//;
$inputs{'Barcode'}="text\t$item->{'barcode'}\t0";
$inputs{'Class'}="hidden\t$data->{'classification'}$dewey$data->{'subclass'}\t2";
#$inputs{'Item Type'}="text\t$data->{'itemtype'}\t3";
#$inputs{'Subject'}="textarea\t$sub\t4";
$inputs{'Publisher'}="hidden\t$data->{'publishercode'}\t5";
#$inputs{'Copyright date'}="text\t$data->{'copyrightdate'}\t6";
$inputs{'ISBN'}="hidden\t$data->{'isbn'}\t7";
$inputs{'Publication Year'}="hidden\t$data->{'publicationyear'}\t8";
$inputs{'Pages'}="hidden\t$data->{'pages'}\t9";
$inputs{'Illustrations'}="hidden\t$data->{'illustration'}\t10";
#$inputs{'Series Title'}="text\t$data->{'seriestitle'}\t11";
#$inputs{'Additional Author'}="text\t$additional\t12";
#$inputs{'Subtitle'}="text\t$subtitle->[0]->{'subtitle'}\t13";
#$inputs{'Unititle'}="text\t$data->{'unititle'}\t14";
$inputs{'ItemNotes'}="textarea\t$item->{'itemnotes'}\t15";
#$inputs{'Serial'}="text\t$data->{'serial'}\t16";
$inputs{'Volume'}="hidden\t$data->{'volumeddesc'}\t17";
#$inputs{'Analytic author'}="text\t\t18";
#$inputs{'Analytic title'}="text\t\t19";

$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}\t20";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}\t21";
$inputs{'itemnumber'}="hidden\t$itemnum\t22";



print <<printend
<FONT SIZE=6><em>$data->{'title'} ($data->{'author'})</em></FONT><br>
printend
;
my @formats=findall($data->{'biblionumber'});
my $count=@formats;
my $format="<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width=\"220\">
";
my $i=0;
while ($i<$count){
  $format.="<TR VALIGN=TOP>
  <td  bgcolor=\"#cccc99\" background=\"/images/background-mem.gif\">
  <B>FORMAT - $formats[$i]->{'description'}</TD></TR>
  <tr VALIGN=TOP  >
  <TD>
  <FONT SIZE=2  face=\"arial, helvetica\">
  <b>ISBN:</b> $formats[$i]->{'isbn'}<br>
  <b>Item type:</b> $formats[$i]->{'itemtype'}<br>
  <b>Class:</b>  $formats[$i]->{'classification'}
  ";
  my $bibitemnumber=$formats[$i]->{'biblioitemnumber'};
  while ($bibitemnumber == $formats[$i]->{'biblioitemnumber'}){
    $format.="<hr>
    <b>Item:</b> <a href=\"/cgi-bin/koha/moredetail.pl?item=36358&bib=12073&bi=61386\">$formats[$i]->{'barcode'}</a><br>
    <b>Location:</b> $formats[$i]->{'holdingbranch'}<br>
    <b>Last Seen:</b> $formats[$i]->{'datelastseen'}
    </font>";
    $bibitemnumber=$formats[$i]->{'biblioitemnumber'};
    $i++;
  }
#  $i++;
  $format.="</td></TR>";
}
					     

$format.="</table>";
my $rightside=mkform3('updateitem.pl',%inputs);


print mktablehdr();
print mktablerow(1,'white',$rightside);

print mktableft();

print endmenu();
print endpage();
