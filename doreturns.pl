#!/usr/bin/perl

use DBI;                                                                                                                             
use C4::Database;                                                                                                                    
use C4::Accounts;                                                                                                                    
use C4::InterfaceCDK;                                                                                                                
use C4::Circulation::Main;                                                                                                           
use C4::Format;                                                                                                                      
use C4::Scan;                                                                                                                        
use C4::Stats;                                                                                                                       
use C4::Search;                                                                                                                      
use C4::Print;


my ($env)=@_;                                                                                                                      
my $dbh=&C4Connect;                                                                                                                
my @items;                                                                                                                         
@items[0]=" "x50;                                                                                                                  
	  my $reason;                                                                                                                        
	    my $item;                                                                                                                          
	      my $reason;                                                                                                                        
	        my $borrower;                                                                                                                      
		  my $itemno;                                                                                                                        
		    my $itemrec;                                                                                                                       
		      my $bornum;                                                                                                                        
		        my $amt_owing;                                                                                                                     
			  my $odues;                                                                                                                         
			    my $issues;                                                                                                                        
			      my $resp;                                                                                                                          
			      # until (($reason eq "Circ") || ($reason eq "Quit")) {                                                                               
			        until ($reason ne "") {                                                                                                            
				    ($reason,$item) =                                                                                                                
				          returnwindow($env,"Enter Returns",                                                                                             
					        $item,\@items,$borrower,$amt_owing,$odues,$dbh,$resp); #C4::Circulation                                                        
						    #debug_msg($env,"item = $item");                                                                                                 
						        #if (($reason ne "Circ") && ($reason ne "Quit")) {                                                                               
							    if ($reason eq "")  {                                                                                                            
							          $resp = "";                                                                                                                    
								        ($resp,$bornum,$borrower,$itemno,$itemrec,$amt_owing) =  
     $resp = "";                                                                                                                    
           ($resp,$bornum,$borrower,$itemno,$itemrec,$amt_owing) =                                                                        
	            checkissue($env,$dbh,$item);                                                                                                
		          if ($bornum ne "") {                                                                                                           
			           ($issues,$odues,$amt_owing) = borrdata2($env,$bornum);                                                                      
				         } else {                                                                                                                       
					         $issues = "";                                                                                                                
						         $odues = "";                                                                                                                 
							         $amt_owing = "";                                                                                                             
								       }                                                                                                                              
								             if ($resp ne "") {                                                                                                             
									             #if ($resp eq "Returned") {                                                                                                  
										             if ($itemno ne "" ) {                                                                                                        
											               my $item = itemnodata($env,$dbh,$itemno);                                                                                  
												                 my $fmtitem = C4::Circulation::Issues::formatitem($env,$item,"",$amt_owing);                                               
														           unshift @items,$fmtitem;                                                                                                   
															             if ($items[20] > "") {                                                                                                     
																                 pop @items;                                                                                                              
																		           }                                                                                                                          
																			           }                                                                                                                            
																				           #} elsif ($resp ne "") {                                                                                                     
																					           #  error_msg($env,"$resp");                                                                                                  
																						           #}                                                                                                                           
																							           #if ($resp ne "Returned") {                                                                                                  
																								           #  error_msg($env,"$resp");                                                                                                  
																									           #  $bornum = "";                                                                                                             
																										           #}                                                                                                                           
																											         }                                                                                                                              
																												     }                                                                                                                                
																												       }                                                                                                                                  
																												       #  clearscreen;                                                                                                                      
																												         $dbh->disconnect;                                                                                                                  
																													   return($reason);                                                                                                                   
																													     }       
