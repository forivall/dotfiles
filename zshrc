#!/usr/bin/env zsh

SH_ROOT="$(dirname "$(realpath ~/.zshrc)")"

setbool() { local code=$?; local arg="$1"; shift; if [[ -z "$@" ]]; then 1=return; 2=$code; fi; if ("$@") 2>&1 >/dev/null ; then eval "$arg=true"; else eval "$arg=false"; fi; }

setbool IS_INTERACTIVE  tty -s
setbool IS_WINDOWS  $([[ "$OS" == "Windows_NT" || -n "$CYGWIN_VERSION" ]])
setbool HAS_ENVOY  whence envoy

# core shell settings
export EDITOR=vim
export VISUAL=vim
HISTSIZE=50000; SAVEHIST=10000
HISTFILE=~/.zsh_history

$IS_INTERACTIVE && export HISTFILE=$HOME/.zsh_history_interactive
APPEND_HISTORY=true; setopt appendhistory; setopt histfcntllock; setopt nohistsavebycopy

$IS_WINDOWS && [[ -n "$VBOX_INSTALL_PATH" ]] && PATH="$PATH:$(cygpath $VBOX_INSTALL_PATH)"
$IS_WINDOWS && CYGWIN="$CYGWIN codepage:oem"

if $IS_WINDOWS; then
  if [[ -e "/c/Qt/Tools/QtCreator" ]]; then PATH="$PATH:/c/Qt/Tools/QtCreator/bin"; fi
  if [[ -e "/c/Qt/5.4/msvc2013_64" ]]; then PATH="$PATH:/c/Qt/5.4/msvc2013_64/bin"; fi
fi

# omz settings
HYPHEN_INSENSITIVE=true
setopt extended_glob
EXTENDED_GLOB=true
setopt bareglobqual
BARE_GLOB_QUAL=true
COMPLETION_WAITING_DOTS=true
DISABLE_AUTO_TITLE=false

ZGEN_OH_MY_ZSH_REPO=forivall
PURE_HIGHLIGHT_REPO=1

source "$SH_ROOT/zgen/zgen.zsh"

if ! zgen saved; then
  zgen oh-my-zsh
  # zgen oh-my-zsh plugins/git
  # zgen oh-my-zsh plugins/git-extras
  # zgen oh-my-zsh plugins/node
  # zgen oh-my-zsh plugins/pip
  # zgen oh-my-zsh plugins/python
  # zgen oh-my-zsh plugins/web-search
  zgen oh-my-zsh plugins/command-not-found
  # zgen oh-my-zsh plugins/virtualenv
  zgen oh-my-zsh plugins/npm
  zgen oh-my-zsh plugins/nvm
  zgen oh-my-zsh plugins/colorize
  zgen oh-my-zsh plugins/cp
  zgen oh-my-zsh plugins/meteor
  zgen oh-my-zsh plugins/git-extras
  # zgen oh-my-zsh encode64
  ! $IS_WINDOWS && zgen load mafredri/zsh-async
  ! $IS_WINDOWS && zgen load sindresorhus/pure
  $IS_WINDOWS && zgen load forivall/pure '' underline-repo-name-no-async
  zgen load zsh-users/zsh-completions src
  zgen load jocelynmallon/zshmarks
  $IS_WINDOWS && zgen load "$SH_ROOT" plugins/cygwin-functions
  zgen load "$SH_ROOT" plugins/simple-history-search
  zgen load "$SH_ROOT" plugins/colors
  zgen load "$SH_ROOT" plugins/coreutils
  zgen load "$SH_ROOT" plugins/git
  zgen load "$SH_ROOT" plugins/github
  zgen load "$SH_ROOT" plugins/magic-cd
  zgen load "$SH_ROOT" plugins/npm
  zgen load "$SH_ROOT" plugins/subl
  zgen load "$SH_ROOT" plugins/trash
  zgen load "$SH_ROOT" plugins/unsorted
  $IS_WINDOWS && zgen load "$SH_ROOT" plugins/cygwin-sudo

  zgen load "$SH_ROOT" plugins/simple-history-search

  [[ -d "$HOME/.opam" ]] && zgen load "$HOME/.opam/opam-init"

  zgen save
fi

autoload -U cygcd

# todo: create a plugin for envoy
$HAS_ENVOY && eval $(envoy -ps)

if [[ "$PERF_TEST" == y ]] ; then exit; else true; fi
