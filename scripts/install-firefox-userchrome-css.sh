#!/usr/bin/env zsh

__filename=${${(%):-%N}:A}
__dirname=${__filename:h}

source ${__dirname}/detect-platform.zsh

if $IS_OSX ; then
  ffpath=~/Library/Application\ Support/Firefox
else
  echo 'TODO: find platform dir'
  exit 1
fi

# http://zdharma.org/Zsh-100-Commits-Club/Zsh-Native-Scripting-Handbook.html#parsing-ini-file

# profile_path=$(< $ffpath/profiles.ini sed -n -e 's/^.*Path=//p' | head -n 1)

parse_ini() {
  setopt localoptions extendedglob

  local __ini_file="$1" __out_hash="$2" __key_prefix="$3"
  local IFS='' __line __cur_section="void" __access_string
  local -a match mbegin mend

  [[ ! -r "$__ini_file" ]] && { builtin print -r "read-ini-file: an ini file is unreadable ($__ini_file)"; return 1; }

  while read -r -t 1 __line; do
      if [[ "$__line" = [[:blank:]]#\;* ]]; then
          continue
      # Match "[Section]" line
      elif [[ "$__line" = (#b)[[:blank:]]#\[([^\]]##)\][[:blank:]]# ]]; then
          __cur_section="${match[1]}"
      # Match "string = string" line
      elif [[ "$__line" = (#b)[[:blank:]]#([^[:blank:]=]##)[[:blank:]]#[=][[:blank:]]#(*) ]]; then
          match[2]="${match[2]%"${match[2]##*[! $'\t']}"}" # severe trick - remove trailing whitespace
          __access_string="${__out_hash}[${__key_prefix}${__cur_section}_${match[1]}]"
          : "${(P)__access_string::=${match[2]}}"
      fi
  done < "$__ini_file"
}

typeset -A profiles
parse_ini $ffpath/profiles.ini profiles

mkdir -p "${ffpath}/${profiles[Profile0_Path]}/chrome"
cd "${ffpath}/${profiles[Profile0_Path]}/chrome"
curl -L -o userChrome.css https://gist.githubusercontent.com/forivall/91fa4ef7cb4da4d11f097112e41e5b47/raw

ffbin=firefox
if $IS_OSX ; then
  ffbin=/Applications/Firefox.app/Contents/MacOS/firefox
fi

$ffbin about:config
echo 'Set toolkit.legacyUserProfileCustomizations.stylesheets to true'

# TODO: create a user.js with the content
# user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);  
