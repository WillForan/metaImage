#!/usr/bin/env bash
dbname=moment
temp=$(mktemp XXXX.js)
cat >$temp <<HEREDOC
db.Pics.remove({})

HEREDOC

mongo localhost/moment $temp
rm $temp
rm -r images/byhash/*

# http://ask.metafilter.com/18923/How-do-you-handle-authentication-via-cookie-with-CURL

# upload image
curl -F "files=@images/wedding/stotians.jpg" http://localhost:3000/upload > /dev/null

# add person via image tagging
curl -d 'Name=Steve+Fie&Email=steveefie%40gmail.com' http://localhost:3000/add/person

# tag person
curl -d '[{"Name":"Steve Fie","Email":"steveefie%40gmail.com","x":"50","y":"41"}]'  http://localhost:3000/image/a2361ada320eaa70d16510f24e44f396

