package C4::Search; #asummes C4/Search

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&CatSearch &BornameSearch &ItemInfo &KeywordSearch &subsearch
&itemdata &bibdata); 
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
  my $query="(Select * from biblio,catalogueentry
  where (catalogueentry.catalogueentry=biblio.author and
  catalogueentry.entrytype='a' and catalogueentry.catalogueentry ~*
  '$search->{'keyword'}') union select * from biblio,catalogueentry where 
  (catalogueentry.catalogueentry=biblio.title and 
  catalogueentry.entrytype='t' and catalogueentry.catalogueentry ~*
  '$search->{'keyword'}')) order by biblio.title"; 
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  my $i=0;
  my $i2=0;
  my $limit=$num+$offset;
  my $count=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $count++;
  }
  $sth->finish;
#  $query=$query." limit $num,$offset";
  $sth=$dbh->prepare($query);
  $sth->execute;
#  print $query;
  while ((my $data=$sth->fetchrow_hashref) && $i < $limit){
    if ($i >= $offset){
      $results[$i2]="$data->{'biblionumber'}\t$data->{'title'}\t$data->{'author'}";
      $i2++;
    }
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
  if ($type eq 'loose') {
#      $query="Select count(*) from biblio,catalogueentry"; 
      if ($search->{'author'} ne ''){
        $query="select biblio.biblionumber,title,author from
         biblio,catalogueentry
         where (catalogueentry.entrytype='a' and 
	 (catalogueentry.catalogueentry = biblio.author)	 
         and (catalogueentry.catalogueentry ~* '$search->{'author'}')) union
	 select biblio.biblionumber,title,author from biblio,biblioanalysis
         where	 biblioanalysis.analyticalauthor ~* '$search->{'author'}'
	 and biblioanalysis.biblionumber=
	 biblio.biblionumber";
#         if ($search->{'title'} ne ''){
#	 }
      } else {
          if ($search->{'title'} ne ''){
    	   $query="select biblio.biblionumber,title,author from biblio,catalogueentry where ((catalogueentry.catalogueentry = biblio.title)
           and (catalogueentry.catalogueentry ~* '^$search->{'title'}') 
           and (entrytype = 't')) union select
           biblio.biblionumber,title,author from
	   biblioanalysis,biblio where analyticaltitle ~*
           '^$search->{'title'}' and
biblio.biblionumber=biblioanalysis.biblionumber
           union select biblio.biblionumber,title,author from
           biblio,bibliosubtitle where subtitle ~* '^$search->{'title'}' and
           biblio.biblionumber=bibliosubtitle.biblionumber";
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
	 $query=$query." ((catalogueentry.catalogueentry = bibliosubject.subject)        
	 and (catalogueentry.catalogueentry like '$search->{'subject'}%') 
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
        $query="select count(*) from items,biblio,biblioitems ";
        my $search2=uc $search->{'isbn'};
        $query=$query." where biblioitems.isbn='$search2' and
        items.biblioitemnumber=biblioitems.biblioitemnumber 
	and biblioitems.biblionumber=biblio.biblionumber";
      }
    }
#print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $count2=0;
  if ($type eq 'precise'){
    my $count=$sth->fetchrow_hashref;
    $count2=$count->{'count'};
  } else {
    while (my $count = $sth->fetchrow_hashref){
      $count2++;
    }
  }
  $sth->finish;
  $query=~ s/count\(\*\)/\*/g;
  if ($type ne 'precise' && $type ne 'subject'){
    $query=$query." order by title limit $num,$offset";
  } else {
    if ($type eq 'subject'){
      $query=$query." order by subject limit $num,$offset";
    }
  }
  $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my $i2=0;
  my $limit=$num+$offset;
  my @results;
  if ($search->{'title'} ne '' || $search->{'author'} ne ''){
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
  return($count2,@results);
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
  my $query="Select * from borrowers where surname like
  '%$searchstring%' or firstname like '%$searchstring%' or othernames like 
  '%$searchstring'";
  print $query,"\n";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my @data=$sth->fetchrow_array){
    print "$data[0] $data[2]\n";
  }
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}
			    
END { }       # module clean-up code here (global destructor)






