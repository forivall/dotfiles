#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

outfile="${__dirname}/wttr.bash"
echo -n Downloading wttr.bash... >&2
curl -sL https://wttr.in/:bash.function | sd '\bcommand shift\b' '[[ "$#" != 0 ]] && shift' > $outfile
echo ' Done.' >&2
