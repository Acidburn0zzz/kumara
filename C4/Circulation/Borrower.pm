package C4::Circulation; #asummes C4/Circulation/Issues

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Accounts;
use C4::Interface;
use C4::Circulation;
use C4::Circulation::Issues;
use C4::Scan;
use C4::Stats;
use C4::Format;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&findborrower &Borenq);
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
  my $borrower = "";
  my $sth = "";
  my $borcode = "";
  my $reason = "";
  my $book;
  while (($bornum eq '') && ($reason ne "Finished issues")) {
    #get borrowerbarcode from scanner
    ($borcode,$reason,$book)=&scanborrower(); C4::Circulation
    if ($borcode ne '') {
      #  output(1,1,$borcode);
      my $ucborcode = uc $borcode;
      $sth=$dbh->prepare("Select * from borrowers where cardnumber='$ucborcode'");
      $sth->execute;
      if ($borrower=$sth->fetchrow_hashref) {
        $bornum=$borrower->{'borrowernumber'};
        $sth->finish;
      } else {
        $sth->finish;
	my $borquery = "Select * from borrowers where surname ~* '$borcode'";
	my $sthb =$dbh->prepare($borquery);
	$sthb->execute;
	my $cntbor = 0;
	my @borrows;
        my @bornums;
        while ($borrower= $sthb->fetchrow_hashref) {
	   my $line = $borrower->{'cardnumber'}.' '.$borrower->{'surname'}.
	      ', '.$borrower->{'othernames'};
	   @borrows[$cntbor] = fmtstr($env,$line,"L50");
	   $bornums[$cntbor]=$borrower->{'borrowernumber'};
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
	   my ($cardnum) = selborrower($env,$dbh,@borrows,@bornums);
           my $query = "select * from borrowers where cardnumber = '$cardnum'";   
	   $sth = $dbh->prepare($query);                          
           $sth->execute;                          
           $borrower =$sth->fetchrow_hashref;
	   $sth->finish;
           $bornum=$borrower->{'borrowernumber'};
        }   	   
        if ($bornum eq '') {
          output(1,1,"Borrower not found, please rescan or re-enter borrower code");
        }
      }
    } elsif ($book ne "") {
      my $query = "select * from issues,items where (barcode = '$book') 
        and (items.itemnumber = issues.itemnumber) 
        and (issues.returndate is null)";
      my $iss_sth=$dbh->prepare($query);
      $iss_sth->execute;
      if (my $issdata  = $iss_sth->fetchrow_hashref) {
         $bornum=$issdata->{'borrowernumber'};
	 $iss_sth->finish;
	 $sth = $dbh->prepare("Select * from borrowers 
	   where borrowernumber =  '$bornum'");
	 $sth->execute;
	 $borrower=$sth->fetchrow_hashref;
	 $sth->finish;
       } else {
         error_msg($env,"Item $book not found");
       } 
    } 
  }
  my $issuesallowed;
  if ($reason ne "Finished issues") {
    my $borrowers=join(' ',($borrower->{'title'},$borrower->{'firstname'},$borrower->{'surname'}));
#    output(1,1,$borrowers);
    $issuesallowed = &checktraps($env,$dbh,$bornum,$borrower);
  }
  return ($bornum, $issuesallowed,$borrower,$reason);
}  

sub checktraps {
  my ($env,$dbh,$bornum,$borrower) = @_;
  my $issuesallowed = "1";
  #process borrower traps (could be function)
  #check first GNA trap (no address this is the 22nd item in the table)
  if ($borrower->{'gonenoaddress'} == 1){
    #got to membership update and update member info
    output(20,1,"Borrower has no address");
    pause();
  }
  #check if member has a card reported as lost
  if ($borrower->{'lost'} ==1){
    #update member info
    output(20,1,"Borrower has lost card");
  }
  #check the notes field if notes exist display them
  if ($borrower->{'borrowernotes'} ne ''){
    #display notes
    #deal with notes as issue_process.doc
    output(20,1,$borrower->{'borrowernotes'});
  }
  #check if borrower has overdue items
  #call overdue checker
  &checkoverdues($env,$bornum,$dbh);
  #check amountowing
  my $amount=checkaccount($env,$bornum,$dbh);    #from C4::Accounts
  #check if borrower has any items waiting
  my $itemswaiting = &checkwaiting($env,$dbh,$bornum);
  #deal with any money still owing
#    output(30,1,$amount);
  if ($amount > 0){
    &reconcileaccount($env,$dbh,$bornum,$amount);
  }
  return ($issuesallowed);
}

sub Borenq {
  my ($env)=@_;
  my $dbh=C4Connect;
  #get borrower guff
  my ($bornum,$issuesallowed,$borrower,$reason) = &findborrower($env,$dbh);
  my ($data,$reason)=&borrowerwindow($env,$borrower);
  if ($reason eq 'Modify'){
    modifyuser($env,$borrower);
  } elsif ($reason eq 'New'){
    Borenq($env);
  }
#  debug_msg("",$reason);
#  debug_msg("",$data);


}  

END { }       # module clean-up code here (global destructor)
