#!/usr/bin/env zsh

set -euo pipefail

if (( $# < 1 )) ; then
  echo "usage: ./install.sh <modifications.json>"
  exit 1
fi

base64=$(< $1 sd '//.*' '' | jq -c . | base64 | sd '={1,2}$' '')

if [[ -n $base64 ]]; then
  open "karabiner://karabiner/assets/complex_modifications/import?url=data:application/json;charset=utf-8;base64,$base64"
fi
