
__zsh_forivall_ledcor_plugin_location=$0:A
__zsh_forivall_ledcor_plugin_location=${__zsh_forivall_ledcor_plugin_location%/*}

path=($path "$__zsh_forivall_ledcor_plugin_location")
fpath=($fpath "$__zsh_forivall_ledcor_plugin_location")

# if hash jdeais 2>/dev/null ; then
#   autoload bashcompinit && bashcompinit
#   if [[ ! -f $__zsh_forivall_ledcor_plugin_location/jdeais.completion ]] ; then
#     echo generating jdeais completion...
#     jdeais completion > $__zsh_forivall_ledcor_plugin_location/jdeais.completion
#   fi
#   source $__zsh_forivall_ledcor_plugin_location/jdeais.completion
# fi
