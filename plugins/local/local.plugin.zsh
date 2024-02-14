# place local-only scripts in this folder

__zsh_forivall_local_plugin_location=$0:A:h

PATH="$PATH:${__zsh_forivall_local_plugin_location}/bin"

[[ -e $__zsh_forivall_local_plugin_location/local.source.zsh ]] &&
  source $__zsh_forivall_local_plugin_location/local.source.zsh
