#!/usr/bin/env zsh
___progress_symbols='|/-\'
___progress_i=0
___progress() { echo -en '\r'; echo -n "${___progress_symbols[(( (__progress_i = ((__progress_i + 1) % 4)) + 1))]} "}
___progress
___time_start () { ___source_time="$(date +%s%N)"; }
___print_time_diff () { local start_time="$1"; shift; local end_time="$(date +%s%N)"; echo $(( (end_time - start_time) / 1000000))ms; }
___time_end () { echo $(___print_time_diff $___source_time) "$@"; }
___timed () { ___time_start; "$@"; ___time_end "$@" }
___time_start

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
# antigen use oh-my-zsh

# omz settings
HYPHEN_INSENSITIVE=true
setopt extended_glob
EXTENDED_GLOB=true
setopt bareglobqual
BARE_GLOB_QUAL=true
COMPLETION_WAITING_DOTS=true
DISABLE_AUTO_TITLE=false

# slow
___progress
export ZSH="$(-antigen-get-clone-dir https://github.com/forivall/oh-my-zsh.git)"
antigen bundle forivall/oh-my-zsh; ___progress
# antigen bundle git
# antigen bundle git-extras
# antigen bundle node
# antigen bundle pip
# antigen bundle python
# antigen bundle web-search
antigen bundle command-not-found; ___progress
# antigen bundle virtualenv

# slow
antigen bundle npm; ___progress
# slow
antigen bundle nvm; ___progress
antigen bundle colorize; ___progress
antigen bundle cp; ___progress
antigen bundle meteor; ___progress
antigen bundle git-extras; ___progress
# antigen bundle encode64
antigen bundle mafredri/zsh-async; ___progress
antigen bundle sindresorhus/pure; ___progress
antigen bundle zsh-users/zsh-completions src; ___progress
# antigen bundle "$SH_ROOT/plugins/"
antigen bundle "$SH_ROOT/plugins" simple-history-search; ___progress
antigen bundle "$SH_ROOT/plugins" colors; ___progress
antigen bundle "$SH_ROOT/plugins" coreutils; ___progress
# slow
antigen bundle "$SH_ROOT/plugins" git; ___progress
antigen bundle "$SH_ROOT/plugins" github; ___progress
antigen bundle "$SH_ROOT/plugins" magic-cd; ___progress
antigen bundle "$SH_ROOT/plugins" npm; ___progress
antigen bundle "$SH_ROOT/plugins" subl; ___progress
antigen bundle "$SH_ROOT/plugins" trash; ___progress
antigen bundle "$SH_ROOT/plugins" unsorted; ___progress
# antigen bundle "$SH_ROOT/plugins" simple-history-search
antigen apply; ___progress
# bashcompletions need to happen after apply
if [[ -d "$HOME/.opam" ]] then antigen bundle "$HOME/.opam/opam-init" ; fi

# todo: create a plugin for envoy
if whence envoy >/dev/null ; then eval $(envoy -ps) ; fi

if [[ "$OS" == "Windows_NT" || -n "$CYGWIN_VERSION" ]]; then
  PATH="$PATH:$(cygpath $VBOX_INSTALL_PATH)"
fi

echo -en '\r'
