#!/usr/bin/perl

use strict;
use C4::Security;
use C4::Circmain;
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
$env{'telnet'} = "Y";

Start_circ(\%env);

#my@date=Issue();
#print @date;
