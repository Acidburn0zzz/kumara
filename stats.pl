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
if ($time eq 'daybefore'){
  $date=ParseDate('2 days ago');
  $date2=ParseDate('yesterday');
}
if ($time=~ /\//){
  $date=ParseDate($time);
  $date2=ParseDateDelta('+ 1 day');
  $date2=DateCalc($date,$date2);
}
$date=UnixDate($date,'%Y-%m-%d');
$date2=UnixDate($date2,'%Y-%m-%d');
my @payments=TotalPaid($date);
my $count=@payments;
my $total=0;
print mktablehdr;
print mktablerow(5,'white','Name','Type','Date/time','Amount', 'Branch');
for (my $i=0;$i<$count;$i++){
  my $hour=substr($payments[$i]{'timestamp'},8,2);
  my  $min=substr($payments[$i]{'timestamp'},10,2);
  my $sec=substr($payments[$i]{'timestamp'},12,2);
  my $time="$hour:$min:$sec";
  $payments[$i]{'amount'}*=-1;
  $total+=$payments[$i]{'amount'};
  my @charges=getcharges($payments[$i]{'borrowernumber'},$payments[$i]{'timestamp'});
  my $count=@charges;
  for (my $i2=0;$i2<$count;$i2++){
    print mktablerow(6,'red',$charges[$i2]->{'description'},$charges[$i2]->{'accounttype'},
    '',
    $charges[$i2]->{'amount'},$charges[$i2]->{'amountoutstanding'});
  }
  my $time2="$payments[$i]{'date'} $time";
  my $branch=Getpaidbranch($time2);
  
  print mktablerow(6,'white',"$payments[$i]{'firstname'} <b>$payments[$i]{'surname'}</b>"
  ,$payments[$i]{'accounttype'},"$payments[$i]{'date'} $time",$payments[$i]{'amount'}
  ,$branch);
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
print "<br>Returns Foxton: $returns";
$returns=Count('return','S',$date,$date2);
print "<br>Returns Shannon: $returns";
