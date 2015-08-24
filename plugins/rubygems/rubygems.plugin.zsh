if whence gem >/dev/null ; then
  local _gempath="$(gem environment gempath)"
  export PATH="$PATH:${_gempath//://bin:}/bin"
fi
