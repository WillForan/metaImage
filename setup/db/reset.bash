#!/usr/bin/env bash

#
# reset the database, after making a backup of course
# ...unless given -K  [Kill]
#
# make dir link to restoredb for restore db
# otherwise will use reset.js
# otherwise will just kill the database
#

# do this all fromt the setup directory
#cd $(dirname $0)

## Backup current db, as long as we dont see a -K
if [[ ! "$@"  =~ "-K" ]] ; then
 [ ! -d olddb ] &&  mkdir olddb
 mongodump --db stv1 -o olddb/stv1_$(date +"%F-%H%M")
else
 echo "really kill the database without backing it up?? [ctrl+c]";
 read
fi


if   [ -d restoredb     ]; then  
  mongorestore restoredb;

elif [ -r initial_db.js ]; then  
  mongo localhost/stv1 initial_db.js;

else # just drop the database!!
  echo "DROPPING DB WITHOUT REPLACING? NOPE"
  echo " run on your own: "
  echo "mongo stv1 --eval 'db.dropDatabase()'";
  echo "or link in restoredb or write initial_db.js"
  echo
fi

