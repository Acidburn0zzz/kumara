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
&itemdata &bibdata &GetItems &borrdata &getacctlist &itemnodata &itemcount
&OpacSearch &borrdata2); 
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

sub OpacSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select count(*) from biblio where 
  (title like '%$key[0]%'";
  while ($i < $count){
    $query=$query." and title like '%$key[$i]%'";
    $i++;
  }
  $query=$query.") or (author like '%$key[0]%'";
  $i=1;
  while ($i < $count){
    $query=$query." and author like '%$key[$i]%'";
    $i++;
  }
  $query=$query.") order by title";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  my $count=$data->{'count(*)'};
  $sth->finish;
  $query=~ s/count\(\*\)/\*/;
  $query= $query." limit $offset,$num";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}";
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($count,@results);
}

sub KeywordSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select * from biblio where 
  (title like '%$key[0]%'";
  while ($i < $count){
    $query=$query." and title like '%$key[$i]%'";
    $i++;
  }
  $query=$query.") order by author,title";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}";
#      print $results[$i];
$i++;
  }
  $sth->finish;
  $sth=$dbh->prepare("Select biblionumber from bibliosubject where subject
  like '%$search->{'keyword'}%'");
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    my $sth2=$dbh->prepare("Select * from biblio where
    biblionumber=$data->{'biblionumber'}");
    $sth2->execute;
    while (my $data2=$sth2->fetchrow_hashref){
      $results[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}";
#      print $results[$i];
      $i++;   
    }
    $sth2->finish;
  }    
  my $i2=1;
  @results=sort @results;
  my @res;
  my $count=@results;
  $i=1;
  $res[0]=$results[0];
  while ($i2 < $count){
    if ($results[$i2] ne $res[$i-1]){
      $res[$i]=$results[$i2];
      $i++;
    }
    $i2++;
  }
  $i2=0;
  my @res2;
  $count=@res;
  while ($i2 < $num && $i2 < $count){
    $res2[$i2]=$res[$i2+$offset];
#    print $res2[$i2];
    $i2++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@res2);
}

