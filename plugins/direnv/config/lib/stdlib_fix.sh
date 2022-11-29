# fix the "what manpage do you want" message when manpath is unsets
MANPATH_add() {
  local old_paths="${MANPATH:-$(man -w 2>/dev/null)}"
  local dir
  dir=$(expand_path "$1")
  export "MANPATH=$dir:$old_paths"
}
