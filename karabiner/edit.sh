#!/usr/bin/env zsh

set -euo pipefail

if (( $# < 1 )) ; then
  echo "usage: ./edit.sh <modifications.json>"
  exit 1
fi

base64=$(< $1 sd '//.*' '' | jq -c . | base64 | sd '={1,2}$' '')

if [[ -n $base64 ]]; then
  open "https://genesy.github.io/karabiner-complex-rules-generator/#$base64"
fi
