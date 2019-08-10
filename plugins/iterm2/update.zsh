#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

curl -L https://iterm2.com/shell_integration/zsh \
-o "${__dirname}/iterm2.plugin.zsh"
