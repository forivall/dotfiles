#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

local compfile="${__dirname}/_lab"
echo "Generating completion for lab..." >&2
lab completion zsh > $compfile
[[ -f "${ZGEN_INIT}" ]] && echo 'You should run `zgen reset` to ensure that zcompdump get rebuilt'
