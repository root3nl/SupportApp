#!/bin/zsh

# Install Support App
#
#
# Copyright 2021 Root3 B.V. All rights reserved.
#
# This script will create the Support App LaunchAgent and reload it when needed.

# LaunchAgent label
launch_agent="nl.root3.support"

# Get the username of the currently logged in user
username=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
echo "Current logged in user: ${username}"

# Get the username ID
uid=$(id -u "${username}")

# Remove "Downloaded from Internet" warning
xattr -d -r com.apple.quarantine "/Applications/Support.app"

# Create the LaunchAgent
defaults write "/Library/LaunchAgents/${launch_agent}.plist" Label -string "${launch_agent}"
defaults write "/Library/LaunchAgents/${launch_agent}.plist" ProgramArguments -array -string "/Applications/Support.app/Contents/MacOS/Support"
# Run every reboot
defaults write "/Library/LaunchAgents/${launch_agent}.plist" KeepAlive -boolean yes
# Set ProcessType to Interactive
defaults write "/Library/LaunchAgents/${launch_agent}.plist" ProcessType -string "Interactive"
# Set permissions
chown root:wheel "/Library/LaunchAgents/${launch_agent}.plist"
chmod 644 "/Library/LaunchAgents/${launch_agent}.plist"

# Reload the LaunchAgent
if [[ -n "${username}" ]]; then
	# Unload the LauchAgent
  launchctl bootout gui/${uid} "/Library/LaunchAgents/${launch_agent}.plist" &> /dev/null

	# Just to be sure, kill Support App if still running
	if pgrep -x "Support" ; then
		killall -9 "Support"
	fi

	# Load the LaunchAgent
  launchctl bootstrap gui/${uid} "/Library/LaunchAgents/${launch_agent}.plist"
fi
