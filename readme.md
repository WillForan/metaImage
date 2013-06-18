### WEB
created with
 dancer -a vone

run with
 bin/app.pl

edit routes
 lib/v1.pm 

edit templates (template toolkit <% %>)
 views/*tt

### images
ln -s $(pwd)/../setup/images/ public/images/testpics

### DB: mongo
setup/db/reset.bash

### UI/UX
# css for images
http://davidwalsh.name/demo/photo-stack.php
## js 
# face detection
http://facedetection.jaysalvat.com/#
https://github.com/jaysalvat/jquery.facedetection
# tag suggestions
https://github.com/tactivos/jquery-sew

# photo tag
http://karlmendes.com/2010/07/jquery-photo-tag-plugin/




### Hints
# mongo
show collections
db.Peps.insert( {Name: 'Will', Byear: 1986}, {Name: 'Emily', Byear: 1988} )
db.Peps.find()
db.Peps.update({Name: 'Will'},{ $push: {Tags: 'code-monkey'} })

##template toolkit (tt)
# <% %>
 set to mantain default config

# debugging
 USE Dumper
 Dumper.dump_html(var)


### Similiar services/software
http://www.phtagr.org/
