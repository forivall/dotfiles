#!/usr/bin/env zsh
# Dont Autostart the Agent
/usr/libexec/PlistBuddy -c "Set :KeepAlive false" /Library/LaunchAgents/at.obdev.littlesnitch.agent.plist
# Stop the Agent
launchctl bootout system /Library/LaunchAgents/at.obdev.littlesnitch.agent.plist
# remove the deamon to backup
mv /Library/LaunchDaemons/at.obdev.littlesnitch.daemon.plist /Library/LaunchDaemons/at.obdev.littlesnitch.daemon.plist.backup
# stop the Deamon
sudo launchctl remove at.obdev.littlesnitch.daemon
