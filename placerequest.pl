#!/usr/bin/perl

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::Reserves2;

my $input = new CGI;
print $input->header;

my @bibitems=$input->param('biblioitem');
my $biblio=$input->param('biblio');
my $borrower=$input->param('member');
my $branch=$input->param('pickup');

my $count=@bibitems;
@bibitems=sort @bibitems;
my $i2=1;
my @realbi;
$realbi[0]=$bibitems[0];
for (my $i=1;$i<$count;$i++){
  my $i3=$i2-1;
  if ($realbi[$i3] ne $bibitems[$i]){
    $realbi[$i2]=$bibitems[$i];
    $i2++;
  }
}
print $input->dump;
my $env;
my $bornum=borrdata($borrower);
my $const;
if ($input->param('request') eq 'any'){
  $const='a';
}
CreateReserve(\$env,$branch,$bornum->{'borrowernumber'},$biblio,$const,\@realbi);
#print @realbi;
