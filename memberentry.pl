#!/usr/bin/perl

#script to do a borrower enquiery/brin up borrower details etc
#written 20/12/99 by chris@katipo.co.nz

use strict;
use C4::Output;
use CGI;
use C4::Search;


my $input = new CGI;
my $member=$input->param('member');

print $input->header;
print startpage();
print startmenu('member');
print mkheadr(1,'Member Search');
print "You Searched for $member<p>";
print mktablehdr;
print mktablerow(8,'#99cc33','<b>Card</b>','<b>Surname</b>','<b>Firstname</b>','<b>Category</b>'
,'<b>Address</b>','<b>OD/Issues</b>','<b>Fines</b>','<b>Notes</b>');
my $env;
my ($count,$results)=BornameSearch($env,$member,'web');
#print $count;
for (my $i=0; $i < $count; $i++){
  #find out stats
  my ($od,$issue,$fines)=borrdata2($env,$results->[$i]{'borrowernumber'});
  $fines=$fines+0;
  print mktablerow(8,'white',mklink("/cgi-bin/koha/addborrower.pl?bornum=".$results->[$i]{'borrowernumber'},$results->[$i]{'cardnumber'}),
  $results->[$i]{'surname'},$results->[$i]{'firstname'},
  $results->[$i]{'categorycode'},$results->[$i]{'streetaddress'},"$od/$issue",$fines,
  $results->[$i]{'borrowernotes'});
}
print mktableft;
print endmenu('member');
print endpage();
