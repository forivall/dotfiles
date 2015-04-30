#!/usr/bin/env bash
# This file defines a couple of git aliases and bash completions for a number
# of git scripts


alias gl='git l'
alias gla='git la'
alias gps='git push'
alias gp='git pull'

alias git-blameview="perl /usr/share/doc/git/contrib/blameview/blameview.perl"
# alias git-new-workdir="sh /usr/share/doc/git/contrib/workdir/git-new-workdir"
alias git-new-workdir="/usr/share/git/workdir/git-new-workdir"
# alias gitview="python /usr/share/doc/git/contrib/gitview/gitview"
alias gitview="/usr/share/git/gitview/gitview"

alias g=git
alias ge="git each"
alias gr="git r"
alias grg="git r git"
alias gst="git st"
alias gitify=gitify_node_module
alias glg="git l3"
alias glga="git l3 --all"
alias glgs="git l3 --stat"
alias glgas="git l3 --all --stat"
alias gti="git"

# t is in a terrible place in querty, and I often hit space first
# TODO: switch keyboard layouts.
function gi() {
    local firstarg
    firstarg=$1
    if [[ "${firstarg}" == t* ]] ; then
        shift
        git "${firstarg:1}" "$@"
        return $?
    else
        env gi "$@"
        return $?
    fi
}

function ___git_indent_helper() {
    "$@" 2>/dev/null | (whitespace="↳ "; while read l; do echo "$whitespace$l"; whitespace="  "; done)
}

___git_ran_once=n
function git() { # also put these in git-aliases for autocomplete
    local a;
    if [[ $___git_ran_once = n ]] ; then
        ___git_ran_once=y
        echo Running ssh-add
        if ! ssh-add -l ; then
          echo Running ssh-add
          ssh-add
        fi
    fi
    case "$1" in
        age) shift; ~/code/git-repos/git-age/git-age $@;;
        diff) shift; if [[ "$1" == '--name-status' || "$1" == '--name-only' ]] ; then /usr/bin/env git --no-pager diff $@ ; else /usr/bin/env git diff $@ ; fi;;
        grep-gedit-open) shift; git-grep-gedit-open $@;;
        blameall) shift; ~/code/git-blameall.py $@;;
        stashed) shift; git stash save && /usr/bin/env git "$@" && git stash pop;;
        checkout|cherry-pick|commit|fetch|merge|pull|push) /usr/bin/env git "$@" && ___git_indent_helper git st --no-files; echo  ;;
        # diffuse) shift; ~/scripts/git-diffuse "$@";;
        *) /usr/bin/env git "$@";;
    esac
}

_git-stashed() {
    _git "$@"
}

if [[ -n "$BASH_VERSION" ]] ; then

#hacky tweak to get my favorite plumbing commands into git bash completion
source /usr/share/bash-completion/completions/git
__git_compute_porcelain_commands
__git_porcelain_commands="$__git_porcelain_commands
ls-files
rev-list
rev-parse
show-ref
show-index"


# git completion functions for my aliases & scripts
_git_branch_archive ()
{ # based on _git_branch
    __gitcomp_nl "$(__git_heads)"
}

_git_gerrit_query () { __gitcomp_nl "$(__git_heads)" "" "$cur" "" ; }

_git_genco () { __git_complete_revlist_file ; }
_git_genpatch () { __git_complete_revlist_file ; }

_git_diffuse ()
{ # based on _git_diff
    __git_has_doubledash && return
    __git_complete_revlist_file
}
_git_subl_modified () { _git_diffuse ; }

__git_extras_workflow_open () { __gitcomp "$(__git_heads | grep "^$1/" | sed "s/^$1\\///g")"; }
_git_open_bug () { __git_extras_workflow_open "bug"; }

if [[ -s /usr/share/git/completion/git-completion.bash ]] ; then
    source /usr/share/git/completion/git-completion.bash
fi

fi

## aliases

ggjs() { gg "$@" -- '*.js' ; }
ggcs() { gg "$@" -- '*.coffee' ; }
ggb() {
    if (( $# < 1 )) ; then gg "$@" ; return 255; fi
    local arg1="$1"
    shift
    gg -I '\b'"$arg1"'\b' "$@" ;
}


git-get-logrefs() { git for-each-ref --format='%(refname)' refs/** | grep -E -v '(heads|remotes/[^/]+)/gh-pages|refs/stash' ; }

function git-on-that-day {
    local all; if [[ $1 == '--all' ]] ; then all=$1 ; shift ; fi
    local a; a="$1"; shift;
    local b; b="$1"; shift;
    git-on-this-day $all "$a $b" "$a $(( $b + 1 ))" "$@"
}
function git-on-this-day {
    local author
    author='--author=jordan'
    if [[ $1 == '--all' ]] ; then author= ; shift ; fi
    local a; a="$1"; shift;
    local b; b="$1"; shift;
    local until_; until_="$([[ -n "$b" ]] && echo "$b" || echo "$a")";
    local dirname
    for d in */.git ; do
      dirname="${d%.git}"
      l="$(cd "$dirname"; git --no-pager -c color=always l3 --all --since "$a" --until "$until_" "$author" "$@")"  # "
      (( $? > 0 )) || (( $(echo -n "$l"|wc -l) > 0 )) && (echo; echo "${d%/.git}"; echo "$l")
    done
}

source "$(dirname "$0")/completions.zsh"
source "$(dirname "$0")/gitify.zsh"
