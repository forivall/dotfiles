#!/usr/bin/env zsh
__zsh_coreutils_plugin_location=${0:A:h}

__zsh_coreutils_plugin_real_sl=$(whence -p sl)
__fix_sl() {
  path=($__zsh_coreutils_plugin_location/bin $path);
  sd ' /[a-z/]+/sl' ' '$__zsh_coreutils_plugin_real_sl $__zsh_coreutils_plugin_location/bin/sl
}

path=($__zsh_coreutils_plugin_location/bin $path);

export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 3) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 5; tput setab 0) # purple on black
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)
# export GROFF_NO_SGR=1

# ls
if whence eza > /dev/null ; then
  alias ls="eza --group-directories-first -F --color=auto"
  alias li="eza --group-directories-first -F --color=auto --icons=auto"
  alias ll="eza -alF --icons"
  alias la="eza -a --icons=auto"
  alias l="eza -F"
else
  alias ls="$(whence ls) --group-directories-first -F --color=auto --hide=\*~ "
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
fi
# use https://github.com/chmln/sl instead
# alias sl="ls"

# grep
export GREP_COLORS='ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36:ne'
# shellcheck disable=SC2139
alias grep="$(whence grep) -I"
# shellcheck disable=SC2139
alias grepi="$(whence grep) -i"
function grep() {
  if [ -t 0 ] ; then
    # TODO: don't use -n for -o
    # shellcheck disable=SC2046
    if [ "$1" = --no-n ] ; then
      shift
      env $(whence grep) "$@" <&0
    else
      env $(whence grep) -n "$@" <&0
    fi
  else
    # echo 'piping'
    # shellcheck disable=SC2046
    env $(whence grep) "$@" <&0
  fi
}

function grepr() {
  local dir="$1"
  shift
  grep "$@" -r "$dir"
}

alias rgb=batgrep
alias bam=batman
(( ${+commands[qman]} )) && alias mqn=qman
[[ -x ~pubrepos/qman/build/src/qman ]] && alias qman="~pubrepos/qman/build/src/qman --config=${__zsh_coreutils_plugin_location:h:h}/config/qman/qman.conf"

# sed
autoload -U sedml

alias no-trailing-nl "sd '\n$' ''"

# du
function jsdu() { du -Sah --apparent-size "$@" | grep "\\.js" | sort -h ; }
function jsduK() { du -SaBK --apparent-size "$@" | grep "\\.js" | sort -n ; }

# mkdir
function mkcd() { mkdir -p "$@" ; cd "$@" ; }

# man
function --a() { ( ( "$@" > /dev/null 2>&1 ) & ) ; }
if type yelp >/dev/null ; then
  function gman() {
    local manpage=$1
    shift
    --a yelp "man:$manpage" $@;
  }
elif [[ -d /Applications/Preview.app || -d /System/Applications/Preview.app ]] ; then
  gman() {
    local preview_app
    preview_app=/System/Applications/Preview.app
    [[ -d /Applications/Preview.app ]] && preview_app=/Applications/Preview.app
    [[ -d /Applications/Skim.app ]] && preview_app=/Applications/Skim.app

    local mantmp
    local target
    target="$(man -w "$@")" || return
    mantmp="$(mktemp -d)/${target:t}"
    if type groff > /dev/null; then
      < "$target" tbl | groff -m mandoc -c -Tps -dpaper=legal -P-plegal -f H > "$mantmp.ps" || return
    else
      man -t "$@" > "$mantmp.ps" || return
    fi
    # if dark mode

    # gs -o "${mantmp} (dark).pdf" \
    #   -sDEVICE=pdfwrite  \
    #   -c "{1 exch sub}{1 exch sub}{1 exch sub}{1 exch sub} setcolortransfer" \
    #   -f "${mantmp}.pdf"

    # mutool draw -G 1.4 -I -o "${mantmp} (dark).pdf" "${mantmp}.pdf"

    # curl -OL https://github.com/acid1103/PDFInverter/releases/download/0.2.0/PDFInverter.jar
    # java -jar $__zsh_coreutils_plugin_location/PDFInverter.jar "${mantmp}.pdf" "${mantmp} (dark).pdf" "#AAAAAA"
    ps2pdf "$mantmp"{.ps,.pdf}
    if type exiftool > /dev/null; then
      exiftool -quiet -Title="man $*" "${mantmp}.pdf"
    fi
    open -a $preview_app "$mantmp.pdf"
  }
