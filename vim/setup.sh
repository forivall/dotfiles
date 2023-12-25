#!/usr/bin/env zsh

__dirname=${0:A:h}

if ${USE_GNU_LN:-false} && type gln; then
  ln() { gln "$@"; }
fi

o() {
  echo "$@"
  "$@"
}

o ln -Ffs -T "$(realpath vim)" ~/.config/nvim
o ln -Ffs -T "$(realpath vim)" ~/.vim
o ln -fs "$(realpath vim/init.vim)" ~/.vimrc

o curl -fLo $__dirname/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall
