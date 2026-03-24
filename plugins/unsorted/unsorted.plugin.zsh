__zsh_unsorted_plugin_location=$0:A:h
path+=("$__zsh_unsorted_plugin_location/bin")

autoload -U clean-env
autoload -U shcat
autoload -U reload-function
compdef _functions reload-function

alias ccat="ccat -G String=darkgreen -G Comment=faint -G Keyword=purple -G Punctuation=teal -G Type=darkred -G Literal=darkred -G Plaintext=reset -G Tag=red"

#alias res="echo -en \"\ec\e[3J\""
alias res="echo -n '$(tput reset)'"

if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] ; then
  alias res="echo -n '$(tput reset)' && osascript -e 'tell application \"System Events\" to keystroke \"k\" using {option down, command down}'"
fi

if [[ "$TERM_PROGRAM" == "iTerm.app" ]] ; then
  alias res="printf '\e]1337;ClearScrollback\a'"
fi

type xclip > /dev/null && alias clip="xclip -selection c"

# shellcheck disable=SC2059
condalias() {
  if [[ -x "$2" ]] || (( $+commands[$2] )); then
    alias "$(printf "$1" "$2")"
  fi
}

condalias markdown_py="%s -x def_list -x abbr" "markdown_py"

alias scat="source-highlight -fesc -o STDOUT -i"
function scat2() { source-highlight -fesc "$@" -o STDOUT; }

condalias gcloud="PAGER=cat %s" gcloud

condalias klogout="%s org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 -1 -1" qdbus

unfunction condalias

### open

function _prompt () {
  if [ -n "${ZSH_VERSION+x}" ] ; then
    read "?'$1' doesn't exist. Make a new file? [Y/n] " response
  else
    read -r -p "'$1' doesn't exist. Make a new file? [Y/n] " response
  fi
  if [[ $response =~ ^([nN][oO]|[nN])$ ]] ; then false ; else true ; fi ;
}

if [[ "$OSTYPE" == darwin* ]] ; then : ; else

__DESKTOP_OPEN=gnome-open
if [[ "$KDE_SESSION_UID" != "" ]]; then
  __DESKTOP_OPEN=xdg-open
fi

function open() {
  for varg in "$@"
  do
    if [[ ! "$varg" =~ ^\S+\:\/\/ ]] &&
      [[ ! -e "$varg" ]] &&
      _prompt "$varg" ; then touch "$varg" ; fi
    ${__DESKTOP_OPEN} "$varg" 2>/dev/null ;
  done
}
fi

function new_note.sh() {
  filename=`date +%Y-%m-%d`.${1-"mkd"}
  touch "$filename" ; open "$filename" ;
}

function markdown_py_auto {
  filename=$(basename "$1")
  extension="${filename##*.}"
  filename="${filename%.*}"
  if [[ $extension =~ ^(mkd|markdown|md)$ ]]
  then fullfile=$1
  else if [[ -e "$filename.markdown" ]] ; then fullfile="$filename.markdown"
  else if [[ -e "$filename.mkd" ]] ; then fullfile="$filename.mkd"
  else if [[ -e "$filename.md" ]] ; then fullfile="$filename.md"
  else echo "File does not exist"; return
  fi ; fi ; fi ; fi
  markdown_py "$fullfile" -f "$filename.html"
  gnome-open "$filename.html"
}


function git-grep-gedit-open {
OIFS=$IFS;
IFS='
'
for a in $(git grep $@); do gedit-open "${a%:*}"; done;
IFS=$OIFS
}

function grepdiff {
diff --old-line-format='%l
' --new-line-format='%l
' --old-group-format='-
%<' --new-group-format='+
%>' --changed-group-format='-
%<+
%>' --unchanged-group-format='' "$@"
}

function history_search {
  local root;
  root="$(cd $__zsh_unsorted_plugin_location; git rev-parse --show-toplevel)"
  (
  (cd $root; git log --reverse -p -S"$1" zsh_history_interactive) |
    grep '^-' | sed 's/^-//';
  history -a;) | grep --color=always "$1" | uniq
}

__cheat_has_opt () {
  for word in $@; do
    if [[ "$word" == -* ]]; then
      return 0;
    fi;
  done
  return 1
}

cheat() {
  if ! __cheat_has_opt "$@" ; then
    /usr/local/bin/cheat "$@" | $PAGER
  else
    /usr/local/bin/cheat "$@"
  fi
}

