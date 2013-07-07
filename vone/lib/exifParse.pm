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

use vars qw($VERSION @ISA @EXPORT_OK );

$VERSION=0.1;
@ISA = qw(Exporter);
@EXPORT_OK = qw(getPicInfo addPic);


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

# setup the perl library

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
       $info{$_}=$value if $tag =~ /Image $_/i;
     }
  
     ### Time
     # if we already have a date, and this isn't the GPS time, skip
     next if (exists($info{Time}) && $tag =~ /Time/ && $tag !~ /GPS/  );
     $info{Time}=$& if $tag=~m/Time/i && $value=~m/\d{2}:\d{2}(:\d{2})/i;
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
  
         $info{Latitude}  = $decCord if $dir =~ /N|S/;
         $info{Longitude} = $decCord if $dir =~ /E|W/;
     }
    
    # THIS SHOULD BE IMPLEMENTED? TODO
    #if we have a lat/long but it's not ideal, use that instead
    #for(qw/Latitude Longitude/){
    #$info{$_} = $value if(!exists($info{$_} && $tag =~ /$_/i )
    #}
  
   }
  
   ### %info 
   ###   Date, Time, Lat, Long, md5sum, Height, Width
  
   return %info;

}

###
#
##
sub getMoment{
    my %info       = %{ shift() };
    my $collection = shift;
    print Dumper(%info);
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