fi
compdef gcp=cp
compdef gmv=mv
compdef gman=man
man() {
  if (( COLUMNS > 120 )); then
    MANPAGER="moor --no-linenumbers" MANWIDTH=120 command man "$@"
  else
    MANPAGER="moor --no-linenumbers" command man "$@"
  fi
}

# touch
function touche() {
  typeset -a files args
  files=()
  args=("$@")
  rest=0
  for r in $args ; do
    if (( rest )); then files+=("$r")
    elif [[ "$r" == "--" ]] ; then
      rest=1
    elif [[ "$r" != -* ]]; then
      files+=("$r")
    fi
  done
  for f in $files ; do if [[ "$f" == */* ]] ; then
    mkdir -p "${f%/*}"
  fi; done
  touch "$@"
}

# diff
if (( ${+aliases[diff]} )); then
  unalias diff;
fi
if (( ${+function[diff]} )); then
  unfunction diff;
fi

if ! (( ${+commands[colordiff]} )); then
  if command diff --color /dev/null{,} &>/dev/null; then
    alias colordiff="diff --color"
  fi
fi

function diff() {
  local args=()
  local usepager=false
  local usecolor=false
  local unified=true
  local checksame=true
  if [[ -t 1 ]]; then
    usepager=true
    usecolor=true
  fi
  for arg in "$@"; do
    if [[ $arg == --help ]] || [[ $arg == -h ]]; then
      command diff "$@"
      return $?
    elif [[ $arg == --no-pager ]]; then
      usepager=false
    elif [[ $arg == --no-color ]]; then
      usecolor=false
    elif [[ $arg == --no-unified ]]; then
      unified=false
    else
      args+=($arg)
    fi
    if [[ $arg == /dev/fd/* ]]; then
      checksame=false
    fi
  done
  local differ=true
  if $checksame && command diff -q "${args[@]}" > /dev/null; then
    differ=false
    echo "Files have the same contents"
  fi
  if $differ; then
    local diffcommand=(command diff)
    if $usecolor; then
      diffcommand=(colordiff)
    fi
    if $unified; then
      diffcommand+=(-u)
    fi
    if $usepager; then
      "${diffcommand[@]}" "${args[@]}" | less -f +X -x2 -R
    else
      "${diffcommand[@]}" "${args[@]}"
    fi
  fi
}
alias diff_="command diff"
function delta() {
  local deltaOpts=()
  if (( ${+commands[dark-mode]} )) && [[ $(dark-mode status) == off ]]; then
    deltaOpts+=(--light --syntax-theme ${DELTA_LIGHT_THEME:-GitHub})
  fi
  command delta "${deltaOpts[@]}" $@
}

# # find
# cleanup() { find -name __tmp; }
# cleanup-run() { find -name __tmp -exec /usr/bin/rm -r ';' ; }

if [[ "$OS" == "Windows_NT" || -n "$CYGWIN_VERSION" ]]; then
  # alias lnd="/cygdrive/c/Program Files/MSysGit/bin/ln"
  autoload -U cygpath-w-convert-args
  if [[ -e "/cygdrive/c/Program Files/MSysGit/bin/ln" ]]; then
      lnd() {
          local opts
          opts=()
          cygpath-w-convert-args opts "$@"
          echo "$opts[@]"
          "/cygdrive/c/Program Files/MSysGit/bin/ln" "$opts[@]"
      }
      lndsu() {
          local opts
          opts=()
          cygpath-w-convert-args opts "/cygdrive/c/Program Files/MSysGit/bin/ln" "$@"
          echo "$opts[@]"
          $(whence sudo) "$opts[@]"
      }
  fi
  mklink() {
    local opts; opts=(); cygpath-w-convert-args opts --winargs "$@"
    # for i in {1..${#opts}}; do opts[$i]=${opts[$i]// /\\\\ }; done

    # # this construction breaks vscode-shellcheck
    # local echoopts; echoopts=()
    # for i in {1..$#}; do
    #   echoopts[$i]="${opts[$i]}"
    #   if [[ "${(P)i}" == '/'* || "${(P)i}" == '.'* ]]; then
    #     echoopts[$i]=\""${opts[$i]}"\"
    #   fi
    # done
    # echo mklink "$echoopts"
    env cmd '/D' '/C' mklink "${opts[@]}"
  }
  mklinksu() {
    local opts; opts=(); cygpath-w-convert-args opts --winargs "$@"
    # for i in {1..${#opts}}; do opts[$i]=${opts[$i]// /\\\\ }; done

    # # this construction breaks vscode-shellcheck
    # local echoopts; echoopts=()
    # for i in {1..$#}; do
    #   echoopts[i]="${opts[i]}"
    #   if [[ "${(P)i}" == '/'* || "${(P)i}" == '.'* ]]; then
    #     echoopts[$i]=\""${opts[$i]}"\"
    #   fi
    # done
    # echo mklink "$echoopts[@]"
    $(whence sudo) env cmd '/D' '/C' mklink "${opts[@]}" '&' 'set' '/p' 'enter="Press enter to exit"'
  }
  # cmd() {
  #   local opts; opts=(); cygpath-w-convert-args opts --winargs --rel "$@"
  #   # echo cmd "$opts"
  #   # echo ${(F)opts}
  #   env cmd "$opts[@]"
  # }
fi

# cp/mv

CLIPBOARD_FILE=~/.config/.pseudo-clipboard

# mark the file(s) for later use with cp or mv
xm() {
  if [[ $1 == -c ]]; then
    printf '' > $CLIPBOARD_FILE
    return
  fi
  if [[ $1 == -p ]]; then
    cat $CLIPBOARD_FILE
    return
  fi
  if [[ $1 == -- ]]; then
    shift
  fi
  for f in "$@"; do
    realpath "$f" >> "$CLIPBOARD_FILE"
  done
}

# copy the marked files
xcp() {
  if ! [[ -s $CLIPBOARD_FILE ]]; then
    echo No files marked! use \`xm\` to mark files
    return 1
  fi

  local files dest flags
  while read line; do
    files+=("$line")
  done < "$CLIPBOARD_FILE"
  flags=()
  dest=()
  for opt in "$@"; do
    case "$opt" in
      -*) flags+=("$opt"); shift;;
      --) dest+=("$@"); break;;
      *) dest+=("$opt"); shift;;
    esac
  done
  if (( ${#dest} <= 0 )); then
    dest+=(.)
  fi
  echo cp $flags $files $dest
  cp $flags $files $dest
}

# move the marked files
xmv() {
  local files dest
  while read line; do
    files+=("$line")
  done < "$CLIPBOARD_FILE"
  dest=("$@")
  if (( ${#dest} <= 0 )); then
    dest+=(.)
  fi
  echo mv $files $dest
  mv $files $dest
  printf '' > $CLIPBOARD_FILE
}

prunedir() {
  local d=$1
  while [[ -n "$d" ]] && rmdir $d; do
    d=${d%/*}
  done
}

# ps
pcmd() {
  ps -o command $@ | tail +2
}
compdef pcmd=ps

# https://wiki.archlinux.org/index.php/Zsh#Help_command
autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk
unalias run-help 2> /dev/null || true
alias help=run-help

autoload -Uz _xargs_better_completion
autoload -Uz _xargs_command_arguments
compdef _xargs_better_completion xargs
