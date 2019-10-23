#!/bin/sh

real_path="`/usr/local/bin/greadlink -f "${1:-$PWD}"`"

osascript -e "
tell application \"iTerm2\"
  tell current window
    create tab with default profile
    delay 0.2
    set pathwithSpaces to \"$real_path\"
    tell current session
      write text \"cd \" & quoted form of pathwithSpaces & \"; tput reset\"
    end tell
  end tell
end tell
"
