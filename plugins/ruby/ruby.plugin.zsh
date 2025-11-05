if whence brew >/dev/null ; then
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$HOMEBREW_PREFIX/opt/openssl@1.1)"
  path=($HOMEBREW_PREFIX/opt/ruby/bin $path)
fi

local _gempath="$(gem environment gempath)"
# add rubygem binaries to the end of the path env.
export PATH="$PATH:${_gempath//://bin:}/bin"
