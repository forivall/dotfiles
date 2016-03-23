
# requires the jq command line tool
# https://stedolan.github.io/jq/

MCSAPIDIR="${MCSAPIDIR:-$(echo ~"/MCS APIs")}"
[[ -d $MCSAPIDIR ]] || mkdir -p "$MCSAPIDIR"

mcs-pack() {
  # TODO: make sure to go to the nearest folder with package.json
  # TODO: support a .mcsignore file
  # TODO: support automatically uploading

  local filename
  filename="$MCSAPIDIR/$(jq -r .name package.json)-$(jq -r .version package.json | sed 's/\./_/g').zip"

  [[ -d node_modules ]] && mv node_modules .dev_node_modules
  nvm use v0.10.25 || return 1
  npm i --production || return 1
  if [[ -e npm-shrinkwrap.json ]]; then env rm npm-shrinkwrap.json || return 1; fi
  npm shrinkwrap || return 1

  [[ -e "$filename" ]] && trash "$filename"

  local dir
  dir="$(basename $PWD)"

  (cd .. && zip "$filename" "$dir"/**/*(.)) || return 1

  if [[ -d node_modules ]] ; then env rm -r node_modules || return 1; fi
  [[ -d .dev_node_modules ]] && mv .dev_node_modules node_modules
}
