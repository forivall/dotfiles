# NOTE: i doubt this compdef works, I just have this file source'd from
# my zshrc
##compdef -p git

_git-branch-archive() { _arguments ':branch-name:__git_branch_names' }
_git-gerrit-query() { _arguments ':branch-name:__git_commits' ; }
_git-genco () { _arguments ':branch-name:__git_commits' ; }
_git-genpatch () { _arguments ':branch-name:__git_commits' ; }

__git_has_doubledash () {
    for word in $words; do
        if [ "--" = "$word" ]; then
            return 0;
        fi;
    done
    return 1
}

_git-diffuse () {
    # _alternative 'commits::__git_commits' 'tags::__git_tags' 'trees::__git_trees' 'blobs::__git_blobs'
    if __git_has_doubledash ; then _files; return ; fi
    _arguments ':branch-name:__git_commits'
}
_git-subl-modified () { _git-diffuse ; }

_git-ls-recent-branches () { _arguments -C \
    '(-n -c -r -k)-n[Number of lines to display]' \
    {-c,--commit}'-[List recently committed branches]' \
    {-r,--creation}'-[List recently created branches]' \
    {-k,--checkout}'-[List recently checked out branches]'
}

# __git_extras_workflow_open () { __gitcomp "$(__git_heads | grep ^$1/ | sed s/^$1\\///g)"; }
_git-open-bug() { _arguments -C ':branch-name:__git_bug_branch_names'}

local comp="$(zstyle -L ':completion:*:*:git:*')"
if (( ${#comp} < 1 )) ; then comp="zstyle ':completion:*:*:git:*'"; fi
# echo ${#comp}
# echo $comp
local autocomps="$(for i in ${${(k)commands[(I)git-*]}#git-} ; do echo -n "'"$(echo $i|sed s/\'/"'\\\\''"/)"' " ; done)"
# autocomps=$(echo $autocomps|tr '()' ' ')
comp="$comp $autocomps \
    branch-archive:'archive a branch via tag archive/<branch-name><date junk to keep unique>' \
    open-bug:'open a bug in mantis' \
    genco:'generate eco for current feature branch' \
    genpatch:'generate patch.xml for current feature branch'\
    gerrit-query:'query gerrit details of commit' \
    age:'blame viewer' \
    diffuse:'diff viewer' \
    prepare-eco:'squash tool' \
    review-merge:'post-squash tool' \
    ls-recent-branches:'display recently accessed/checked out/created branches' \
    "
# echo $comp
# echo $autocomps
eval $comp
