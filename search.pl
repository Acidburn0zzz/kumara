#!/usr/bin/perl
#script to provide intranet (librarian) advanced search facility
#modified 9/11/1999 by chris@katipo.co.nz
#adding an extra comment to play with CVS (Si, 19/11/99)
#modified 29/12/99 by chris@katipo.co.nz to be usavle by opac as well

use strict;
use C4::Search;
use CGI;
use C4::Output;

my $env;
my $input = new CGI;
print $input->header;
#whether it is called from the opac of the intranet                                                            
my $type=$input->param('type');                                                                                
#setup colours                                                                                                 
my $main;                                                                                                      
my $secondary;                                                                                                 
if ($type eq 'opac'){                                                                                          
  $main='#99cccc';    
  $secondary='#efe5ef';
} else {                                                                                                       
  $main='#99cc33';                                                                                             
  $secondary='#ffffcc';                                                                                        
}       

#print $input->dump;
my $blah;
my %search;
#build hash of users input
my $title=$input->param('title');
$search{'title'}=$title;
my $keyword=$input->param('keyword');
$search{'keyword'}=$keyword;
my $author=$input->param('author');
$search{'author'}=$author;
my $subject=$input->param('subject');
$search{'subject'}=$subject;
my $itemnumber=$input->param('item');
$search{'item'}=$itemnumber;
my $isbn=$input->param('isbn');
$search{'isbn'}=$isbn;
my $datebefore=$input->param('date-before');
$search{'date-before'};
my $class=$input->param('class');
$search{'class'}=$class;
my @results;
my $offset=$input->param('offset');
if ($offset eq ''){
  $offset=0;
}
my $num=$input->param('num');
if ($num eq ''){
  $num=10;
}
print startpage();
print startmenu($type);
print mkheadr(1,'Catalogue Search Results');
print center();
my $count;
my @results;
if ($itemnumber ne '' || $isbn ne ''){
    ($count,@results)=&CatSearch(\$blah,'precise',\%search,$num,$offset);
} else {
  if ($subject ne ''){
    ($count,@results)=&CatSearch(\$blah,'subject',\%search,$num,$offset);
  } else {
    if ($keyword ne ''){
#      print "hey";
      ($count,@results)=&KeywordSearch(\$blah,'intra',\%search,$num,$offset);
    } else {
      ($count,@results)=&CatSearch(\$blah,'loose',\%search,$num,$offset);
#            print "hey";
    }
  }
}
print "You searched on ";
while ( my ($key, $value) = each %search) {                                 
  if ($value ne ''){
    print bold("$key $value,");
  }                          
}
print " $count results found";
my $offset2=$num+$offset;
print "<br> Results $offset to $offset2 displayed";
print mktablehdr;
if ($type ne 'opac'){
  if ($subject ne ''){
   print mktablerow(1,$main,'<b>SUBJECT</b>','/images/background-mem.gif');
  } else {
   print mktablerow(6,$main,'<b>TITLE</b>','<b>AUTHOR</b>',bold('&copy;'),'<b>COUNT</b>',bold('LOCATION'),'','/images/background-mem.gif');
  }
} else {
  if ($subject ne ''){
   print mktablerow(1,$main,'<b>SUBJECT</b>');
  } else {
   print mktablerow(6,$main,'<b>TITLE</b>','<b>AUTHOR</b>',bold('&copy;'),'<b>COUNT</b>',bold('LOCATION'),'');
  }
}
my $count2=@results;
#print $count2;
my $i=0;
my $colour=1;
while ($i < $count2){
#    print $results[$i]."\n";
    my @stuff=split('\t',$results[$i]);
    my $title2=$stuff[1];
    $title2=~ s/ /%20/g;
    if ($subject eq ''){
#      print $stuff[0];
      $stuff[1]=mklink("/cgi-bin/koha/detail.pl?type=$type&bib=$stuff[2]&title=$title2",$stuff[1]);
      my $word=$stuff[0];
#      print $word;
      $word=~ s/([a-z]) +([a-z])/$1%20$2/ig;
      $word=~ s/ //g;
      $word=~ s/\,/\,%20/g;
      $word=~ s/\n//g;
      my $url="/cgi-bin/koha/search.pl?author=$word&type=$type";
      $stuff[0]=mklink($url,$stuff[0]);
      my ($count,$lcount,$nacount,$fcount,$scount)=itemcount($env,$stuff[2]);
      $stuff[4]=$count;
      if ($nacount > 0){
        $stuff[5]=$stuff[5]."On Loan 1";
      }
      if ($lcount > 0){
        $stuff[5]=$stuff[5]." L$lcount";
      }
      if ($fcount > 0){
        $stuff[5]=$stuff[5]." F$fcount";
      }
      if ($scount > 0){
        $stuff[5]=$stuff[5]." S$scount";
      }
      if ($type ne 'opac'){
        $stuff[6]=mklink("/cgi-bin/koha/request.pl?bib=$stuff[2]","Request");
      }
    } else {
      my $word=$stuff[1];
      $word=~ s/ /%20/g;
      
        $stuff[1]=mklink("/cgi-bin/koha/subjectsearch.pl?subject=$word&type=$type",$stuff[1]);

    }

    if ($colour == 1){
      print mktablerow(6,$secondary,$stuff[1],$stuff[0],$stuff[3],$stuff[4],$stuff[5],$stuff[6]);
      $colour=0;
    } else{
      print mktablerow(6,'white',$stuff[1],$stuff[0],$stuff[3],$stuff[4],$stuff[5],$stuff[6]);
      $colour=1;
    }
    $i++;
}
$offset=$num+$offset;
if ($type ne 'opac'){
 print mktablerow(6,$main,' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp;','','','/images/background-mem.gif');
} else {
 print mktablerow(6,$main,' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp; ','','');
}
print mktableft();
if ($offset < $count){
    my $search="num=$num&offset=$offset&type=$type";
    if ($subject ne ''){
      $subject=~ s/ /%20/g;
      $search=$search."&subject=$subject";
    }
    if ($title ne ''){
      $title=~ s/ /%20/g;
      $search=$search."&title=$title";
    }
    if ($author ne ''){
      $author=~ s/ /%20/g;
      $search=$search."&author=$author";
    }
    if ($keyword ne ''){
      $keyword=~ s/ /%20/g;
      $search=$search."&keyword=$keyword";
    }
    
    my $stuff=mklink("/cgi-bin/koha/search.pl?$search",'Next');
    print $stuff;
}

print endcenter();
print endmenu($type);
print endpage();
