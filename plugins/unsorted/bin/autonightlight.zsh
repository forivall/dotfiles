#!/usr/bin/env zsh

set -euo pipefail

/opt/homebrew/bin/nightlight schedule "$(~/.local/opt/sunwait/sunwait list set 49.28N 123.12W)" "$(~/.local/opt/sunwait/sunwait list rise 49.28N 123.12W)"
