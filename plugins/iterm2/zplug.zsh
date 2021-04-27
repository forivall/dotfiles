#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

outfile="${__dirname}/iterm2_shell_integration.zsh"
if [[ -f ~/.iterm2_shell_integration.zsh ]] ; then
  mv ~/.iterm2_shell_integration.zsh $outfile
else
  curl -L https://iterm2.com/shell_integration/zsh -o $outfile
fi

if [[ -f ~/.iterm2/imgcat ]] ; then
  mv ~/.iterm2/* "${__dirname}/utilities"
  rmdir ~/.iterm2
else
  pushd "${__dirname}/utilities"
  # https://github.com/gnachman/iterm2-website/tree/master/source/utilities
  for f in $(
    curl https://api.github.com/repos/gnachman/iterm2-website/contents/source/utilities |
    jq -r ".[].download_url"
  ) ; do
    curl -OL $f
  done
  popd
fi
