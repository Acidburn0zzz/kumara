#!/usr/bin/perl

#written 14/1/2000
#script to display reports

use C4::Stats;
use strict;
use Date::Manip;
use CGI;
use C4::Output;

my $input=new CGI;
my $time=$input->param('time');
print $input->header;
my $date;
my $date2;
if ($time eq 'yesterday'){
  $date=ParseDate('yesterday');
  $date2=ParseDate('today');
}
if ($time eq 'today'){
  $date=ParseDate('today');
  $date2=ParseDate('tomorrow');
}

$date=UnixDate($date,'%Y-%m-%d');
$date2=UnixDate($date2,'%Y-%m-%d');
my @payments=TotalPaid($date);
my $count=@payments;
my $total=0;
print mktablehdr;
print mktablerow(5,'white','Name','Type','Date/time','Amount');
for (my $i=0;$i<$count;$i++){
  my $hour=substr($payments[$i]{'timestamp'},8,2);
  my  $min=substr($payments[$i]{'timestamp'},10,2);
  my $sec=substr($payments[$i]{'timestamp'},12,2);
  my $time="$hour:$min:$sec";
  $payments[$i]{'amount'}*=-1;
  $total+=$payments[$i]{'amount'};
  print mktablerow(5,'white',"$payments[$i]{'firstname'} <b>$payments[$i]{'surname'}</b>"
  ,$payments[$i]{'accounttype'},"$payments[$i]{'date'} $time",$payments[$i]{'amount'},
  $payments[$i]{'itemnumber'});
  my @charges=getcharges($payments[$i]{'borrowernumber'},$payments[$i]{'timestamp'});
}
print mktableft;

print "<p><b>$total</b>";

my $issues=Count('issue','C',$date,$date2);
print "<p>Issues Levin: $issues";
$issues=Count('issue','F',$date,$date2);
print "<br>Issues Foxton: $issues";
$issues=Count('issue','S',$date,$date2);
print "<br>Issues Shannon: $issues";
my $returns=Count('return','C',$date,$date2);
print "<p>Returns Levin: $returns";
$returns=Count('return','F',$date,$date2);
print "<p>Returns Foxton: $returns";
$returns=Count('return','S',$date,$date2);
print "<p>Returns Shannon: $returns";
