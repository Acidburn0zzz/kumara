package C4::Reserves; #asummes C4/Reserves

#requires DBI.pm to be installed
#uses DBD:Pg

use strict;
require Exporter;
use DBI;
use C4::Format;
use C4::Interface;
use C4::Interface::Reserveentry;
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
  my %search;
  #debug_msg($env,"ti $title");
  #debug_msg($env,"key $keyword");
  #debug_msg($env,"au $author");
  #debug_msg($env,"su $subject");
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
  if ($no_ents > 1) {
    my %biblio_xref;
    my @bibtitles;
    my $i = 0;
    while ($i < $no_ents) {
       my @ents = split("\t",@results[$i]);
       my $line;
       my $totlen = length(@ents[1]) + length(@ents[2]);
       if ($totlen < 60) {
         $line = join(": ",@ents[1],@ents[2]);
       } else {
	 my $len2 = length(@ents[2]);
	 if ($len2 > 20) {
	   $line = join(": ",substr(@ents[1],0,40),@ents[2]);
	 } else {
	   $line = join(": ",substr(@ents[1],1,(59-$len2)),@ents[2])
         }
         $line = substr($line,0,60);
       }
       @bibtitles[$i]=$line;	 
       $biblio_xref{$line}=@ents[0];
       $i++;
     }
     titlepanel($env,"Reserves","Select Title");
     my ($results,$bibres)  =  SelectBiblio($env,$count,\@bibtitles);
     debug_msg($env,$bibres);
     $biblionumber = $biblio_xref{$bibres};
   } elsif ($no_ents = 1) {
     my @ents = split("\t",@results[0]);
     $biblionumber  = @ents[0];
   } 
  
}

			
END { }       # module clean-up code here (global destructor)
