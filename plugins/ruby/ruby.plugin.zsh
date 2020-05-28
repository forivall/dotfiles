if whence gem >/dev/null ; then
  local _gempath="$(gem environment gempath)"
  # add rubygem binaries to the end of the path env.
  export PATH="$PATH:${_gempath//://bin:}/bin"
fi

if whence brew >/dev/null ; then
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
fi
