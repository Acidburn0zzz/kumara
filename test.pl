#!/usr/bin/perl

use strict;
#use DBI;
use C4::Database;
use C4::Circulation;

my $num=$ARGV[0];

my @data=Issue($num,3);
print @data;
print "\n$data[21]\n";
