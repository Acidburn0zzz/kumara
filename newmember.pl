#!/usr/bin/perl

#script to print confirmation screen, then if accepted calls itself to insert data

use strict;
use C4::Output;
use CGI;
use Date::Manip;


my $input = new CGI;
#get varibale that tells us whether to show confirmation page
#or insert data
my $insert=$input->param('insert');

#get rest of data
my %data;
my @names=$input->param;
foreach my $key (@names){                                                                                    
  $data{$key}=$input->param($key);                                                                           
}  
print $input->header;
print startpage();
print startmenu('member');
my $main="#99cc33";
my $image="/images/background-mem.gif";
if ($insert eq ''){
  #check that all compulsary fields are entered
  my $string="The following compulsary fields have been left blank. Please push the back button
  and try again<p>";
  if ($data{'cardnumber'} eq ''){
    $string.=" Cardnumber<br>";
  }
  #we are printing confirmation page
  print mkheadr(1,'Confirm New Adult Member');
  print mktablehdr;
  print mktablerow(2,$main,bold('NEW MEMBER'),"",$image);
  my $name=$data{'title'}." ";
  if ($data{'othernames'} ne ''){
    $name.=$data{'othernames'}." ";
  } else {
    $name.=$data{'firstname'}." ";
  }
  $name.="$data{'surname'} ( $data{'firstname'}, $data{'initials'})";
  print mktablerow(2,'white',bold('Name'),$name);
  print mktablerow(2,$main,bold('MEMBERSHIP DETAILS'),"",$image);
  print mktablerow(2,'white',bold('Membership Number'),$data{'borrowernumber'});
  print mktablerow(2,'white',bold('Cardnumber'),$data{'cardnumber'});
  print mktablerow(2,'white',bold('Membership Category'),$data{'category'});
  print mktablerow(2,'white',bold('Area'),$data{'area'});
  print mktablerow(2,'white',bold('Fee'),$data{'fee'});
  $data{'joining'}=ParseDate('today');
  print mktablerow(2,'white',bold('Joining Date'),$data{'joining'});
  $data{'expiry'}=ParseDate('in 1 year');
  print mktablerow(2,'white',bold('Expiry Date'),$data{'expiry'});
  print mktablerow(2,'white',bold('Joining Branch'),$data{'joinbranch'});
  print mktablerow(2,$main,bold('PERSONAL DETAILS'),"",$image);
  my $ethnic=$data{'ethnicity'}." ".$data{'ethnicnotes'};
  print mktablerow(2,'white',bold('Ethnicity'),$ethnic);
  print mktablerow(2,'white',bold('Date of Birth'),$data{'dateofbirth'});
  my $sex;
  if ($data{'sex'} eq 'm'){
    $sex="Male";
  } else {
    $sex="Female";
  }
  print mktablerow(2,'white',bold('Sex'),$sex);
  print mktablerow(2,$main,bold('MEMBER ADDRESS'),"",$image);
  my $postal=$data{'address'}."<br>".$data{'city'};
  my $home;
  if ($data{'streetaddress'} ne ''){
    $home=$data{'streetaddress'}."<br>".$data{'streetcity'};
  } else {
    $home=$postal;
  }
  print mktablerow(2,'white',bold('Postal Address'),$postal);
  print mktablerow(2,'white',bold('Home Address'),$home);
  print mktablerow(2,$main,bold('MEMBER CONTACT DETAILS'),"",$image);
  print mktablerow(2,'white',bold('Phone (Home)'),$data{'phone'});
  print mktablerow(2,'white',bold('Phone (Daytime)'),$data{'phoneday'});
  print mktablerow(2,'white',bold('Fax'),$data{'faxnumber'});
  print mktablerow(2,'white',bold('Email'),$data{'emailaddress'});
  print mktablerow(2,$main,bold('ALTERNATIVE CONTACT DETAILS'),"",$image);
  print mktablerow(2,'white',bold('Name'),$data{'contactname'});
  print mktablerow(2,'white',bold('Phone'),$data{'altphone'});
  print mktablerow(2,'white',bold('Relationship'),$data{'relation'});
  print mktablerow(2,'white',bold('Notes'),$data{'altnotes'});
  print mktablerow(2,$main,bold('Notes'),"",$image);
  print mktablerow(2,'white',bold('General Notes'),$data{'borrowernotes'});

  print mktableft;
  #set up form to post data thru for modification or insertion
  my $i=0;
  my @inputs;
  while (my ($key, $value) = each %data) {
    $inputs[$i]=["hidden","$key","$value"];       
    $i++;
  }
  print mkformnotable("/cgi-bin/koha/member.pl",@inputs);
}
#print $input->dump;

print mktablehdr;

print mktableft;
print endmenu('member');
print endpage();
