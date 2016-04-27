__zsh_unsorted_plugin_location=$0:A
__zsh_unsorted_plugin_location=${__zsh_oneliner_plugin_location%/*}

autoload -U clean-env
autoload -U shcat

#alias res="echo -en \"\ec\e[3J\""
alias res="echo -n '$(tput reset)'"

if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] ; then
    alias res="echo -n '$(tput reset)' && osascript -e 'tell application \"System Events\" to keystroke \"k\" using {option down, command down}'"
fi

type xclip > /dev/null && alias clip="xclip -selection c"

# shellcheck disable=SC2059
condalias() {
    if [[ -e "$2" ]]; then
        alias "$(printf "$1" "$2")"
    fi
}

condalias markdown_py="%s -x def_list -x abbr" "/usr/bin/markdown_py"

alias scat="source-highlight -fesc -o STDOUT -i"
function scat2() { source-highlight -fesc "$@" -o STDOUT; }

unfunction condalias

### open

function _prompt () {
    if [ -n "${ZSH_VERSION+x}" ] ; then
        read "?'$1' doesn't exist. Make a new file? [Y/n] " response
    else
        read -r -p "'$1' doesn't exist. Make a new file? [Y/n] " response
    fi
    if [[ $response =~ ^([nN][oO]|[nN])$ ]] ; then false ; else true ; fi ;
}

if [[ "$OSTYPE" == darwin* ]] ; then : ; else

__DESKTOP_OPEN=gnome-open
if [[ "$KDE_SESSION_UID" != "" ]]; then
    __DESKTOP_OPEN=xdg-open
fi

function open() {
    for varg in "$@"
    do
        if [[ ! "$varg" =~ ^\S+\:\/\/ ]] &&
            [[ ! -e "$varg" ]] &&
            _prompt "$varg" ; then touch "$varg" ; fi
        ${__DESKTOP_OPEN} "$varg" 2>/dev/null ;
    done
}
fi

function new_note.sh() {
    filename=`date +%Y-%m-%d`.${1-"mkd"}
    touch "$filename" ; open "$filename" ;
}

function markdown_py_auto {
    filename=$(basename "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"
    if [[ $extension =~ ^(mkd|markdown|md)$ ]]
    then fullfile=$1
    else if [[ -e "$filename.markdown" ]] ; then fullfile="$filename.markdown"
    else if [[ -e "$filename.mkd" ]] ; then fullfile="$filename.mkd"
    else if [[ -e "$filename.md" ]] ; then fullfile="$filename.md"
    else echo "File does not exist"; return
    fi ; fi ; fi ; fi
    markdown_py "$fullfile" -f "$filename.html"
    gnome-open "$filename.html"
}


function git-grep-gedit-open {
OIFS=$IFS;
IFS='
'
for a in $(git grep $@); do gedit-open "${a%:*}"; done;
IFS=$OIFS
}

function grepdiff {
diff --old-line-format='%l
' --new-line-format='%l
' --old-group-format='-
%<' --new-group-format='+
%>' --changed-group-format='-
%<+
%>' --unchanged-group-format='' "$@"
}

function history_search {
    local root;
    root="$(cd $__zsh_unsorted_plugin_location; git rev-parse --show-toplevel)"
    (
    (cd $root; git log --reverse -p -S"$1" zsh_history_interactive) |
        grep '^-' | sed 's/^-//';
    history -a;) | grep --color=always "$1" | uniq
}

__cheat_has_opt () {
    for word in $@; do
        if [[ "$word" == -* ]]; then
            return 0;
        fi;
    done
    return 1
}

cheat() {
    if ! __cheat_has_opt "$@" ; then
        /usr/local/bin/cheat "$@" | most
    else
        /usr/local/bin/cheat "$@"
    fi
}

alias klogout="qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 -1 -1"
