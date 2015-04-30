#!/usr/bin/env bash
# usage: cd node_modules; gitify_node_module ../../vidi-server ../../vidi-shop-server ...
# or, even quicker: gitify_node_module ../../*
gitify_node_module() {
  local d; local m; local ad; #local others;
  # others=()
  rmdir _tmp
  for d in "$@" ; do       # for d in process.argv
    ad="$(realpath "$d")"
    m="${d##*/}";          #   m = _.last(d.split('/'))
    if [[ -d $m ]]; then
      if [[ ! -e $m/.git ]]; then  #   if fs.statSync(m).isDirectory() and not
        (git-new-workdir "$d" _tmp "$(cd "$m"; _gitify_node_module_get_rev "$ad")" && mv _tmp/.git "$m" && rm -r _tmp) ||
        ([[ -d _tmp ]] && mv _tmp/.git "$d.git")
      else
        echo "Skipping $m: already gitified"
      fi
    fi
  done
}

# gitify_all() {
#   [[ -d 'node_modules' ]] && (cd node_modules && gitify_node_module "$HOME/Dev/vidigami/"*)
#   [[ -d 'bower_components' ]] && (cd bower_components && gitify_node_module "$HOME/Dev/vidigami/"*)
# }

_gitify_node_module_get_rev() {
  local repo="$1"
  # package = require('./package.json'); rev = package.gitHead or _.last(package._resolved?.split('#'))
  local rev;
  if [[ -f 'package.json' ]] ; then
    rev="$(< package.json jq -r '.gitHead // (""+._resolved) | split("#") | .[length - 1]')" || return 1
    if rev=$(cd "$repo"; git rev-list -n1 "$rev" 2> /dev/null) ; then : ; else
      rev="$(< package.json jq -r '(""+._id) | split("@") | .[length - 1]')" || return 1
      rev=$(cd "$repo"; git rev-list -n1 "$rev" 2> /dev/null) || return 1
    fi
  fi
  [[ -z "$rev" || "$rev" == "null" ]] && [[ -f '.bower.json' ]] && rev="$(< .bower.json jq -r '._resolution.commit // ._release')"
  [[ "$rev" == "null" ]] && return 1
  echo "$rev"
}
