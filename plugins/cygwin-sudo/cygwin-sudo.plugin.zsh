__zsh_cygwinsudo_plugin_location=$0:A
__zsh_cygwinsudo_plugin_location=${__zsh_cygwinsudo_plugin_location%/*}

# # Didn't work
# # git submodule add git@github.com:nu774/sudo-for-cygwin.git ./sudo-for-cygwin
# __zsh_cygwinsudo_plugin_installinstructions() {
#   echo "sudo-for-cygwin installed. To use, make sure sudoserver.py is running."
#   echo
#   echo "To automatically run sudoserver at startup, add the following to the"
#   echo "Windows Task Scheduler:"
#   echo ""
#   echo 'Action: "Start a program"'
#   echo 'Triggers: "At log on"'
#   echo '"Run with highest privileges": checked.'
#   echo '"Run only when user is logged on": checked.'
#   echo '"Program/script": '"$(cygpath -w "$(whence python)"|sed 's/\\/\\\\/g')"
#   echo '"Add arguments(optional)": '"$__zsh_cygwinsudo_plugin_location/sudo-for-cygwin/sudoserver.py -nw"
# }
#
# if [[ ! -e "$__zsh_cygwinsudo_plugin_location/.installed" ]]; then
#   local piplist="$(pip2 list)"
#   if [[ ! "$piplist" =~ greenlet ]]; then
#     pip2 install greenlet
#   fi
#   if [[ ! "$piplist" =~ greenlet ]]; then
#     pip2 install eventlet
#   fi
#   __zsh_cygwinsudo_plugin_installinstructions
#   touch "$__zsh_cygwinsudo_plugin_location/.installed"
# fi
#
# export PATH="$__zsh_cygwinsudo_plugin_location/sudo-for-cygwin:$PATH"

if [[ -n "$ProgramW6432" ]]; then __zsh_cygwinsudo_arch=x64; else __zsh_cygwinsudo_arch=x86; fi

if [[ -x "$__zsh_cygwinsudo_plugin_location/elevate/bin/$__zsh_cygwinsudo_arch/Release/Elevate" ]]; then
  alias cygsudo=/usr/bin/sudo
  alias sudo=elevate
else
  # TODO: create a release on github, download it instead of building
  echo "Please build elevate in release mode for your platform."
  cygstart "$__zsh_cygwinsudo_plugin_location/elevate/Elevate.sln"
fi

elevate() {
  echo "elevate" "$@"
  "$__zsh_cygwinsudo_plugin_location/elevate/bin/$__zsh_cygwinsudo_arch/Release/Elevate" "$@"
}

sudow() {
  local opts; opts=()

  local use_cmd; if [[ "$1" == "-c" ]] then use_cmd=true; shift; else use_cmd=false; fi
  raw_command="$1"
  if whence "$raw_command" >/dev/null 2>/dev/null ; then
    command="$(whence -p "$raw_command")"
    shift
    echo "$command"
    echo "$@"
    cygpath-w-convert-args opts "$command" "$@"
    echo "$opts[@]"
    elevate "$opts[@]"
  else
    if [[ "$#" == 0 ]] ; then
      elevate "$(cygpath -w "$(whence -p cmd)")"
      return
    fi
    command="$raw_command"
    shift
    cygpath-w-convert-args opts --winargs "$@"
    # for i in {1..${#opts}}; do opts[$i]=${opts[$i]// /\\\\ }; done
    local echoopts; echoopts=()
    for i in {1..$#}; do
      echoopts[$i]="${opts[$i]}"
      if [[ "${(P)i}" == '/'* || "${(P)i}" == '.'* ]]; then
        echoopts[$i]=\""${opts[$i]}"\"
      fi
    done
    echo "$command" "$echoopts[@]"
    elevate env cmd '/D' '/C' "$command" "$echoopts[@]" '&' 'set' '/p' 'enter="Press enter to exit"'
  fi
}

# compdef _elevate elevate
# compinit -d "${ZGEN_DIR}/zcompdump"
