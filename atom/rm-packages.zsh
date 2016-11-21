#!/usr/bin/env zsh

packages=($(comm -23 <(apm ls --installed --bare | sort --ignore-case | cut -d@ -f1) <(< my-packages.txt | sort --ignore-case)))

if (( ${#packages} > 0 )) ; then
    echo -n "apm rm ${packages} ? (y/N) "
    read yn
    if [[ "$yn" =~ [Yy](es)? ]] ; then
        apm rm ${packages}
    fi
fi
