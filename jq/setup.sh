#!/usr/bin/env zsh

HEADER="# GENERATED. DONT EDIT"
if [[ -f ~/.jq ]]; then
  if [[ "$HEADER" != "$(head -1 ~/.jq)" ]]; then
    echo '~/.jq edited. ignoring'
    exit 1
  fi
  rm ~/.jq
elif [[ -e ~/.jq ]]; then
  echo '~/.jq is not a regular file. ignoring'
  exit 1
fi

__dirname="${0:A:h}"
echo "$HEADER" >> ~/.jq

if [[ $1 == 'include' ]]; then
  # this only works with gojq, broken in jq.
  for m in $__dirname/*.jq; do
    NAME="${${m:t}%.jq}"
    echo "include \"$NAME\" {\"search\": \"$__dirname\"};" >> ~/.jq
  done
  # # workaround for standard jq
  # for m in $__dirname/*.jq; do
  #   NAME="${${m:t}%.jq}"
  #   echo "import \"$NAME\" as I {\"search\": \"$__dirname\"};" >> ~/.jq
  # done
  # for m in $__dirname/*.jq; do
  #   NAME="${${m:t}%.jq}"
  #   echo "def $NAME: I::$NAME;" >> ~/.jq
  # done
else
  for m in $__dirname/*.jq; do
    < $m >> ~/.jq
  done
fi
