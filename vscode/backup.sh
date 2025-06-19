#!/usr/bin/env zsh

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

DOTFILES_DIR=${0:a:h}

cp "$VSCODE_USER_DATADIR/settings.json" $DOTFILES_DIR
cp "$VSCODE_USER_DATADIR/keybindings.json" $DOTFILES_DIR
cp -r --dereference "$VSCODE_USER_DATADIR/snippets" $DOTFILES_DIR
code --list-extensions > extensions.txt
