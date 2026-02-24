#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

function generate_completions() {
  if (( ${+commands[$1]} )); then
    local compfile="${__dirname}/_$1"
    echo "Generating completion for $1..." >&2
    $@ > $compfile
  else
    echo "Command $1 not found. Completions not generated" >&2
  fi
}
generate_completions gh completion -s zsh
