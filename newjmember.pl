#!/usr/bin/perl

#script to print confirmation screen, then if accepted calls itself to insert data

use strict;
use C4::Output;
use C4::Input;
use CGI;
use Date::Manip;

my %env;
my $input = new CGI;
#get varibale that tells us whether to show confirmation page
#or insert data
my $insert=$input->param('insert');
print $input->header;
#get rest of data
my %data;
my @names=$input->param;
foreach my $key (@names){                                                                                    
  $data{$key}=$input->param($key);                                                                           
}  
my $ok=0;

my $string="The following compulsary fields have been left blank. Please push the back button
and try again<p>";                                                                                    
for (my $i=0;$i<3;$i++){
  my $number=$data{"cardnumber_child_$i"};
  my $firstname=$data{"firstname_child_$i"};
  my $surname=$data{"surname_child_$i"};
  my $dob=$data{"dateofbirth_child_$i"};
  my $sex=$data{"sex_child_$i"};
  if ($number eq ''){                                                                       
    if ($i == 0){
      $string.=" Cardnumber<br>";                                                                        
      $ok=1;               
    }
  } else {
    if ($firstname eq ''){                                                                         
      $string.=" Given Names<br>";                                                                        
      $ok=1;                                                                                              
    }                                                                                                     
    if ($surname eq ''){                                                                          
      $string.=" Surname<br>";                                                                            
      $ok=1;                                                                                              
    }
    if ($dob eq ''){                                                                          
      $string.=" Date Of Birth<br>";                                                                            
      $ok=1;                                                                                              
    }
    if ($sex eq ''){                                                                              
      $string.=" Gender <br>";                                                                            
      $ok=1;                                                                                              
    } 
    my $valid=checkdigit(\%env,$data{"cardnumber_child_$i"});                                                   
    if ($valid != 1){                                                                                  
      $ok=1;                                                                                           
      $string.=" Invalid Cardnumber $number<br>";
    }                                
  }
}

print startpage();
print startmenu('member');

if ($ok == 0){
  print mkheadr(1,'Confirm Record');
  my $main="#99cc33";                                                                                     
  my $image="/images/background-mem.gif"; 
  print mktablehdr;                                                                                    
  print mktablerow(2,$main,bold('NEW MEMBER'),"",$image);
  print mktablerow(2,'white',bold('Membership Number'),$data{'borrowernumber'});
  print mktableft;
  
  my $i=0;                                                                                             
  my @inputs;                                                                                          
  while (my ($key, $value) = each %data) {                                                             
    $value=~ s/\"/%22/g;                                                                               
    $inputs[$i]=["hidden","$key","$value"];                                                            
    $i++;                                                                                              
  }                                                                                                    
  $inputs[$i]=["submit","submit","submit"];                                                            
  print mkformnotable("/cgi-bin/koha/insertjdata.pl",@inputs);                                          
  
} else {


#print $input->dump;
print $string;
}
print endmenu('member');
print endpage();
