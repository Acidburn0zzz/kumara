#!/usr/bin/perl

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;

my $input= new CGI;
#print $input->header;
#print $input->dump;

my $title=$input->param('Title');
my $author=$input->param('Author');
my $bibnum=$input->param('bibnum');
my $copyright=$input->param('Copyright');

modbiblio($bibnum,$title,$author,$copyright);

print $input->redirect("detail.pl?type=intra&bib=$bibnum");
