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

() {
  if (( $# > 1 )); then nvm use $2 || return ; fi
  local new="$(list-packages)"
  local old="$(list-packages $1)"
  # echo "$curr"; echo ===; echo "$old"
  packages=($(comm -13 <(echo "$curr") <(echo "$old"))) || return
  echo npm i -g $packages

  echo -n 'Continue? (y/n) '
  read yn
  [[ "$yn" == 'y' ]] && npm i -g $packages

  unfunction list-packages
} "$@"
