__zsh_rust_plugin_location=${0:A:h}

path=($path ~/.cargo/bin)

alias cm="cargo make"
alias cr="cargo run"

[[ -f "${__zsh_rust_plugin_location}/broot.source.zsh" ]] &&
  source "${__zsh_rust_plugin_location}/broot.source.zsh"
