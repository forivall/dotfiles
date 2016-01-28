if [ -z "${KDE_SESSION_UID+x}" ] ; then
  alias rm=gvfs-trash
  alias rmsu="sudo gvfs-trash"
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

alias rmd=/bin/rm
alias rmdsu="sudo /usr/bin/rm"

if [[ -n "$CYGWIN_VERSION" ]]; then
    alias rm="recycle -f"
fi
