#!/usr/bin/perl

#script to keep total of number of issues;


use C4::Circulation::Fines;
use Date::Manip;

my ($count,$data)=Getoverdues();
#print $count;
my $count2=0;
#$count=1000;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$mon++;
$year=$year+1900;
#my $date=Date_DaysSince999($mon,$mday,$year);
my $date=Date_DaysSince999(1,19,2000);
my $bornum;
my $borrower;
my $max=5;
for (my $i=0;$i<$count;$i++){
  my @dates=split('-',$data->[$i]->{'date_due'});
    my $date2=Date_DaysSince999($dates[1],$dates[2],$dates[0]);    
    if ($date2 <= $date){
      $count2++;
      my $difference=$date-$date2;
      if ($bornum != $data->[$i]->{'borrowernumber'}){
        $bornum=$data->[$i]->{'borrowernumber'};
        $borrower=BorType($bornum);
      }


          my ($amount,$type)=CalcFine($data->[$i]->{'itemnumber'},$borrower->{'categorycode'},$difference);      
	  if ($amount > $max){
  	    $amount=$max;
	  }
	  if ($amount > 0){
            UpdateFine($data->[$i]->{'itemnumber'},$bornum,$amount,$type);
              print "$borrower->{'firstname'} $borrower->{'surname'} $data->[$i]->{'date_due'} $type $difference\n";
	  } else {
#	    print "0 fine\n";
	  }

    }
}
print "\n $count2\n";
