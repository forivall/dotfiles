#!/usr/bin/env zsh
whence nvm > /dev/null && nvm current || . "$NVM_DIR/nvm.sh"

list-packages () {
  (
  if [[ -n "$1" ]] ; then
    nvm use --silent "$1"
  fi
  local prefix="$(npm -g prefix)"
  # npm ls -g --parseable --depth=0 | sed -E "s|$prefix/lib(/node_modules/)?||g" | sort
  cd "$prefix/lib/node_modules"
  echo ${(@F)$(echo *(/))}
  )
}

set -e
nvm use $1
packages=($(comm -13 <(list-packages) <(list-packages $2)))
echo npm i -g $packages
npm i -g $packages
