#!/usr/bin/env zsh
# https://github.com/creationix/nvm#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file

__zsh_nvm_plugin__filename=${0:A}
__zsh_nvm_plugin__dirname=${0:A:h}

# TODO: switch to https://volta.sh

autoload -U __zsh_nvm_plugin__build_completions

# use NVM_AUTO_USE in nvm plugin instead

if [[ $TERM_PROGRAM == vscode ]]; then
  function zleenvnode() {
    emulate -L zsh
    setopt extendedglob

    local MATCH
    if [[ $LBUFFER = ' /usr/bin/env'* || $LBUFFER = ' cd '*'; /usr/bin/env'* ]]; then
      local NVM_NODE="$(whence node)"
      LBUFFER="${LBUFFER//\/opt\/homebrew\/bin\/node/$NVM_NODE}"
      return
    fi
  }
  autoload -U add-zle-hook-widget
  add-zle-hook-widget -Uz line-finish zleenvnode
fi
