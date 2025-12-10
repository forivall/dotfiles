#!/usr/bin/env zsh

__filename=${0:A}
__dirname=${__filename:h}

gem environment gempath > $__dirname/gempath


