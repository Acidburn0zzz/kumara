#!/usr/bin/perl

#script to display reports
#written 8/11/99

use strict;
use CGI;
use C4::Output;
use C4::Database;

my $input = new CGI;
print $input->header;
my $type=$input->param('type');
print startpage();
print startmenu('issue');


my $dbh=C4Connect;
my $query="Select description from categories";
my $sth=$dbh->prepare($query);
$sth->execute;
print "<Table><tr><td> &nbsp</td>";

while (my $data=$sth->fetchrow_hashref){
  print "<td>$data->{'description'}</td>";
}
print "</tr>";
print "</table>";
print endmenu('issue');
print endpage();
