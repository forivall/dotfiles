# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/bashrc.pre.bash" ]] && builtin source "$HOME/.fig/shell/bashrc.pre.bash"
[[ -f "$HOME/.bash_profile" ]] && builtin source "$HOME/.bash_profile"

export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="%F %T: "
export HISTFILE=$HOME/.bash_history_interactive

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/bashrc.post.bash" ]] && builtin source "$HOME/.fig/shell/bashrc.post.bash"
