package C4::Acquisitions; #asummes C4/Acquisitions.pm

use strict;
require Exporter;
use C4::Database;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&getorders &bookseller &breakdown &basket &newbasket &bookfunds
&ordersearch &newbiblio &newbiblioitem &newsubject &newsubtitle &neworder
 &newordernum &modbiblio &modorder &getsingleorder &invoice &receiveorder
 &bookfundbreakdown &curconvert &updatesup &insertsup &makeitems &modbibitem
&getcurrencies &modsubtitle &modsubject &modaddauthor &moditem &countitems 
&findall &needsmod);
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

sub getorders {
  my ($supplierid)=@_;
  my $dbh=C4Connect;
  my $query = "Select count(*),authorisedby,entrydate,basketno from aqorders where 
  booksellerid='$supplierid' and (datereceived = '0000-00-00' or
datereceived is NULL) and (cancelledby is NULL or cancelledby = '')";
  $query.=" group by basketno order by entrydate";
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
  return ($i,\@results);
}

sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblio,biblioitems,aqorders,aqorderbreakdown 
  where aqorders.ordernumber=$ordnum 
  and biblio.biblionumber=aqorders.biblionumber and
  biblioitems.biblioitemnumber=aqorders.biblioitemnumber and
  aqorders.ordernumber=aqorderbreakdown.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub invoice {
  my ($invoice)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where
  booksellerinvoicenumber='$invoice' 
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub ordersearch {
  my ($search)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblioitems
  where aqorders.biblioitemnumber=
  biblioitems.biblioitemnumber 
  and ((";
  my @data=split(' ',$search);
  my $count=@data;
  for (my $i=0;$i<$count;$i++){
    $query.= "(aqorders.title like '$data[$i]%' or aqorders.title like '% $data[$i]%') and ";
  }
  $query=~ s/ and $//;
  $query.=" ) or biblioitems.isbn='$search' 
  or aqorders.ordernumber='$search') 
  group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
     my $sth2=$dbh->prepare("Select * from biblio where
     biblionumber='$data->{'biblionumber'}'");
     $sth2->execute;
     my $data2=$sth2->fetchrow_hashref;
     $sth2->finish;
     $data->{'author'}=$data2->{'author'};
     $sth2=$dbh->prepare("Select * from aqorderbreakdown where
    ordernumber=$data->{'ordernumber'}");
    $sth2->execute;
    $data2=$sth2->fetchrow_hashref;
    $sth2->finish;
    $data->{'branchcode'}=$data2->{'branchcode'};
    $data->{'bookfundid'}=$data2->{'bookfundid'};
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}


sub bookseller {
  my ($searchstring)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqbooksellers where name like '$searchstring%' or
  id = '$searchstring'";
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
  return($i,@results);
}

sub breakdown {
  my ($id)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorderbreakdown where ordernumber='$id'";
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

sub basket {
  my ($basketno)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where basketno='$basketno'
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber
  =aqorders.biblioitemnumber group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
#  print $query;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub newbasket {
  my $dbh=C4Connect;
  my $query="Select max(basketno) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $basket=$$data[0];
  $basket++;
  $sth->finish;
  $dbh->disconnect;
  return($basket);
}

sub bookfunds {
  my $dbh=C4Connect;
  my $query="Select * from aqbookfund,aqbudget where aqbookfund.bookfundid
  =aqbudget.bookfundid group by aqbookfund.bookfundid order by bookfundname";
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
  return($i,@results);
}

sub bookfundbreakdown {
  my ($id)=@_;
  my $dbh=C4Connect;
  my $query="Select quantity,datereceived,freight,unitprice,listprice
  from aqorders,aqorderbreakdown where bookfundid='$id' and 
  aqorders.ordernumber=aqorderbreakdown.ordernumber and entrydate >=
  '1999-06-01'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $comtd=0;
  my $spent=0;
  while (my $data=$sth->fetchrow_hashref){
    if ($data->{'datereceived'} =~ /0000/){
       $comtd+=($data->{'listprice'}+$data->{'freight'})*$data->{'quantity'};
    } else {
       $spent+=($data->{'unitprice'}+$data->{'freight'})*$data->{'quantity'};
    }
  }
  $sth->finish;
  $dbh->disconnect;
  return($spent,$comtd);
}
      

sub newbiblio {
  my ($title,$author,$copyright)=@_;
  my $dbh=C4Connect;
  my $query="Select max(biblionumber) from biblio";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $bibnum=$$data[0];
  $bibnum++;
  $sth->finish;
  $query="insert into biblio (biblionumber,title,author,copyrightdate) values
  ($bibnum,'$title','$author','$copyright')";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
  return($bibnum);
}

sub modbiblio {
  my ($bibnum,$title,$author,$copyright,$seriestitle,$serial,$unititle,$notes)=@_;
  my $dbh=C4Connect;
#  $title=~ s/\'/\\\'/g;
#  $author=~ s/\'/\\\'/g;
  my $query="update biblio set title='$title',
  author='$author',copyrightdate='$copyright',
  seriestitle='$seriestitle',serial='$serial',unititle='$unititle',notes='$notes'
  where
  biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
#    print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
    return($bibnum);
}

sub modsubtitle {
  my ($bibnum,$subtitle)=@_;
  my $dbh=C4Connect;
  my $query="update bibliosubtitle set subtitle='$subtitle' where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub modaddauthor {
  my ($bibnum,$author)=@_;
  my $dbh=C4Connect;
  my $query="Select * from additionalauthors where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  if (my $data=$sth->fetchrow_hashref){
    $query="update additionalauthors set author='$author' where biblionumber=$bibnum";
  } else {
    $query="insert into additionalauthors (author,biblionumber) values ('$author','$bibnum')";
  }
  $sth->finish;
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
} 

sub modsubject {
  my ($bibnum,$force,@subject)=@_;
  my $dbh=C4Connect;
  my $count=@subject;
  my $error;
  for (my $i=0;$i<$count;$i++){
    $subject[$i]=~ s/^ //g;
    $subject[$i]=~ s/ $//g;
    my $query="select * from catalogueentry where entrytype='s' and
    catalogueentry='$subject[$i]'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    if (my $data=$sth->fetchrow_hashref){
      
    } else {
      if ($force eq $subject[$i]){
         #subject not in aut, chosen to force anway
	 #so insert into cataloguentry so its in auth file
	 $query="Insert into catalogueentry (entrytype,catalogueentry)
	 values ('s','$subject[$i]')";
	 my $sth2=$dbh->prepare($query);
#	 print $query;
	 $sth2->execute;
	 $sth2->finish;
      } else {      
        $error="$subject[$i]\n does not exist in the subject authority file";
        $query= "Select * from catalogueentry where
        entrytype='s' and (catalogueentry like '$subject[$i] %' or 
        catalogueentry like '% $subject[$i] %' or catalogueentry like
        '% $subject[$i]')";
        my $sth2=$dbh->prepare($query);
#        print $query;
        $sth2->execute;
        while (my $data=$sth2->fetchrow_hashref){
          $error=$error."<br>$data->{'catalogueentry'}";
        }
        $sth2->finish;
#       $error=$error."<br>$query";
     }
   }
    $sth->finish;
  }
  if ($error eq ''){  
    my $query="Delete from bibliosubject where biblionumber=$bibnum";
#  print $query;
    my $sth=$dbh->prepare($query);
#  print $query;
    $sth->execute;
    $sth->finish;
    for (my $i=0;$i<$count;$i++){
      $sth=$dbh->prepare("Insert into bibliosubject values ('$subject[$i]',$bibnum)");
#     print $subject[$i];
      $sth->execute;
      $sth->finish;
    }
  }
  $dbh->disconnect;
  return($error);
}

sub modbibitem {
  my
($bibitemnum,$itemtype,$isbn,$publishercode,$publicationdate,$classification,$dewey,$subclass,$illus,$pages,$volumeddesc,$notes,$size)=@_;
  my $dbh=C4Connect;
  my $query="update biblioitems set itemtype='$itemtype',
  isbn='$isbn',publishercode='$publishercode',publicationyear='$publicationdate',
  classification='$classification',dewey='$dewey',subclass='$subclass',illus='$illus',
  pages='$pages',volumeddesc='$volumeddesc',notes='$notes',size='$size'
  where
  biblioitemnumber=$bibitemnum";
  my $sth=$dbh->prepare($query);
#    print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newbiblioitem {
  my ($bibnum,$itemtype,$isbn,$volinf,$class)=@_;
  my $dbh=C4Connect;
  my $query="Select max(biblioitemnumber) from biblioitems";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $bibitemnum=$$data[0];
  $bibitemnum++;
  $sth->finish;
  $query="insert into biblioitems (biblionumber,biblioitemnumber,
  itemtype,isbn,volumeddesc,classification) 
  values
  ($bibnum,$bibitemnum,'$itemtype','$isbn','$volinf','$class')";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
  return($bibitemnum);
}

sub newsubject {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
  my $query="insert into bibliosubject (biblionumber) values
  ($bibnum)";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newsubtitle {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
  my $query="insert into bibliosubtitle (biblionumber) values
  ($bibnum)";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub neworder {
  my ($bibnum,$title,$ordnum,$basket,$quantity,$listprice,$supplier,$who,
  $notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst)=@_;
  my $dbh=C4Connect;
  my $query="insert into aqorders (biblionumber,title,ordernumber,basketno,
  quantity,listprice,booksellerid,entrydate,requisitionedby,authorisedby,notes,
  biblioitemnumber,rrp,ecost,gst) 
  values
  ($bibnum,'$title',$ordnum,$basket,$quantity,$listprice,'$supplier',now(),
  '$who','$who','$notes',$bibitemnum,'$rrp','$ecost','$gst')";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="insert into aqorderbreakdown (ordernumber,bookfundid) values
  ($ordnum,'$bookfund')";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub modorder {
  my ($title,$ordnum,$quantity,$listprice)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set title='$title',
  quantity='$quantity',listprice='$listprice' where
  ordernum=$ordnum";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newordernum {
  my $dbh=C4Connect;
  my $query="Select max(ordernumber) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $ordnum=$$data[0];
  $ordnum++;
  $sth->finish;
  $dbh->disconnect;
  return($ordnum);
}

sub receiveorder {
  my ($biblio,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set quantityreceived='$quantrec',
  datereceived=now(),booksellerinvoicenumber='$invoiceno',
  biblioitemnumber=$bibitemno,unitprice='$cost',freight='$freight'
  where biblionumber=$biblio and ordernumber=$ordnum
  ";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub curconvert {
  my ($currency,$price)=@_;
  my $dbh=C4Connect;
  my $query="Select rate from currency where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  my $cur=$data->{'rate'};
  if ($cur==0){
    $cur=1;
  }
  my $price=$price / $cur;
  return($price);
}

sub getcurrencies {
  my $dbh=C4Connect;
  my $query="Select * from currency";
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
  return($i,@results);
} 

sub updatesup {
   my ($data)=@_;
   my $dbh=C4Connect;
   my $query="Update aqbooksellers set
   name='$data->{'name'}',address1='$data->{'address1'}',address2='$data->{'address2'}',
   address3='$data->{'address3'}',address4='$data->{'address4'}',postal='$data->{'postal'}',
   phone='$data->{'phone'}',fax='$data->{'fax'}',url='$data->{'url'}',
   contact='$data->{'contact'}',contpos='$data->{'contpos'}',
   contphone='$data->{'contphone'}', contfax='$data->{'contfax'}', contaltphone=
   '$data->{'contaltphone'}', contemail='$data->{'contemail'}', contnotes=
   '$data->{'contnotes'}', active=$data->{'active'},
   listprice='$data->{'listprice'}', invoiceprice='$data->{'invoiceprice'}',
   gstreg=$data->{'gstreg'}, listincgst=$data->{'listincgst'},
   invoiceincgst=$data->{'invoiceincgst'}, specialty='$data->{'specialty'}',
   discount='$data->{'discount'}'
   where id='$data->{'id'}'";
   my $sth=$dbh->prepare($query);
   $sth->execute;
   $sth->finish;
   $dbh->disconnect;
#   print $query;
}

sub insertsup {
  my ($data)=@_;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select max(id) from aqbooksellers");
  $sth->execute;
  my $data2=$sth->fetchrow_hashref;
  $sth->finish;
  $data2->{'max(id)'}++;
  $sth=$dbh->prepare("Insert into aqbooksellers (id) values ($data2->{'max(id)'})");
  $sth->execute;
  $sth->finish;
  $data->{'id'}=$data2->{'max(id)'};
  $dbh->disconnect;
  updatesup($data);
  return($data->{'id'});
}

sub makeitems {
  my ($count,$bibitemno,$biblio,$replacement,$price,$booksellerid,$branch,@barcodes)=@_;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select max(itemnumber) from items");
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  my $item=$data->{'max(itemnumber)'};
  $sth->finish;
  $item++;
  for (my $i=0;$i<$count;$i++){
    $barcodes[$i]=uc $barcodes[$i];
    my $query="Insert into items (biblionumber,biblioitemnumber,itemnumber,barcode,
    booksellerid,dateaccessioned,homebranch,holdingbranch,price,replacementprice,
    replacementpricedate) values
    ($biblio,$bibitemno,$item,'$barcodes[$i]','$booksellerid',now(),'$branch',
    '$branch','$price','$replacement',now())";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $item++;
#    print $query;
  }
  $dbh->disconnect;
}

sub moditem {
  my ($itemnum,$bibitemnum,$barcode,$notes)=@_;
  my $dbh=C4Connect;
  my $query="update items set biblioitemnumber=$bibitemnum,
  barcode='$barcode',itemnotes='$notes'
  where itemnumber=$itemnum";
  if ($barcode eq ''){
    $query="update items set biblioitemnumber=$bibitemnum where itemnumber=$itemnum";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub countitems{
  my ($bibitemnum)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from items where biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data->{'count(*)'});
}

sub findall {
  my ($biblionumber)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems,items,itemtypes where 
  biblioitems.biblionumber=$biblionumber 
  and biblioitems.biblioitemnumber=items.biblioitemnumber and
  itemtypes.itemtype=biblioitems.itemtype
  order by items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

sub needsmod{
  my ($bibitemnum,$itemtype)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems where biblioitemnumber=$bibitemnum
  and itemtype='$itemtype'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $result=0;
  if (my $data=$sth->fetchrow_hashref){
    $result=1;
  }
  $sth->finish;
  $dbh->disconnect;
  return($result);
}

END { }       # module clean-up code here (global destructor)
  
    
