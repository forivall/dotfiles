#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

function generate_completions() {
  local compfile="${__dirname}/_$1"
  echo "Generating completion for $1..." >&2
  $@ > $compfile
}
generate_completions gh completion -s zsh
