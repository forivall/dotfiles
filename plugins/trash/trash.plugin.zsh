if [ -z "${KDE_SESSION_UID+x}" ] ; then
  alias rm=gvfs-trash
  alias rmsu="sudo gvfs-trash"
else
  if whence kioclient5 2>/dev/null >/dev/null ; then
    rm() { kioclient5 move "$@" "trash:/" ; }
    rmsu() { sudo kioclient5 move "$@" "trash:/" ; }
  else
    rm() { kioclient move "$@" "trash:/" ; }
    rmsu() { sudo kioclient move "$@" "trash:/" ; }
  fi

fi

alias rmd=/bin/rm
alias rmdsu="sudo /usr/bin/rm"

if [[ -n "$CYGWIN_VERSION" ]]; then
    alias rm="recycle -f"
fi
