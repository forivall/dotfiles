__zsh_github_plugin_location=$0:A
__zsh_github_plugin_location=${__zsh_github_plugin_location%/*}

# TODO: use https://scoop.sh/ instead
PATH="$PATH:$__zsh_github_plugin_location"
if [[ "$OS" == "Windows_NT" || -n "$CYGWIN_VERSION" ]]; then
  __zsh_github_do_upgrade() {
    local version=$newest_version
    local arch
    if [[ -n "$ProgramW6432" ]]; then arch=amd64; else arch=386; fi
    local release_name=hub-windows-$arch-$version
    echo "Downloading new release $version..."
    curl -L -o $__zsh_github_plugin_location/$release_name.tar.gz \
      https://github.com/github/hub/releases/download/v$version/$release_name.tar.gz
    tar -xf $__zsh_github_plugin_location/$release_name.tar.gz --directory $__zsh_github_plugin_location
    mv $__zsh_github_plugin_location/$release_name/etc/hub.zsh_completion $__zsh_github_plugin_location/_hub
    mv $__zsh_github_plugin_location/$release_name/hub.exe $__zsh_github_plugin_location/hub.exe
    if [ "$commands[(I)recycle]" ]; then
      recycle -f $__zsh_github_plugin_location/$release_name $__zsh_github_plugin_location/$release_name.tar.gz
    else
      rm -r $__zsh_github_plugin_location/$release_name $__zsh_github_plugin_location/$release_name.tar.gz
    fi
  }
  upgrade_github() {
    local newest_version="$(curl -sI https://github.com/github/hub/releases/latest | sed -nE 's|^Location:\s.*/v([0-9.]+)|\1|p')"
    if [ "$commands[(I)hub]" ]; then
      local hub_version="$(hub --version | sed -En 's/^hub version ([0-9.]+)/\1/p')"
      if [[ "$hub_version" != "$(echo -e "$hub_version\n$newest_version"|sort -V|tail -n1)" ]]; then
        __zsh_github_do_upgrade
      else
        echo "Up to date."
      fi
    else
      __zsh_github_do_upgrade
    fi
  }
fi
