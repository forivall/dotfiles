
zgen-zplug-before-save() {
  __zgen_zplug_before=${#fpath}
}

zgen-zplug-after-save() {
  local count=$(( ${#fpath} - $__zgen_zplug_before ))
  unset __zgen_zplug_before

  for plugindir in ${fpath[0,$count]} ; do
    if [[ -f ${plugindir}/zplug.zsh ]] ; then
      echo "Running ${plugindir}/zplug.zsh" >&2
      (builtin cd $plugindir && ./zplug.zsh)
    fi
  done
}

zgen-zplug-run() {
  for plugindir in ${fpath} ; do
    if [[ $plugindir = *$1* && -f ${plugindir}/zplug.zsh ]] ; then
      echo -n "Run \`${plugindir}/zplug.zsh\` (Y/n)? " >&2
      read yn
      if [[ -z "$yn" || "$yn" =~ [Yy](es)? ]] ; then
        (builtin cd $plugindir && ./zplug.zsh)
      fi
    fi
  done
}

zgenom-zplug-run() {
  zgen-zplug-run "$@"
}
