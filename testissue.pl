#!/usr/bin/perl

use strict;
#use DBI;
use C4::Database;
use C4::Circulation;
use C4::Interface;

my $num=$ARGV[0];

my @data=Issue($num,3);
my $data=join(' ',@data);
#resultout('console',$data);
print "\n$data[21]\n";
