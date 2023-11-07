#!/usr/bin/env zsh

__zsh_forivall_wttr_plugin_location=${0:A:h}

wttr() {
  emulate sh -c "source $__zsh_forivall_wttr_plugin_location/wttr.bash"
}
