#!/usr/bin/env zsh

__zshrc_filename=${${(%):-%N}:A}
__zshrc_dirname=${__zshrc_filename:h}

# TODO: separate out all os-specific code so that we only run the platform
# detection code on zgen reset
source "${__zshrc_dirname}/scripts/detect-platform.zsh"

sourceIfExists() { [[ -e "$1" ]] && source "$1" }
$IS_LINUXY && sourceIfExists /etc/profile.d/vte.sh

if $IS_OSX ; then
  if [ -x /usr/libexec/path_helper ]; then
    eval `/usr/libexec/path_helper -s`
  fi
  path=(/usr/local/opt/coreutils/libexec/gnubin /usr/local/opt/gnu-sed/libexec/gnubin $path)
fi

if ! type realpath >/dev/null ; then
  realpath() { readlink -f "$@"; }
fi

if $IS_LINUXY ; then
  # https://wiki.archlinux.org/index.php/SSH_keys#Start_ssh-agent_with_systemd_user
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
  setbool() { local code=$?; local arg="$1"; shift; if [[ -z "$@" ]]; then 1=return; 2=$code; fi; if ("$@") 2>&1 >/dev/null ; then eval "$arg=true"; else eval "$arg=false"; fi; }
  #setbool HAS_ENVOY  whence envoy
  unset setbool

  # todo: create a plugin for envoy
fi

# core shell settings
export EDITOR=vim
export VISUAL=vim
HISTSIZE=50000; SAVEHIST=10000
HISTFILE=~/.zsh_history
tabs -2

$IS_INTERACTIVE && export HISTFILE=$HOME/.zsh_history_interactive
APPEND_HISTORY=true; setopt appendhistory; setopt histfcntllock; setopt nohistsavebycopy

# omz settings
DISABLE_AUTO_UPDATE=true
HYPHEN_INSENSITIVE=true
COMPLETION_WAITING_DOTS=true
DISABLE_AUTO_TITLE=false

# zsh settings
setopt extended_glob
setopt bareglobqual

# zsh highlighting settings
zle_highlight+=(paste:none)
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# pure prompt settings
PURE_HIGHLIGHT_REPO=1
PURE_PROMPT_SYMBOL="%B»%b"

zstyle ':completion:*' rehash true

# local git plugin settings
export UNTRACKED_FILES_STORAGE="$HOME/code/.old-untracked-files"

path=(~/.local/bin $path ~/.zgen/deliciousinsights/git-stree-master)

sourceIfExists "${HOME}/.iterm2_shell_integration.zsh"

unset sourceIfExists

source "$__zshrc_dirname/zgen/zgen.zsh"
setopt extendedglob
if ! zgen saved; then
  zgen load zsh-users/zsh-syntax-highlighting

  zgen oh-my-zsh
  zgen oh-my-zsh plugins/web-search
  # zgen oh-my-zsh plugins/command-not-found # very slow
  zgen oh-my-zsh plugins/colorize
  zgen oh-my-zsh plugins/cp
  zgen oh-my-zsh plugins/git-extras
  zgen oh-my-zsh plugins/docker
  # zgen oh-my-zsh plugins/jump

  zgen load srijanshetty/zsh-pandoc-completion ''

  zgen load "$__zshrc_dirname/plugins/jump"
  # zgen oh-my-zsh encode64
  ! $IS_WINDOWS && zgen load mafredri/zsh-async
  # ! $IS_WINDOWS && zgen load sindresorhus/pure
  ! $IS_WINDOWS && zgen load forivall/pure '' underline-repo-name
  $IS_WINDOWS && zgen load forivall/pure '' underline-repo-name-no-async
  zgen load zsh-users/zsh-completions src
  zgen load zsh-users/zsh-history-substring-search
  # zgen load deliciousinsights/git-stree
  ! $IS_WINDOWS && zgen load lukechilds/zsh-nvm 
  zgen load lukechilds/zsh-better-npm-completion
  # zgen load jocelynmallon/zshimarks
  zgen load "$__zshrc_dirname/plugins/functional"
  $IS_WINDOWS && zgen load "$__zshrc_dirname/plugins/cygwin-functions"
  $IS_WINDOWS && zgen load "$__zshrc_dirname/plugins/cygwin-sudo"
  $IS_OSX && zgen load "$__zshrc_dirname/plugins/iterm2"

  zgen load "$__zshrc_dirname/plugins/oneliner"
  zgen load "$__zshrc_dirname/plugins/external-tools"
  zgen load "$__zshrc_dirname/plugins/dimensions-in-title"
  zgen load "$__zshrc_dirname/plugins/colors"
  # zgen load "$__zshrc_dirname/plugins/rubygems"
  zgen load "$__zshrc_dirname/plugins/coreutils"
  zgen load "$__zshrc_dirname/plugins/git"
  zgen load "$__zshrc_dirname/plugins/git-ftp"
  zgen load "$__zshrc_dirname/plugins/github"
  zgen load "$__zshrc_dirname/plugins/lab"
  zgen load "$__zshrc_dirname/plugins/magic-cd"
  zgen load "$__zshrc_dirname/plugins/npm"
  $IS_WINDOWS && zgen load "$__zshrc_dirname/plugins/npm"

  # zgen load "$__zshrc_dirname/plugins/nvm"
  zgen load "$__zshrc_dirname/plugins/yarn"
  zgen load "$__zshrc_dirname/plugins/yargs"
  # zgen load "$__zshrc_dirname/plugins/subl"
  zgen load "$__zshrc_dirname/plugins/trash"
  zgen load "$__zshrc_dirname/plugins/unsorted"
  zgen load "$__zshrc_dirname/plugins/simple-history-search"
  # zgen load "$__zshrc_dirname/plugins/zgen-autoupdate" # TODO: figure out why this is slooooow!

  [[ -d "$HOME/.opam" ]] && zgen load "$HOME/.opam/opam-init"


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

# TODO: move to a vscode plugin
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


true
