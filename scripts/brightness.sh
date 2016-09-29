xrandr --output eDP1 --set Backlight $(( $(xrandr --props|grep Backlight:|cut -d' ' -f2) + $1 ))
