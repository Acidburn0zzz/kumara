#!/usr/bin/perl

use DBI;
use C4::Database;
use C4::Circulation::Issues;
use C4::Circulation::Main;
use C4::InterfaceCDK;
use C4::Circulation::Borrower;


my ($env) = @_;                                                                  
  startint();
  helptext('');                                                                    
my $done;                                                                        
my ($items,$items2,$amountdue);                                                  
my $itemsdet;                                                                    
$env->{'sysarea'} = "Issues";                                                    
$done = "Issues";                                                                
my $i=0;
my $dbh=&C4Connect;                                                              
  my ($bornum,$issuesallowed,$borrower,$reason,$amountdue) = C4::Circulation::Borrower::findborrower($env,$dbh);
  $env->{'loanlength'}="";                                                       
  if ($reason ne "") {                                                           
    $done = $reason;                                                             
  } elsif ($env->{'IssuesAllowed'} eq '0') {                                     
    error_msg($env,"No Issues Allowed =$env->{'IssuesAllowed'}");                
  } else {                                                                       
    $env->{'bornum'} = $bornum;                                                  
    $env->{'bcard'}  = $borrower->{'cardnumber'};                                
    ($items,$items2)=C4::Circulation::Main::pastitems($env,$bornum,$dbh); #from Circulation.pm    
    $done = "No";                                                                
    my $it2p=0;                                                                  
    while ($done eq 'No'){                                                       
      ($done,$items2,$it2p,$amountdue,$itemsdet) = C4::Circulation::Issues::processitems($env,$bornum,$borrower,$items,$items2,$it2p,$amountdue,$itemsdet);                                    
    }                                                                            
    
  } 
  if ($done ne 'Issues'){
      $dbh->disconnect;                                                                
      die "test";
  }
$dbh->disconnect;                                                                
