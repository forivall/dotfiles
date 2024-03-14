[[ -n ${functions[_direnv_hook]} ]] && _direnv_hook

if [[ -v HOMEBREW_PREFIX ]] && [[ -d $HOMEBREW_PREFIX/lib/node_modules/update-nodejs-notifier ]]; then
  node -e "require('$HOMEBREW_PREFIX/lib/node_modules/update-nodejs-notifier').updateNodejsNotifier({ notSupported: false, stableMajor: false, stableMinor: true, stablePatch: true, notify: ({message}) => console.log(message) })"
fi
