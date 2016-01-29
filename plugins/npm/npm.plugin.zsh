__zsh_npm_plugin_location=$0:A
__zsh_npm_plugin_location=${__zsh_npm_plugin_location%/*}

alias nr="npm run"

if ${IS_WINDOWS:-false} ; then
  if [[ ! -e "${__zsh_npm_plugin_location}/_npm" ]] ; then
    cp "${__zsh_npm_plugin_location}/npm.completion.zsh" "${__zsh_npm_plugin_location}/_npm"
  fi
  # if [[ -e /usr/share/zsh/5.0.7/functions/_npm ]] ; then
  #   mkdir -p /usr/share/zsh/5.0.7/functions-disabled
  #   mv /usr/share/zsh/5.0.7/functions/_npm /usr/share/zsh/5.0.7/functions-disabled
  # fi
  local __completion_file_location="$(dirname "$(whence -p npm)")/node_modules/npm/lib/completion.js"
  if [[ ! -e "${__completion_file_location}~" ]]; then
    fix_npm_completion() {
      local __completion_file_location="$(dirname "$(whence -p npm)")/node_modules/npm/lib/completion.js"
      < "${__completion_file_location}" sed 's/if (process.platform === "win32") {/if (false \&\& process.platform === "win32") { \/\/ disabled for cygwin/g' > ${__zsh_npm_plugin_location}/npm_completion.js
      sudow -c move "${__completion_file_location}" "${__completion_file_location}~"
      sudow -c move "${__zsh_npm_plugin_location}/npm_completion.js" "${__completion_file_location}"
      unfunction fix_npm_completion
    }
    echo "call fix_npm_completion to fix npm completion on cygwin"
  fi
fi

function npm() {
  command=$1
  if [[ ${(k)functions[npm-$command]} == npm-$command ]] ; then
    shift; npm-$command "$@"; return
  fi
  local npm_bin="$(whence -p npm)";
  local -a npm_cmd; npm_cmd=( "$npm_bin" )
  # npm_cmd+=( "--node-gyp=$("$npm_bin" -g root)/pangyp/bin/node-gyp.js" )
  if ${IS_WINDOWS:-false} && [[ -t 1 ]]; then npm_cmd+=( --color=always ); fi
  if [[ "$1" == "-g" ]] ; then npm_cmd+=( -g ); shift; fi
  case "$1" in
    # t) ;&
    # tst) ;&
    # test) ;&
    # start) ;&
    # stop) ;&
    ru[nm]) shift; ${npm_cmd[@]} run --no-spin "$@";;
    # diffuse) shift; ~/scripts/git-diffuse "$@";;
    go) shift; cd $(${npm_cmd[@]} explore "$@" pwd);;
    *) ${npm_cmd[@]} "$@";;
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
