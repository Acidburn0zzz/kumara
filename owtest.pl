#!/usr/bin/perl

use strict;
use C4::Security;
use C4::Circulation;
use C4::Circulation::Issues;
use C4::Circulation::Returns;
use C4::Circulation::Renewals;
use C4::Circulation::Borrower;
use C4::Reserves;
use C4::Interface;
use C4::Security;

# set up environment array
# branchcode - logged on branch
# usercode - current user
# proccode - current or last procedure
# borrowernumber - current or last borrowernumber
# logintime - time logged on
# lasttime - lastime security checked
# tempuser - temporary user
my %env = (
  branchcode => "", usercode => "", proccode => "lgon", borrowernumber => "",
  logintime  => "", lasttime => "", tempuser => "", debug => "9"
  );
#Login(\%env);
$env{'branchcode'} = "C";
$env{'usercode'} = "olwen";

 Start_circ(\%env);

#my@date=Issue();
#print @date;
