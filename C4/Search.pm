package C4::Search; #asummes C4/Search

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
#use C4::InterfaceCDK;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&CatSearch &BornameSearch &ItemInfo &KeywordSearch &subsearch
&itemdata &bibdata &GetItems &borrdata &getacctlist); 
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

sub KeywordSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  my $query ="Select count(*) from biblio where author like
'%$search->{'keyword'}%' or
  title like '%$search->{'keyword'}%'";

  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count2=$sth->fetchrow_arrayref;
  $sth->finish;  
  my $i=0;
  my $count=$count2->[0];
  my @results;
  $query=~ s/count\(\*\)/\*/;
  $query=$query." order by title limit $offset,$num";
  $sth=$dbh->prepare($query);
#      print $query;
  $sth->execute;
#
  while (my $data=$sth->fetchrow_hashref){

    $results[$i]="$data->{'biblionumber'}\t$data->{'title'}\t$data->{'author'}";
        $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($count,@results);
}

sub CatSearch  {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  my $query = '';
  my $title = lc($search->{'title'}); 
  if ($type eq 'loose') {
      if ($search->{'author'} ne ''){
        $query="select count(*) from
         biblio
         where biblio.author like '%$search->{'author'}%'";     
         if ($search->{'title'} ne ''){ 
	   $query=$query. " and title like '%$search->{'title'}%'";
	 }
      } else {
          if ($search->{'title'} ne ''){
            $query="select count(*) from biblio
	    where title like '%$search->{'title'}%'";	 
	 }
      }
  } 
  if ($type eq 'subject'){
      $query="Select distinct(subject) from catalogueentry,bibliosubject"; 
      if ($search->{'subject'} ne ''){
         if ($query =~ /where/){
	    $query=$query." and ";
	 } else {
   	    $query=$query." where ";
	 }
	 $search->{'subject'}=uc $search->{'subject'};
	 $query=$query." ((lower(catalogueentry.catalogueentry) = lower(bibliosubject.subject))        
	 and (lower(catalogueentry.catalogueentry) like
            lower('$search->{'subject'}%')) 
	 and (entrytype = 's'))"; 
      }
   }
   if ($type eq 'precise'){
      $query="select count(*) from items,biblio ";
      if ($search->{'item'} ne ''){
        my $search2=uc $search->{'item'};
        $query=$query." where barcode='$search2' and
        items.biblionumber=biblio.biblionumber ";
      }
      if ($search->{'isbn'} ne ''){
        my $search2=uc $search->{'isbn'};
	#
	# Commented code does not work properly, but would be much faster 
	# if it did
	# Can't make it returne the biblionumber properly
	#
        my $query1 = "select * from biblioitems where isbn='$search2'";
        #debug_msg($env,$query1);
	my $sth1=$dbh->prepare($query);
	$sth1->execute;
        my $i2=0;
	while (my @data=$sth1->fetchrow_hashref) {
	   $query="select * from biblioitems,items,biblio where
           biblioitems.biblioitemnumber = '$data->{'biblioitemnumber'}' 
	   and biblioitems.biblionumber =
           biblio.biblionumber and items.biblioitemnumber =
           biblioitems.biblioitemnumber";
	   my $sth=$dbh->prepare($query);
	   $sth->execute;
	   my $data=$sth->fetchrow_hashref;
           $results[$i2]="$data->{'biblionumber'}\t$data->{'title'}\t$data->{'author'}";
           $i2++;
	   $sth->finish;
	}
      }
    }
#print $query;
  my $sth=$dbh->prepare($query);
    $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $count=$data->[0];
  $sth->finish;
  $query=~ s/count\(\*\)/\*/g;
  if ($type ne 'precise' && $type ne 'subject'){
    $query=$query." order by title limit $offset,$num";
  } else {
    if ($type eq 'subject'){
      $query=$query." order by subject limit $offset,$num";
    }
  }
  $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my $i2=0;
  my $limit=$num+$offset;
  my @results;
  if ($search->{'title'} ne '' || $search->{'author'} ne '' ){
    while ((my $data=$sth->fetchrow_hashref) && $i < $limit){
      if ($i >= $offset){
        $results[$i2]="$data->{'biblionumber'}\t$data->{'title'}\t$data->{'author'}";
        $i2++;
      }
      $i++;
    }
  } else {
    while (my $data=$sth->fetchrow_hashref){
     if ($type ne 'subject'){
      $results[$i]="$data->{'biblionumber'}\t$data->{'title'}\t
      $data->{'author'}";
     } elsif ($search->{'isbn'} ne ''){
     } else {  
      $results[$i]="$data->{'biblionumber'}\t$data->{'subject'}\t
      $data->{'author'}";
     }
     $i++;
    }
  }
  $sth->finish;
#    print "$query\n";
  #only update stats if search is from opac
