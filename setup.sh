#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || exit

_is_xdg() {
  local _XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg:/foo/bar};
  local OIFS="$IFS"
  IFS=':'
  local xdg_config_dirs=(${_XDG_CONFIG_DIRS});
  IFS="$OIFS"
  [[ -d ${xdg_config_dirs[0]} ]]
}
if _is_xdg ; then is_xdg=true ; else is_xdg=false ; fi

if [[ "$(uname)" == "Darwin" ]] ; then IS_OSX=true; else IS_OSX=false; fi

o() {
  echo "$@"
  "$@"
}

if $is_xdg ; then
  : ${XDG_CONFIG_HOME:=$HOME/.config}
  # Move this dir into XDG_CONFIG_HOME, and then symlink back to the old spot
  if [[ "$PWD" != "$XDG_CONFIG_HOME/dotfiles" ]] ; then
    echo "Moving dotfiles to \"$XDG_CONFIG_HOME/dotfiles\"..."
    DIR="$PWD"
    cd ..
    mv "$DIR" "$XDG_CONFIG_HOME/dotfiles"
    cd "$XDG_CONFIG_HOME/dotfiles"
    ln -s "$XDG_CONFIG_HOME/dotfiles" "$DIR"
  fi
fi

# TODO: use gnu stow
# http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html?round=two

if ! type realpath >/dev/null ; then
  if type grealpath >/dev/null ; then
    realpath() { grealpath "$@"; }
  else
    realpath() { readlink -f "$@"; }
  fi
fi

o git submodule update --init
o ln -fs "$(realpath zshrc)" ~/.zshrc
o ln -fs "$(realpath zsh_history_interactive)" ~/.zsh_history_interactive

o mkdir -p ~/.config

o ./vim/setup.sh

o ln -fs "$(realpath jshintrc)" ~/.jshintrc
o ln -fs "$(realpath gitconfig)" ~/.gitconfig
o ln -fs "$(realpath gitignore)" ~/.gitignore
o ln -fs "$(realpath oglrc)" ~/.ogl
o ln -fs "$(realpath hgrc)" ~/.hgrc
o ln -fs "$(realpath nanorc)" ~/.nanorc
o ln -fs "$(realpath pythonhist)" ~/.pythonhist
o ln -fs -T "$(realpath plugins/direnv/config)" ~/.config/direnv
o mkdir -p ~/.config/glab-cli
o ln -fs "$(realpath plugins/glab/aliases.yml)" ~/.config/glab-cli/aliases.yml
o mkdir -p ~/.config/htop
o ln -fs "$(realpath htoprc)" ~/.config/htop/htoprc
o mkdir -p ~/.config/gh
o ln -fs "$(realpath gh/config.yml)" ~/.config/gh/config.yml
o mkdir -p ~/.config/helix
o ln -fs "$(realpath helix/config.toml)" ~/.config/helix/config.toml
o ln -fs "$(realpath helix/themes)" ~/.config/helix/themes
o ln -fs "$(realpath ctop)" ~/.ctop
o ln -fs "$(realpath config/watchman.json)" ~/.config/watchman.json

o ln -fs "$(realpath colordiffrc)" ~/.colordiffrc
o ln -fs "$(realpath bash/bash_completion)" ~/.bash_completion
o ln -fs "$(realpath bash/bash_completion.d)" ~/.bash_completion.d


if $IS_OSX ; then
  mkdir -p ~/.config/mackup
  o ln -fs "$(realpath mackup.cfg)" ~/.mackup.cfg
  mkdir -p ~/.config/yabai
  o ln -fs "$(realpath config/yabairc)" ~/.config/yabai/yabairc
fi
# TODO: gnu stow or some other alternative to mackup for linux.

if [[ -n "$BABUN_HOME" ]]; then
    BINPATH="$(cygpath "$HOMEPATH")/.local/bin"
    o mkdir -p "$BINPATH"
    if [[ ! -e "$BINPATH/recycle.exe" ]] ; then
        o curl -OL http://www.maddogsw.com/cmdutils/cmdutils.zip
        o unzip cmdutils.zip -d cmdutils
        o cp cmdutils/Recycle.exe "$BINPATH/recycle.exe"
    fi
fi

if type systemctl >/dev/null 2>/dev/null ; then
  if ! type ssh-agent ; then
    if type yum >/dev/null 2>/dev/null ; then
      o sudo yum install openssh-askpass
    else
      echo please install ssh-agent
      exit 1
    fi
  fi

  o mkdir -p ~/.config/systemd/user
  o cp ./systemd/ssh-agent.service ~/.config/systemd/user

  o systemctl --user enable ssh-agent.service
  o systemctl --user start ssh-agent.service
fi

if $is_xdg ; then
  XDG_AUTOSTART_DIR="${XDG_CONFIG_HOME/autostart}"
  o mkdir -p "${XDG_AUTOSTART_DIR}"

  o ln -fs "$(realpath autostart/redshift.desktop)" "${XDG_AUTOSTART_DIR}/autostart/redshift.desktop"
  o ln -fs "$(realpath autostart/synclient.desktop)" "${XDG_AUTOSTART_DIR}/autostart/synclient.desktop"
fi
