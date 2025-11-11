__zsh_rust_plugin_location=${0:A:h}

path=($path ~/.cargo/bin $__zsh_rust_plugin_location/bin)

alias cm="cargo make"
alias cr="cargo run"
alias inlyne="command inlyne --config ${__zsh_rust_plugin_location:h:h}/config/inlyne.toml"
alias yz="yazi"
function md() {
  ( command inlyne --config "${__zsh_rust_plugin_location:h:h}/config/inlyne.toml" "$@" 2>/dev/null & )
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

[[ -f "${__zsh_rust_plugin_location}/intelli-shell-init.zsh" ]] &&
  source "${__zsh_rust_plugin_location}/intelli-shell-init.zsh"

if (( ${+commands[yazi]} )) ; then
  function y() {
    local tmp cwd
    tmp=$(mktemp -t "yazi-cwd.XXXXXX")

    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi
