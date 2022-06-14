if type brew &>/dev/null
then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
    done
  fi

  if [[ -f "$HOMEBREW_PREFIX/opt/python@3.8/libexec/bin/python" ]]; then
    export CLOUDSDK_PYTHON="$HOMEBREW_PREFIX/opt/python@3.8/libexec/bin/python"
  fi
  CLOUDSDK_HOME="$HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
fi