if [[ $IS_OSX ]] ; then
  xs() {
    local script="
    tell application \"Xamarin Studio\"
      activate
      open \"$(realpath "$1")\"
    end tell
    "
    # echo "$script"
    osascript -e "$script"
  }
fi

# whatever...
forever() { while eval "$@" || (echo "Exited Abnormally! Restarting in 1 second."; sleep 1); do : ; done; }

function sleep_until {
  seconds=$(( $(date -d "$*" +%s) - $(date +%s) )) # Use $* to eliminate need for quotes
  echo "Sleeping for $seconds seconds"
  sleep $seconds
}

isvg() {
  rsvg-convert "$@" | imgcat
}

async_run_job_sync() {
  local callback=$1
  local jobname=$2
  shift 1
	float -F duration=$EPOCHREALTIME

	local has_xtrace=0
	[[ -o xtrace ]] && {
		has_xtrace=1
		unsetopt xtrace
	}

  out="$(
    local stdout stderr ret tok
    {
      stdout=$(eval "$@")
      ret=$?
      duration=$(( EPOCHREALTIME - duration ))  # Calculate duration.

      print -r -n - ${(q)jobname} $ret ${(q)stdout} $duration
    } 2> >(stderr=$(command -p cat) && print -r -n - " "${(q)stderr})
  )"

	# Return output (<job_name> <return_code> <stdout> <duration> <stderr>).
	items=("${(@Q)${(z)out}}")
	(( has_xtrace )) && setopt xtrace
	$callback "${items[@]}"
}

prompt_pure_reset_time() {
  typeset -g prompt_pure_cmd_timestamp=$EPOCHSECONDS
}

prompt_pure_sync_refresh() {
	prompt_pure_check_cmd_exec_time
	unset prompt_pure_cmd_timestamp
	prompt_pure_set_title 'expand-prompt' '%~'
	prompt_pure_set_colors
	async_run_job_sync prompt_pure_async_callback prompt_pure_async_vcs_info
	async_run_job_sync prompt_pure_async_callback prompt_pure_async_git_arrows
	async_run_job_sync prompt_pure_async_callback prompt_pure_async_git_dirty ${PURE_GIT_UNTRACKED_DIRTY:-1}
	prompt_pure_preprompt_render
}

prompt_pure_run_cmd() {
  prompt_pure_sync_refresh
  print
  if [[ $1 == '-p' ]]; then
    shift 1
    print -Pn $PROMPT
    echo "$*"
  else
    print -P ${PROMPT%\${prompt_newline}*}
  fi
	prompt_pure_set_title 'ignore-escape' "$PWD:t: $*"
  prompt_pure_reset_time
  "$@"
}

if [[ $IS_OSX && "$TERM_PROGRAM" == "vscode" ]]; then
  code() {
    if [[ "$1" == "--goto" ]]; then
      local file_path="$2"
      local suffix=""
      if [[ $file_path == *:[0-9]## ]]; then
        suffix="${file_path#**:}"
        file_path="${file_path%:*}"
        if [[ $file_path == *:[0-9]## ]]; then
          suffix="${file_path#**:}$suffix"
          file_path="${file_path%:*}"
        fi
      fi
      open "vscode://file/$(realpath "$file_path")$suffix"
      return
    elif [[ "$#" -eq 1 && "$1" != -* ]]; then
      open "vscode://file/$(realpath "$1")"
      return
    fi
    command code "$@"
  }
fi

(( ${+commands[cursor]} )) && alias csr=cursor
(( ${+commands[cursor]} )) && alias cur=cursor

function keyhint() {
  local -a keymap_cmd binding_cmd showkey_binding
  local keymap_name is_mapping is_ranges binding binding_key prefix prefix_keys
  prefix=${1::-1}
  prefix_keys=${(V)prefix}
  for keymap in ${(f)"$(bindkey -Ll)"}; do
    keymap_cmd=(${(z)keymap})
    keymap_name=${keymap_cmd[3]}
    if [[ ${keymap_cmd[2]} == -A ]]; then continue; fi
    for binding in ${(f)"$(bindkey -M $keymap_name -L)"}; do
      binding_cmd=(${(z)binding})
      binding_key=${(Q)binding_cmd[-2]}
      if [[ $binding_key == "$prefix_keys"* ]]; then
        echo "$binding"
      fi
    done
  done
}
show-multikey-bindings() {
  zle -M "$(keyhint "$KEYS")"
}
zle -N show-multikey-bindings
bindkey -M main '^X^I' show-multikey-bindings
bindkey -M main '^[^I' show-multikey-bindings
