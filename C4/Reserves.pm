package C4::Reserves; #asummes C4/Reserves

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Format;
use C4::InterfaceCDK;
use C4::Interface::ReserveentCDK;
use C4::Circulation::Main;
use C4::Circulation::Borrower;
use C4::Search;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&EnterReserves CalcReserveFee CreateReserve );
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

sub EnterReserves{
  my ($env)=@_;  
  my $titlepanel = titlepanel($env,"Reserves","Enter Selection");
  my @flds = ("No of entries","Barcode","ISBN","Title","Keywords","Author","Subject");
  my @fldlens = ("5","15","15","50","50","50","50");
  my ($reason,$num,$itemnumber,$isbn,$title,$keyword,$author,$subject) =
     FindBiblioScreen($env,"Reserves",7,\@flds,\@fldlens);
  my $donext ="Circ";
  if ($reason ne "") {
    $donext = $reason;
  } else {  
    my %search;
    $search{'title'}= $title;
    $search{'keyword'}=$keyword;
    $search{'author'}=$author;
    $search{'subject'}=$subject;
    $search{'item'}=$itemnumber;
    $search{'isbn'}=$isbn;
    my @results;
    my $count;
    if ($num < 1 ) {
      $num = 30;
    }
    my $offset = 0;
    my $title = titlepanel($env,"Reserves","Searching");
    if ($itemnumber ne '' || $isbn ne ''){
      ($count,@results)=&CatSearch($env,'precise',\%search,$num,$offset);
    } else {
      if ($subject ne ''){
        ($count,@results)=&CatSearch($env,'subject',\%search,$num,$offset);
      } else {
        if ($keyword ne ''){
          ($count,@results)=&KeywordSearch($env,'intra',\%search,$num,$offset);
        } else { 
          ($count,@results)=&CatSearch($env,'loose',\%search,$num,$offset);
        }
      }
    }
    my $no_ents = @results;
    my $biblionumber;
    if ($no_ents > 0) {
      if ($no_ents == 1) {
        my @ents = split("\t",@results[0]);
        $biblionumber  = @ents[2];       
      } else {  
        my %biblio_xref;
        my @bibtitles;
        my $i = 0;
        my $line;
        while ($i < $no_ents) {
          my @ents = split("\t",@results[$i]);
          $line = fmtstr($env,@ents[1],"L70");
	  my $auth = substr(@ents[0],0,30);
	  substr($line,(70-length($auth)-2),length($auth)+2) = "  ".$auth;
          @bibtitles[$i]=$line;	 
          $biblio_xref{$line}=@ents[2];
          $i++;
        }
        my $title = titlepanel($env,"Reserves","Select Title");
      	my ($results,$bibres) = SelectBiblio($env,$count,\@bibtitles);
        if ($results eq "") {
       	  $biblionumber = $biblio_xref{$bibres};
        } else {
	  $donext = $results;	    
	}
      }
      #debug_msg($env,"Do Next $donext");
      #debug_msg($env,"Biblio $biblionumber ");           



      if ($biblionumber eq "") {
        error_msg($env,"No items found");   
      } else {
        #debug_msg($env,"getting items $biblionumber");	
        my @items = GetItems($env,$biblionumber);
        #debug_msg($env,"got items ");
	 
	my $cnt_it = @items;
	my $dbh = &C4Connect;
	#debug_msg($env,"select biblio $biblionumber ");
	    
        my $query = "Select * from biblio where biblionumber = $biblionumber";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
        my @branches;
	#debug_msg($env,"select branches ");
	    
        my $query = "select * from branches where issuing=1 order by branchname";
        my $sth=$dbh->prepare($query);
        $sth->execute;
        while (my $branchrec=$sth->fetchrow_hashref) {
          my $branchdet =
            fmtstr($env,$branchrec->{'branchcode'},"L2")." ".$branchrec->{'branchname'};
          push @branches,$branchdet;
        }
	$sth->finish;
        $donext = "";
	while ($donext eq "") {
          my $title = titlepanel($env,"Reserves","Create Reserve");
       	  #debug_msg($env,"make reserves");
	  my ($reason,$borcode,$branch,$constraint,$bibitems) =
            MakeReserveScreen($env, $data, \@items, \@branches);
      	  if ($borcode ne "") { 
   	    my ($borrnum,$borrower) = findoneborrower($env,$dbh,$borcode);
       	    if ($reason eq "") { 
       	      if ($borrnum ne "") {
	        my ($fee,$amtowing) =
                  CalcReserveFee($env,$borrnum,$biblionumber,$constraint,$bibitems);
                CreateReserve($env,$branch,$borrnum,$biblionumber,$constraint,$bibitems);
                $donext = "Circ"
              }
	      
            } else {
       	      $donext = $reason;
	    }
	  } else { $donext = "Circ" }  
	} 
	$dbh->disconnect;
      }
    }
  }
  return ($donext);  
}

