#!/usr/bin/env zsh

__dirname=${0:A:h}

o() {
  echo "$@"
  "$@"
}

o ln -TFfs "$(realpath vim)" ~/.config/nvim
o ln -TFfs "$(realpath vim)" ~/.vim
o ln -fs "$(realpath vim/init.vim)" ~/.vimrc

o curl -fLo $__dirname/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall
