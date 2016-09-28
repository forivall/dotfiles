#!/usr/bin/env zsh
set -e
. "$NVM_DIR/nvm.sh"
npm i -g $(comm -13 <(cd "$(npm -g prefix)/lib/node_modules"; echo ${(@F)$(echo *(/))}) <(nvm use --silent $1 && cd "$(npm -g prefix)/lib/node_modules" && echo ${(@F)$(echo *(/))}))
