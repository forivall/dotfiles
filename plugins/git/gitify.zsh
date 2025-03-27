#!/usr/bin/env zsh
# shellcheck disable=SC2299

alias gitify_vscode_plugin=gitify_node_module

gitify_node_module() {
  if [[ $1 != --force ]] && git rev-parse --show-toplevel 2> /dev/null; then
    local ecode=$?
    echo already a git repo!
    return $ecode
  fi
  local remote repo owd
  remote="$(jq -r '(.repository.url? // .repository)' package.json | sd '^(remote-)?git\+http' http)"
  echo "$remote"
  repo=${${remote:t}%.git}
  rev=$(_gitify_node_module_get_rev)
  echo $rev
  if [[ -d ~pubrepos/$repo ]]; then
    echo "~pubrepos/$repo" exists, using it... "(todo: check if it's the correct repo)"
  else
    git clone "$remote" ~pubrepos/$repo
  fi
  owd=$PWD
  cd ~pubrepos/$repo
  mv $owd $owd.tmp
  git worktree add --no-checkout $owd -b ${owd:t} $rev
  mv $owd/.git $owd.tmp
  command rmdir $owd
  mv $owd.tmp $owd
  cd -
  echo git checkout -- "${(@f)$(git diff --name-only --diff-filter=D)}"
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

  if [[ "$rev" == "null" ]]; then
    git tag -l $(jq -r .version package.json) | head -n1
  else
    echo "$rev"
  fi
}
