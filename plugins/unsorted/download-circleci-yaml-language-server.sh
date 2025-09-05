#!/usr/bin/env zsh

RELEASE=0.14.2
PLATFORM=darwin-arm64
DESTINATION=~/.local/bin/circleci-yaml-language-server
curl -o $DESTINATION https://github.com/CircleCI-Public/circleci-yaml-language-server/releases/download/$RELEASE/${PLATFORM}-lsp
chmod +x $DESTINATION
mkdir -p ~/.local/lib/circleci-yaml-language-server
curl -o ~/.local/lib/circleci-yaml-language-server/schema.json https://github.com/CircleCI-Public/circleci-yaml-language-server/raw/refs/tags/$RELEASE/schema.json
