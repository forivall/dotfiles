#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

function generate_completions() {
  local compfile="${__dirname}/_$1"
  echo "Generating completion for $1..." >&2
  $@ > $compfile
}
generate_completions rustup completions zsh
generate_completions srgn --completions zsh
tv init zsh > ${__dirname}/tv-init.zsh
patch -p3 -f -i tv-init.patch

[[ -f "${ZGEN_INIT}" ]] && echo 'You should run `zgen reset` to ensure that zcompdump get rebuilt'

broot --set-install-state installed
broot --print-shell-function zsh > $__dirname/broot.source.zsh

(( ${+commands[procs]} )) && (cd  $__dirname && procs --gen-completion zsh)
