#!/usr/bin/env zsh

apm ls --installed --bare |
  cut -d@ -f1 |
  sort --ignore-case -V |
  uniq > my-packages.txt

