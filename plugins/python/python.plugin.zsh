__zsh_python_plugin_location=${0:A:h}

alias httpp=http-prompt


[[ -e "$__zsh_python_plugin_location/pyenv-init.sh" ]] &&
  source "$__zsh_python_plugin_location/pyenv-init.sh"
