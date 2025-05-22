#!/usr/bin/env zsh

set -euo pipefail

a=(${(@s/, /)${"$(~/.local/opt/sunwait/sunwait list angle 49.28N 123.12W)"}})
angle="$(python3 -c "from datetime import datetime as dt, timedelta as td; day_len=dt.strptime('${a[2]}', '%H:%M') - dt.strptime('${a[1]}', '%H:%M'); print(9*(day_len/td(1)-0.2)/0.4)")"
echo angle=$angle

brightness=0.4; if [[ $1 == rise ]]; then brightness=1; fi
~/.local/opt/sunwait/sunwait list angle $angle $1 49.28N 123.12W
~/.local/opt/sunwait/sunwait wait angle $angle $1 49.28N 123.12W || echo "setting $brightness now"
~/.local/bin/lunar displays external normalizedBrightness $brightness
if [[ $1 == rise ]]; then exit; fi
~/.local/opt/sunwait/sunwait wait $1 49.28N 123.12W || echo "setting 0.2 now"
~/.local/bin/lunar displays external normalizedBrightness 0.2
~/.local/opt/sunwait/sunwait wait civil $1 49.28N 123.12W || echo "setting 0.0 now"
~/.local/bin/lunar displays external normalizedBrightness 0
