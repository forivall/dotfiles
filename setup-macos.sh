#!/usr/bin/env zsh

open -a 'Audio MIDI Setup'

echo 'Click the Add button > Create Aggregate Device. Name it "Built-in Microphone"'
echo 'Select the "use" checkbox for "MacBook Pro Microphone"'
echo -n 'Press enter to continue'
read

osascript -e '
tell application "System Events" to
  tell process "Audio MIDI Setup" to
	  click menu item "Quit Audio MIDI Setup" of menu "Audio MIDI Setup" of menu bar 1
'
open /System/Library/PreferencePanes/Sound.prefPane
echo 'Use "Built-in Microphone" as the default input'

echo 'Done.'