sub CalcReserveFee {
  my ($env,$borrnum,$biblionumber,$constraint,$bibitems) = @_;
  #check for issues;
  my $dbh = &C4Connect;
  my $const = lc substr($constraint,0,1);
  my $query = "select * from borrowers,categories 
    where (borrowernumber = '$borrnum') 
    and (borrowers.categorycode = categories.categorycode)";
  my $sth = $dbh->prepare($query);
  $sth->execute;
  my $data = $sth->fetchrow_hashref;
  $sth->finish();
  my $fee = $data->{'reservefee'};
  my $cntitems = @$bibitems;
  if ($fee > 0) {
    # check for items on issue
    # first find biblioitem records
    my @biblioitems;
    my $query1 = "select * from biblio,biblioitems 
       where biblionunmber = '$biblionumber'";
    my $sth1 = $dbh->prepare($query1);
    $sth1->execute();
    while (my $data1=$sth1->fetchrow_hashref) {
      if ($const eq "a") {
        push @biblioitems,$data;
      } else {
        my $found = 0;
        my $x = 0;
	while ($x < $cntitems) {
          if (@$bibitems->{'biblioitemnumber'} == $data->{'biblioitemnumber'}) {
	    $found = 1;
	  }
	  $x++;
        } 
	if ($const eq 'o') { 
	  if ($found == 1) {
	    push @biblioitems,$data;
	  }
	} else {
	  if ($found == 0) {
	    push @biblioitems,$data;
	  }
	}
      }
    }
    $sth1->finish;
    my $cntitemsallowed = @biblioitems;
    my $issues = 0;
    my $x = 0;
    my $allissued = 1;
    while ($x < $cntitemsallowed) {
      my $bitdata = @biblioitems[$x]; 
      my $query2 = "select * from items 
        where biblioitemnumber = '$bitdata->{'biblioitemnumber'}'"; 
      my $sth2 = $dbh->prepare($query2);
      $sth->execute;
      while (my $itdata=$sth2->fetchrow_hashref) { 
        my $query3 = "select * from issues 
           where itemnumber = '$itdata->{'itemnumber'}";
        my $sth3 = $dbh->prepare($query3);
	$sth3->execute();
	if (my $isdata=$sth3->fetchrow_hashref) {
	  } else { $allissued = 0; }
	}
      $x++;
    }
    if ($allissued == 0) { $fee = 0;}
  }
  $dbh->disconnect();
  return $fee;
  
}

sub CreateReserve {
  my ($env,$branch,$borrnum,$biblionumber,$constraint,$bibitems) = @_;
  my $dbh = &C4Connect;
  #$dbh->{RaiseError} = 1;
  #$dbh->{AutoCommit} = 0;
  my $const = lc substr($constraint,0,1);
  debug_msg($env,"constraint $constraint $const");
  my @datearr = localtime(time);
  my $resdate = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  #eval {     
    # updates take place here
    my $query="insert into reserves (borrowernumber,biblionumber,reservedate,branchcode,constrainttype) values ('$borrnum','$biblionumber','$resdate','$branch','$const')";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    debug_msg($env,"const = $const"); 
    if (($const eq "o") || ($const eq "e")) {
      my $numitems = @$bibitems;
      my $i = 0;
      while ($i < $numitems) {
        my $biblioitem = @$bibitems[$i];
    	my $query = "insert into reserveconstraints
    	   (borrowernumber,biblionumber,reservedate,biblioitemnumber)
    	   values ('$borrnum','$biblionumber','$resdate','$biblioitem')";
        my $sth = $dbh->prepare($query);
    	$sth->execute();
	$i++;
      }
    }
  #$dbh->commit();
  #};
  #if (@_) {
  #  # update failed
  #  my $temp = @_;
  #  #  error_msg($env,"Update failed");    
  #  $dbh->rollback(); 
  #}
  $dbh->disconnect();
  return();
}    
    


			
END { }       # module clean-up code here (global destructor)
