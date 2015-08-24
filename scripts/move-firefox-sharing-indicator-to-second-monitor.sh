#!/usr/bin/sh

wid="$(xdotool search --name 'Firefox - Sharing Indicator') | head -n1"
xdotool windowmove "$wid" $(( 1920 * 2 - 55 )) 0

