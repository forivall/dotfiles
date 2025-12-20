#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

mkdir -p bin

curl -sOL https://gitlab.gnome.org/GNOME/vte/-/raw/master/perf/256test.sh
mv "256test.sh" bin
chmod +x bin/256test.sh
sed -i 's|#!/usr/bin/env bash|#!/usr/bin/env zsh|' bin/256test.sh

function generate_completions() {
  local compfile="${__dirname}/_$1"
  echo "Generating completion for $1..." >&2
  $@ > $compfile
}
generate_completions carapace _carapace zsh

echo "Generating cursor shell integration"
CURSOR_INTEGRATION=$__dirname/cursor-shell-integration.source.zsh
cursor-agent shell-integration zsh > $CURSOR_INTEGRATION
echo "Patching cursor shell integration for performance"
sd 'exec (~/.local/bin/)?cursor-agent record' '# $0' $CURSOR_INTEGRATION
sd --fixed-strings '$(cursor --locate-shell-integration-path zsh)' "${(qq)$(cursor --locate-shell-integration-path zsh)}" $CURSOR_INTEGRATION
sd --fixed-strings '
# Create a new chat session at the start of each shell session
if [[ -z "$CURSOR_AGENT_CHAT_ID" ]]; then
  export CURSOR_AGENT_CHAT_ID=$(cursor-agent create-chat)
fi' '
_ensure_cursor_agent() {
  # Create a new chat session when needed
  if [[ -z "$CURSOR_AGENT_CHAT_ID" ]]; then
    export CURSOR_AGENT_CHAT_ID=$(cursor-agent create-chat)
  fi
}' $CURSOR_INTEGRATION
sd '^( *).*--resume \$CURSOR_AGENT_CHAT_ID' '${1}_ensure_cursor_agent\n$0' $CURSOR_INTEGRATION

