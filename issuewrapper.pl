#!/usr/bin/perl

#my @args=('issuewrapper.pl',"$env{'branchcode'}","$env{'usercode'}","$env{'telnet'}","$env{'queue'}","$env{'printtype'}");

$done = "Issues";                                                                
my $i=0;
my $bcard;
while ($done eq "Issues") {                                                      
  my @args=('./borrwraper.pl',@ARGV,$bcard);
  eval{$bcard=system(@args)};
  $exit_value  = $? >> 8;
  if ($exit_value){
    $done=$exit_value;
  }

}                                                                                
