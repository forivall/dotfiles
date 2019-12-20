
__zsh_external_tools_plugin__dirname=${0:A:h}

path=($path $__zsh_external_tools_plugin__dirname/bin)

[[ -d $__zsh_external_tools_plugin__dirname/fabiokr-dotfiles ]] && path=(
  $path $__zsh_external_tools_plugin__dirname/fabiokr-dotfiles/bin
)
[[ -d $__zsh_external_tools_plugin__dirname/leshylabs-blogcode ]] && path=(
  $path $__zsh_external_tools_plugin__dirname/leshylabs-blogcode/2013-08-04-making_animated_gifs_from_the_linux_command_line
)
