
function showkey() {
  local -a keymap_cmd binding_cmd showkey_binding
  local keymap_name is_mapping is_ranges binding
  for keymap in ${(f)"$(bindkey -Ll)"}; do
    keymap_cmd=(${(z)keymap})
    keymap_name=${keymap_cmd[3]}
    if [[ ${keymap_cmd[2]} == -A ]]; then continue; fi
    binding="$(bindkey -M $keymap_name "$@")"
    binding_cmd=(${(z)binding})
    if [[ ${binding_cmd[-1]} == undefined-key ]]; then continue; fi
    echo "$binding"
  done
}

function showkeys() {
  showkeys_restore_cmd=(${(z)"$(bindkey -Ll main)"})
  zle -N show_key_binding
  bindkey -N showkeys
  local -A keys
  local -a keymap_cmd binding_cmd showkey_binding
  local keymap_name is_mapping is_ranges
  for keymap in ${(f)"$(bindkey -Ll)"}; do
    keymap_cmd=(${(z)keymap})
    keymap_name=${keymap_cmd[3]}
    if [[ $keymap_name == showkeys || ${keymap_cmd[2]} == -A ]]; then continue; fi
    for binding in ${(f)"$(bindkey -LM $keymap_name)"}; do
      binding_cmd=(${(z)binding})
      shift binding_cmd
      is_mapping=false
      if [[ ${binding_cmd[1]} == -s ]]; then is_mapping=true; shift binding_cmd; fi
      is_ranges=false
      if [[ ${binding_cmd[1]} == -R ]]; then is_ranges=true; shift binding_cmd; fi
      if [[ $keymap_name == vicmd && ${binding_cmd[1]} == -a ]]; then shift binding_cmd;
      elif [[ ${binding_cmd[1]} == -M && ${binding_cmd[2]} == $keymap_name ]]; then shift 2 binding_cmd;
      else echo "bad argument ${(qq)binding_cmd[@]} in ${(qq)keymap_cmd[@]}"; return 1;
      fi
      showkey_binding=(-M showkeys "${(Q)binding_cmd[@]:0:-1}" showkeys_onkey)
      if $is_mapping; then
        showkey_binding=(-s $showkey_binding)
      elif $is_ranges; then
        showkey_binding=(-R $showkey_binding)
      fi
      bindkey "${showkey_binding[@]}"
    done
  done
  bindkey -M showkeys '^C' showkeys_restore
  bindkey -M showkeys '^[' showkeys_restore
  bindkey -A showkeys main
}

function showkeys_restore() {
  "${showkeys_restore_cmd[@]}"
  zle -M "$(showkey -L "$KEYS")"
  bindkey -D showkeys
}
zle -N showkeys_restore
function showkeys_onkey() {
  zle -M "$(showkey -L "$KEYS")"
}
zle -N showkeys_onkey
