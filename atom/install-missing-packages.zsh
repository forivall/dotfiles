#!/usr/bin/env zsh

packages=($(comm -13 <(apm ls --installed --bare | sort --ignore-case | cut -d@ -f1) <(< my-packages.txt | sort --ignore-case | cut -d@ -f1)))

if (( ${#packages} > 0 )) ; then
    echo -n "apm install ${packages} ? (y/N) "
    read yn
    if [[ "$yn" =~ [Yy](es)? ]] ; then
        apm install ${packages}
    fi
fi
