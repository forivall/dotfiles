#!/usr/bin/env zsh

if [[ -d "$1" ]] ; then
  open "$1"
else
  echo "$1|$2|$3|$4|$5" >> ~/itermOpenFile.log
  /usr/local/bin/code -g "$1:$2"
fi
