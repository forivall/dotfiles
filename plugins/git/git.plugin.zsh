#!/usr/bin/env zsh
# This file defines a couple of git aliases and bash completions for a number
# of git scripts
__zsh_forivall_git_plugin_location=$0:A
__zsh_forivall_git_plugin_location=${__zsh_forivall_git_plugin_location%/*}
PATH="$PATH:${__zsh_forivall_git_plugin_location}/bin"

alias gl='git l'
alias gla='git la'
alias gps='git push'
alias gp='git pull'

alias git-blameview="perl /usr/share/doc/git/contrib/blameview/blameview.perl"
# alias git-new-workdir="sh /usr/share/doc/git/contrib/workdir/git-new-workdir"
alias git-new-workdir="/usr/share/git/workdir/git-new-workdir"
# alias gitview="python /usr/share/doc/git/contrib/gitview/gitview"
alias gitview="/usr/share/git/gitview/gitview"

alias g=git
alias gg="git grep"
# alias ge="git each"
ge() {
    local first; first="$1"
    if whence "$first" >/dev/null 2>/dev/null ; then
        shift
    else
        first=git
    fi
    for d in */.git(#q:s/\\/.git//)(/); do echo "$yellow❯ $teal$d$reset" >&2; (cd "$d"; "$first" "$@"); done;
}
alias gr="git r"
alias grg="git r git"
alias gst="git st"
alias gitify=gitify_node_module
alias glg="git l3"
alias glga="git l3 --all"
alias glgs="git l3 --stat"
alias glgas="git l3 --all --stat"
alias gti="git"

# t is in a terrible place in querty, and I often hit space first
# TODO: switch keyboard layouts.
function gi() {
    local firstarg
    firstarg=$1
    if [[ "${firstarg}" == t* ]] ; then
        shift
        git "${firstarg:1}" "$@"
        return $?
    else
        env gi "$@"
        return $?
    fi
}

function ___git_indent_helper() {
    "$@" 2>/dev/null | (whitespace="↳ "; while read l; do echo "$whitespace$l"; whitespace="  "; done)
}

GIT_SSH_AGENT_CHECK=(ssh-add -l)
GIT_SSH_AGENT_ADD=(ssh-add)

# ssh-add works fine if envoy is started in ssh-agent mode
# GIT_SSH_AGENT_CHECK=(envoy -l)
# GIT_SSH_AGENT_ADD=(envoy -a)

___git_ran_once=n
function git() { # also put these in git-aliases for autocomplete
  local a;
  if [[ $___git_ran_once = n && "$1" =~ "clone|fetch|fetch-pack|pull|push|send-pack" ]] ; then
    ___git_ran_once=y
    if ! $GIT_SSH_AGENT_CHECK >/dev/null; then
      $GIT_SSH_AGENT_ADD
    fi
  fi
  case "$1" in
    age) shift; ~/code/git-repos/git-age/git-age $@;;
    diff) shift; if [[ "$1" == '--name-status' || "$1" == '--name-only' ]] ; then /usr/bin/env git --no-pager diff $@ ; else /usr/bin/env git diff $@ ; fi;;
    grep-gedit-open) shift; git-grep-gedit-open $@;;
    blameall) shift; ~/code/git-blameall.py $@;;
    stashed) shift; git stash save && /usr/bin/env git "$@" && git stash pop;;
    checkout|cherry-pick|commit|fetch|merge|pull|push) /usr/bin/env git "$@" && ___git_indent_helper git st --no-files; echo  ;;
    # diffuse) shift; ~/scripts/git-diffuse "$@";;
    *) /usr/bin/env git "$@";;
  esac
}

_git-stashed() {
    _git "$@"
}

## aliases

ggjs() { gg "$@" -- '*.js' ; }
ggcs() { gg "$@" -- '*.coffee' ; }
ggb() {
    if (( $# < 1 )) ; then gg "$@" ; return 255; fi
    local arg1="$1"
    shift
    gg -I '\b'"$arg1"'\b' "$@" ;
}


git-get-logrefs() { git for-each-ref --format='%(refname)' refs/** | grep -E -v '(heads|remotes/[^/]+)/gh-pages|refs/stash' ; }

function git-on-that-day {
    local all; if [[ $1 == '--all' ]] ; then all=$1 ; shift ; fi
    local a; a="$1"; shift;
    local b; b="$1"; shift;
    git-on-this-day $all "$a $b" "$a $(( $b + 1 ))" "$@"
}
function git-on-this-day {
    local author
    author='--author=jordan'
    if [[ $1 == '--all' ]] ; then author= ; shift ; fi
    local a; a="$1"; shift;
    local b; b="$1"; shift;
    local until_; until_="$([[ -n "$b" ]] && echo "$b" || echo "$a")";
    local dirname
    for d in */.git ; do
      dirname="${d%.git}"
      l="$(cd "$dirname"; git --no-pager -c color=always l3 --all --since "$a" --until "$until_" "$author" "$@")"  # "
      (( $? > 0 )) || (( $(echo -n "$l"|wc -l) > 0 )) && (echo; echo "${d%/.git}"; echo "$l")
    done
}

# source "$__zsh_forivall_git_plugin_location/completions.zsh"
source "$__zsh_forivall_git_plugin_location/gitify.zsh"
