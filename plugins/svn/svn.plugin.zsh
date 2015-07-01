
# svn aliases
function svn() {
    if [ "$1" == "st" ] ; then
        shift
        /usr/bin/svn status $@
    elif [ "$1" == "lg" ] ; then
        shift
        #printf '\033[?7l' # truncate line if not piping to a pager
        /usr/bin/svn log "$@"|(
            read
            while true ; do
                read h || break
                read
                m=""
                while read l; do
                    echo "$l" | grep -q '^[-]\+$' && break
                    [ -z "$m" ] && m=$l
                done
                echo "$h % $m" | sed 's#\(.*\) | \(.*\) | \([-0-9 :]\{16\}\).* % \(.*\)#\1 \2 (\3) \4#'
            done)|most
        #printf '\033[?7h'
    elif [ "$1" == "log" ] ; then
        /usr/bin/svn $@|most
    else
        /usr/bin/svn $@
    fi
}
