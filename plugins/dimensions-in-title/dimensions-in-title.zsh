
# TODO: use TRAPWINCH instead (trap window change)
# currenly conflicts with zsh-async
TMOUT=1

__columns_in_title_last_dimensions="$COLUMNS:$LINES"

TRAPALRM() {
  # tell the terminal we are setting the title
  print -Pn "\e]0;"

  [[ "$COLUMNS:$LINES" != "${__columns_in_title_last_dimensions}" ]] && print -Pn "[$COLUMNS:$LINES] "
  __columns_in_title_last_dimensions="$COLUMNS:$LINES"

  ### rest of the pure prompt's title

  # show hostname if connected through ssh
  [[ "$SSH_CONNECTION" != '' ]] && print -Pn "(%m) "

  # shows the full path in the title
  print -Pn "%~\a"
}
