#!/usr/bin/env zsh

__zsh_ngrok_plugin__filename=${0:A}
__zsh_ngrok_plugin__dirname=${0:A:h}

if command -v ngrok &>/dev/null; then
  ngrok completion > $__zsh_ngrok_plugin__dirname/_ngrok
fi