#  updatesearchstats($dbh,$query);
  $dbh->disconnect;
  return($count,@results);
}

sub updatesearchstats{
  my ($dbh,$query)=@_;
  
}

sub subsearch {
  my ($env,$subject)=@_;
  my $dbh=C4Connect();
  my $query="Select * from biblio,bibliosubject where
biblio.biblionumber=bibliosubject.biblionumber and
bibliosubject.subject='$subject'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
#  print $query;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'title'}\t$data->{'author'}\t$data->{'biblionumber'}";
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}


sub ItemInfo {
  my ($env,$biblionumber)=@_;
  my $dbh = &C4Connect;
  my $query="Select * from items,biblio,biblioitems,branches 
  where (items.biblioitemnumber = biblioitems.biblioitemnumber)
  and biblioitems.biblionumber=biblio.biblionumber
  and biblio.biblionumber='$biblionumber' and branches.branchcode=
  items.holdingbranch";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    my $iquery = "Select * from issues
    where itemnumber = '$data->{'itemnumber'}'
    and returndate is null";
    my $datedue = '';
    my $isth=$dbh->prepare($iquery);
    $isth->execute;
    if (my $idata=$isth->fetchrow_hashref){
      $datedue = $idata->{'date_due'};
    }

$isth->finish;

$results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$data->{'dewey'}";
     $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

sub GetItems {
   my ($env,$biblionumber)=@_;
   my $dbh = &C4Connect;
   my $query = "Select * from biblioitems where (biblionumber = $biblionumber)";
   my $sth=$dbh->prepare($query);
   $sth->execute;
   debug_msg($env,"executed query");
      
   my $i=0;
   my @results;
   while (my $data=$sth->fetchrow_hashref) {
      debug_msg($env,$data->{'biblioitemnumber'});
      my $line = $data->{'biblioitemnumber'}."\t".$data->{'itemtype'};
      $line = $line."\t$data->{'classification'}\t$data->{'dewey'}";
      $line = $line."\t$data->{'subclass'}\t$data->{isbn}";
      $line = $line."\t$data->{'volume'}\t$data->{number}";
      my $isth= $dbh->prepare("select * from items where biblioitemnumber = $data->{'biblioitemnumber'}");
      $isth->execute;
      while (my $idata = $isth->fetchrow_hashref) {
        my $iline = $idata->{'barcode'}."[".$idata->{'holdingbranch'}."[";
	if ($idata->{'notforloan'} = 1) {
	  $iline = $iline."NFL ";
	}
	if ($idata->{'itemlost'} = 1) {
	  $iline = $iline."LOST ";
	}        
        $line = $line."\t$iline"; 
      }
      $isth->finish;
      $results[$i] = $line;
      $i++;      
   }
   $sth->finish;
   $dbh->disconnect;
   return(@results);
}	     
  
sub itemdata {
  my ($barcode)=@_;
  my $dbh=C4Connect;
  my $query="Select * from items,biblioitems where barcode='$barcode'
  and items.biblioitemnumber=biblioitems.biblioitemnumber";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub bibdata {
  my ($title)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblio where title='$title'";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub BornameSearch  {
  my ($env,$searchstring,$type)=@_;
  my $dbh = &C4Connect;
  $searchstring = lc $searchstring;
  my $query="Select * from borrowers 
  where lower(surname) like '%$searchstring%' 
  or lower(firstname)  like '%$searchstring%' 
  or lower(othernames) like '%$searchstring%'
  order by lower(surname),lower(firstname)";
  #print $query,"\n";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $cnt=0;
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
    $cnt ++;
  }
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
  return ($cnt,\@results);
}

sub borrdata {
  my ($cardnumber)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh=C4Connect;
  my $query="Select * from borrowers where cardnumber='$cardnumber'";
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}
		  
sub getacctlist {
   my ($env,$params) = @_;
   my $dbh=C4Connect;
   my @acctlines;
   my $numlines;
   my $query = "Select borrowernumber, accountno, date, amount, description,
      dispute, accounttype, amountoutstanding, barcode, title
      from accountlines,items,biblio   
      where borrowernumber = $params->{'borrowernumber'} ";
   if ($params->{'acctno'} ne "") {
      my $query = $query." and accountlines.accountno = $params->{'acctno'} ";
      }
   my $query = $query." and accountlines.itemnumber = items.itemnumber
      and items.biblionumber = biblio.biblionumber
      and accountlines.amountoutstanding<>0 order by date";
   my $sth=$dbh->prepare($query);
   $sth->execute;
   my $total=0;
   while (my $data=$sth->fetchrow_hashref){
      $acctlines[$numlines] = $data;
      $numlines++;
      $total = $total+ $data->{'amountoutstanding'};
   }
   return ($numlines,\@acctlines,$total);
}
				      
END { }       # module clean-up code here (global destructor)






