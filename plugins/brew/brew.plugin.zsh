if type brew &>/dev/null
then
  : ${HOMEBREW_PREFIX:="$(brew --prefix)"}
  # TODO: disable the non-zsh compat ones here, instead of my delete workaround
  # or, after everything is loaded, only try to load bash completions that dont
  # already have a zsh completion

  # if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  # then
  #   source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  # else
  #   for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
  #   do
  #     [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
  #   done
  # fi

  if [[ -f "$HOMEBREW_PREFIX/opt/python@3.8/libexec/bin/python" ]]; then
    export CLOUDSDK_PYTHON="$HOMEBREW_PREFIX/opt/python@3.8/libexec/bin/python"
  fi
  CLOUDSDK_HOME="$HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"

  # [[ -d "/usr/local/opt/node@12/bin" ]] && path=(/usr/local/opt/node@12/bin $path)
  export PLAN9="/usr/local/plan9"
  [[ -d $PLAN9 ]] && path=($path $PLAN9/bin)
  local OPENJDK

  OPENJDK=$HOMEBREW_PREFIX/opt/openjdk  # todo: openjdk@{VER}
  [[ -d $OPENJDK/bin ]] && path=($OPENJDK/bin $path)
  # For compilers to find openjdk you may need to set:
  #   export CPPFLAGS="-I${OPENJDK}/include"

  export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}";
fi

if open -Ra Gittyup 2> /dev/null ; then
  alias gittyup="open -a Gittyup"
fi

if type openman >/dev/null 2>/dev/null ; then
  alias oman=openman
fi

if [[ -d /Applications/WebStorm.app/Contents/MacOS ]] ; then
  path+=(/Applications/WebStorm.app/Contents/MacOS)
fi
