#!/usr/bin/env zsh

zmodload zsh/datetime

_zgen-autoupdate_current_epoch() {
  echo $(( $EPOCHSECONDS / 60 / 60 / 24 ))
}

_zgen-autoupdate_update_zsh_update() {
  echo "LAST_EPOCH=$(_zgen-autoupdate_current_epoch)" >! ~/.zsh-update
}

_zgen-autoupdate_upgrade_zsh() {
  zgen selfupdate
  zgen update
  # update the zsh file
  _zgen-autoupdate_update_zsh_update
}

epoch_target=$UPDATE_ZSH_DAYS
if [[ -z "$epoch_target" ]]; then
  # Default to old behavior
  epoch_target=13
fi

if [ -f ~/.zsh-update ]
then
  . ~/.zsh-update

  if [[ -z "$LAST_EPOCH" ]]; then
    _zgen-autoupdate_update_zsh_update && return 0;
  fi

  epoch_diff=$(($(_zgen-autoupdate_current_epoch) - $LAST_EPOCH))
  if [ $epoch_diff -gt $epoch_target ]
  then
    if [ "$DISABLE_UPDATE_PROMPT" = "true" ]
    then
      _zgen-autoupdate_upgrade_zsh
    else
      echo "[zgen-autoupdate] Would you like to check for updates? [Y/n]: \c"
      read line
      if [ "$line" = Y ] || [ "$line" = y ] || [ -z "$line" ]; then
        _zgen-autoupdate_upgrade_zsh
      else
        _zgen-autoupdate_update_zsh_update
      fi
    fi
  fi
else
  # create the zsh file
  _zgen-autoupdate_update_zsh_update
fi

unfunction _zgen-autoupdate_current_epoch
unfunction _zgen-autoupdate_update_zsh_update
unfunction _zgen-autoupdate_upgrade_zsh
