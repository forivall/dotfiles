#!/usr/bin/env zsh
___progress_symbols='|/-\'
___progress_i=0
___progress() { echo -en '\r'; echo -n "${___progress_symbols[(( (__progress_i = ((__progress_i + 1) % 4)) + 1))]} "}
___progress


___print_time_diff () { local start_time="$1"; shift; local end_time="$(date +%s%N)"; echo $(( (end_time - start_time) / 1000000))ms; }

# SH_ROOT="$XDG_CONFIG/ermahger-sh"
SH_ROOT="$(dirname "$(realpath ~/.zshrc)")"

# core shell settings
export EDITOR=vim
export VISUAL=vim

# Keep 10000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=50000
SAVEHIST=10000
HISTFILE=~/.zsh_history
if tty -s >/dev/null 2>&1; then export HISTFILE=$HOME/.zsh_history_interactive; fi
APPEND_HISTORY=true
setopt appendhistory
setopt histfcntllock
setopt nohistsavebycopy

source "$SH_ROOT/antigen/antigen.zsh"
antigenp() { antigen "$@"; ___progress ; }

# omz settings
HYPHEN_INSENSITIVE=true
setopt extended_glob
EXTENDED_GLOB=true
setopt bareglobqual
BARE_GLOB_QUAL=true
COMPLETION_WAITING_DOTS=true
DISABLE_AUTO_TITLE=false

IS_WINDOWS=false
if [[ "$OS" == "Windows_NT" || -n "$CYGWIN_VERSION" ]]; then
  IS_WINDOWS=true
  PATH="$PATH:$(cygpath $VBOX_INSTALL_PATH)"
  CYGWIN="$CYGWIN codepage:oem"
fi

export _ANTIGEN_CACHE_ENABLED=true
if whence -- -zcache-start >/dev/null; then HAS_CACHE=true; else HAS_CACHE=false fi
# HAS_CACHE=false
___progress

export ZSH="$(-antigen-get-clone-dir https://github.com/forivall/oh-my-zsh.git)"

# $HAS_CACHE && -zcache-start bundles
#
#
# # slow
# antigenp bundle forivall/oh-my-zsh
# # antigenp bundle git
# # antigenp bundle git-extras
# # antigenp bundle node
# # antigenp bundle pip
# # antigenp bundle python
# # antigenp bundle web-search
# antigenp bundle command-not-found
# # antigenp bundle virtualenv
#
# # slow
# antigenp bundle npm
# # slow
# antigenp bundle nvm
# antigenp bundle colorize
# antigenp bundle cp
# antigenp bundle meteor
# antigenp bundle git-extras
# # antigenp bundle encode64
# antigenp bundle mafredri/zsh-async
# antigenp bundle sindresorhus/pure
# antigenp bundle zsh-users/zsh-completions src
# # antigenp bundle "$SH_ROOT/plugins/"
# $IS_WINDOWS && antigenp bundle "$SH_ROOT/plugins" cygwin-functions
# antigenp bundle "$SH_ROOT/plugins" simple-history-search
# antigenp bundle "$SH_ROOT/plugins" colors
# antigenp bundle "$SH_ROOT/plugins" coreutils
# antigenp bundle "$SH_ROOT/plugins" git
# antigenp bundle "$SH_ROOT/plugins" github
# antigenp bundle "$SH_ROOT/plugins" magic-cd
# antigenp bundle "$SH_ROOT/plugins" npm
# antigenp bundle "$SH_ROOT/plugins" subl
# antigenp bundle "$SH_ROOT/plugins" trash
# antigenp bundle "$SH_ROOT/plugins" unsorted
# $IS_WINDOWS && antigenp bundle "$SH_ROOT/plugins" cygwin-sudo
#
# antigenp bundle "$SH_ROOT/plugins" simple-history-search
# $HAS_CACHE && -zcache-done
#
$IS_WINDOWS && antigen bundles <<EOBUNDLES
  forivall/oh-my-zsh
  command-not-found
  npm
  nvm
  colorize
  cp
  meteor
  git-extras
  mafredri/zsh-async
  sindresorhus/pure
  zsh-users/zsh-completions src
  "$SH_ROOT/plugins" cygwin-functions
  "$SH_ROOT/plugins" simple-history-search
  "$SH_ROOT/plugins" colors
  "$SH_ROOT/plugins" coreutils
  "$SH_ROOT/plugins" git
  "$SH_ROOT/plugins" github
  "$SH_ROOT/plugins" magic-cd
  "$SH_ROOT/plugins" npm
  "$SH_ROOT/plugins" subl
  "$SH_ROOT/plugins" trash
  "$SH_ROOT/plugins" unsorted
  "$SH_ROOT/plugins" cygwin-sudo
  "$SH_ROOT/plugins" simple-history-search
EOBUNDLES

! $IS_WINDOWS && antigen bundles <<EOBUNDLES
  forivall/oh-my-zsh
  command-not-found
  npm
  nvm
  colorize
  cp
  meteor
  git-extras
  mafredri/zsh-async
  sindresorhus/pure
  zsh-users/zsh-completions src
  "$SH_ROOT/plugins" simple-history-search
  "$SH_ROOT/plugins" colors
  "$SH_ROOT/plugins" coreutils
  "$SH_ROOT/plugins" git
  "$SH_ROOT/plugins" github
  "$SH_ROOT/plugins" magic-cd
  "$SH_ROOT/plugins" npm
  "$SH_ROOT/plugins" subl
  "$SH_ROOT/plugins" trash
  "$SH_ROOT/plugins" unsorted
  "$SH_ROOT/plugins" simple-history-search
EOBUNDLES
#
antigenp apply
# bashcompletions need to happen after apply
if [[ -d "$HOME/.opam" ]] then antigenp bundle "$HOME/.opam/opam-init" ; fi


# todo: create a plugin for envoy
if whence envoy >/dev/null ; then eval $(envoy -ps) ; fi

unfunction antigenp
echo -en '\r'
# ___time_end
[[ "$PERF_TEST" == y ]] && exit
true
