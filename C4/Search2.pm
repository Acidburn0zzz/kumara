package C4::Search; #asummes C4/Search

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Reserves2;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&CatSearch &BornameSearch &ItemInfo &KeywordSearch &subsearch
&itemdata &bibdata &GetItems &borrdata &getacctlist &itemnodata &itemcount
&OpacSearch &borrdata2 &NewBorrowerNumber &bibitemdata &borrissues
&getboracctrecord &ItemType &itemissues &FrontSearch &subject &subtitle
&addauthor &bibitems &barcodes &findguarantees); 
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
sub findguarantees{         
  my ($bornum)=@_;         
  my $dbh=C4Connect;           
  my $query="select cardnumber,borrowernumber from borrowers where    
  guarantor='$bornum'";               
  my $sth=$dbh->prepare($query);                 
  $sth->execute;                   
  my @dat;                     
  my $i=0;                       
  while (my $data=$sth->fetchrow_hashref){    
    $dat[$i]=$data;                           
    $i++;                               
  }                                   
  $sth->finish; 
  $dbh->disconnect;         
  return($i,\@dat);             
}

sub NewBorrowerNumber {           
  my $dbh=C4Connect;        
  my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");     
  $sth->execute;            
  my $data=$sth->fetchrow_hashref;                                  
  $sth->finish;                   
  $data->{'max(borrowernumber)'}++;         
  $dbh->disconnect;
  return($data->{'max(borrowernumber)'}); 
}    

sub OpacSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  $search->{'keyword'}=~ s/'/\\'/g;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select count(*) from biblio where 
  ((title like '$key[0]%' or title like '% $key[0]%')";
  while ($i < $count){
    $query=$query." and (title like '$key[$i]%' or title like '% $key[$i]%')";
    $i++;
  }
  $query=$query.") or ((author like '$key[0]%' or author like '% $key[0]%')";
  $i=1;
  while ($i < $count){
    $query=$query." and (author like '$key[$i]%' or author like '% $key[$i]%')";
    $i++;
  }
  $query.=") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";
  }
  $query.= ") or ((notes like '$key[0]%' or notes like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (notes like '$key[$i]%' or notes like '% $key[$i]%')";
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


  
sub FrontSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  $search->{'front'}=~ s/ +$//;
  $search->{'front'}=~ s/'/\\'/;
  my @key=split(' ',$search->{'front'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select * from biblio,bibliosubtitle where
  biblio.biblionumber=bibliosubtitle.biblionumber and
  ((title like '$key[0]%' or title like '% $key[0]%'
  or subtitle like '$key[0]%' or subtitle like '% $key[0]%'
  or author like '$key[0]%' or author like '% $key[0]%')";
  while ($i < $count){
    $query=$query." and (title like '%$key[$i]%' or subtitle like '%$key[$i]%')";
    $i++;
  }
  $query=$query.") group by biblio.biblionumber order by author,title";
  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}";
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

$results[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data->{'copyrightdate'}";
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

  
sub KeywordSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  $search->{'keyword'}=~ s/ +$//;
  $search->{'keyword'}=~ s/'/\\'/;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select * from biblio,bibliosubtitle,biblioitems where
  biblio.biblionumber=bibliosubtitle.biblionumber and
  biblioitems.biblionumber=biblio.biblionumber and
  (((title like '$key[0]%' or title like '% $key[0]%')";
  while ($i < $count){
    $query=$query." and (title like '$key[$i]%' or title like '% $key[$i]%')";
    $i++;
  }
  $query.= ") or ((subtitle like '$key[0]%' or subtitle like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.= " and (subtitle like '$key[$i]%' or subtitle like '% $key[$i]%')";
  }
  $query.= ") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";
  }
  $query.= ") or ((biblio.notes like '$key[0]%' or biblio.notes like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblio.notes like '$key[$i]%' or biblio.notes like '% $key[$i]%')";
  }
  $query.= ") or ((biblioitems.notes like '$key[0]%' or biblioitems.notes like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblioitems.notes like '$key[$i]%' or biblioitems.notes like '% $key[$i]%')";
  }
  if ($search->{'keyword'} =~ /new zealand/i){
    $query.= "or (title like 'nz%' or title like '% nz %' or title like '% nz' or subtitle like 'nz%'
    or subtitle like '% nz %' or subtitle like '% nz' or author like 'nz %' 
    or author like '% nz %' or author like '% nz')"
  }
  if ($search->{'keyword'} eq  'nz' || $search->{'keyword'} eq 'NZ' ||
  $search->{'keyword'} =~ /nz /i || $search->{'keyword'} =~ / nz /i ||
  $search->{'keyword'} =~ / nz/i){
    $query.= "or (title like 'new zealand%' or title like '% new zealand %'
    or title like '% new zealand' or subtitle like 'new zealand%' or
    subtitle like '% new zealand %'
    or subtitle like '% new zealand' or author like 'new zealand%' 
    or author like '% new zealand %' or author like '% new zealand' or 
    seriestitle like 'new zealand%' or seriestitle like '% new zealand %'
    or seriestitle like '% new zealand')"
  }
  $query=$query."))";
    if ($search->{'class'} ne ''){
    my @temp=split(/\|/,$search->{'class'});
    my $count=@temp;
    $query.= "and ( itemtype='$temp[0]'";
    for (my $i=1;$i<$count;$i++){
      $query.=" or itemtype='$temp[$i]'";
    }
    $query.=")"; 
  }
   $query.="group by biblio.biblionumber order by author,title";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}";
