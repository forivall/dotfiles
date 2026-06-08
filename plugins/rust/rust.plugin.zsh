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

${INTELLI_SHELL_ENABLE:-true} && [[ -f "${__zsh_rust_plugin_location}/intelli-shell-init.zsh" ]] &&
  source "${__zsh_rust_plugin_location}/intelli-shell-init.zsh"

if (( ${+commands[lf]} )) ; then
  function y() {
    local tmp cwd
    tmp=$(mktemp -t "yazi-cwd.XXXXXX")

    lf "$@" --last-dir-path="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
elif (( ${+commands[yazi]} )) ; then
  function y() {
    local tmp cwd
    tmp=$(mktemp -t "yazi-cwd.XXXXXX")

    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

if (( ${+commands[fzf]} && ${+commands[rg]} )) ; then
  function rf() {
    local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    local INITIAL_QUERY="${*:-}"
    fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:$RG_PREFIX {q} || true" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become(vim {1} +{2})'
  }
fi
