#!/usr/bin/perl

#script to keep total of number of issues;


use C4::Circulation::Fines;
use Date::Manip;

my ($count,$data)=Getoverdues();
print $count;
my $count2=0;
#$count=1000;
my $date=Date_DaysSince999(12,30,1999);
my $bornum;
my $borrower;
my $max=25;
for (my $i=0;$i<$count;$i++){
  my @dates=split('-',$data->[$i]->{'date_due'});
    my $date2=Date_DaysSince999($dates[1],$date[2],$dates[0]);    
    if ($date2 <= $date){
      $count2++;
      my $difference=$date-$date2;
      if ($bornum != $data->[$i]->{'borrowernumber'}){
        $bornum=$data->[$i]->{'borrowernumber'};
        $borrower=BorType($bornum);
      }

      if ($borrower->{'description'} !~ /Staff/ && $borrower->{'description'} !~ /Branch/){
          my ($amount)=CalcFine($data->[$i]->{'itemnumber'},$borrower->{'categorycode'},$difference);      
	  if ($amount > $max){
  	    $amount=25;
	  }
	  if ($amount > 0){
            UpdateFine($data->[$i]->{'itemnumber'},$bornum,$amount);
   	    print "$amount\n";
	  } else {
	    print "0 fine\n";
	  }
      }
    }
}
print "\n $count2\n";
