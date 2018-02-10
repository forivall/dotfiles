#!/usr/bin/env zsh
whence nvm > /dev/null && nvm current || . "$NVM_DIR/nvm.sh"

list-packages () {
  echo "list packages $1"
  local pkgs="$(
    if [[ -n "$1" ]] ; then
      nvm use --silent "$1"
    fi
    npm ls -g --parseable --depth=0 | grep node_modules
  )"
  local pkgl=(${(f)pkgs})
  pkgln=()
  pkgi=()
  for pkg in $pkgl ; do
    if [[ -n "$pkg" && -d "$pkg" ]] ; then
      if [[ -h "$pkg" ]] ; then
        pkgln+=("$pkg")
      else
        pkgi+=("${pkg##*/node_modules/}")
      fi
    fi
  done

    # ; done ; | sed -E "s|$prefix/lib(/node_modules/)?||g" | sort
  # cd "$prefix/lib/node_modules"
  echo ${(@F)pkgi}
}

() {
  if (( $# > 1 )); then nvm use $2 || return ; fi
  local pkgi
  local pkgln
  list-packages
  local new=($pkgi)
  list-packages "$1"
  local old=($pkgi)
  # echo "$curr"; echo ===; echo "$old"
  packages=($(comm -13 <(echo "${(F)new}") <(echo "${(F)old}"))) || return
  echo npm i -g $packages

  echo -n 'Continue? (y/n) '
  read yn
  [[ "$yn" == 'y' ]] && npm i -g $packages

  echo "you should also link $pkgln"

  unfunction list-packages
} "$@"
