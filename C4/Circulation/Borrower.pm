package C4::Circulation::Borrower; #assumes C4/Circulation/Borrower

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Circulation::Main;
use C4::Circulation::Issues;
use C4::Scan;
use C4::Stats;
use C4::Format;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&findborrower &Borenq &findoneborrower);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);
	
# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();
		    
# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();
	
# all file-scoped lexicals must be created before
# the functions below that use them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();
			    
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;


sub findborrower  {
  my ($env,$dbh) = @_;
  helptext('');
  clearscreen();
  my $bornum = "";
  my $sth = "";
  my $borcode = "";
  my $borrower;
  my $reason = "";
  my $book;
  while (($bornum eq '') && ($reason eq "")) {
    #get borrowerbarcode from scanner
    my $title = titlepanel($env,$env->{'sysarea'},"Borrower Entry");
    ($borcode,$reason,$book)=&C4::Circulation::Main::scanborrower($env); 
    #C4::Circulation::Main
    if ($reason eq "") {
      if ($borcode ne '') {
        ($bornum,$borrower) = findoneborrower($env,$dbh,$borcode);
      } elsif ($book ne "") {
        my $query = "select * from issues,items where (barcode = '$book') 
          and (items.itemnumber = issues.itemnumber) 
          and (issues.returndate is null)";
        my $iss_sth=$dbh->prepare($query);
        $iss_sth->execute;
        if (my $issdata  = $iss_sth->fetchrow_hashref) {
           $bornum=$issdata->{'borrowernumber'};
	   $sth = $dbh->prepare("Select * from borrowers 
	     where borrowernumber =  '$bornum'");
	   $sth->execute;
	   $borrower=$sth->fetchrow_hashref;
	   $sth->finish;  
         } else {
           error_msg($env,"Item $book not found");
         } 
	 $iss_sth->finish;
      }
    } 
  } 
  my $issuesallowed;
  if ($reason eq "") {
    $env->{'bornum'} = $bornum;
    $env->{'bcard'} = $borrower->{'cardnumber'};
    my $borrowers=join(' ',($borrower->{'title'},$borrower->{'firstname'},$borrower->{'surname'}));
#    output(1,1,$borrowers);
    $issuesallowed = &checktraps($env,$dbh,$bornum,$borrower);
  }
  return ($bornum, $issuesallowed,$borrower,$reason);
};


sub findoneborrower {
  #  output(1,1,$borcode);
  my ($env,$dbh,$borcode)=@_;
  my $bornum;
  my $borrower;
  my $ucborcode = uc $borcode;
  my $lcborcode = lc $borcode;
  my $sth=$dbh->prepare("Select * from borrowers where cardnumber='$ucborcode'");
  $sth->execute;
  if ($borrower=$sth->fetchrow_hashref) {
    $bornum=$borrower->{'borrowernumber'};
    $sth->finish;
  } else {
    $sth->finish;
    # my $borquery = "Select * from borrowers
    # where surname ~* '$borcode' order by surname";
	      
    my $borquery = "Select * from borrowers 
      where lower(surname) = '$lcborcode' order by surname,firstname";
    my $sthb =$dbh->prepare($borquery);
    $sthb->execute;
    my $cntbor = 0;
    my @borrows;
    my @bornums;
    while ($borrower= $sthb->fetchrow_hashref) {
      my $line = $borrower->{'cardnumber'}.' '.$borrower->{'surname'}.
        ', '.$borrower->{'othernames'};
      $borrows[$cntbor] = fmtstr($env,$line,"L50");
      $bornums[$cntbor] =$borrower->{'borrowernumber'};
      $cntbor++;
    }
    if ($cntbor == 1)  {
      $bornum = $bornums[0];       
      my $query = "select * from borrowers where borrowernumber = '$bornum'";	   
      $sth = $dbh->prepare($query);
      $sth->execute;
      $borrower =$sth->fetchrow_hashref;
      $sth->finish;					         
    } elsif ($cntbor > 0) {
      my ($cardnum) = selborrower($env,$dbh,\@borrows,\@bornums);
      my $query = "select * from borrowers where cardnumber = '$cardnum'";   
      $sth = $dbh->prepare($query);                          
      $sth->execute;                          
      $borrower =$sth->fetchrow_hashref;
      $sth->finish;
      $bornum=$borrower->{'borrowernumber'};
       	   
      clearscreen;
      if ($bornum eq '') {
        error_msg($env,"Borrower not found");
      }
    }  
  }
  return ($bornum,$borrower); 
}
sub checktraps {
  my ($env,$dbh,$bornum,$borrower) = @_;
  my $issuesallowed = "1";
  #process borrower traps (could be function)
  #check first GNA trap (no address this is the 22nd item in the table)
  my @traps_set;
  if ($borrower->{'gonenoaddress'} == 1){
    push (@traps_set,"GNA");
  }
  #check if member has a card reported as lost
  if ($borrower->{'lost'} ==1){
    push (@traps_set,"LOST");
  }
  #check the notes field if notes exist display them
  if ($borrower->{'borrowernotes'} ne ''){
    push (@traps_set,"NOTES");
  }
  #check if borrower has overdue items
  #call overdue checker
  my $odues = &C4::Circulation::Main::checkoverdues($env,$bornum,$dbh);
  #check amountowing
  my $amount=checkaccount($env,$bornum,$dbh);    #from C4::Accounts
  #check if borrower has any items waiting
  my $itemswaiting = &C4::Circulation::Main::checkwaiting($env,$dbh,$bornum);
  #deal with any money still owing
  if ($amount > 0){
    &reconcileaccount($env,$dbh,$bornum,$amount,$borrower,$odues);
  }
  return ($issuesallowed, $odues);
}

sub Borenq {
  my ($env)=@_;
  my $dbh=C4Connect;
  #get borrower guff
  my $bornum;
  my $issuesallowed;
  my $borrower;
  my $reason;
  $env->{'sysarea'} = "Enquiries";
  while ($reason eq "") {
    $env->{'sysarea'} = "Enquiries";
    ($bornum,$issuesallowed,$borrower,$reason) = &findborrower($env,$dbh);
    if ($reason eq "") {
      my ($data,$reason)=&borrowerwindow($env,$borrower);
    if ($reason eq 'Modify'){
      modifyuser($env,$borrower);
      $reason = "";
    } elsif ($reason eq 'New'){
      $reason = "";
    }
  }
  $dbh->disconnect;
#  debug_msg("",$reason);
#  debug_msg("",$data);
  }
  return $reason;
}  

sub modifyuser {
  my ($env,$borrower) = @_;
  debug_msg($env,"Please use intranet");
  #return;
}


END { }       # module clean-up code here (global destructor)
