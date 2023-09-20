#!/usr/bin/env zsh

__dirname=${0:A:h}

if $IS_OSX; then
  path+=(~/Library/Python/3.10/bin)
fi

poetry completions zsh > $__dirname/_poetry
pdm completion > $__dirname/_pdm

curl -L https://raw.githubusercontent.com/mkoskar/pyenv/nicer-zsh-completion/completions/pyenv.zsh > $__dirname/_pyenv
echo _pyenv >> $__dirname/_pyenv

pyenv init - > $__dirname/pyenv-init.sh
