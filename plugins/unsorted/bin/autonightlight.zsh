#!/usr/bin/env zsh

set -euo pipefail

TZ="$(date +%Z)"
resp="$(curl -s "https://api.sunrisesunset.io/json?lat=49.2827&lng=-123.1207&timezone=$TZ&date=today")"
/opt/homebrew/bin/nightlight schedule "$(echo $resp | /opt/homebrew/bin/jq -r '.results.sunset | sub(":\\d\\d "; "")')" "$(echo $resp | /opt/homebrew/bin/jq -r '.results.sunrise | sub(":\\d\\d "; "")')"
