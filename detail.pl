#!/usr/bin/perl

#script to display detailed information
#written 8/11/99

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;
print startpage();
print startmenu();
my $blah;

my $bib=$input->param('bib');
my $title=$input->param('title');

my @items=ItemInfo(\$blah,$bib,$title);
#print @items;
my $count=@items;
my $i=0;
print center();
print mktablehdr;
print mktablerow(5,'#cccc99','Title','Barcode','DateDue','Location','Dewey'); 
my $colour=1;
while ($i < $count){
  my @results=split('\t',$items[$i]);
  if ($results[2] eq ''){
    $results[2]='Available';
  }
  if ($colour == 1){                                                                          
    print mktablerow(5,'#ffffcc',@results);                                        
    $colour=0;                                                                                
  } else{                                                                                     
    print mktablerow(5,'white',@results);                                          
    $colour=1;                                                                                
  }
   $i++;
}
print endcenter();
print mktableft();
print endmenu();
print endpage();
