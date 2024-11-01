#!/usr/bin/env zsh -i

cd $(zgenom api clone_dir ohmyzsh/ohmyzsh)
git remote rename origin upstream
git remote add origin https://github.com/forivall/oh-my-zsh
git checkout master
git branch --set-upstream-to=origin/master
