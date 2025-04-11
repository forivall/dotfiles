#!/usr/bin/env zsh

# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# zmodload zsh/zprof
# setopt xtrace
# shellcheck disable=SC2168,2296

unset CI

# shellcheck disable=2298
__zshrc_filename=${${(%):-%N}:A}
__zshrc_dirname=${__zshrc_filename:h}

# TODO: separate out all os-specific code so that we only run the platform
# detection code on zgen reset
source "${__zshrc_dirname}/scripts/detect-platform.zsh"

# shellcheck disable=SC1090
sourceIfExists() { [[ -e "$1" ]] && source "$1"; }
$IS_LINUXY && sourceIfExists /etc/profile.d/vte.sh

if $IS_OSX ; then
  if [ -x /usr/libexec/path_helper ]; then
    eval "$(/usr/libexec/path_helper -s)"
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  elif [[ -x /usr/local/opt/bin/brew ]]; then
    HOMEBREW_PREFIX="/usr/local/opt"
  fi
  HOMEBREW_BUNDLE_FILE=${__zshrc_dirname}/Brewfile

  if [[ -n "$HOMEBREW_PREFIX" ]]; then
    path=(
      $HOMEBREW_PREFIX/bin
      $HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin
      $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
      $path
    )
    fpath[${fpath[(i)$HOMEBREW_PREFIX/share/zsh/site-functions]}]=()
    fpath=($fpath $HOMEBREW_PREFIX/share/zsh/site-functions)
  fi
fi

if ! type realpath >/dev/null ; then
  realpath() { readlink -f "$@"; }
fi

if $IS_LINUXY ; then
  # https://wiki.archlinux.org/index.php/SSH_keys#Start_ssh-agent_with_systemd_user
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# core shell settings
# export SHELL=$(whence $(ps wwwe -p $$ -o comm=))  # broken on m1 mac
# export SHELL=zsh
export EDITOR=hx

export VISUAL="wait-code"
export LC_ALL="en_CA.UTF-8"
export HISTTIMEFORMAT=": %F %T:0;"
export HISTFILESIZE=
export HISTSIZE=
HISTSIZE=50000; SAVEHIST=10000
HISTFILE=~/.zsh_history
tabs -2

zmodload -i zsh/complist

$IS_INTERACTIVE && export HISTFILE=$HOME/.zsh_history_interactive
APPEND_HISTORY=true; setopt appendhistory; setopt histfcntllock; setopt nohistsavebycopy

# Bun
if [[ -x ~/.bun/bin/bun ]]; then
  export BUN_INSTALL=~/.bun
  path=("$BUN_INSTALL/bin" $path)
fi

# zgen settings
ZGEN_AUTOLOAD_COMPINIT=0

# omz settings
DISABLE_AUTO_UPDATE=true
HYPHEN_INSENSITIVE=true
# COMPLETION_WAITING_DOTS=true
DISABLE_AUTO_TITLE=false
ZSH_COMPINIT_CACHE=true
# ZSH_PYENV_QUIET=true
# ENABLE_CORRECTION=true

# export BAT_PAGER="less +X -x2 -FR"
export LESS='-SRiF'  # --mouse --wheel-lines=1  # scroll wheel used to freeze iterm2
export BAT_PAGER="moar --no-linenumbers"
export BAT_LIGHT_THEME=base16-tomorrow
export DELTA_LIGHT_THEME=base16-tomorrow
export MOAR="--statusbar=bold --no-linenumbers"
export RIPGREP_CONFIG_PATH="${__zshrc_dirname}/config/ripgreprc"

__FZF_BASE_COMMAND="fd --hidden --follow --exclude '.git' --exclude 'node_modules' --exclude '.marks' --exclude \$(realpath --relative-to=. $HOME/Library)"
export FZF_DEFAULT_COMMAND="$__FZF_BASE_COMMAND --type f"
export FZF_ALT_C_COMMAND="$__FZF_BASE_COMMAND --type d"
export FZF_CTRL_T_COMMAND=""

# zsh-nvm settings
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
sourceIfExists "${__zshrc_dirname}/plugins/nvm/cache"

export DIRENV_WARN_TIMEOUT=1m

