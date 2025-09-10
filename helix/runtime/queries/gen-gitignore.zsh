#!/usr/bin/env zsh

symlinks=(*(@))
symlinks=(/${^symlinks})
echo ${(F)symlinks} > .gitignore
