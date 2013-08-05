#!/usr/bin/env perl

package exifParse;

use strict;
use warnings;
use Data::Dumper;
#use v5.14;
use File::Copy;
use File::Path qw(make_path);
use Image::ExifTool qw(:Public);
use Graphics::Magick;
use Time::Piece;
use DateTime;


use vars qw($VERSION @ISA @EXPORT_OK );

$VERSION=0.1;
@ISA = qw(Exporter);
@EXPORT_OK = qw(getPicInfo addPic getMoment);


######
# 
# get meta info from pictures
# setup events
# add picture and thumbnail to server directory
#
#####

# give array of input and outputs
# resize
# thumbs dir is hardcoded!!
sub addFiles {
     my $filename = shift;
     my $uri      = shift;   
     my $origdir  = shift;

     my $thumbdir = "$origdir/../thumbs";
     make_path($origdir) if(! -d $origdir);
     make_path($thumbdir) if(! -d $thumbdir);

    
     copy($uri,"$origdir/$filename") or return 0;

     # gm params?
     ## see http://even.li/imagemagick-sharp-web-sized-photographs/
     ##     for sharpening
     # http://www.graphicsmagick.org/perl.html
     #      for perl 
     ### want to do
     # gm convert -resize '300x' -auto-orient -normalize -unsharp 2x0.5+0.7+0 -quality 98 stotians.jpg stotians_small_sharp.jpg

     # image is ugly, someting in command line is better?
     #fork("gm convert -resize '300x' -auto-orient -normalize -unsharp 2x0.5+0.7+0 -quality 98 stotians.jpg stotians_small_sharp.jpg")
     my $image = Graphics::Magick->new();
     $image->set('quality',98);
     warn "cannot read $origdir/$filename" unless $image->Read("$origdir/$filename"); 


     # resize to a width of 300, scale hieght
     my ($origw, $origh) = $image->Get('width','height');
     $image->Resize(width=>300,height=>$origh*300/$origw);

     # sharpen the blur of resize
     $image->UnsharpMask(radius=> 2,sigma=> .5 ,amount=> .7 ,threshold=> 1);

     # bring out the colors
     $image->Normalize();

     #write it out
     warn "cannot write $thumbdir/$filename" unless $image->Write("$thumbdir/$filename");

     return 1;

}


### %info 
###   Date, Time,Epoch=Unix seconds, DateTime=ISODate Lat, Long, loc=[long,lat], md5sum, Height, Width
sub getPicInfo{
   my $file=shift;
   my %info;
  
   # skip if DNE
   warn("bad file $file!") && return %info unless ( -r $file);
  
   #TODO: do in pure perl
   #get md5sum
   $info{'md5sum'}=(split(/\ /,qx(md5sum "$file")))[0];
  
   # load exif info
   my $exifTool= new Image::ExifTool;
   $exifTool->ExtractInfo($file);
  
   # get the tags
   my @tagList = $exifTool->GetFoundTags('File');
  
   # build hash using only the tags we want (Date/Time and GPS Pos)
   for my $tagref (grep {m/Date|Time|Lat|Long|Pos|Image/i && ! m/File|Ref/i} @tagList) {
     my $tag   = $exifTool->GetDescription($tagref);
     my $value = $exifTool->GetValue($tagref) ;
     
     #### Size, height and width
     for (qw/Height Width/) {
       $info{$_}=int($value) if $tag =~ /Image $_/i;
     }
  
     ### Time
     # if we already have a date, and this isn't the GPS time, skip
     next if (exists($info{Time}) && $tag =~ /Time/ && $tag !~ /GPS/  );
     $info{Time}=$& if $tag=~m/Time/i && $value=~m/\d{2}:\d{2}:\d{2}/i;
     #TODO: check format, is there an AM PM?
  
  
     ### Date (2013:03:31)
     # if we already have a date, and this isn't the GPS time, skip
     next if (exists($info{Date}) && $tag =~ /Date/ && $tag !~ /GPS/  );
     $info{Date}=$& if $tag=~m/Date|Time/i && $value=~m/\d{4}:\d{2}:\d{2}/i;
  
  
     ### GPS
     # Ideal GPS format 
     while( $value =~ m/(\d+) deg (\d+). ([0-9.]+)" (N|W|S|E)/ig ){ 
         my $decCord= $1+$2/60+$3/3600;
         my $dir = $4;
	 #print "$decCord -> ";
         $decCord*=-1 if $dir =~ /S|W/; 
         $decCord=sprintf("%.6f",$decCord);
	 #print "$decCord\n";
  
	 # set as long or lat, make sure its not stringified
         $info{Latitude}  = 0+$decCord if $dir =~ /N|S/;
         $info{Longitude} = 0+$decCord if $dir =~ /E|W/;
     }
    
    # THIS SHOULD BE IMPLEMENTED? TODO
    #if we have a lat/long but it's not ideal, use that instead
    #for(qw/Latitude Longitude/){
    #$info{$_} = $value if(!exists($info{$_} && $tag =~ /$_/i )
    #}
  
   }
  
   

   #  mongodb manual says use array like longitude, latitude (pdf page 375)
   $info{loc} = [ $info{Longitude}, $info{Latitude} ];
  
   ### add year. (dayofyear + (hour + minute/60 +second/3600)/24  )/(daysinyear) -- leap year hours count less
   #$info{Date}=~m/(?<year>\d{4}):(?<month>\d{2}):(?<day>\d{2})/;
   #$info{Time}=~m/(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})/;
   ### ... or just use unix seconds since epoc
   $info{EpocTime}=Time::Piece->
                      strptime("$info{Date}:$info{Time}", '%Y:%m:%d:%T')->
                      strftime('%s');;

   # field for mongodb ISODate
   #my $datetime=$info{Date};
   #$datetime=~s/:/-/g; $datetime.="T$info{Time}Z"; 
   #$info{DateTime}="ISODate('$datetime')"; # doesn't work!
   $info{DateTime}=DateTime->from_epoch(epoch=>$info{EpocTime},time_zone => 'floating' ); #TODO: add real timezone?


   return %info;
}

