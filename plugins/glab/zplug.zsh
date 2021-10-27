#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

local compfile="${__dirname}/_glab"
echo "Generating completion for glab..." >&2
glab completion -s zsh > $compfile
[[ -f "${ZGEN_INIT}" ]] && echo 'You should run `zgen reset` to ensure that zcompdump get rebuilt'
