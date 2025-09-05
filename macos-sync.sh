#!/usr/bin/env zsh

set -e

DRY=false
if [[ $1 == --dry-run ]]; then
    DRY=true
    shift
fi

cd "$(dirname "$0")" || exit

CP_COMMAND=cp
(( ${+commands[gcp]} )) && CP_COMMAND=gcp

cp() {
  echo '>' $CP_COMMAND --verbose ${(q)@}
  if ! $DRY; then
    command $CP_COMMAND --verbose "$@"
  fi
}

mu=~/.config/mackup
appsupport="Library/Application Support"
appprefs="Library/Preferences"

#                repo_dir          config_dir                                     file_or_glob  ...flags
vscode=(         ./vscode          ~/$appsupport/Code/User                        "*.json")
vscode_snippets=(./vscode/snippets ~/$appsupport/Code/User/snippets               "*.json")
smerge_settings=(./subl/merge      "~/$appsupport/Sublime Merge/Packages/User"  "*.sublime-settings")
smerge_keymap=(  ./subl/merge      "~/$appsupport/Sublime Merge/Packages/User"  "Default*.sublime-keymap")
subl_settings=(  ./subl/text       "~/$appsupport/Sublime Text 3/Packages/User" "*.sublime-settings")
bat_themes=(     ./bat/themes      ~/.config/bat/themes                           "*")
bat_config=(     ./bat             ~/.config/bat                                  config)
procs_config=(   ./config/procs    ~/$appprefs/com.github.dalance.procs           "*.toml")
lapce_config=(   ./config/lapce    ~/$appsupport/dev.lapce.Lapce-Stable           "*.toml")
zed_config=(     ./config/zed      ~/.config/zed                                  "*.json(.)")
zed_themes=(     ./config/zed/themes ~/.config/zed/themes                         "*.json")
hammerspoon=(    ./hammerspoon     ~/.hammerspoon                                 "*.lua")

if (( $# < 2 )); then
    entries=(
      vscode
      vscode_snippets
      smerge_settings
      smerge_keymap
      subl_settings
      bat_themes
      bat_config
      procs_config
      lapce_config
      zed_config
      hammerspoon
    )
else
    entries=(${@:2})
fi

echo '#' $1 ${(N)entries[@]}

for entry in $entries; do
  repo_dir=${(@)${(P)entry}[1]}
  config_dir=${(@)${(P)entry}[2]}
  file_or_glob=${(@)${(P)entry}[3]}
  flags=(${(@)${(P)entry}[4,-1]})

  if [[ $1 = 'to-local' ]] || [[ $1 = 'push' ]]; then
    cp "${flags[@]}" $repo_dir/${~file_or_glob} --target-directory=$config_dir
  elif [[ -d $config_dir ]]; then
    cp "${flags[@]}" $config_dir/${~file_or_glob} --target-directory=$repo_dir
  fi
done