###
# assign picture to a moment
##
sub getMoment{
    my %info       = %{ shift() };
    my $collection = shift;
    #print Dumper(%info);

    # check nearby place and times
    #   add events of all matching to even
    #   - 3 hours and 
    #   - ~ 1/4 mi
    #     
    #   - moment not in the excluded Moments
    #   -- if same person, disance should be greater
    # else set moment to unique value currenttime+position
    
    
    # GPS UTM: 1 mile
    # 43.664659,-97.53793
    # 43.647007,-97.638245

    # better logic to catch midnight to 1am
   ## TODO FINISH
   
   #$collection->find({EpocTime => {'$ge' => $info{EpocTime}+2*60*60, '$le'=>$info{EpocTime}-2*60*60 },
   # sqrt($info{Longitude} - search)^2  + $info{Longitude} - search)^2 ) };
   ## mongodb manual pdf page 377
   #The following example query returns all documents within a 10-mile radius of longitude 88 W and latitude 30 N.
   #The example converts distance to radians by dividing distance by the approximate radius of the earth, 3959 miles:
   #db.<collection>.find( { loc : { $geoWithin :
   #    { $centerSphere :
   #      [ [ 88 , 30 ] , 10 / 3959 ]
   #    } } } )
   my $moment=$info{md5sum};
   if(exists($info{loc}) and $info{loc}->[1] ne undef) {
    my $closeby = $collection->count({loc => {'$geoWithin' => { '$centerSphere' => [ [ $info{loc}->[0], $info{loc}->[1] ], .25 ] } },
    	                             DateTime => {'$le' => $info{DateTime}->add(hours=>3) },
    	                             DateTime => {'$gt' => $info{DateTime}->add(hours=>-3) },
				 } );
    print "\n\nNEARBY:\n@{$info{loc}} @".$info{DateTime}->hour." hour: ",Dumper($closeby),"\n";
   }
   #my $success = $picCol->find_and_modify({query=>{ md5sum => $hash}, update=>{'$set'=>{Peps => $peps  }} });

}

## add pic to file system and db
# return 0 or md5sum
# take 3 args: 
#        where the picture is,
#        where it should be saved,
#        the colletion to add it to
sub addPic{
    my $uri        = shift;
    my $savedir    = shift; 
    my $collection = shift;

    my %info=getPicInfo($uri);

    #check hash before copy


    return 0 if( $collection->count({ md5sum=>$info{md5sum} }) > 0);
    return 0 unless addFiles("$info{md5sum}.jpg",$uri,$savedir );
    return 0 unless $collection->insert({%info});

    return $info{md5sum};
}

1;
