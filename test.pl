#!/usr/bin/perl

use strict;
#use DBI;
use C4::Database;

my $dbh=&C4Connect();
my $sth=$dbh->prepare("Select * from test");
$sth->execute;
my @data=$sth->fetchrow_array;
print @data;
$sth->finish;

my @names=$dbh->tables;
$dbh->disconnect;

print @names;
