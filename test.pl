#!/usr/bin/perl

use strict;
#use DBI;
use C4::Interface2;



startint("Circulation");
my $data=dialog("Borrower");
print $data;
endint();
