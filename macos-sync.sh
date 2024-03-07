#!/usr/bin/env zsh

set -e

cd "$(dirname "$0")" || exit

cp() {
  echo '>' cp --verbose ${(q)@}
  command cp --verbose "$@"
}

mu=~/.config/mackup
appsupport="Library/Application Support"

#                repo_dir          config_dir                                     file_or_glob  ...flags
vscode=(         ./vscode          ~/$appsupport/Code/User                        "*.json")
vscode_snippets=(./vscode/snippets ~/$appsupport/Code/User/snippets               "*.json")
smerge_settings=(./subl/merge      "$mu/$appsupport/Sublime Merge/Packages/User"  "*.sublime-settings")
smerge_keymap=(  ./subl/merge      "$mu/$appsupport/Sublime Merge/Packages/User"  "Default*.sublime-keymap")
subl_settings=(  ./subl/text       "$mu/$appsupport/Sublime Text 3/Packages/User" "*.sublime-settings")
bat_themes=(     ./bat/themes      ~/.config/bat/themes                           "*")
bat_config=(     ./bat             ~/.config/bat                                  config)

entries=(
  vscode
  vscode_snippets
  smerge_settings
  smerge_keymap
  subl_settings
  bat_themes
  bat_config
)

for entry in $entries; do
  repo_dir=${(@)${(P)entry}[1]}
  config_dir=${(@)${(P)entry}[2]}
  file_or_glob=${(@)${(P)entry}[3]}
  flags=(${(@)${(P)entry}[4,-1]})

  if [[ $1 == 'to-local' ]]; then
    cp "${flags[@]}" $repo_dir/${~file_or_glob} --target-directory=$config_dir
  else
    cp "${flags[@]}" $config_dir/${~file_or_glob} --target-directory=$repo_dir
  fi
done
