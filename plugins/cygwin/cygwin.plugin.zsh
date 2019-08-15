CYGWIN="$CYGWIN codepage:oem"

[[ -n "$VBOX_INSTALL_PATH" ]] && path=($path "$(cygpath $VBOX_INSTALL_PATH)")
autoload -U cygcd
