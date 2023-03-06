# fix the "what manpage do you want" message when manpath is unsets
MANPATH_add() {
  local old_paths="${MANPATH:-$(manpath)}"
  local dir
  dir=$(expand_path "$1")
  export MANPATH="$dir${MANPATH+:$MANPATH}:"
}
