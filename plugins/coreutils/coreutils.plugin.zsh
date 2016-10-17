# ls
alias ls="$(whence ls) --hide=\*~"
alias lsd="ls --group-directories-first"
alias sl="ls"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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


# whatever...
forever() { while eval "$@" || (echo "Exited Abnormally! Restarting in 1 second."; sleep 1); do : ; done; }

function sleep_until {
  seconds=$(( $(date -d "$*" +%s) - $(date +%s) )) # Use $* to eliminate need for quotes
  echo "Sleeping for $seconds seconds"
  sleep $seconds
}