#      print $results[$i];
    $i++;
  }
  $sth->finish;
  $sth=$dbh->prepare("Select biblionumber from bibliosubject where subject
  like '%$search->{'keyword'}%'");
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $query="Select * from biblio,biblioitems where
    biblio.biblionumber=$data->{'biblionumber'} and biblio.biblionumber=biblioitems.biblionumber";
    if ($search->{'class'} ne ''){
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;
      $query.= " and ( itemtype='$temp[0]'";
      for (my $i=1;$i<$count;$i++){
        $query.=" or itemtype='$temp[$i]'";
      }
      $query.=")"; 
    }
    my $sth2=$dbh->prepare($query);
    $sth2->execute;
#    print $query;
    while (my $data2=$sth2->fetchrow_hashref){
       $results[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}";
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
  if ($count > 0){
    $res[0]=$results[0];
  }
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
#  $i--;
  return($i,@res2);
}

sub CatSearch  {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
  my $query = '';
    my @results;
  $search->{'title'}=~ s/'/\\'/g;
    $search->{'author'}=~ s/'/\\'/g;
  my $title = lc($search->{'title'}); 
  
  if ($type eq 'loose') {
      if ($search->{'author'} ne ''){
        my @key=split(' ',$search->{'author'});
	my $count=@key;
	my $i=1;
        $query="select *,biblio.author from
         biblioitems,biblio
	 left join additionalauthors
	 on additionalauthors.biblionumber =biblio.biblionumber
         where biblioitems.biblionumber=biblio.biblionumber 
	 and
         ((biblio.author like '$key[0]%' or biblio.author like '% $key[0]%' or
	 additionalauthors.author like '$key[0]%' or additionalauthors.author 
	 like '% $key[0]%'
	 	 )";    
	 while ($i < $count){ 
           $query=$query." and (
	   biblio.author like '$key[$i]%' or biblio.author like '% $key[$i]%' or
	   additionalauthors.author like '$key[$i]%' or additionalauthors.author like '% $key[$i]%'
	   )";
           $i++;       
	 }   
	 $query=$query.")";
         if ($search->{'title'} ne ''){ 
	   $query=$query. " and title like '%$search->{'title'}%'";
	 }
	 if ($search->{'class'} ne ''){
      	   my @temp=split(/\|/,$search->{'class'});
	   my $count=@temp;
	   $query.= "and ( itemtype='$temp[0]'";
	   for (my $i=1;$i<$count;$i++){
	     $query.=" or itemtype='$temp[$i]'";
  	   }
	   $query.=") ";
	 }
	 if ($search->{'dewey'} ne ''){
	      $query.=" and dewey='$search->{'dewey'}' ";
         }           
	 
	 $query.=" group by biblio.biblionumber";
      } else {
          if ($search->{'title'} ne ''){
	   if ($search->{'ttype'} eq 'exact'){
	     $query="select * from biblio
	     where                            
	     (biblio.title='$search->{'title'}' or (biblio.unititle = '$search->{'title'}'
	     or biblio.unititle like '$search->{'title'} |%' or 
	     biblio.unititle like '%| $search->{'title'} |%' or
	     biblio.unititle like '%| $search->{'title'}') or
	     (biblio.seriestitle = '$search->{'title'}' or
	     biblio.seriestitle like '$search->{'title'} |%' or
	     biblio.seriestitle like '%| $search->{'title'} |%' or
	     biblio.seriestitle like '%| $search->{'title'}')
	     )";
	   } else {
	    my @key=split(' ',$search->{'title'});
	    my $count=@key;
	    my $i=1;
            $query="select * from biblio,bibliosubtitle,biblioitems
	    where
            (biblio.biblionumber=bibliosubtitle.biblionumber and
            biblioitems.biblionumber=biblio.biblionumber) and
	    (((title like '$key[0]%' or title like '% $key[0] %' or title like '% $key[0]')";
	    while ($i<$count){
	      $query=$query." and (title like '$key[$i]%' or title like '% $key[$i] %' or title like '% $key[$i]')";
	      $i++;
	    }
	    $query.=") or ((subtitle like '$key[0]%' or subtitle like '% $key[0] %' or subtitle like '% $key[0]')";
	    for ($i=1;$i<$count;$i++){
	      $query.=" and (subtitle like '$key[$i]%' or subtitle like '% $key[$i] %' or subtitle like '% $key[$i]')";
	    }
	    $query.=") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0] %' or seriestitle like '% $key[0]')";
	    for ($i=1;$i<$count;$i++){
	      $query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i] %')";
	    }
	    $query.=") or ((unititle like '$key[0]%' or unititle like '% $key[0] %' or unititle like '% $key[0]')";
	    for ($i=1;$i<$count;$i++){
	      $query.=" and (unititle like '$key[$i]%' or unititle like '% $key[$i] %')";
	    }
	    $query=$query."))";
	    if ($search->{'class'} ne ''){
	      my @temp=split(/\|/,$search->{'class'});
	      my $count=@temp;
	      $query.= " and ( itemtype='$temp[0]'";
	      for (my $i=1;$i<$count;$i++){
	       $query.=" or itemtype='$temp[$i]'";
	      }
	      $query.=")";
	    }
	    if ($search->{'dewey'} ne ''){
	      $query.=" and dewey='$search->{'dewey'}' ";
	    }
	   }
	  } elsif ($search->{'class'} ne ''){
	     $query="select * from biblioitems,biblio where biblio.biblionumber=biblioitems.biblionumber";
	     my @temp=split(/\|/,$search->{'class'});
	      my $count=@temp;
	      $query.= " and ( itemtype='$temp[0]'";
	      for (my $i=1;$i<$count;$i++){
	       $query.=" or itemtype='$temp[$i]'";
	      }
	      $query.=")";
	  } elsif ($search->{'dewey'} ne ''){
	     $query="select * from biblioitems,biblio 
	     where biblio.biblionumber=biblioitems.biblionumber
	     and biblioitems.dewey like '$search->{'dewey'}%'";
	  }
          $query .=" group by biblio.biblionumber";	 
      }

  } 
  if ($type eq 'subject'){
    my @key=split(' ',$search->{'subject'});
    my $count=@key;
    my $i=1;
    $query="select distinct(subject) from bibliosubject where( subject like
    '$key[0]%' or subject like '% $key[0]%' or subject like '% $key[0]' or subject like '%($key[0])%')";
    while ($i<$count){
      $query.=" and (subject like '$key[$i]%' or subject like '% $key[$i]%'
      or subject like '% $key[$i]'
      or subject like '%($key[$i])%')";
      $i++;
    }
    if ($search->{'subject'} eq 'NZ' || $search->{'subject'} eq 'nz'){ 
      $query.= " or (subject like 'NEW ZEALAND %' or subject like '% NEW ZEALAND %'
      or subject like '% NEW ZEALAND' or subject like '%(NEW ZEALAND)%' ) ";
    } elsif ( $search->{'subject'} =~ /^nz /i || $search->{'subject'} =~ / nz /i || $search->{'subject'} =~ / nz$/i){
      $query=~ s/ nz/ NEW ZEALAND/ig;
      $query=~ s/nz /NEW ZEALAND /ig;
      $query=~ s/\(nz\)/\(NEW ZEALAND\)/gi;
    }  
  }
  if ($type eq 'precise'){
      $query="select * from items,biblio ";
      if ($search->{'item'} ne ''){
        my $search2=uc $search->{'item'};
        $query=$query." where 
        items.biblionumber=biblio.biblionumber 
	and barcode='$search2'";
      }
      if ($search->{'isbn'} ne ''){
        my $search2=uc $search->{'isbn'};
        my $query1 = "select * from biblioitems where isbn='$search2'";
	my $sth1=$dbh->prepare($query1);
#	print $query1;
	$sth1->execute;
        my $i2=0;
	while (my $data=$sth1->fetchrow_hashref) {
	   $query="select * from biblioitems,biblio where
           biblio.biblionumber = $data->{'biblionumber'}
           and biblioitems.biblionumber = biblio.biblionumber";
	   my $sth=$dbh->prepare($query);
	   $sth->execute;
	   my $data=$sth->fetchrow_hashref;
           $results[$i2]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$data->{'isbn'}\t$data->{'itemtype'}";
           $i2++; 
	   $sth->finish;
	}
	$sth1->finish;
      }
  }
