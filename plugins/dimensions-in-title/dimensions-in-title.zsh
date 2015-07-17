
# TODO: use TRAPWINCH instead (trap window change)
# currenly conflicts with zsh-async

_dimensions_in_title_last_dimensions="$COLUMNS:$LINES"

_dimensions_in_title_print() {
  # tell the terminal we are setting the title
  print -Pn "\e]0;"

  if [[ "$COLUMNS:$LINES" != "${_dimensions_in_title_last_dimensions}" ]] ; then
    print -Pn "[$COLUMNS:$LINES] "
    _dimensions_in_title_debounce_time="$(( $(date +%s) + 1 ))"
    ( ( sleep 2; _dimensions_in_title_clear ) &)
  fi
  _dimensions_in_title_last_dimensions="$COLUMNS:$LINES"

  ### rest of the pure prompt's title

  # show hostname if connected through ssh
  [[ "$SSH_CONNECTION" != '' ]] && print -Pn "(%m) "

  # shows the full path in the title
  print -Pn "%~\a"
}

_dimensions_in_title_debounce_time=
_dimensions_in_title_clear() {
  if [[ -n "_dimensions_in_title_debounce_time" ]] && (( $(date +%s) > _dimensions_in_title_debounce_time )); then
    kill -WINCH $$
  fi
}

_dimensions_in_title_precmd() {
  trap "_dimensions_in_title_print" WINCH
  # trap "_dimensions_in_title_print" USR2
}
add-zsh-hook precmd _dimensions_in_title_precmd

# TMOUT=1
# TRAPALRM() {
#   _dimensions_in_title_print
# }
