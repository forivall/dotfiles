#!/usr/bin/env zsh

# setopt XTRACE

# Uncomment the below to profile startup
# zmodload zsh/datetime
# source() {
#   local now=$EPOCHREALTIME
#   builtin source "$@"
#   echo $(( EPOCHREALTIME - now )) source "$@"
# }
# alias .=source

sourceIfExists() { [[ -e "$1" ]] && source "$1" }
sourceIfExists /etc/profile.d/vte.sh

[[ "$HOST" == "shrubbery-ni" ]] && export VAGRANT_HOME=/mnt/Peng/vagrant-home-linux

setbool() { local code=$?; local arg="$1"; shift; if [[ -z "$@" ]]; then 1=return; 2=$code; fi; if ("$@") 2>&1 >/dev/null ; then eval "$arg=true"; else eval "$arg=false"; fi; }

setbool IS_INTERACTIVE  tty -s
setbool IS_WINDOWS  $([[ "$OS" == "Windows_NT" || -n "$CYGWIN_VERSION" ]])
setbool IS_OSX  $([[ "$(uname)" == "Darwin" ]])
setbool IS_LINUXY  $(! $IS_WINDOWS && ! $IS_OSX)  # could also be BSD
IS_XDG() {
  local _XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg:/foo/bar};
  local xdg_config_dirs=(${(@s/:/)_XDG_CONFIG_DIRS});
  [[ -d ${xdg_config_dirs[1]} ]]
}
setbool IS_XDG IS_XDG
unset IS_XDG

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

# sourceIfExists /home/forivall/.travis/travis.sh
# sourceIfExists /usr/local/opt/chruby/share/chruby/chruby.sh
# sourceIfExists "$SH_ROOT/api_keys.sh"
sourceIfExists "${HOME}/.iterm2_shell_integration.zsh"

source "$SH_ROOT/zgen/zgen.zsh"
setopt extendedglob
if ! zgen saved; then
  zgen oh-my-zsh
  # zgen oh-my-zsh plugins/git
  # zgen oh-my-zsh plugins/git-extras
  # zgen oh-my-zsh plugins/node
  # zgen oh-my-zsh plugins/pip
  # zgen oh-my-zsh plugins/python
  zgen oh-my-zsh plugins/web-search
  # zgen oh-my-zsh plugins/command-not-found # very slow
  # zgen oh-my-zsh plugins/virtualenv
  # zgen oh-my-zsh plugins/npm
  # zgen oh-my-zsh plugins/nvm
  zgen oh-my-zsh plugins/colorize
  zgen oh-my-zsh plugins/cp
  # zgen oh-my-zsh plugins/meteor
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
  # zgen load deliciousinsights/git-stree
  zgen load lukechilds/zsh-nvm
  zgen load lukechilds/zsh-better-npm-completion
  # zgen load jocelynmallon/zshimarks
  zgen load "$SH_ROOT/plugins/functional"
  $IS_WINDOWS && zgen load "$SH_ROOT/plugins/cygwin-functions"
  $IS_WINDOWS && zgen load "$SH_ROOT/plugins/cygwin-sudo"
  $IS_OSX && zgen load "$SH_ROOT/plugins/iterm2"

  zgen load "$SH_ROOT/plugins/oneliner"
  zgen load "$SH_ROOT/plugins/external-tools"
  zgen load "$SH_ROOT/plugins/dimensions-in-title"
  zgen load "$SH_ROOT/plugins/colors"
  # zgen load "$SH_ROOT/plugins/rubygems"
  zgen load "$SH_ROOT/plugins/coreutils"
  zgen load "$SH_ROOT/plugins/git"
  zgen load "$SH_ROOT/plugins/git-ftp"
  zgen load "$SH_ROOT/plugins/github"
  zgen load "$SH_ROOT/plugins/lab"
  zgen load "$SH_ROOT/plugins/magic-cd"
  zgen load "$SH_ROOT/plugins/npm"
  # zgen load "$SH_ROOT/plugins/nvm"
  zgen load "$SH_ROOT/plugins/yarn"
  zgen load "$SH_ROOT/plugins/yargs"
  # zgen load "$SH_ROOT/plugins/subl"
  zgen load "$SH_ROOT/plugins/trash"
  zgen load "$SH_ROOT/plugins/unsorted"
  zgen load "$SH_ROOT/plugins/simple-history-search"
  # zgen load "$SH_ROOT/plugins/zgen-autoupdate" # TODO: figure out why this is slooooow!

  [[ -d "$HOME/.opam" ]] && zgen load "$HOME/.opam/opam-init"

  zgen load zsh-users/zsh-syntax-highlighting

  $IS_OSX && zgen load nilsonholger/osx-zsh-completions

  # Build completions files
  local ofpath=(${fpath})
  fpath=(${(q)ZGEN_COMPLETIONS[@]} ${fpath})
  for func in ${(kM)functions:#*__build_completions} ; do
    # echo "Running $func..." >&2
    $func
  done
  fpath=(${ofpath})

  zgen save
fi
unsetopt nomatch

if [[ "$VSCODE_CLI" == 1 ]] ; then
  AMD_ENTRYPOINT=
  ELECTRON_NO_ASAR=
  ELECTRON_NO_ATTACH_CONSOLE=
  ELECTRON_RUN_AS_NODE=
  GOOGLE_API_KEY=
  PIPE_LOGGING=
  VERBOSE_LOGGING=
  VSCODE_CLI=
  VSCODE_HANDLES_UNCAUGHT_ERRORS=
  VSCODE_IPC_HOOK=
  VSCODE_IPC_HOOK_EXTHOST=
  VSCODE_LOG_STACK=
  VSCODE_NLS_CONFIG=
  VSCODE_PID=
  VSCODE_WINDOW_ID=
fi

clean-env

autoload bashcompinit && bashcompinit

unset setbool
unset sourceIfExists

true
