function npm() {
  for cmd in ${=$(compgen -c -X '!npm-*'|sort|uniq)} ; do
    if [[ "$1" == "${cmd#npm-}" ]] ; then shift; "$cmd" "$@" ; return ; fi
  done
  local -a npm_cmd; npm_cmd=( /usr/bin/env npm )
  if [[ "$1" == "-g" ]] ; then npm_cmd+=( -g ); shift; fi
  case "$1" in
    ru[nm]) shift; ${npm_cmd[@]} run --no-spin "$@";;
    # diffuse) shift; ~/scripts/git-diffuse "$@";;
    go) shift; cd $(${npm_cmd[@]} explore "$@" pwd);;
    *) /usr/bin/env npm "$@";;
  esac
}

npm-git-get-branch() {
  local m="$1"
  # package = require('./package.json'); branch = _.last((package.dependencies?[m] or package.devDependencies?[m])?.split('#'))
  local branch="$(< package.json jq -r "(.dependencies[\"$m\"] // .devDependencies[\"$m\"]) | split(\"#\") | .[length - 1]")" || return 1
  [[ "$branch" == "null" ]] && return 1
  echo $branch
}

npm-git-save() {
  local branch
  local m="$1"
  if branch=$(npm-git-get-branch "$m") then
    (cd "node_modules/$m" && git checkout --detach origin/$branch) || return
  fi
  mv "node_modules/$m/.git" "node_modules/$m.git"
}
npm-git-unsave() {
  local m="$1"
  mv "node_modules/$m.git" "node_modules/$m/.git"
}
npm-git-rm-all() { npm rm $(eval echo $(< package.json jq '.dependencies | to_entries | .[] | select(.value | startswith("git")) | .key')) ; }
npm-install-sub() {
  npm-sub i
}
npm-sub() {
  # dependencies = _.map(_.pairs(require('./package.json').dependencies), JSON.stringify)
  # parent_dependencies = _.map(_.pairs(require('../../package.json').dependencies), JSON.stringify)
  # unique_dependencies_names = _.map(_.difference(dependencies, parent_dependencies), (dependency) -> JSON.parse(dependency)[0])
  # a proper implementation would use semver to check if the package is the same version, and do the proper node_modules folder traversal
  # https://www.npmjs.org/doc/files/npm-folders.html#cycles-conflicts-and-folder-parsimony
  eval npm "$@" $(comm -13 <( < ../../package.json jq -c '.dependencies | to_entries | .[]'|sort) <( < ./package.json jq -c '.dependencies | to_entries | .[]'|sort)|jq '.key')
}
npm-rm-parent-deps() {
  eval npm rm $(comm -12 <( < ../../package.json jq -c '.dependencies | to_entries | .[]'|sort) <( < ./package.json jq -c '.dependencies | to_entries | .[]'|sort)|jq '.key')
}
npm-rm-parent-deps-all() {
  for d in * ; do if [[ -d $d ]] ; then (cd $d; echo $d; npm-rm-parent-deps); fi ; done
}
