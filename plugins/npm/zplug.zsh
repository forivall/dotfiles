#!/usr/bin/env zsh

cp ~/.bun/_bun .
echo _bun >> _bun

if (( ${+commands[appservices]} )); then
  appservices completion zsh > _appservices
fi

node ./tsc-completion.js >> _tsc
