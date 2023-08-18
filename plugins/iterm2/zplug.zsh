#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

outfile="${__dirname}/iterm2_shell_integration.zsh"
if [[ -f ~/.iterm2_shell_integration.zsh ]] ; then
  mv ~/.iterm2_shell_integration.zsh $outfile
else
  echo -n Downloading iterm2 shell integration... >&2
  curl -sL https://raw.githubusercontent.com/gnachman/iTerm2-shell-integration/main/shell_integration/zsh -o $outfile
  echo ' Done.' >&2
fi

if [[ -f ~/.iterm2/imgcat ]] ; then
  mv ~/.iterm2/* "${__dirname}/utilities"
  rmdir ~/.iterm2
else
  echo -n Downloading iterm2 utilities...
  pushd "${__dirname}/utilities"
  # https://github.com/gnachman/iterm2-website/tree/master/source/utilities
  for f in $(
    curl -s https://api.github.com/repos/gnachman/iTerm2-shell-integration/contents/utilities |
    jq -r ".[].download_url"
  ) ; do
    echo -n . >&2
    curl -sOL $f
    chmod +x $f
  done
  echo ' Done.' >&2
  popd
fi
