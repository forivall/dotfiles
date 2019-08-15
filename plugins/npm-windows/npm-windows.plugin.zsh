__zsh_npm_windows_plugin_location=${0:A:h}

export NVM_DIR="/c/Users/$USER/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # This loads nvm

echo FIXME ${0:A}

if [[ ! -e "${__zsh_npm_plugin_location}/_npm" ]] ; then
  cp "${__zsh_npm_plugin_location}/npm.completion.zsh" "${__zsh_npm_plugin_location}/_npm"
fi
# if [[ -e /usr/share/zsh/5.0.7/functions/_npm ]] ; then
#   mkdir -p /usr/share/zsh/5.0.7/functions-disabled
#   mv /usr/share/zsh/5.0.7/functions/_npm /usr/share/zsh/5.0.7/functions-disabled
# fi
local __completion_file_location="$(dirname "$(whence -p npm)")/node_modules/npm/lib/completion.js"
if [[ ! -e "${__completion_file_location}~" ]]; then
  fix_npm_completion() {
    local __completion_file_location="$(dirname "$(whence -p npm)")/node_modules/npm/lib/completion.js"
    < "${__completion_file_location}" sed 's/if (process.platform === "win32") {/if (false \&\& process.platform === "win32") { \/\/ disabled for cygwin/g' > ${__zsh_npm_plugin_location}/npm_completion.js
    sudow -c move "${__completion_file_location}" "${__completion_file_location}~"
    sudow -c move "${__zsh_npm_plugin_location}/npm_completion.js" "${__completion_file_location}"
    unfunction fix_npm_completion
  }
  echo "call fix_npm_completion to fix npm completion on cygwin"
fi
