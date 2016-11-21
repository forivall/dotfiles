#!/usr/bin/env zsh

packages=($(comm -23 <(apm ls --installed --bare | cut -d@ -f1 | sort | uniq) <(< my-packages.txt sort)))

if (( ${#packages} > 0 )) ; then
    echo -n "apm rm ${packages} ? (y/N) "
    read yn
    if [[ "$yn" =~ [Yy](es)? ]] ; then
        apm rm ${packages}
    fi
fi
