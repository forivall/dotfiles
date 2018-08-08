#!/usr/bin/env bash
# cd "$(dirname "$0")"


# TODO: use gnu stow
# http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html?round=two

WINUSERPROFILE="/c/Users/forivall"
DOTFILESPATH="/e/forivall/Code/repos/git@forivall/dotfiles"

rm "$WINUSERPROFILE/.zshrc"
mklinksu "$WINUSERPROFILE/.zshrc" "$DOTFILESPATH/zshrc"

rm "$WINUSERPROFILE/.zsh_history_interactive"
mklinksu "$WINUSERPROFILE/.zsh_history_interactive" "$DOTFILESPATH/zsh_history_interactive"


rm "$WINUSERPROFILE/.jshintrc"
mklinksu "$WINUSERPROFILE/.jshintrc" "$DOTFILESPATH/jshintrc"

rm "$WINUSERPROFILE/.gitconfig"
mklinksu "$WINUSERPROFILE/.gitconfig" "$DOTFILESPATH/gitconfig"

rm "$WINUSERPROFILE/.gitignore"
mklinksu "$WINUSERPROFILE/.gitignore" "$DOTFILESPATH/gitignore"

rm "$WINUSERPROFILE/.hgrc"
mklinksu "$WINUSERPROFILE/.hgrc" "$DOTFILESPATH/hgrc"

rm "$WINUSERPROFILE/.vimrc.after"
mklinksu "$WINUSERPROFILE/.vimrc.after" "$DOTFILESPATH/vimrc.after"

rm "$WINUSERPROFILE/.pythonhist"
mklinksu "$WINUSERPROFILE/.pythonhist" "$DOTFILESPATH/pythonhist"


rm "$WINUSERPROFILE/.colordiffrc"
mklinksu "$WINUSERPROFILE/.colordiffrc" "$DOTFILESPATH/colordiffrc"


rm "$WINUSERPROFILE/.bash_completion"
mklinksu "$WINUSERPROFILE/.bash_completion" "$DOTFILESPATH/bash/bash_completion"

rm "$WINUSERPROFILE/.bash_completion.d"
mklinksu -d "$WINUSERPROFILE/.bash_completion.d" "$DOTFILESPATH/bash/bash_completion.d"

