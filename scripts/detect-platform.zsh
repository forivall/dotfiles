setbool() { local code=$?; local arg="$1"; shift; if [[ -z "$@" ]]; then 1=return; 2=$code; fi; if ("$@") 2>&1 >/dev/null ; then eval "export $arg=true"; else eval "export $arg=false"; fi; }

setbool IS_INTERACTIVE  tty -s
setbool IS_WINDOWS  $([[ "$OS" = "Windows_NT" || -n "$CYGWIN_VERSION" ]])
setbool IS_OSX  $([[ "$OSTYPE" = darwin* ]])
setbool IS_LINUXY  $(! $IS_WINDOWS && ! $IS_OSX)  # could also be BSD
IS_XDG_() {
  local _XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg:/foo/bar};
  local xdg_config_dirs=(${(@s/:/)_XDG_CONFIG_DIRS});
  [[ -d ${xdg_config_dirs[1]} ]]
}
setbool IS_XDG IS_XDG_
unset IS_XDG_

unset setbool
