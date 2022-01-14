#!/usr/bin/env zsh

mkdir -p ~/.local/bin

cmds=(
  'npm i -g bash-language-server'
  'npm i -g npm-name-cli'
  'npm i -g chokidar-cli'
  'npm i -g js-yaml'

  'cargo install bingrep'
  'cargo install consoletimer'
  'cargo install ddh'
  'cargo install dtg'
  'cargo install huniq'
  'cargo install hx'
  'cargo install pueue'
  'cargo install runiq'
  'cargo install sd'
  'cargo install sl_cli'
  'cargo install viu'
)

for c in $cmds; do
  if [[ -n "$1" && "${${(@s/ /)c}[1]}" != "$1" ]]; then continue; fi
  echo $c
  eval $c
done
