#!/usr/bin/env zsh

__dirname=${0:A:h}

if $IS_OSX; then
  path+=(~/Library/Python/3.14/bin)
fi

function generate_completions() {
  if (( ${+commands[$1]} )); then
    local compfile="${__dirname}/_$1"
    echo "Generating completion for $1..." >&2
    $@ > $compfile
  else
    echo "Command $1 not found. Completions not generated" >&2
  fi
}

generate_completions poetry completions zsh
generate_completions pdm completion
generate_completions jc --zsh-comp

curl -L https://raw.githubusercontent.com/mkoskar/pyenv/nicer-zsh-completion/completions/pyenv.zsh > "$__dirname/_pyenv"
echo _pyenv >> "$__dirname/_pyenv"

pyenv init - > "$__dirname/pyenv-init.sh"
sd 'command pyenv rehash' '# $1' "$__dirname/pyenv-init.sh"

