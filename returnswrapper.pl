#!/usr/bin/perl

#my @args=('issuewrapper.pl',"$env{'branchcode'}","$env{'usercode'}","$env{'telnet'}","$env{'queue'}","$env{'printtype'}");

$done = "returns";                                                                
my $i=0;
while ($done eq "returns") {                                                      
  my @args=('doreturns.pl',@ARGV);
  eval{system(@args)};
  $exit_value  = $? >> 8;
  if ($exit_value){
    $done=$exit_value;
  }

}                                                                                
