
if $IS_WINDOWS; then
  alias rm="recycle -f"
elif $IS_OSX; then
  if ! type trash >/dev/null 2>/dev/null ; then
    brew install trash
  fi
  alias rm="trash -F"
  alias rmsu="sudo trash -F"
elif [ -z "${KDE_SESSION_UID+x}" ] ; then
  if whence gio 2>/dev/null >/dev/null ; then
    alias rm="gio trash --"
    alias rmsu="sudo gio trash --"
  else
    alias rm=gvfs-trash
    alias rmsu="sudo gvfs-trash"
  fi
else
  if whence kioclient5 2>/dev/null >/dev/null ; then
    trash() { kioclient5 move "$@" "trash:/" 2> >(grep -v "Invalid Context" 1>&2) ; }
    trashsu() { sudo kioclient5 move "$@" "trash:/" ; }
  else
    trash() { kioclient move "$@" "trash:/" ; }
    trashsu() { sudo kioclient move "$@" "trash:/" ; }
  fi
  alias rm=trash
  alias rmsu=trashsu
fi

alias rmd="command rm"
alias rmdsu="sudo rm"

if (( ${+commands[gmv]} )); then
  alias mv="command gmv -b"
else
  alias mv="mv -b"
fi
if (( ${+commands[gcp]} )); then
  alias cp="command gcp -b"
else
  alias cp="cp -b"
fi
