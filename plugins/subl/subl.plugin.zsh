
if ! whence subl 2>/dev/null >/dev/null && whence subl3 2>/dev/null >/dev/null; then
    alias subl=subl3
fi

if [[ -e "/cygdrive/c/Program Files/Sublime Text 3/sublime_text.exe" ]]; then
    subl() {
        local opts
        local optval
        opts=()
        for i in {1..$#}; do
            optval=${(P)i}
            opts[$i]=$optval
            if [[ "$optval[1]" != "-" ]] ; then
                opts[$i]="$(cygpath -w "$optval"|sed 's/\\/\\\\/g')"
            fi
        done
        # echo "$opts"
        "/cygdrive/c/Program Files/Sublime Text 3/sublime_text.exe" "$opts"
    }
fi

if [[ -e "/cygdrive/c/Users/forivall/AppData/Local/atom/bin/atom.cmd" ]]; then
    atom() {
        local opts
        local optval
        opts=()
        for i in {1..$#}; do
            optval=${(P)i}
            opts[$i]=$optval
            if [[ "$optval[1]" != "-" ]] ; then
                opts[$i]="$(cygpath -w "$optval"|sed 's/\\/\\\\/g')"
            fi
        done
        "atom.cmd" "$opts"
    }
    alias apm=apm.cmd
fi

if [[ -e "/cygdrive/c/Program Files/Gimp/bin/gimp-2.8.exe" ]]; then
    gimp() {
        local opts
        local optval
        opts=()
        for i in {1..$#}; do
            optval=${(P)i}
            opts[$i]=$optval
            if [[ "$optval[1]" != "-" ]] ; then
                opts[$i]="$(cygpath -w "$optval"|sed 's/\\/\\\\/g')"
            fi
        done
        ("/cygdrive/c/Program Files/Gimp/bin/gimp-2.8.exe" "$opts" 2> /dev/null &)
    }
fi
