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
        env $(whence grep) -n "$@" <&0
    else
        # echo 'piping'
        # shellcheck disable=SC2046
        env $(whence grep) "$@" <&0
    fi
}

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

# diff
function diff { colordiff -u "$@" | most ; }
alias diff_=/usr/bin/diff

# # find
# cleanup() { find -name __tmp; }
# cleanup-run() { find -name __tmp -exec /usr/bin/rm -r ';' ; }

if [[ "$OS" == "Windows_NT" || -n "$CYGWIN_VERSION" ]]; then
  # alias lnd="/cygdrive/c/Program Files/MSysGit/bin/ln"
  __coreutils_pathopts() {
    local argname=$1
    local optstmp
    local optval
    local optconverted
    optstmp=()
    shift
    for i in {1..$#}; do
        optval=${(P)i}
        optconverted=$optval
        if [[ "$optval[1]" != "-" ]] ; then
            optconverted="$(cygpath -w "$optval"|sed 's/\\/\\\\/g')"
        fi
        eval ${argname}+=${(q)optconverted}
    done
  }
  if [[ -e "/cygdrive/c/Program Files/MSysGit/bin/ln" ]]; then
      lnd() {
          local opts
          opts=()
          __coreutils_pathopts opts "$@"
          echo "$opts"
          "/cygdrive/c/Program Files/MSysGit/bin/ln" $opts
      }
      lndsu() {
          local opts
          opts=()
          __coreutils_pathopts opts "$@"
          echo "$opts"
          sudo "/cygdrive/c/Program Files/MSysGit/bin/ln" $opts
      }
  fi
fi


# whatever...
forever() { while eval "$@" || (echo "Exited Abnormally! Restarting in 1 second."; sleep 1); do : ; done; }
