if [ -z "${KDE_SESSION_UID+x}" ] ; then
    alias rm=gvfs-trash
    alias rmsu="sudo gvfs-trash"
else
    rm() { kioclient move "$@" "trash:/" ; }
    rmsu() { sudo kioclient move "$@" "trash:/" ; }
fi

alias rmd=/bin/rm
alias rmdsu="sudo /usr/bin/rm"
