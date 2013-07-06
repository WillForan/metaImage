#!/usr/bin/env bash 
cd  $(dirname $0)
# start new session, and detatch
tmux new-session -s 'ST' -d -n vi  'vim vone/lib/vone.pm'
#tmux set-option remain-on-exit 'on'
# see respaw-window to kill 
# open 
tmux new-window -t 'ST' -n app 'vone/bin/app.pl'
tmux new-window -t 'ST' -n db  'sleep 10; mongo localhost/stv1'
tmux new-window -t 'ST' -n dbd 'sudo mongod --smallfiles'
# attach with 256 colors, and detatch from elsewhere
tmux -2 attach-session -t 'ST' -d 
