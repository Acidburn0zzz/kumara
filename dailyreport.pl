#!/usr/bin/perl

#written 14/1/2000
#script to display reports

use C4::Stats;
use strict;
use Date::Manip;
use CGI;

my $input=new CGI;
print $input->header;
my $date=ParseDate('yesterday');
$date=UnixDate($date,'%Y-%m-%d');

my @payments=TotalPaid($date);
my $count=@payments;

for (my $i=0;$i<$count;$i++){
  $payments[$i]{'amount'}*=-1;
  print "$payments[$i]{'surname'} $payments[$i]{'firstname'} $payments[$i]{'accounttype'} $payments[$i]{'date'} $payments[$i]{'amount'}
  <br>";
}
