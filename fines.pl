#!/usr/bin/perl

use strict;
use C4::Database;
use C4::Stats;

#script to total up fines and alter accounts
#should be run nightly with a cron job or the like
#written by chris@katipo.co.nz 30/12/99

my $dbh=C4Connect;

my $count=Overdues;
print $count;


$dbh->disconnect;
