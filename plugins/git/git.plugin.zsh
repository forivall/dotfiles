#!/usr/bin/env zsh
# This file defines a couple of git aliases and bash completions for a number
# of git scripts
__zsh_forivall_git_plugin_location=$0:A
__zsh_forivall_git_plugin_location=${__zsh_forivall_git_plugin_location%/*}
PATH="$PATH:${__zsh_forivall_git_plugin_location}/bin"
if $IS_OSX ; then
  PATH="$PATH:${__zsh_forivall_git_plugin_location}/bin-osx"
fi

# GIT_CONTRIB_ROOT="/usr/share/doc/git/contrib"
GIT_CONTRIB_ROOT="/usr/share/git"
if $IS_OSX ; then
  GIT_REALPATH="$(readlink -f "$(whence -p git)")"
  GIT_CONTRIB_ROOT="${GIT_REALPATH%/bin/git}/share/git-core/contrib"
fi

# for alias in g ga gap gam gcb gcm gco gcp gcs gcsb gd gds gdd gdds ge gf gfo gitify gg gl gla glf glfg glg glga glgs glgas gp gpr gprs gps gst gti gts gtv gtl gwip gunwip ; do
#   whence $alias && echo "warning: $alias already set"
# done

# alias git-blameview="perl /usr/share/doc/git/contrib/blameview/blameview.perl"
# alias git-new-workdir="sh /usr/share/doc/git/contrib/workdir/git-new-workdir"
#
alias git-new-workdir="$GIT_CONTRIB_ROOT/workdir/git-new-workdir"
# alias gitview="python /usr/share/doc/git/contrib/gitview/gitview"
alias gitview="/usr/share/git/gitview/gitview"

alias g=git

alias ga='git add'
alias gap='git add -p'
alias gam='git amend'

alias gcb='git checkout -b'
alias gcm='git commit'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gcs='git switch'
alias gcsb='git switch -c'

alias gd='git diff'
alias gds='git diff --staged'
alias gdd='git delta diff'
alias gdds='git delta diff --staged'

# alias ge="git each"
ge() {
    local first; first="$1"
    if whence "$first" >/dev/null 2>/dev/null ; then
        shift
    else
        first=git
    fi
    for d in */.git; do e="${d%/.git}"; echo "$yellow❯ $teal$d$reset" >&2; (cd "$d"; "$first" "$@"); done;
}

alias gf='git fetch'
alias gfo='git fetch origin'

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

alias gitify=gitify_node_module

alias gg="git grep-pretty"

alias gl='git l'
alias gla='git la'
alias glf='git ls-files'
alias glfg='git ls-files | grep'
alias glg="git l3"
alias glga="git l3 --all"
alias glgs="git l3 --stat"
alias glgas="git l3 --all --stat"
alias gll='ogl'
alias glla='ogl --all'

alias gp='git pull'
alias gpr='git pull --rebase'
alias gprs='git pull --rebase --autostash'
alias gps='git push'

alias gst="git st"

alias gti="git"
alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gtl='gtl(){ git tag --sort=-v:refname -n -l "${1}*" }; noglob gtl'

# TODO: modify and put this in my gitignore
# alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
# alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'

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

    if ! $IS_OSX && ! $GIT_SSH_AGENT_CHECK >/dev/null; then
      $GIT_SSH_AGENT_ADD
    fi
  fi

  local cont=true
  local gitcommand gitcommandopts
  local opts
  opts=()
  while $cont && (( $# > 0 )); do
  cont=false
  case "$1" in
    -*) opts+=($1 $2); shift; (( $# > 0 )) && shift; cont=true;;
    fancy) shift;
      local pager=($(git "${opts[@]}" config core.pager || echo -n "less"))
      git -c color.diff=always "${opts[@]}" "$@" | diff-so-fancy | $pager
      ;;
    delta) shift;
      local pager=($(git "${opts[@]}" config core.pager || echo -n "less"))
      if (( $# == 0 )); then 
        git -c color.diff=always diff "${opts[@]}" "$@" | delta | $pager
      else
        git -c color.diff=always "${opts[@]}" "$@" | delta | $pager
      fi
      ;;
    diff) shift;
      if [[ "$1" == '--name-status' || "$1" == '--name-only' ]] ; then
        command git --no-pager "${opts[@]}" diff $@
      else
        command git "${opts[@]}" diff $@
      fi
      ;;
    stashed) shift; git stash save && command git "$@" && git stash pop;;
    wt) gitcommand=worktree; gitcommandopts=${#opts}; shift; cont=true;;
    sm) gitcommand=submodule; gitcommandopts=${#opts}; shift; cont=true;;
    sbt) gitcommand=subtree; gitcommandopts=${#opts}; shift; cont=true;;
    worktree|submodule|subtree) gitcommand=$1; gitcommandopts=${#opts}; shift; cont=true;;
  esac
  done

  if [[ -n $gitcommand ]]; then
    if (( $# == 0 )) ; then
      command git "${opts[@]:0:$gitcommandopts}" $gitcommand "${opts[@]:$gitcommandopts}"
      if (( $opts[(Ie)-h] )); then
        command git --no-pager config --get-regex "alias.$gitcommand-.*" | sd "^alias\.$gitcommand-(\S+)" "   or: git $gitcommand \$1  = "
      fi
    else
      local alias="$gitcommand-$1"
      if git config --get alias.$alias > /dev/null; then
        shift
        command git "${opts[@]}" $alias "$@"
      else
        command git "${opts[@]:0:$gitcommandopts}" $gitcommand "${opts[@]:$gitcommandopts}" "$@"
      fi
    fi
  else
    command git "${opts[@]}" "$@"
  fi
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
    author='--author=emily'
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

autoload ogl
