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
@EXPORT = qw(&CatSearch &BornameSearch);
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

sub CatSearch  {
  my ($searchstring,$type)=@_;
  my $dbh = &C4Connect;
  my $query = '';
  SWITCH: {
    if ($type eq 'aa') {
      $query="Select * from biblio,catalogueentry,biblioanalysis
      where (catalogueentry.catalogueentry = biblioanalysis.catalogueentry)
      and (bibliosubject.biblionumber = biblio.biblionumber)
      and (catalogueentry.catalogueentry like '%$searchstring%') 
      and (entrytype like '$type%')";
      last SWITCH;
    };
    if ($type eq 'at') {
      $query="Select * from biblio,catalogueentry,biblioanalysis
      where (catalogueentry.catalogueentry = biblioanalysis.analyticaltitle)
      and (bibliosubject.biblionumber = biblio.biblionumber)
      and (catalogueentry.catalogueentry like '%$searchstring%') 
      and (entrytype like '$type%')";
      last SWITCH;
    };
    if ($type eq 'a') {
      $query="Select * from biblio,catalogueentry 
      where (catalogueentry.catalogueentry = biblio.author)
      and (catalogueentry.catalogueentry like '%$searchstring%') 
      and (entrytype like '$type%')";
      last SWITCH;
    };
    if ($type eq 't') {
      $query="Select * from biblio,catalogueentry
      where (catalogueentry.catalogueentry = biblio.title)
      and (catalogueentry.catalogueentry like '%$searchstring%')
      and (entrytype like '$type%')";
      last SWITCH;
    };
    if ($type eq 's') {
      $query="Select * from biblio,catalogueentry,bibliosubject
      where (catalogueentry.catalogueentry = bibliosubject.catalogueentry)
      and (bibliosubject.biblionumber = biblio.biblionumber)
      and (catalogueentry.catalogueentry like '%$searchstring%')
      and (entrytype like '$type%')";
      last SWITCH;
    };
    $query="Select * from catalogueentry where catalogueentry like
    '%$searchstring%' and entrytype like '$type%'";
    last SWITCH;
  }
  print "$query\n";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my @data=$sth->fetchrow_array){
    print "$data[0]\n";
  }
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}    


sub BornameSearch  {
  my ($searchstring,$type)=@_;
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






