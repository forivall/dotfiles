# ls
if whence exa > /dev/null ; then
  alias ls="exa --group-directories-first -F --color=auto"
  alias li="exa --group-directories-first -F --color=auto --icons"
  alias ll="exa -alF --icons"
  alias la="exa -a --icons"
  alias l="exa -F"
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

# sed
autoload -U sedml

# du
function jsdu() { du -Sah --apparent-size "$@" | grep "\\.js" | sort -h ; }
function jsduK() { du -SaBK --apparent-size "$@" | grep "\\.js" | sort -n ; }

# mkdir
function mkcd() { mkdir -p "$@" ; cd "$@" ; }

# man
function --a() { ( ( "$@" > /dev/null 2>&1 ) & ) ; }
if type yelp >/dev/null ; then
  function gman() { --a yelp "man:$1" ; }
elif [[ -d /Applications/Preview.app ]] ; then
  gman() {
    man -t "$@" | open -f -a /Applications/Preview.app/
  }
elif [[ -d /System/Applications/Preview.app ]] ; then
  gman() {
    man -t "$@" | open -f -a /System/Applications/Preview.app/
  }
fi

# touch
function touche {
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
function diff { colordiff -u "$@" | most ; }
alias diff_=/usr/bin/diff

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
    local echoopts; echoopts=()
    for i in {1..$#}; do
      echoopts[$i]="${opts[$i]}"
      if [[ "${(P)i}" == '/'* || "${(P)i}" == '.'* ]]; then
        echoopts[$i]=\""${opts[$i]}"\"
      fi
    done
    echo mklink "$echoopts"
    env cmd '/D' '/C' mklink "$opts[@]"
  }
  mklinksu() {
    local opts; opts=(); cygpath-w-convert-args opts --winargs "$@"
    # for i in {1..${#opts}}; do opts[$i]=${opts[$i]// /\\\\ }; done
    local echoopts; echoopts=()
    for i in {1..$#}; do
      echoopts[$i]="${opts[$i]}"
      if [[ "${(P)i}" == '/'* || "${(P)i}" == '.'* ]]; then
        echoopts[$i]=\""${opts[$i]}"\"
      fi
    done
    echo mklink "$echoopts[@]"
    $(whence sudo) env cmd '/D' '/C' mklink "$echoopts[@]" '&' 'set' '/p' 'enter="Press enter to exit"'
  }
  # cmd() {
  #   local opts; opts=(); cygpath-w-convert-args opts --winargs --rel "$@"
  #   # echo cmd "$opts"
  #   # echo ${(F)opts}
  #   env cmd "$opts[@]"
  # }
fi

# https://wiki.archlinux.org/index.php/Zsh#Help_command
autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk
unalias run-help 2> /dev/null || true
alias help=run-help
