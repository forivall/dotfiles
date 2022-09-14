#!/usr/bin/env zsh
# https://github.com/creationix/nvm#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file

__zsh_nvm_plugin__filename=${0:A}
__zsh_nvm_plugin__dirname=${0:A:h}

# TODO: switch to https://volta.sh

autoload -U __zsh_nvm_plugin__build_completions

# use NVM_AUTO_USE in nvm plugin instead
