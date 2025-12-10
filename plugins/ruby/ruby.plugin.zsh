__zsh_ruby_plugin_location=${0:A:h}

if whence brew >/dev/null ; then
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$HOMEBREW_PREFIX/opt/openssl@1.1)"
  path=($HOMEBREW_PREFIX/opt/ruby/bin $path)
fi

if [[ -f $__zsh_ruby_plugin_location/gempath ]]; then
  local _gempath="$(< $__zsh_ruby_plugin_location/gempath)"
  # add rubygem binaries to the end of the path env.
  export PATH="$PATH:${_gempath//://bin:}/bin"
fi
