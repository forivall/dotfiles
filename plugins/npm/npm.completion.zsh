#compdef npm

# npm completion for cygwin zsh. requires the lines
#   if (process.platform === "win32") {
#     var e = new Error("npm completion not supported on windows")
#     e.code = "ENOTSUP"
#     e.errno = require("constants").ENOTSUP
#     return cb(e)
#   }
# are commented out

_npm_completion () {
  local cword line point si words_prefix words_prefix_str
  # read -Ac words
  cword=$CURRENT
  let cword-=1
  line="${words[*]}"
  words_prefix=("${words[@]:0:$cword}")
  words_prefix+=$PREFIX
  words_prefix_str="${words_prefix[*]}"
  point=${#words_prefix_str}
  si="$IFS"
  IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                     COMP_LINE="$line" \
                     COMP_POINT="$point" \
                     npm completion -- "${words[@]}" \
                     2>/dev/null)) || return $?
  IFS="$si"
  compadd -- ${reply[@]}
}
# compctl -K _npm_completion npm

_npm_completion "$@"
