#!/usr/bin/env bash
cd "$(dirname "$0")"

if ! type realpath >/dev/null ; then
  if ! type grealpath >/dev/null ; then
    realpath() { grealpath "$@"; }
  else
    realpath() { readlink -f "$@"; }
  fi
fi

# TODO: use gnu stow
# http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html?round=two

ln -fs "$(realpath atom/build-tools-cpp.projects)" ~/.atom/build-tools-cpp.projects
ln -fs "$(realpath atom/command-toolbar.json)" ~/.atom/command-toolbar.json
ln -fs "$(realpath atom/config.cson)" ~/.atom/config.cson
ln -fs "$(realpath atom/init.coffee)" ~/.atom/init.coffee
if [[ "$(uname)" == "Darwin" ]] ; then
  ln -fs "$(realpath atom/keymap.darwin.cson)" ~/.atom/keymap.cson
else
  ln -fs "$(realpath atom/keymap.cson)" ~/.atom/keymap.cson
fi
#ln -fs "$(realpath atom/projects.cson)" ~/.atom/projects.cson
ln -fs "$(realpath atom/snippets.cson)" ~/.atom/snippets.cson
ln -fs "$(realpath atom/styles.less)" ~/.atom/styles.less
