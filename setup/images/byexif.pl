#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
#use v5.14;
use File::Copy;


#use 'vone/lib/exifParse.pm'
use lib '../../vone/lib/';
use exifParse qw(addPic getPicInfo);

######
# 
# get meta info from pictures
# setup events
#
#####


#TODO: setup db
use MongoDB;
my $db = MongoDB::MongoClient->new(host => 'localhost', port => 27017)->get_database( 'stv1' );
my $eventCollection = $db->get_collection( 'Events' ) or die 'cannot open db Events collection in stv1';
my $picCollection = $db->get_collection( 'Pics' ) or die 'cannot open db Pics collection in stv1';

# get all the jpgs and there info
for my $f (glob('wedding/*jpg')) {

   print "\n\n$f\n";
   
   print(Dumper(getPicInfo($f)));
   #my $moment = getMoment(\%picInfo,$eventCollection );
   print addPic($f,'byhash/', $picCollection ),"\n";
 
}
