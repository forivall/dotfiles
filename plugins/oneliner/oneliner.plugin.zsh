__zsh_oneliner_plugin_location=${0:A:h}

path+=($path $__zsh_oneliner_plugin_location/bin)

oneliner() {
  local cmd="${1}"
  if [[ -z "${cmd}" ]]; then
    echo "usage: oneliner [create|...(todo!)]"
    return 1
  fi

  shift

  if functions "oneliner-${cmd}" > /dev/null ; then
    "oneliner-${cmd}" "${@}"
  else
    echo "oneliner: command not found: ${cmd}"
  fi
}
alias oneliner="nocorrect noglob oneliner"

oneliner-create() {
  local name="${1}"
  if [[ -z "${name}" ]]; then
    echo "usage: oneliner create <name> <command>"
    return 1
  fi

  shift

  code="${1}"

  if [[ -z "$code" ]]; then
    echo -n "> "
    read code
  fi

  echo "$code" > "$__zsh_oneliner_plugin_location/$name"

  unfunction "$fname"
  autoload -U "$name"

  echo "Successfully created oneliner \"$name\""
}
alias oneliner-create="nocorrect noglob oneliner-create"

oneliner-init() {
  local s
  local name
  for s in "$__zsh_oneliner_plugin_location/"* ; do
    name="${s##*/}"
    if [[ "$name" != "oneliner.plugin.zsh" ]]; then
      autoload -U "$name"
    fi
  done
}

if [[ -z "$NO_ONELINER_AUTOINIT" ]]; then
  oneliner-init
fi

oneliner-list() {
  local s
  local name
  for s in "$__zsh_oneliner_plugin_location/"* ; do
    name="${s##*/}"
    if [[ "$name" != "oneliner.plugin.zsh" ]]; then
      echo "$name"
    fi
  done
}

[[ -n ${_comps[rg]} ]] && compdef rgp=rg
