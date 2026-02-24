autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindins() {
  bindkey "$@"
  bindkey -M viins "$@"
  if $ZHM_ENABLED; then
    bindkey -M hxins "$@"
  fi
}
# make search up and down work, so partially type and hit up/down to find relevant stuff
bindins '^[OA' up-line-or-beginning-search
bindins '^[OB' down-line-or-beginning-search
# bindins '^[[A' up-line-or-beginning-search
bindins '^[[B' down-line-or-beginning-search

if (( ${+commands[atuin]} )); then
  bindins '^P' atuin-up-search
  # bindins '^[[1;5A' atuin-up-search
else
  # bindins '^[[1;5A' up-line-or-search
fi

bindins '^[[1;5A' up-line-or-search
bindins '^[[1;5B' down-line-or-search

bindins '^[[1;2A' history-substring-search-up
bindins '^[[1;2B' history-substring-search-down

unfunction bindins
