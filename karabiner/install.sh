#!/usr/bin/env zsh

set -euo pipefail

if (( $# < 1 )) ; then
  echo "usage: ./install.sh <modifications.json>"
  exit 1
fi

kbcli=/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli
echo -n 'linting... '
$kbcli --lint-complex-modifications $1

base64=$(< $1 sd '//.*' '' | jq -c . | sd '\n$' '' | base64 --wrap=0)

if [[ -n $base64 ]]; then
  echo "karabiner://karabiner/assets/complex_modifications/import?url=data:application/json;charset=utf-8;base64,$base64"
  open -u "karabiner://karabiner/assets/complex_modifications/import?url=data:application/json;charset=utf-8;base64,$base64"
fi
