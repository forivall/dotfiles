__git_ftp_zsh_plugin_location=${0:A:h}
manpath=($manpath "$__git_ftp_zsh_plugin_location/man")
path=($path "$__git_ftp_zsh_plugin_location/bin")

install-or-update-git-ftp() {
  local tmpdir="$(mktemp -d)"
  cd $tmpdir
  curl -L https://github.com/git-ftp/git-ftp/tarball/develop | tar -xvz
  cd git-ftp-git-ftp-*
  make install-all DESTDIR="$__git_ftp_zsh_plugin_location"
  cd "$__git_ftp_zsh_plugin_location"
}
