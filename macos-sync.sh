#!/usr/bin/env zsh

set -e

cd "$(dirname "$0")" || exit

cp ~/Library/Application\ Support/Code/User/*.json ./vscode
cp -r ~/.config/mackup/Library/Application\ Support/Code/User/snippets ./vscode
cp ~/.config/mackup/Library/Application\ Support/Sublime\ Merge/Packages/User/*.sublime-settings ./subl/merge
cp ~/.config/mackup/Library/Application\ Support/Sublime\ Merge/Packages/User/Default*.sublime-keymap ./subl/merge
cp ~/.config/mackup/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/*.sublime-settings ./subl/text
