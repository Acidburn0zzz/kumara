#!/usr/bin/perl

#script to insert data into the database
#needs authentication, only used for adding new biblios etc
# written 9/11/99 by chris@katipo.co.nz

use CGI;
use C4::Database;
use C4::Input;
use Date::Manip;
use strict;

my $input= new CGI;
print $input->header;
print $input->dump;

#get all the data into a hash
my @names=$input->param;
my %data;
my $keyfld;
my $keyval;
my $problems;
my $env;
foreach my $key (@names){
  $data{$key}=$input->param($key);
}
my $updtype = $data{'updtype'};

if ($data{'type'} eq 'biblio'){
  $data{'serial'}=~ s/No/0/;
  $data{'serial'}=~ s/Yes/1/;
  my $bibnum=getmax('biblio','biblionumber');
  my $num=$bibnum->{'max'};
  $num++;
  $data{'biblionumber'}=$num;
} elsif ($data{'type'} eq 'borrowers') {
  # required fields
  $data{dateofbirth} = &UnixDate(&ParseDate($data{dateofbirth}),"%Y-%m-%d");
  my @reqflds = ("cardnumber","surname","firstname",
    "streetaddress","phone","altstreetaddress","altphone","dateofbirth","contactname");       
  my $probflds = checkflds($env,\@reqflds,\%data);
  if (@$probflds[0] ne "") {
    $problems = "The following required fields are missing: <br>";
    $problems = $problems.join(", ",@$probflds)."<br>";
  }
  $data{cardnumber} = uc ($data{cardnumber});
  my $validcard = checkdigit($env,$data{cardnumber});
  if ($validcard ne "1") {
    $problems = $problems."The card number failed the check digit check.<br>";  
  }
  if ($problems eq "") {
    if ($updtype eq "M") {
      $keyfld = "borrowernumber";
    } else {
      my $bornum=getmax('borrowers','borrowernumber');
      my $num=$bornum->{'max(borrowernumber)'};
      $num++;
      $data{'borrowernumber'}=$num;
      $data{'branchcode'}="L";
    }
  }  
} elsif ($data{'type'} eq "accountlines") {
  $keyfld = "accountno\tborrowernumber";
  $keyval = $data{'accountno'}."\t".$data{'borrowernumber'};
}

if ($problems eq "") {
  if ($updtype eq "M") {
    if ($keyval eq "") {
       &sqlupdate($data{'type'},$keyfld,$data{$keyfld},%data);
     } else {
       &sqlupdate($data{'type'},$keyfld,$keyval,%data);
     }	 
  } else {
    &sqlinsert($data{'type'},%data);
  }
} else {
  print "<strong>The following problems occured with the data:</strong><br>";
  print $problems;
  print "<br><br><strong>Please press the back key to fix this problem.</strong>";
}  
