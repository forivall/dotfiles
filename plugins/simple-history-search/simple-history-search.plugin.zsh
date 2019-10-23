
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# make search up and down work, so partially type and hit up/down to find relevant stuff
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

bindkey '^[[1;5A' up-line-or-search
bindkey '^[[1;5B' down-line-or-search

bindkey '^[[1;2A' history-substring-search-up
bindkey '^[[1;2B' history-substring-search-down
