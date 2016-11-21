#!/usr/bin/env zsh

packages=($(comm -13 <(apm ls --bare | cut -d@ -f1 | sort | uniq ) <(< my-packages.txt sort)))

if (( ${#packages} > 0 )) ; then
    echo -n "apm install ${packages} ? (y/N) "
    read yn
    if [[ "$yn" =~ [Yy](es)? ]] ; then
        apm install ${packages}
    fi
fi
