#!/usr/bin/env zsh

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

export ZSH="$(-antigen-get-clone-dir https://github.com/forivall/oh-my-zsh.git)"
antigen bundle forivall/oh-my-zsh

# antigen bundle git
# antigen bundle git-extras
# antigen bundle npm
# antigen bundle node
# antigen bundle pip
# antigen bundle python
# antigen bundle web-search
# antigen bundle command-not-found
# antigen bundle virtualenv
# antigen bundle npm
# antigen bundle colorize
# antigen bundle cp
# antigen bundle encode64
antigen bundle sindresorhus/pure
antigen bundle zsh-users/zsh-completions src
# antigen bundle "$SH_ROOT/plugins/"
antigen bundle "$SH_ROOT/plugins" simple-history-search
antigen bundle "$SH_ROOT/plugins" colors
antigen bundle "$SH_ROOT/plugins" coreutils
antigen bundle "$SH_ROOT/plugins" git
antigen bundle "$SH_ROOT/plugins" magic-cd
antigen bundle "$SH_ROOT/plugins" npm
antigen bundle "$SH_ROOT/plugins" subl
antigen bundle "$SH_ROOT/plugins" unsorted
# antigen bundle "$SH_ROOT/plugins" zsh-opts
# antigen bundle "$SH_ROOT/plugins" simple-history-search
antigen apply
# bashcompletions need to happen after apply
antigen bundle "$HOME/.opam/opam-init"

eval $(envoy -ps)
