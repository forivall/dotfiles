#!/usr/bin/env zsh

__dirname=${0:A:h}

if $IS_OSX; then
  path+=(~/Library/Python/3.10/bin)
fi

poetry completions zsh > $__dirname/_poetry