#print $query;
if ($type ne 'precise' && $type ne 'subject'){
  if ($search->{'author'} ne ''){   
      $query=$query." order by biblio.author,title";
  } else {
      $query=$query." order by title";
  }
} else {
  if ($type eq 'subject'){
      $query=$query." order by subject";
  }
}
my $sth=$dbh->prepare($query);
$sth->execute;
my $count=0;
my $i=0;
my $limit= $num+$offset;
while (my $data=$sth->fetchrow_hashref){
  if ($count > $offset && $count <= $limit){
    if ($type ne 'subject' && $type ne 'precise'){
       $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}";
    } elsif ($search->{'isbn'} ne '' || $search->{'item'} ne ''){
       $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}";
    } else {  
     $results[$i]="$data->{'author'}\t$data->{'subject'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}";
    }
    $i++;
  }
  $count++;
}
$sth->finish;

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
  bibliosubject.subject='$subject' group by biblio.biblionumber
  order by biblio.title";
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
  my ($env,$biblionumber,$type)=@_;
  my $dbh = &C4Connect;
  my $query="Select * from items,biblio,biblioitems,branches 
  where (items.biblioitemnumber = biblioitems.biblioitemnumber)
  and biblioitems.biblionumber=biblio.biblionumber
  and biblio.biblionumber='$biblionumber' and branches.branchcode=
  items.holdingbranch ";