sub CatSearch  {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  my $query = '';
    my @results;
  my $title = lc($search->{'title'}); 
  if ($type eq 'loose') {
      if ($search->{'author'} ne ''){
        my @key=split(' ',$search->{'author'});
	my $count=@key;
	my $i=1;
        $query="select count(*) from
         biblio
         where (biblio.author like '%$key[0]%'";    
	 while ($i < $count){ 
           $query=$query." and author like '%$key[$i]%'";   
           $i++;       
	 }   
	 $query=$query.")";
         if ($search->{'title'} ne ''){ 
	   $query=$query. " and title like '%$search->{'title'}%'";
	 }
      } else {
          if ($search->{'title'} ne ''){
	    my @key=split(' ',$search->{'title'});
	    my $count=@key;
	    my $i=1;
            $query="select count(*) from biblio
	    where (title like '%$key[0]%'";
	    while ($i<$count){
	      $query=$query." and title like '%$key[$i]%'";
	      $i++;
	    }
	    $query=$query.")";
	  } elsif ($search->{'class'} ne ''){
	     $query="select count(*) from biblioitems where classification
	     like '%$search->{'class'}%'";
	  }
	 
      }
  } 
  if ($type eq 'subject'){
    $query="select distinct(subject) from bibliosubject where subject like
    '$search->{'subject'}%'";
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
        my $query1 = "select * from biblioitems where isbn='$search2'";
	my $sth1=$dbh->prepare($query1);
	$sth1->execute;
        my $i2=0;
	while (my $data=$sth1->fetchrow_hashref) {
	   $query="select * from biblioitems,items,biblio where
           biblioitems.biblioitemnumber = '$data->{'biblioitemnumber'}' 
	   and biblioitems.biblionumber =
           biblio.biblionumber and items.biblioitemnumber =
           biblioitems.biblioitemnumber";
	   my $sth=$dbh->prepare($query);
	   $sth->execute;
	   my $data=$sth->fetchrow_hashref;
	   $results[$i2]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}";
           $i2++; 
	   $sth->finish;
	}
	$sth1->finish;
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

  if ($search->{'title'} ne '' || $search->{'author'} ne '' ){
    while ((my $data=$sth->fetchrow_hashref) && $i < $limit){
      if ($i >= $offset){

$results[$i2]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}";
        $i2++;
      }
      $i++;
    }
  } else {
    while (my $data=$sth->fetchrow_hashref){
     if ($type ne 'subject'){
      $results[$i]="$data->{'author'}\t$data->{'title'}\t
      $data->{'biblionumber'}";
     } elsif ($search->{'isbn'} ne ''){
     } else {  
      $results[$i]="$data->{'author'}\t$data->{'subject'}\t
      $data->{'biblionumber'}";
     }
     $i++;
    }
  }
  $sth->finish;
#    print "$query\n";
  #only update stats if search is from opac
#  updatesearchstats($dbh,$query);
  $dbh->disconnect;
  if ($search->{'isbn'} ne ''){
    $count=1;
  }
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
    my $class = $data->{'classification'};
    my $dewey = $data->{'dewey'};
    $dewey =~ s/0+$//;
    if ($dewey eq "0.") { $dewey = "";};
    $class = $class.$dewey;
    $class = $class.$data->{'subclass'};
 #   $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$data->{'dewey'}";
     $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$class\t$data->{'itemnumber'}";

    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

sub GetItems {
   my ($env,$biblionumber)=@_;
   #debug_msg($env,"GetItems");
   my $dbh = &C4Connect;
   my $query = "Select * from biblioitems where (biblionumber = $biblionumber)";
   #debug_msg($env,$query);
   my $sth=$dbh->prepare($query);
   $sth->execute;
   #debug_msg($env,"executed query");
      
   my $i=0;
   my @results;
   while (my $data=$sth->fetchrow_hashref) {
      #debug_msg($env,$data->{'biblioitemnumber'});
      my $dewey = $data->{'dewey'};
      $dewey =~ s/0+$//; 
      my $line = $data->{'biblioitemnumber'}."\t".$data->{'itemtype'};
      $line = $line."\t$data->{'classification'}\t$dewey";
      $line = $line."\t$data->{'subclass'}\t$data->{isbn}";
      $line = $line."\t$data->{'volume'}\t$data->{number}";
      my $isth= $dbh->prepare("select * from items where biblioitemnumber = $data->{'biblioitemnumber'}");
      $isth->execute;
      while (my $idata = $isth->fetchrow_hashref) {
        my $iline = $idata->{'barcode'}."[".$idata->{'holdingbranch'}."[";
	if ($idata->{'notforloan'} == 1) {
	  $iline = $iline."NFL ";
	}
	if ($idata->{'itemlost'} == 1) {
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

sub itemnodata {
  my ($env,$dbh,$itemnumber) = @_;
  my $query="Select * from biblio,items,biblioitems
    where items.itemnumber = '$itemnumber'
    and biblio.biblionumber = items.biblionumber
    and biblioitems.biblioitemnumber = items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;    
  return($data);	       
}

#used by member enquiries from the intranet
#called by member.pl
sub BornameSearch  {
  my ($env,$searchstring,$type)=@_;
  my $dbh = &C4Connect;
  my $query="Select * from borrowers 
  where surname like '%$searchstring%' 
  or firstname  like '%$searchstring%' 
  or othernames like '%$searchstring%'
  or cardnumber = '$searchstring'
  order by surname,firstname";
  #print $query,"\n";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $cnt=0;
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
    $cnt ++;
  }
#  $sth->execute;
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

sub borrdata2 {
  my ($env,$bornum)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from issues where borrowernumber='$bornum' and
    returndate is NULL";
    # print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select count(*) from issues where
    borrowernumber='$bornum' and date_due < now() and returndate is NULL");
  $sth->execute;
  my $data2=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select sum(amountoutstanding) from accountlines where
    borrowernumber='$bornum'");
  $sth->execute;
  my $data3=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;

return($data2->{'count(*)'},$data->{'count(*)'},$data3->{'sum(amountoutstanding)'});
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

sub itemcount { 
  my ($env,$bibnum)=@_; 
  my $dbh=C4Connect;   
  my $query="Select * from items where     
  biblionumber=$bibnum";       
  my $sth=$dbh->prepare($query);         
  #  print $query;           
  $sth->execute;           
  my $count=0;             
  my $lcount=0;               
  my $nacount=0;                 
  my $fcount=0;
  my $scount=0;
  while (my $data=$sth->fetchrow_hashref){
    $count++;                     
    my $query2="select * from issues where itemnumber=                          
    '$data->{'itemnumber'}' and returndate is NULL"; 
    my $sth2=$dbh->prepare($query2);     
    $sth2->execute;         
    if (my $data2=$sth2->fetchrow_hashref){         
       $nacount++;         
    } else {         
      if ($data->{'holdingbranch'} eq 'C'){         
        $lcount++;               
      }                       
      if ($data->{'holdingbranch'} eq 'F'){         
        $fcount++;               
      }                       
      if ($data->{'holdingbranch'} eq 'S'){         
        $scount++;               
      }                       

    }                             
    $sth2->finish;     
  }                                 
  $sth->finish; 
  $dbh->disconnect;                   
  return ($count,$lcount,$nacount,$fcount,$scount); 


}
END { }       # module clean-up code here (global destructor)






