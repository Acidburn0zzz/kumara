package C4::Reserves; #asummes C4/Reserves

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Format;
use C4::Interface;
use C4::Interface::Reserveentry;
use C4::Circulation::Borrower;
use C4::Search;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&EnterReserves);
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
  titlepanel($env,"Reserves","Enter Selection");
  my @flds = ("No of entries","Barcode","ISBN","Title","Keywords","Author","Subject");
  my @fldlens = ("5","15","15","50","50","50","50");
  my ($reason,$num,$itemnumber,$isbn,$title,$keyword,$author,$subject) =
     FindBiblioScreen($env,"Reserves",7,\@flds,\@fldlens);
  my $donext ="Circ";
  if ($reason ne "1") {
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
    titlepanel($env,"Reserves","Searching");
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
      if ($no_ents > 1) {
        my %biblio_xref;
        my @bibtitles;
        my $i = 0;
        my $line;
        while ($i < $no_ents) {
          my @ents = split("\t",@results[$i]);
          $line = fmtstr($env,@ents[1],"L60");
	  my $auth = substr(@ents[2],0,20);
	  substr($line,(60-length($auth)-2),length($auth)+2) = "  ".$auth;
          @bibtitles[$i]=$line;	 
          $biblio_xref{$line}=@ents[0];
          $i++;
        }
        titlepanel($env,"Reserves","Select Title");
        my ($results,$bibres)  =  SelectBiblio($env,$count,\@bibtitles);
        if ($results ne 1) {
  	  $biblionumber = $biblio_xref{$bibres};
          if ($biblionumber eq "")  {
            error_msg($env,"No item selected");
          } else {
	    $donext = $results;
	  }  
	}  
      } else  {
        my @ents = split("\t",@results[0]);
        $biblionumber  = @ents[0];
      }
      if ($biblionumber ne "") {
        my @items = GetItems($env,$biblionumber);
        my $cnt_it = @items;
	my $dbh = &C4Connect;
        my $query = "Select * from biblio where biblionumber = $biblionumber";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
        my @branches;
        my $query = "select * from branches order by branchname";
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
	  clearscreen();
          titlepanel($env,"Reserves","Create Reserve");
       	  my ($reason,$borcode,$branch,$constraint,$bibitems) =
            MakeReserveScreen($env, $data, \@items, \@branches);
      	  my ($borrnum,$borrower) = findoneborrower($env,$dbh,$borcode);
          $dbh->disconnect;
	  debug_msg ($env,$reason);
      	  if ($reason eq "") { 
       	    if ($borrnum ne "") {
              CreateReserve($env,$branch,$borrnum,$biblionumber,$constraint,$bibitems);
            $donext = "Circ"
            }
          } else {
            $dbh->disconnect;
      	    $donext = $reason;
	  }  
	} 
      } else {
        error_msg($env,"No items found"); 
      }
    }
  }
  return ($donext);  
}


sub CreateReserve {
  my ($env,$branch,$borrnum,$biblionumber,$constraint,$bibitems) = @_;
  my $dbh = &C4Connect;
  $dbh->{RaiseError} = 1;
  $dbh->{AutoCommit} = 0;
  debug_msg($env,"making reserve");
  my $const = lc substr($constraint,0,1);
  debug_msg($env,"constraint $const");
  my @datearr = localtime(time);
  my $resdate = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  eval {     
    # updates take place here
    my $query="insert into reserves (borrowernumber,biblionumber,reservedate,branchcode,constrainttype) values ('$borrnum','$biblionumber','$resdate','$branch','$const')";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    #if (($const eq "o") || ($const eq "e")) {
    #  my $numitems = @$bibitems;
    #  my $i = 0;
    #  while ($i < $numitems) {
    #    my $biblioitem = @$bibitems[$i];
    #	my $query = "insert into reserveconstraints
    #	   (borrowernumber,reservedate,biblionumber,biblioitemnumber)
    #	   values ('$borrnum','$biblionumber','$resdate','$biblioitem')";
    #	my $sth = $dbh->prepare($query);
    #	$sth->execute();
    #  }
    #}
    $dbh->commit();
  };
  if (@_) {
    # update failed
    my $temp = @_;
    error_msg($env,"error trap @_");
    
    $dbh->rollback();
  }
  $dbh->disconnect();
  return();
}    
    


			
END { }       # module clean-up code here (global destructor)