#  print $type;
  if ($type ne 'intra'){
    $query.=" and (items.itemlost<>1 or items.itemlost is NULL)
    and (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  $query=$query."order by items.dateaccessioned desc";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
#  print $query;
  while (my $data=$sth->fetchrow_hashref){
    my $iquery = "Select * from issues
    where itemnumber = '$data->{'itemnumber'}'
    and returndate is null";
    my $datedue = '';
    my $isth=$dbh->prepare($iquery);
    $isth->execute;
    if (my $idata=$isth->fetchrow_hashref){
      my @temp=split('-',$idata->{'date_due'});
      $datedue = "$temp[2]/$temp[1]/$temp[0]";
    }
    if ($data->{'itemlost'} eq '1'){
        $datedue='Itemlost';
    }
    if ($data->{'wthdrawn'} eq '1'){
      $datedue="Cancelled";
    }
    if ($datedue eq ''){
       my ($rescount,$reserves)=FindReserves($biblionumber,'');   
       if ($rescount >0){                                
          $datedue='Request';
       }
    }
    $isth->finish;
    my $class = $data->{'classification'};
    my $dewey = $data->{'dewey'};
    $dewey =~ s/0+$//;
    if ($dewey eq "000.") { $dewey = "";};    
    if ($dewey < 10){$dewey='00'.$dewey;}
    if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
    if ($dewey <= 0){
      $dewey='';
    }
    $dewey=~ s/\.$//;
    $class = $class.$dewey;
    $class = $class.$data->{'subclass'};
 #   $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$data->{'dewey'}";
    my @temp=split('-',$data->{'datelastseen'});
    my $date="$temp[2]/$temp[1]/$temp[0]";
    $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$class\t$data->{'itemnumber'}\t$data->{'itemtype'}\t$date\t$data->{'biblioitemnumber'}\t$data->{'volumeddesc'}";
#    print "$results[$i] <br>";
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
  my ($bibnum,$type)=@_;
  my $dbh=C4Connect;
  my $query="Select *,biblio.notes from biblio,biblioitems,bibliosubtitle where biblio.biblionumber=$bibnum
  and biblioitems.biblionumber=$bibnum and 
(bibliosubtitle.biblionumber=$bibnum)"; 
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $query="Select * from bibliosubject where biblionumber='$bibnum'";
  $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $dat=$sth->fetchrow_hashref){
    $data->{'subject'}.=" | $dat->{'subject'}";

  }
  #print $query;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub bibitemdata {
  my ($bibitem)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblio,biblioitems,itemtypes where biblio.biblionumber=
  biblioitems.biblionumber and biblioitemnumber=$bibitem and
  biblioitems.itemtype=itemtypes.itemtype";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub subject {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
  my $query="Select * from bibliosubject where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

sub addauthor {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
  my $query="Select * from additionalauthors where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

sub subtitle {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
  my $query="Select * from bibliosubtitle where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}



sub itemissues {
  my ($bibitem,$biblio)=@_;
  my $dbh=C4Connect;
  my $query="Select * from items where 
  items.biblioitemnumber=$bibitem";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    my $query2="select * from issues,borrowers where itemnumber=$data->{'itemnumber'}
    and returndate is NULL and issues.borrowernumber=borrowers.borrowernumber";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute;
    if (my $data2=$sth2->fetchrow_hashref){
      $data->{'date_due'}=$data2->{'date_due'};
      $data->{'card'}=$data2->{'cardnumber'};
    } else {
      if ($data->{'wthdrawn'} eq '1'){
        $data->{'date_due'}='Cancelled';
      } else {
#         my ($rescount,$reserves)=FindReserves($biblio,'');   
#         if ($rescount >0){#
#	   $data->{'date_due'}='Request';
#	 } else {
          $data->{'date_due'}='Available';
#	}
      }
    }
    $sth2->finish;
    $query2="select * from issues,borrowers where itemnumber='$data->{'itemnumber'}'
    and issues.borrowernumber=borrowers.borrowernumber 
    order by date_due desc";
    my $sth2=$dbh->prepare($query2);
#   print $query2;
    $sth2->execute;
    for (my $i2=0;$i2<2;$i2++){
      if (my $data2=$sth2->fetchrow_hashref){
        $data->{"timestamp$i2"}=$data2->{'timestamp'};
        $data->{"card$i2"}=$data2->{'cardnumber'};
	$data->{"borrower$i2"}=$data2->{'borrowernumber'};
      }
    }
    $sth2->finish;
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

sub itemnodata {
  my ($env,$dbh,$itemnumber) = @_;
  $dbh=C4Connect;
  my $query="Select * from biblio,items,biblioitems
    where items.itemnumber = '$itemnumber'
    and biblio.biblionumber = items.biblionumber
    and biblioitems.biblioitemnumber = items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;  
  $dbh->disconnect;
  return($data);	       
}

#used by member enquiries from the intranet
#called by member.pl
sub BornameSearch  {
  my ($env,$searchstring,$type)=@_;
  my $dbh = &C4Connect;
  $searchstring=~ s/\'/\\\'/g;
  my @data=split(' ',$searchstring);
  my $count=@data;
  my $query="Select * from borrowers 
  where ((surname like \"$data[0]%\" or surname like \"% $data[0]%\" 
  or firstname  like \"$data[0]%\" or firstname like \"% $data[0]%\" 
  or othernames like \"$data[0]%\" or othernames like \"% $data[0]%\")
  ";
  for (my $i=1;$i<$count;$i++){
    $query=$query." and (surname like \"$data[$i]%\" or surname like \"% $data[$i]%\"                  
    or firstname  like \"$data[$i]%\" or firstname like \"% $data[$i]%\"                    
    or othernames like \"$data[$i]%\" or othernames like \"% $data[$i]%\")";
  }
  $query=$query.") or cardnumber = \"$searchstring\"
  order by surname,firstname";
#  print $query,"\n";
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
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh=C4Connect;
  my $query;
  if ($bornum eq ''){
    $query="Select * from borrowers where cardnumber='$cardnumber'";
  } else {
      $query="Select * from borrowers where borrowernumber='$bornum'";
  }
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub borrissues {
  my ($bornum)=@_;
  my $dbh=C4Connect;
  my $query;
  $query="Select * from issues,biblio,items where borrowernumber='$bornum' and
items.itemnumber=issues.itemnumber and
items.biblionumber=biblio.biblionumber and issues.returndate is NULL order
by date_due";
  #print $query;
  my $sth=$dbh->prepare($query);
    $sth->execute;
  my @result;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $result[$i]=$data;;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@result);
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
#   print $query;
   $sth->execute;
   my $total=0;
   while (my $data=$sth->fetchrow_hashref){
      $acctlines[$numlines] = $data;
      $numlines++;
      $total = $total+ $data->{'amountoutstanding'};
   }
   return ($numlines,\@acctlines,$total);
   $sth->finish;
   $dbh->disconnect;
}

sub getboracctrecord {
   my ($env,$params) = @_;
   my $dbh=C4Connect;
   my @acctlines;
   my $numlines=0;
   my $query= "Select * from accountlines where
borrowernumber=$params->{'borrowernumber'} order by date desc,timestamp desc";
   my $sth=$dbh->prepare($query);
#   print $query;
   $sth->execute;
   my $total=0;
   while (my $data=$sth->fetchrow_hashref){
#      if ($data->{'itemnumber'} ne ''){
#        $query="Select * from items,biblio where items.itemnumber=
#	'$data->{'itemnumber'}' and biblio.biblionumber=items.biblionumber";
#	my $sth2=$dbh->prepare($query);
#	$sth2->execute;
#	my $data2=$sth2->fetchrow_hashref;
#	$sth2->finish;
#	$data=$data2;
 #     }
      $acctlines[$numlines] = $data;
      $numlines++;
      $total = $total+ $data->{'amountoutstanding'};
   }
   $sth->finish;
   $dbh->disconnect;
   return ($numlines,\@acctlines,$total);
}

sub itemcount { 
  my ($env,$bibnum,$type)=@_; 
  my $dbh=C4Connect;   
  my $query="Select * from items where     
  biblionumber=$bibnum ";
  if ($type ne 'intra'){
    $query.=" and (itemlost <>1 or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";      
  }
  my $sth=$dbh->prepare($query);         
  #  print $query;           
  $sth->execute;           
  my $count=0;             
  my $lcount=0;               
  my $nacount=0;                 
  my $fcount=0;
  my $scount=0;
  my $lostcount=0;
  my $mending=0;
  my $transit=0;
  my $ocount=0;
  while (my $data=$sth->fetchrow_hashref){
    $count++;                     
    my $query2="select * from issues,items where issues.itemnumber=                          
    '$data->{'itemnumber'}' and returndate is NULL
    and items.itemnumber=issues.itemnumber and (items.itemlost <>1 or
    items.itemlost is NULL)"; 
    my $sth2=$dbh->prepare($query2);     
    $sth2->execute;         
    if (my $data2=$sth2->fetchrow_hashref){         
       $nacount++;         
    } else {         
      if ($data->{'holdingbranch'} eq 'C'){         
        $lcount++;               
      }                       
      if ($data->{'holdingbranch'} eq 'F' || $data->{'holdingbranch'} eq 'FP'){         
        $fcount++;               
      }                       
      if ($data->{'holdingbranch'} eq 'S' || $data->{'holdingbranch'} eq 'SP'){         
        $scount++;               
      }                       
      if ($data->{'itemlost'} eq '1'){
        $lostcount++;
      }
      if ($data->{'holdingbranch'} eq 'FM'){
        $mending++;
      }
      if ($data->{'holdingbranch'} eq 'TR'){
        $transit++;
      }
    }                             
    $sth2->finish;     
  } 
#  if ($count == 0){
    my $query2="Select * from aqorders where biblionumber=$bibnum";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute;
    if (my $data=$sth2->fetchrow_hashref){
      $ocount=$data->{'quantity'} - $data->{'quantityreceived'};
    }
#    $count+=$ocount;
    $sth2->finish;
  $sth->finish; 
  $dbh->disconnect;                   
  return ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit,$ocount); 
}

sub ItemType {
  my ($type)=@_;
  my $dbh=C4Connect;
  my $query="select description from itemtypes where itemtype='$type'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $dat=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return ($dat->{'description'});
}

sub bibitems {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems,itemtypes,items where
  biblioitems.biblionumber='$bibnum' and biblioitems.itemtype=itemtypes.itemtype and
  biblioitems.biblioitemnumber=items.biblioitemnumber group by
  items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub barcodes{
  my ($biblioitemnumber)=@_;
  my $dbh=C4Connect;
  my $query="Select barcode from items where
   biblioitemnumber='$biblioitemnumber'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @barcodes;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $barcodes[$i]=$data->{'barcode'};
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@barcodes);
  
}
END { }       # module clean-up code here (global destructor)






