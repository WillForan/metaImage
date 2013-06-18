# OVERVIEW
## Purpose
Bring life to image metadata

## On hacking
* perl dancer: localhost:3000 
* mongodb: localhost/stv1 (setup/db/reset.bash)

1. tmux.bash: launch project development 
2. setup/db/reset.bash to start new database
  - setup/images/imagesToJson.bash  generates part of this (setup/db/readme)


##  Notes
### Editing
run with
  bin/app.pl

edit routes
  lib/v1.pm 

edit templates (template toolkit <% %>)
  views/*tt

created with
  dancer -a vone
### images
  ln -s $(pwd)/../setup/images/ public/images/testpics

### DB: mongo
  setup/db/reset.bash

# UI/UX Notes
## css for images
http://davidwalsh.name/demo/photo-stack.php

## js 
### face detection
http://facedetection.jaysalvat.com/#
https://github.com/jaysalvat/jquery.facedetection
### tag suggestions

https://github.com/tactivos/jquery-sew
### photo tag

http://karlmendes.com/2010/07/jquery-photo-tag-plugin/



# Hints
## mongo
show collections
db.Peps.insert( {Name: 'Will', Byear: 1986}, {Name: 'Emily', Byear: 1988} )
db.Peps.find()
db.Peps.update({Name: 'Will'},{ $push: {Tags: 'code-monkey'} })

##template toolkit (tt)
# <% %>
 set to mantain default config

### debugging
 USE Dumper
 Dumper.dump_html(var)


# Similiar services/software
http://www.phtagr.org/
