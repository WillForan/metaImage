#!/bin/sh

#
# use images put in "event" folders and exiftool
# to create an initial collection for Pics and Events
# most pics will only have File and Event fields
# those with GPS data will have time, lat, and long
# TODO: make lat and long decimal numbers
#

#set -xe
jsonout=pics_$(date +%F).json
(
 echo "db.Pics.insert([ "
 for pic in */*jp*; do
   #echo $pic
   #echo
   export p=$(dirname $pic)
   export md5=$(md5sum $pic|cut -f1 -d' ')
   # parse the file into a few good fields
   exiftool $pic | perl -lne '
 s/=//g; s/ +/ /g;
 m/^(.*) +: +(.*)$/;
 $key=$1;$value=$2;

 if( $value =~ m/(\d+) deg (\d+). ([0-9.]+)" (N|W|S|E)/i ){ 
     $value= $1+$2/60+$3/3600;
     $value*=-1 if $4 =~ /S|E/;
     $value=sprintf("%.6f",$value);
 }
 $a{Latitude}=$value if $key =~ /GPS Latitude$/i; 
 $a{Longitude}=$value if $key =~ /GPS Longitude$/i; 

 $a{Height}=$value if $key =~ /Height/i; 
 $a{Width}=$value if $key =~ /Width/i; 
 if($key =~ m:Date/Time Original:){
     @F=split(/ /,$value);
     $F[0] =~ s/:/-/g;
     $a{Date}="$F[0]T$F[1]";
     $F[1] =~ s/://g;
     $a{Time}="$F[1]";
 }
 $a{File}="$value/$a{File}" if $key =~ /directory/i; 
 $a{File}.=$value if $key =~ /file name/i; 
 END{
  $a{Event}=$ENV{p};
  $a{Owner}="Will";
  $a{Hash}=$ENV{md5};
  print " { ";
  print "\t", join(",\n\t", map {$q=(/Lat|Long|Height|Width|Time/g)?"":"\""; "$_: $q$a{$_}$q"} (keys %a) ) ;
  print " },";
 }
   '
 done | sed '$s/},/}/'
 echo ' ] )'
) | tee $jsonout

# write out events based on pictures
perl -lne '$a{$1}++ if m/Event: "(.*)"/;END{$,="\n";print "db.Events.insert({Name: \"$_\"})" for keys(%a)}' < $jsonout >> $jsonout
