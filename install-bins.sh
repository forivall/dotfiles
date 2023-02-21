#!/usr/bin/env zsh

mkdir -p ~/.local/bin

installer="$1"

cmds=(
  'corepack enable'
  'npm i -g bash-language-server'
  'npm i -g npm-name-cli'
  'npm i -g chokidar-cli'
  'npm i -g js-yaml'
  'npm i -g nx'

  'cargo install bingrep'
  'cargo install consoletimer'
  'cargo install ddh'
  'cargo install dtg'
  'cargo install huniq'
  'cargo install hx'
  'cargo install pueue'
  'cargo install runiq'
  'cargo install sd'
  # 'cargo install sl_cli'
  'cargo install toml-cli'
  'cargo install viu'

  'pip install simple-term-menu'
  'pip install termdown'
)

alias pip='python3 -m pip'

for c in $cmds; do
  cmd_installer="${${(@s/ /)c}[1]}"
  if [[ -n "$installer" && "$cmd_installer" != "$installer" ]]; then continue; fi
  echo $c
  eval $c
done