# TODO: use https://github.com/Schniz/fnm instead?
export TSC_NONPOLLING_WATCHER=true
export WATCHMAN_CONFIG_FILE="${__zshrc_dirname}/config/watchman.json"

# zsh settings
setopt no_extended_glob # breaks `git show HEAD^`
setopt bareglobqual

# zsh highlighting settings
zle_highlight+=(paste:none)
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# fuzzy completion

if $ENABLE_AUTOCOMPLETE; then
  zstyle ':completion:*' completer _prefix _complete _correct _approximate
else
  zstyle ':completion:*' completer _prefix _expand_alias _complete _correct _approximate
fi
zstyle ':completion:*:correct:::' max-errors 2 not-numeric
zstyle ':completion:*' matcher-list 'r:|?=**'
zstyle ':completion:*:approximate:::' max-errors 2 numeric
zstyle ':completion:*:complete:*:*:*' matcher-list '' 'm:{a-z}={A-Z}'
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' list-suffixes true
# zstyle ':autocomplete:list-choices:*' max-lines 40%
zstyle ':autocomplete:list-choices:*' max-lines 18
zstyle ':autocomplete:history-search-backward:*' list-lines 2000
zstyle ':autocomplete:tab:*' completion select
zstyle ':autocomplete:*' min-input 3
zstyle ':autocomplete:*' delay 0.1
zstyle ':autocomplete:tab:*' widget-style menu-select

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

zstyle ':completion:*:warnings' format '%F{yellow}%d%f'

ENABLE_AUTOCOMPLETE=false

