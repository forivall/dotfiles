#!/usr/bin/env zsh

if [[ -e /etc/profile.d/vte.sh ]] ; then
  source /etc/profile.d/vte.sh
fi

# echo $NODE_PATH
# source() {
#   echo $NODE_PATH
#   echo source "$@"
#   grep NODE_PATH "$1"
#   builtin source "$@"
# }
# alias .=source

[[ "$HOST" == "shrubbery-ni" ]] && export VAGRANT_HOME=/mnt/Peng/vagrant-home-linux

setbool() { local code=$?; local arg="$1"; shift; if [[ -z "$@" ]]; then 1=return; 2=$code; fi; if ("$@") 2>&1 >/dev/null ; then eval "$arg=true"; else eval "$arg=false"; fi; }

setbool IS_INTERACTIVE  tty -s
setbool IS_WINDOWS  $([[ "$OS" == "Windows_NT" || -n "$CYGWIN_VERSION" ]])
setbool IS_OSX  $([[ "$(uname)" == "Darwin" ]])
setbool IS_LINUXY  $(! $IS_WINDOWS && ! $IS_OSX)  # could also be BSD

if $IS_OSX ; then
  if [ -x /usr/libexec/path_helper ]; then
    eval `/usr/libexec/path_helper -s`
  fi
  path=(/usr/local/opt/coreutils/libexec/gnubin /usr/local/opt/gnu-sed/libexec/gnubin $path)
fi

if ! type realpath >/dev/null ; then
  realpath() { readlink -f "$@"; }
fi

SH_ROOT="$(dirname "$(realpath ~/.zshrc)")"

if $IS_LINUXY ; then
  # https://wiki.archlinux.org/index.php/SSH_keys#Start_ssh-agent_with_systemd_user
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
  #setbool HAS_ENVOY  whence envoy

  # todo: create a plugin for envoy
fi

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
DISABLE_AUTO_UPDATE=true
HYPHEN_INSENSITIVE=true
setopt extended_glob
EXTENDED_GLOB=true
setopt bareglobqual
BARE_GLOB_QUAL=true
COMPLETION_WAITING_DOTS=true
DISABLE_AUTO_TITLE=false
export C9_USER='Emily Klassen' # override for `fullname` on npm

PURE_HIGHLIGHT_REPO=1

# https://wiki.archlinux.org/index.php/Zsh#Help_command
autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk
unalias run-help 2> /dev/null || true
alias help=run-help

zstyle ':completion:*' rehash true

# PURE_PROMPT_SYMBOL="$(printf '\u2765')"
# PURE_PROMPT_SYMBOL="$(printf '\u2771')"
# PURE_PROMPT_SYMBOL="›"
PURE_PROMPT_SYMBOL="»"
PURE_PROMPT_SYMBOL="%B»%b"
# PURE_PROMPT_SYMBOL="%B>%b"
# PURE_PROMPT_SYMBOL="→"
# PURE_PROMPT_SYMBOL="$"
export UNTRACKED_FILES_STORAGE="$HOME/code/.old-untracked-files"

path=(~/.local/bin $path ~/.zgen/deliciousinsights/git-stree-master ~/.cargo/bin ~/.fastlane/bin)
zle_highlight+=(paste:none)
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

export GOPATH="$HOME/.gocode"

if [[ "$PERF_TEST" == y ]] ; then exit; else true; fi

# unfunction source
# unalias .
if $IS_WINDOWS ; then
  export NVM_DIR="/c/Users/forivall/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
fi

# added by travis gem
[ -f /home/forivall/.travis/travis.sh ] && source /home/forivall/.travis/travis.sh

source /usr/local/opt/chruby/share/chruby/chruby.sh

[[ -e "$SH_ROOT/api_keys.sh" ]] && source "$SH_ROOT/api_keys.sh"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

source "$SH_ROOT/zgen/zgen.zsh"

if ! zgen saved; then
  zgen oh-my-zsh
  # zgen oh-my-zsh plugins/git
  # zgen oh-my-zsh plugins/git-extras
  # zgen oh-my-zsh plugins/node
  # zgen oh-my-zsh plugins/pip
  # zgen oh-my-zsh plugins/python
  zgen oh-my-zsh plugins/web-search
  zgen oh-my-zsh plugins/command-not-found
  # zgen oh-my-zsh plugins/virtualenv
  # zgen oh-my-zsh plugins/npm
  zgen oh-my-zsh plugins/nvm
  zgen oh-my-zsh plugins/colorize
  zgen oh-my-zsh plugins/cp
  zgen oh-my-zsh plugins/meteor
  zgen oh-my-zsh plugins/git-extras
  # zgen oh-my-zsh plugins/jump

  zgen load srijanshetty/zsh-pandoc-completion ''

  zgen load "$SH_ROOT/plugins/jump"
  # zgen oh-my-zsh encode64
  ! $IS_WINDOWS && zgen load mafredri/zsh-async
  # ! $IS_WINDOWS && zgen load "$SH_ROOT/../../repos/git/zsh-pure"
  # ! $IS_WINDOWS && zgen load sindresorhus/pure
  ! $IS_WINDOWS && zgen load forivall/pure '' underline-repo-name
  $IS_WINDOWS && zgen load forivall/pure '' underline-repo-name-no-async
  zgen load zsh-users/zsh-completions src
  zgen load deliciousinsights/git-stree
  zgen load lukechilds/zsh-better-npm-completion
  # zgen load jocelynmallon/zshimarks
  zgen load "$SH_ROOT/plugins/functional"
  $IS_WINDOWS && zgen load "$SH_ROOT/plugins/cygwin-functions"
  $IS_WINDOWS && zgen load "$SH_ROOT/plugins/cygwin-sudo"
  zgen load "$SH_ROOT/plugins/oneliner"
  zgen load "$SH_ROOT/plugins/external-tools"
  zgen load "$SH_ROOT/plugins/dimensions-in-title"
  zgen load "$SH_ROOT/plugins/colors"
  zgen load "$SH_ROOT/plugins/rubygems"
  zgen load "$SH_ROOT/plugins/coreutils"
  zgen load "$SH_ROOT/plugins/git"
  zgen load "$SH_ROOT/plugins/git-ftp"
  zgen load "$SH_ROOT/plugins/github"
  zgen load "$SH_ROOT/plugins/magic-cd"
  zgen load "$SH_ROOT/plugins/npm"
  zgen load "$SH_ROOT/plugins/subl"
  zgen load "$SH_ROOT/plugins/trash"
  zgen load "$SH_ROOT/plugins/unsorted"
  zgen load "$SH_ROOT/plugins/simple-history-search"
  zgen load "$SH_ROOT/plugins/zgen-autoupdate"
  [[ "$HOST" == *ledcor* ]] && zgen load "$SH_ROOT/plugins/ledcor"

  [[ -d "$HOME/.opam" ]] && zgen load "$HOME/.opam/opam-init"

  zgen load zsh-users/zsh-syntax-highlighting
  zgen save
fi
unsetopt nomatch
autoload -U cygcd

clean-env

autoload bashcompinit && bashcompinit
source '/Users/jordanklassen/.local/lib/azure-cli/az.completion'

