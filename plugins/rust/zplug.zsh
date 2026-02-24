#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

function generate_completions() {
  if (( ${+commands[$1]} )); then
    local compfile="${__dirname}/_$1"
    echo "Generating completion for $1..." >&2
    $@ > $compfile
  else
    echo "Command $1 not found. Completions not generated" >&2
  fi
}
generate_completions rustup completions zsh
generate_completions srgn --completions zsh
generate_completions dua completions zsh
generate_completions mcat --generate zsh
COMPLETE=zsh generate_completions treemd
[[ -f _treemd ]] && sd --fixed-strings 'compdef _clap_dynamic_completer_treemd treemd
' 'if [ "$funcstack[1]" = "_treemd" ]; then
    _clap_dynamic_completer_treemd "$@"
else
    compdef _clap_dynamic_completer_treemd treemd
fi' _treemd

tv init zsh > ${__dirname}/tv-init.zsh
intelli-shell init zsh > ${__dirname}/intelli-shell-init.zsh
patch -p3 -f -i tv-init.patch

[[ -f "${ZGEN_INIT}" ]] && echo 'You should run `zgen reset` to ensure that zcompdump get rebuilt'

broot --set-install-state installed
broot --print-shell-function zsh > $__dirname/broot.source.zsh

(( ${+commands[procs]} )) && (cd  $__dirname && procs --gen-completion zsh)
