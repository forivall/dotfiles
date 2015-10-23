#!/usr/bin/env bash
cd "$(dirname "$0")"

# TODO: use gnu stow
# http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html?round=two

if ! whence realpath >/dev/null ; then
  realpath() { readlink -f "$@"}
fi

git submodule update --init
ln -fs "$(realpath zshrc)" ~/.zshrc
ln -fs "$(realpath zsh_history_interactive)" ~/.zsh_history_interactive


if [[ ! -d ~/.vim ]] ; then
  curl -Lo- https://bit.ly/janus-bootstrap | bash
fi

ln -fs "$(realpath jshintrc)" ~/.jshintrc
ln -fs "$(realpath gitconfig)" ~/.gitconfig
ln -fs "$(realpath gitignore)" ~/.gitignore
ln -fs "$(realpath hgrc)" ~/.hgrc
ln -fs "$(realpath vimrc.after)" ~/.vimrc.after
ln -fs "$(realpath pythonhist)" ~/.pythonhist

ln -fs "$(realpath colordiffrc)" ~/.colordiffrc

ln -fs "$(realpath bash/bash_completion)" ~/.bash_completion
ln -fs "$(realpath bash/bash_completion.d)" ~/.bash_completion.d

if [[ -n "$BABUN_HOME" ]]; then
    BINPATH="$(cygpath "$HOMEPATH")/.local/bin"
    mkdir -p "$BINPATH"
    if [[ ! -e "$BINPATH/recycle.exe" ]] ; then
        curl -OL http://www.maddogsw.com/cmdutils/cmdutils.zip
        unzip cmdutils.zip -d cmdutils
        cp cmdutils/Recycle.exe "$BINPATH/recycle.exe"
    fi
fi
