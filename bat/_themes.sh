#!/usr/bin/env zsh
__dirname=${0:A:h}
cd "${__dirname}/themes"
curl -OL https://github.com/chriskempson/tomorrow-theme/raw/master/textmate/Tomorrow-Night.tmTheme
curl -OL https://github.com/chriskempson/tomorrow-theme/raw/master/textmate/Tomorrow.tmTheme
curl -OL https://github.com/chriskempson/base16-textmate/raw/master/Themes/base16-tomorrow.tmTheme
curl -OL https://github.com/chriskempson/base16-textmate/raw/master/Themes/base16-tomorrow-night.tmTheme
sd '#96989655' '#3b3d3e' base16-tomorrow-night.tmTheme
