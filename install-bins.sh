#!/usr/bin/env zsh

mkdir -p ~/.local/bin

installer="$1"

cmds=(
  'corepack enable'
  'npm install -g bash-language-server'
  'npm install -g npm-name-cli'
  'npm install -g chokidar-cli'
  'npm install -g js-yaml'
  'npm install -g nx'
  'npm install -g serve'
  'npm install -g git-file-history'
  'npm install -g graphql-language-service-cli'

  'cargo install bingrep'
  'cargo install consoletimer'
  'cargo install ddh'
  'cargo install dtg'
  'cargo install drft'
  'cargo install huniq'
  # 'cargo install hx' # hex editor, conflicts with helix
  'cargo install pueue'
  'cargo install runiq'
  'cargo install hx-lsp'
  # 'cargo install sl_cli'
  'cargo install --git https://github.com/estin/simple-completion-language-server.git'
  'cargo install toml-cli'
  'cargo install viu'
  'cargo install gh-xplr'
  # 'cargo install tree-grepper'
  'LIBSQLITE3_FLAGS="-DSQLITE_ENABLE_MATH_FUNCTIONS" cargo install intelli-shell --locked'

  'pipx install simple-term-menu'
  'pipx install termdown'
  'pipx install visidata'
  'pipx install humble-explorer'
  'pipx install jrnl'

  'go install github.com/ChausseBenjamin/termpicker@latest'
  'go install github.com/dlvhdr/diffnav@latest'
  'go install github.com/unkn0wn-root/resterm/cmd/resterm@latest'

  'uv tool install tombi'
  'eget biomejs/gritql --asset=grit'
  'eget grouzen/framework-tool-tui'

  'gh extension install yusukebe/gh-markdown-preview'
  'gh extension install dlvhdr/gh-dash'
  'gh extension install gennaro-tedesco/gh-s'
  'gh extension install gennaro-tedesco/gh-f'
  'gh extension install heaths/gh-label'
  'gh extension install sgoedecke/gh-standup'
  'gh extension install redraw/gh-install'
  'gh extension install sayanarijit/gh-xplr'
)

if [[ "$(uname)" != "Darwin" ]]; then cmds+=(
  # already installed with brew
  'cargo install bkmr'
  'cargo install sd'
); fi

alias pip='python3 -m pip'

for c in $cmds; do
  cmd=(${=c})
  cmd_installer=
  for a in $cmd; do
    if [[ $a != *'='* ]]; then
      cmd_installer="$a"
      break
    fi
  done
  if [[ -n "$installer" && "$cmd_installer" != "$installer" ]]; then continue; fi
  echo $c
  eval $c
done
