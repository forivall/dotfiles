#!/bin/sh

[[ `stat -c "%a" /sys/class/backlight/acpi_video0/brightness` == 6?? ]] &&  pkexec chmod -w /sys/class/backlight/acpi_video0/brightness
exit
[[ -e ~/.holdlight.pid ]] && kill `cat ~/.holdlight.pid` && exit

echo $$ > ~/.holdlight.pid
sleep 0.15
light="`light -r`"

sleep 0.25
light -r -S "$light"

rm ~/.holdlight.pid

