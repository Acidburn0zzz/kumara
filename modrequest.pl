#!/usr/bin/perl

#script to modify reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::Reserves2;

my $input = new CGI;
#print $input->header;

#print $input->dump;

my @rank=$input->param('rank-request');
my @biblio=$input->param('biblio');
my @borrower=$input->param('borrower');

my $count=@rank;

for (my $i=0;$i<$count;$i++){
  if ($rank[$i] ne 'del'){
    updatereserves($rank[$i],$biblio[$i],$borrower[$i],0); #from C4::Reserves2
  } else {
    updatereserves($rank[$i],$biblio[$i],$borrower[$i],1); #from C4::Reserves2
  }
  
}

print $input->redirect("/cgi-bin/koha/request.pl?bib=$biblio[0]");
