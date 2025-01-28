#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

# repos_dir=${__dirname:h:h:h}
# : ${MARKPATH:=$HOME/.marks}
# if [[ -d $MARKPATH/pubrepos ]]; then
#   repos_dir=$MARKPATH/pubrepos
# fi
# repos_dir=${repos_dir:A}

# if [[ ! -d $repos_dir/bat-extras ]]; then (
#   cd $repos_dir
#   git clone https://github.com/eth-p/bat-extras.git
# ); fi

if [[ -n "$HOMEBREW_PREFIX" ]]; then
  path=(
    $HOMEBREW_PREFIX/bin
    $HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin
    $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
    $path
  )
  fpath[${fpath[(i)$HOMEBREW_PREFIX/share/zsh/site-functions]}]=()
  fpath=($fpath $HOMEBREW_PREFIX/share/zsh/site-functions)
fi

autoload -Uz +X _xargs
autoload -Uz _xargs_command_arguments

functions[_xargs_better_completion]="${functions[_xargs]}"
echo '#compdef xargs' > _xargs_better_completion
type -f _xargs_better_completion | sed s/_normal/_xargs_command_arguments/ >> _xargs_better_completion
echo '_xargs_better_completion "$@"' >> _xargs_better_completion
