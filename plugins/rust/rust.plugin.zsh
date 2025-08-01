__zsh_rust_plugin_location=${0:A:h}

path=($path ~/.cargo/bin)

alias cm="cargo make"
alias cr="cargo run"
alias inlyne="command inlyne --config ~dotfiles/config/inlyne.toml"
alias yz="yazi"
function md() {
  ( command inlyne --config ~dotfiles/config/inlyne.toml "$@" 2>/dev/null & )
}
function cargo-repo() {
  cargo info $@ | sed -n s/repository:\ //p
}
function cargo-clone() {
  git clone $(cargo-repo $@)
}

[[ -f "${__zsh_rust_plugin_location}/broot.source.zsh" ]] &&
  source "${__zsh_rust_plugin_location}/broot.source.zsh"

[[ -f "${__zsh_rust_plugin_location}/tv-init.zsh" ]] &&
  source "${__zsh_rust_plugin_location}/tv-init.zsh"
