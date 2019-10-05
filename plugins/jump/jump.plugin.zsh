# Easily jump around the file system by manually adding marks
# marks are stored as symbolic links in the directory $MARKPATH (default $HOME/.marks)
#
# jump FOO: jump to a mark named FOO
# mark FOO: create a mark named FOO
# unmark FOO: delete a mark
# marks: lists all marks
#
# This is a fork of https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/jump/jump.plugin.zsh
# which registers the marks as zsh static named directories
#
: ${MARKPATH:=$HOME/.marks}
export MARKPATH

: ${MARK_NOCONFIRM:=false}
: ${MARK_CREATENAMEDDIRS:=true}

if $MARK_CREATENAMEDDIRS; then
	# load all marks into hash
    () {
        setopt localoptions nullglob
        for d in $MARKPATH/*(@); do hash -d "${d##*/}=${d:A}"; done
    }
fi

jump() {
	cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
	$MARK_CREATENAMEDDIRS && echo $PWD
}

mark() {
	if [[ ( $# == 0 ) || ( "$1" == "." ) ]]; then
		MARK=$(basename "$PWD")
	else
		MARK="$1"
	fi
	if $MARK_NOCONFIRM || read -q \?"Mark $PWD as ${MARK}? (y/n) "; then
		mkdir -p "$MARKPATH"; ln -s "$PWD" "$MARKPATH/$MARK"
		if $MARK_CREATENAMEDDIRS; then
			hash -d "$MARK"="$PWD"
		fi
	fi
}

unmark() {
	local MARK
	local MARK_
	if (($# >= 1)); then MARK=$1; else
		for MARK_ in "$MARKPATH"/*(@); do if [[ "${MARK_:A}" == "${PWD:A}" ]] ; then MARK="${MARK_##*/}"; break; fi; done
	fi
	if [[ -z "$MARK" || ! -h "$MARKPATH/$MARK" ]]; then return 1; fi
	rm -i "$MARKPATH/$MARK"
	if $MARK_CREATENAMEDDIRS; then
		unhash -d "$MARK"
	fi
}

marks() {
	for link in $MARKPATH/*(@); do
		local markname="$fg[cyan]${link:t}$reset_color"
		local markpath="$fg[blue]$(readlink $link)$reset_color"
		printf "%s\t" $markname
		printf "-> %s \t\n" $markpath
	done
}

_completemarks() {
	if [[ $(ls "${MARKPATH}" | wc -l) -gt 1 ]]; then
		reply=($(ls $MARKPATH/**/*(-) | grep : | sed -E 's/(.*)\/([_a-zA-Z0-9\.\-]*):$/\2/g'))
	else
		if readlink -e "${MARKPATH}"/* &>/dev/null; then
			reply=($(ls "${MARKPATH}"))
		fi
	fi
}
compctl -K _completemarks jump
compctl -K _completemarks unmark

_mark_expansion() {
	setopt extendedglob
	autoload -U modify-current-argument
	modify-current-argument '$(readlink "$MARKPATH/$ARG")'
}
zle -N _mark_expansion
bindkey "^g" _mark_expansion
