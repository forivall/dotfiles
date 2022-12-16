#!/usr/bin/env zsh

__dirname=${0:A:h}

DATADIR=
case "$(node -p process.platform)" in
  win32)
    if [[ -n "$APPDATA" ]]
    then DATADIR="$APPDATA"
    else DATADIR="$USERPROFILE/AppData/Roaming"
    fi ;;
  darwin)
    DATADIR=~"/Library/Application Support" ;;
  linux)
    if [[ -n "$XDG_CONFIG_HOME" ]]
    then DATADIR="$XDG_CONFIG_HOME"
    else DATADIR=~/.config
    fi ;;
  *) echo Platform not supported >&2; exit 1; ;;
esac

VSCODE_USER_DATADIR=$DATADIR/Code/User

o() {
  echo "$@"
  "$@"
}

o ln -fs "$__dirname/customui.css" $VSCODE_USER_DATADIR/customui.css