source "$__zshrc_dirname/zgen/zgenom.zsh"
alias zgen=zgenom
if ! zgen saved; then
  zgen load zsh-users/zsh-syntax-highlighting

  $IS_OSX && zgen load "$__zshrc_dirname/plugins/brew"

  zgen ohmyzsh
  zgen ohmyzsh plugins/web-search
  # zgen ohmyzsh plugins/command-not-found # very slow
  $IS_OSX && zgen ohmyzsh plugins/brew
  zgen ohmyzsh plugins/colorize
  zgen ohmyzsh plugins/cp
  zgen ohmyzsh plugins/git-extras
  # zgen ohmyzsh plugins/docker
  zgen ohmyzsh plugins/docker-compose
  # zgen ohmyzsh plugins/npm
  [[ -d $CLOUDSDK_HOME ]] && zgen ohmyzsh plugins/gcloud
  zgen ohmyzsh plugins/rbenv
  zgen load "$__zshrc_dirname/plugins/python"
  zgen ohmyzsh plugins/python
  # zgen ohmyzsh plugins/pyenv
  whence kubectl > /dev/null && zgen ohmyzsh plugins/kubectl
  # zgen ohmyzsh plugins/jump
  # zgen ohmyzsh encode64

  zgenom load unixorn/fzf-zsh-plugin
  zgen load atuinsh/atuin
  zgen load zsh-users/zsh-autosuggestions
  if $ENABLE_AUTOCOMPLETE; then
    zgen load marlonrichert/zsh-autocomplete
  else
    zgen load zsh-users/zsh-history-substring-search
    zgen load "$__zshrc_dirname/plugins/simple-history-search"
  fi

  zgen load srijanshetty/zsh-pandoc-completion /

  zgen load "$__zshrc_dirname/plugins/jump"
  ! $IS_WINDOWS && zgen load mafredri/zsh-async / main
  # ! $IS_WINDOWS && zgen load sindresorhus/pure
  ! $IS_WINDOWS && zgen load forivall/pure / underline-repo-name
  $IS_WINDOWS && zgen load forivall/pure / underline-repo-name-no-async
  zgen load zsh-users/zsh-completions src
  # zgen load deliciousinsights/git-stree

  ! $IS_WINDOWS && zgen load forivall/zsh-nvm
  zgen load "$__zshrc_dirname/plugins/nvm"
  # zgen load forivall/zsh-yarn-autocompletions / main
  $IS_OSX && zgen load nilsonholger/osx-zsh-completions
  # zgen load jocelynmallon/zshimarks

  zgen load "$__zshrc_dirname/plugins/functional"
  $IS_WINDOWS && zgen load "$__zshrc_dirname/plugins/cygwin-functions"
  $IS_WINDOWS && zgen load "$__zshrc_dirname/plugins/cygwin-sudo"
  $IS_OSX && zgen load "$__zshrc_dirname/plugins/iterm2"


  zgen load "$__zshrc_dirname/plugins/oneliner"
  zgen load "$__zshrc_dirname/plugins/external-tools"
  zgen load "$__zshrc_dirname/plugins/dimensions-in-title"
  zgen load "$__zshrc_dirname/plugins/rust"
  zgen load "$__zshrc_dirname/plugins/ruby"
  zgen load "$__zshrc_dirname/plugins/coreutils"
  zgen load "$__zshrc_dirname/plugins/git"
  zgen load "$__zshrc_dirname/plugins/git-ftp"
  zgen load "$__zshrc_dirname/plugins/github"
  zgen load "$__zshrc_dirname/plugins/go"
  whence lab > /dev/null && zgen load "$__zshrc_dirname/plugins/lab"
  whence glab > /dev/null && zgen load "$__zshrc_dirname/plugins/glab"
  zgen load jscutlery/nx-completion / main
  # zgen load forivall/nx-completion / update
  zgen load "$__zshrc_dirname/plugins/magic-cd"
  zgen load "$__zshrc_dirname/plugins/ngrok"
  zgen load "$__zshrc_dirname/plugins/npm"
  zgen load "$__zshrc_dirname/plugins/pnpm"
  whence twilio > /dev/null && zgen load "$__zshrc_dirname/plugins/twilio"

  zgen load "$__zshrc_dirname/plugins/wttr"
  zgen load "$__zshrc_dirname/plugins/yarn"
  zgen load "$__zshrc_dirname/plugins/yargs"
  zgen load "$__zshrc_dirname/plugins/yargs"
  # zgen load "$__zshrc_dirname/plugins/subl"
  zgen load "$__zshrc_dirname/plugins/trash"
  zgen load "$__zshrc_dirname/plugins/unsorted"
  zgen load "$__zshrc_dirname/plugins/zgen-zplug"
  # zgen load "$__zshrc_dirname/plugins/zgen-autoupdate" # TODO: figure out why this is slooooow!

  [[ -d "$HOME/.opam" ]] && zgen load "$HOME/.opam/opam-init"

  $IS_OSX && zgen load nilsonholger/osx-zsh-completions
  zgen load gentslava/zsh-better-npm-completion
  zgen load g-plane/zsh-yarn-autocompletions
  zgen load g-plane/pnpm-shell-completion
  (( ${+commands[direnv]} )) && zgen ohmyzsh plugins/direnv && zgen load "$__zshrc_dirname/plugins/direnv"

  # zgen load dim-an/cod
  # zgen load forivall/cod / feat/zsh-local-build
  zgen load "$__zshrc_dirname/plugins/local"

  # Build completions files
  local ofpath=(${fpath})
  fpath=(${(q)ZGEN_COMPLETIONS[@]} ${fpath})
  for func in ${(kM)functions:#*__build_completions} ; do
    echo "Running $func..." >&2
    $func
  done
  fpath=(${ofpath})

  zgen-zplug-before-save
  zgen save
  zgen-zplug-after-save
fi
[[ $(whence -w 9 2>/dev/null) == '9: alias' ]] && unalias 9
unsetopt nomatch
# from ohmyzsh web-search. github is from github desktop.
[[ $(whence -w github 2>/dev/null) == 'github: alias' ]] && unalias github

# bindkey -M emacs "^\`" _complete_help
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

bindkey '^[[5C' forward-word
bindkey '^[[5D' backward-word

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

if [[ "$TERM_PROGRAM" == "vscode" ]] ; then
  VSCODE_INJECTION=0
  VSCODE_SUGGEST=1
  source "$(code --locate-shell-integration-path zsh)"
else
  unset VSCODE_CWD
fi

clean-env

# zstyle ':completion:*:warnings' format '%F{yellow}%d%f'

# dont override my variables, ya arse.
FIG_DOTFILES_SOURCED=1

whence _omz_compdump > /dev/null && _omz_compdump
# zprof

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

true
