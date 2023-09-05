#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

mkdir -p bin

curl -sOL https://gitlab.gnome.org/GNOME/vte/-/raw/master/perf/256test.sh
mv "256test.sh" bin
chmod +x bin/256test.sh
sed -i 's|#!/usr/bin/env bash|#!/usr/bin/env zsh|' bin/256test.sh
