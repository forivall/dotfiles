

alias ds='pushd'
alias dp='popd'
alias cd..="cd .."

local colored="$(tput setaf 7 2>/dev/null)"
local resetcolor="$(tput sgr0 2>/dev/null)"

# simple method to handle multiple cd customizations
function _next_cd() { _next_cd_false=1 ; }
function _next_cd_reset() { _next_cd_false=0 ; }
function _next_cd_test() { return ${_next_cd_false} ; }
_next_cd_false=1

if [[ -n "$ZSH_VERSION" ]] ; then
    function _multidot_cd() {
        # allow cd ... and such
        if [[ -n "$1" && "$1" =~ (^\\.+$) && (( "${#1}" > 2 )) ]] ; then
            local n
            local d
            n=${#1}
            for i in $(eval echo "{2..$n}") ; do
                d=$d"../"
            done
            echo $d 1>&2
            _real_cd "$d"
        else
            _next_cd "$@"
        fi
    }
else

function _multidot_cd() {
    # allow cd ... and such
    if [[ -n "$1" && "$1" =~ (^\.+$) && (( "${#1}" > 2 )) ]] ; then
        local n
        local d
        n=${#1}
        for i in $(eval echo "{2..$n}") ; do
            d=$d"../"
        done
        echo $d 1>&2
        _real_cd "$d"
    else
        _next_cd "$@"
    fi
}
fi

function _project_cd() {
  if [[ "$1" != "" ]]; then
    _next_cd "$@"
  else
    local PROJECT_ROOT
    local PACKAGE_ROOT
    PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
    [[ "$PROJECT_ROOT" == "$PWD" ]] && PROJECT_ROOT="$(cd ..; git rev-parse --show-toplevel 2>/dev/null)"
    _get_package_root

    if [[ -z "$PROJECT_ROOT" || (( ${PACKAGE_ROOT} > ${PROJECT_ROOT} )) ]]; then PROJECT_ROOT="$PACKAGE_ROOT" ; fi
    if [[ -e "$PROJECT_ROOT" ]]; then _real_cd "$PROJECT_ROOT" ; else _next_cd ; fi
  fi
}

function _get_package_root() {
  if [[ "$1" != "" ]]; then
    _next_cd "$@"
  else
    local d
    local r
    d="${PWD:h}"
    while [[ "$d" != "/" ]]; do
      r=("$d/"(package.json|Cargo.lock|pyproject.toml))
      if [[ -f "${r[1]}" ]]; then
        PACKAGE_ROOT="$d"
        break
      fi
      d="${d:h}"
    done
  fi
}

function _cd_to_file() {
    if (( "$#" == 1 )) && [[ -f "$1" ]]; then
        builtin cd "$(dirname "$1")"
    else
        _next_cd "$@"
    fi
}

function _real_cd() {
    builtin cd "$@"
    local exitcode=$?

    # if the new directory is a symlink, print the actual physical directory
    local REAL_PWD
    REAL_PWD=$(pwd -P)
    if [[ "$REAL_PWD" != $(pwd) ]]; then
        echo -n "${colored}${REAL_PWD}${resetcolor}" >&2
        echo >&2
        # echo " ('cd -P .' to go there)" >&2
    fi

    return $exitcode
}

function cd() {
    _next_cd_reset
    # echo d 1>&2

    _multidot_cd "$@"
    if _next_cd_test ; then return ; fi ; _next_cd_reset
    # echo c 1>&2

    _project_cd "$@"
    if _next_cd_test ; then return ; fi ; _next_cd_reset
    # echo b 1>&2

    _cd_to_file "$@"
    if _next_cd_test ; then return ; fi
    # echo a 1>&2

    # TODO: cd to zshmarks

    _real_cd "$@"
}

alias ...="cd ..."
alias ....="cd ...."
alias .....="cd ....."
alias ..2="cd ..."
alias ..3="cd ...."
alias ..4="cd ....."
alias ..5="cd ......"

# change worktree
function cwt() {
  local maintree gittoplevel
  gittoplevel=$(_call_program toplevel git rev-parse --show-toplevel 2>/dev/null)
  if maintree=$(git worktree list --porcelain | head -n1 | sd '^worktree ' '') ; then
    if (( $# == 0 )) && [[ "$gittoplevel" != "$maintree" ]]; then
      cd $maintree
      return
    fi
    local name=${1:-pr}
    local root=${maintree:h}/$name-worktrees/${maintree:t}
    if [[ ! -d $root ]] ; then
      local branch
      if (( $#>=2 )); then
        branch=$2
      elif branch=$(git symbolic-ref HEAD --short) ; then
        branch=$branch+$name
      fi
      if [[ -z $branch ]]; then
        git worktree add $root --detach
      else
        git worktree add $root -b $branch ||
        git worktree add $root $branch
      fi
    fi
    local prefix="$(git rev-parse --show-prefix)"
    while ! cd "$root/$prefix"; do prefix=${prefix:h}; [[ -z "$prefix" ]] && break; done;
  else
    echo 'not in git dir'
  fi

}

function _cwt() {
  local gittoplevel gittoplevelbasename maintree maintreebasename maintreedirname tmp ismain

  gittoplevel=$(_call_program toplevel git rev-parse --show-toplevel 2>/dev/null)
  gittoplevelbasename=${gittoplevel:t}

  local -a records=( ${(ps.\n\n.)"$(_call_program directories git worktree list --porcelain)"} )
  local -a directories descriptions
  local i hash branch
  ismain=true
  for i in $records; do
    tmp=${${i%%$'\n'*}#worktree }
    if $ismain; then
      ismain=false
      maintree=$tmp
      maintreebasename=${maintree:t}
      maintreedirname=${maintree:h}
    fi
    if [[ $tmp == $gittoplevel ]]; then continue; fi
    tmp=${tmp#$maintreedirname/}
    tmp=${tmp%/$maintreebasename}
    directories+=( ${tmp%-worktrees} )
    hash=${${${"${(f)i}"[2]}#HEAD }[1,9]}
    branch=${${"${(f)i}"[3]}#branch refs/heads/}

    # Simulate the non-porcelain output
    if [[ $branch == detached ]]; then
      # TODO: show a ref that points at $hash here, like vcs_info does?
      branch="(detached HEAD)"
    else
      branch="[$branch]"
    fi

    descriptions+=( "${directories[-1]}"$'\t'"$hash $branch" )
  done
  _wanted directories expl 'working tree' compadd -ld descriptions -S ' ' -f -M 'r:|/=* r:|=*' -a directories
}

compdef _cwt cwt
