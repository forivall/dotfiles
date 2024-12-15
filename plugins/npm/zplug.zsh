#!/usr/bin/env zsh

cp ~/.bun/_bun .
echo _bun >> _bun

if (( ${+commands[appservices]} )); then
  appservices completion zsh > _appservices
fi

node ./tsc-completion.js > _tsc
node ./eslint-completion.js > _eslint
node ./prettier-completion.mjs > _prettier
node ./hereby-completion.mjs > _hereby
