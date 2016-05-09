#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || exit

# TODO: use gnu stow
# http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html?round=two

if ! type realpath >/dev/null ; then
  if ! type grealpath >/dev/null ; then
    realpath() { grealpath "$@"; }
  else
    realpath() { readlink -f "$@"; }
  fi
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

if type systemctl >/dev/null 2>/dev/null ; then
  if ! type ssh-agent ; then
    if type yum >/dev/null 2>/dev/null ; then
      sudo yum install openssh-askpass
    else
      echo please install ssh-agent
      exit 1
    fi
  fi

  mkdir -p ~/.config/systemd/user
  cp ./systemd/ssh-agent.service ~/.config/systemd/user

  systemctl --user enable ssh-agent.service
  systemctl --user start ssh-agent.service
fi
