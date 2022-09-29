#!/usr/bin/env zsh
# zmodload zsh/zprof

# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && . "$HOME/.fig/shell/zshrc.pre.zsh"

unset CI

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

  if [[ -x /opt/homebrew/bin/brew ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  elif [[ -x /usr/local/opt/bin/brew ]]; then
    HOMEBREW_PREFIX="/usr/local/opt"
  fi

  if [[ -n "$HOMEBREW_PREFIX" ]]; then
    path=(
      $HOMEBREW_PREFIX/bin
      $HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin 
      $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
      $path
    )
  fi
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
# export SHELL=$(whence $(ps wwwe -p $$ -o comm=))  # broken on m1 mac
# export SHELL=zsh
export EDITOR=vim
export VISUAL=code
export LC_ALL="en_CA.UTF-8"
HISTSIZE=50000; SAVEHIST=10000
HISTFILE=~/.zsh_history
tabs -2

# bindkey -M emacs "^\`" _complete_help

$IS_INTERACTIVE && export HISTFILE=$HOME/.zsh_history_interactive
APPEND_HISTORY=true; setopt appendhistory; setopt histfcntllock; setopt nohistsavebycopy

# Bun
if [[ -x ~/.bun/bin/bun ]] {
  export BUN_INSTALL=~/.bun
  path=("$BUN_INSTALL/bin" $path)
}

# TODO: switch to
# https://github.com/jandamm/zgenom or
# https://github.com/zdharma-continuum/zinit or
# https://github.com/marlonrichert/zsh-snap or
# https://github.com/zimfw/zimfw
# zgen settings
ZGEN_AUTOLOAD_COMPINIT=0

# omz settings
DISABLE_AUTO_UPDATE=true
HYPHEN_INSENSITIVE=true
# COMPLETION_WAITING_DOTS=true
DISABLE_AUTO_TITLE=false
ZSH_PYENV_QUIET=true
# ENABLE_CORRECTION=true

export BAT_PAGER="less +X -x2 -FR"
export DELTA_LIGHT_THEME=base16-tomorrow

# zsh-nvm settings
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
sourceIfExists "${__zshrc_dirname}/plugins/nvm/cache"
# TODO: use https://github.com/Schniz/fnm instead?
export TSC_NONPOLLING_WATCHER=true

# zsh settings
setopt no_extended_glob # breaks `git show HEAD^`
setopt bareglobqual

# zsh highlighting settings
zle_highlight+=(paste:none)
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# fuzzy completion
zstyle ':completion:*' matcher-list 'r:|?=**'
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' list-suffixes true
# zstyle ':autocomplete:list-choices:*' max-lines 40%
zstyle ':autocomplete:list-choices:*' max-lines 24
zstyle ':autocomplete:tab:*' completion select

# pure prompt settings
PURE_HIGHLIGHT_REPO=1
PURE_PROMPT_SYMBOL="%B»%b"
PURE_GIT_UNTRACKED_DIRTY=0
zstyle :prompt:pure:git:stash show yes
# $prompt_pure_git_stash

zstyle ':completion:*' rehash true

# local git plugin settings
export UNTRACKED_FILES_STORAGE="$HOME/code/.old-untracked-files"

path=(
  ~/.local/bin
  ~/.cargo/bin
  $path
  ~/.zgen/deliciousinsights/git-stree-master
)

unset sourceIfExists

autoload -Uz bashcompinit && bashcompinit
autoload -Uz compinit && compinit -i

zstyle ':completion:*:warnings' format '%F{yellow}%d%f'

source "$__zshrc_dirname/zgen/zgen.zsh"
if ! zgen saved; then
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-autosuggestions
  # zgen load marlonrichert/zsh-autocomplete

  $IS_OSX && zgen load "$__zshrc_dirname/plugins/brew"

  zgen oh-my-zsh
  zgen oh-my-zsh plugins/web-search
  # zgen oh-my-zsh plugins/command-not-found # very slow
  $IS_OSX && zgen oh-my-zsh plugins/brew
  zgen oh-my-zsh plugins/colorize
  zgen oh-my-zsh plugins/cp
  zgen oh-my-zsh plugins/git-extras
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/docker-compose
  [[ -d $CLOUDSDK_HOME ]] && zgen oh-my-zsh plugins/gcloud
  zgen oh-my-zsh plugins/rbenv
  zgen load "$__zshrc_dirname/plugins/python"
  zgen oh-my-zsh plugins/python
  zgen oh-my-zsh plugins/pyenv
  whence kubectl > /dev/null && zgen oh-my-zsh plugins/kubectl
  whence direnv > /dev/null && zgen oh-my-zsh plugins/direnv
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

  ! $IS_WINDOWS && zgen load forivall/zsh-nvm
  zgen load "$__zshrc_dirname/plugins/nvm"
  zgen load lukechilds/zsh-better-npm-completion
  zgen load g-plane/zsh-yarn-autocompletions
  $IS_OSX && zgen load nilsonholger/osx-zsh-completions
  # zgen load jocelynmallon/zshimarks

  zgen load "$__zshrc_dirname/plugins/functional"
  $IS_WINDOWS && zgen load "$__zshrc_dirname/plugins/cygwin-functions"
  $IS_WINDOWS && zgen load "$__zshrc_dirname/plugins/cygwin-sudo"
  $IS_OSX && zgen load "$__zshrc_dirname/plugins/iterm2"

  zgen load "$__zshrc_dirname/plugins/oneliner"
  zgen load "$__zshrc_dirname/plugins/external-tools"
  zgen load "$__zshrc_dirname/plugins/dimensions-in-title"
  zgen load "$__zshrc_dirname/plugins/ruby"
  zgen load "$__zshrc_dirname/plugins/coreutils"
  zgen load "$__zshrc_dirname/plugins/git"
  zgen load "$__zshrc_dirname/plugins/git-ftp"
  zgen load "$__zshrc_dirname/plugins/github"
  whence lab > /dev/null && zgen load "$__zshrc_dirname/plugins/lab"
  whence glab > /dev/null && zgen load "$__zshrc_dirname/plugins/glab"
  whence nx > /dev/null && zgen load jscutlery/nx-completion
  zgen load "$__zshrc_dirname/plugins/magic-cd"
  zgen load "$__zshrc_dirname/plugins/npm"
  $IS_WINDOWS && zgen load "$__zshrc_dirname/plugins/npm"
  whence twilio > /dev/null && zgen load "$__zshrc_dirname/plugins/twilio"

  zgen load "$__zshrc_dirname/plugins/yarn"
  zgen load "$__zshrc_dirname/plugins/yargs"
  # zgen load "$__zshrc_dirname/plugins/subl"
  zgen load "$__zshrc_dirname/plugins/trash"
  zgen load "$__zshrc_dirname/plugins/unsorted"
  zgen load "$__zshrc_dirname/plugins/simple-history-search"
  # zgen load "$__zshrc_dirname/plugins/zgen-autoupdate" # TODO: figure out why this is slooooow!

  [[ -d "$HOME/.opam" ]] && zgen load "$HOME/.opam/opam-init"

  $IS_OSX && zgen load nilsonholger/osx-zsh-completions

  zgen load dim-an/cod

  # Build completions files
  local ofpath=(${fpath})
  fpath=(${(q)ZGEN_COMPLETIONS[@]} ${fpath})
  for func in ${(kM)functions:#*__build_completions} ; do
    echo "Running $func..." >&2
    $func
  done
  fpath=(${ofpath})

  local before=${#fpath}
  zgen save
  local count=$(( ${#fpath} - $before ))

  for plugindir in ${fpath[0,$count]} ; do
    if [[ -f ${plugindir}/zplug.zsh ]] ; then
      # echo "Running ${plugindir}/zplug.zsh" >&2
      (builtin cd $plugindir && ./zplug.zsh)
    fi
  done
fi
unalias 9
unsetopt nomatch
# from oh-my-zsh web-search. github is from github desktop.
unalias github

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

if [[ "$TERM_PROGRAM" != "vscode" ]] ; then
  unset VSCODE_CWD
fi

clean-env

# https://gist.github.com/ctechols/ca1035271ad134841284
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+1) ]]; then
	compinit
  compdump
else
	compinit -C # dont check cache
fi;

# zstyle ':completion:*:warnings' format '%F{yellow}%d%f'
# zprof

# dont override my variables, ya arse.
FIG_DOTFILES_SOURCED=1

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && . "$HOME/.fig/shell/zshrc.post.zsh"

true
