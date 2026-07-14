#!/bin/zsh --no-rcs

# Install Privileged Helper Tool
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# This script will install the Privileged Helper Tool.
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ------------------    edit the variables below this line    ------------------

# Path to Privileged Helper Tool
privileged_helper_tool="/Library/PrivilegedHelperTools/nl.root3.support.helper"

# LaunchDaemon domain
launch_daemon="nl.root3.support.helper"

# Install location
install_location="/Applications/Support.app"

# Developer Team Identifier used for the SpawnConstraint
team_identifier="98LJ4XBGYK"

# Path to PlistBuddy
plistbuddy="/usr/libexec/PlistBuddy"

# Load Requirements
autoload is-at-least

# macOS Version
os_version=$(sw_vers -productVersion)

# ------------------    PrivilegedHelperTool    ------------------

# Create "/Library/PrivilegedHelperTools/" if not present
if [[ ! -d "/Library/PrivilegedHelperTools/" ]]; then
  mkdir "/Library/PrivilegedHelperTools/"
fi

# Copy the PrivilegedHelperTool
cp "${install_location}/Contents/Library/LaunchServices/${launch_daemon}" "/Library/PrivilegedHelperTools/"
# Set permissions
chown root:wheel "${privileged_helper_tool}"
chmod 544 "${privileged_helper_tool}"

# ------------------    LaunchDaemon PrivilegedHelperTool    ------------------

# Path to the LaunchDaemon property list
launch_daemon_plist="/Library/LaunchDaemons/${launch_daemon}.plist"

# Remove any existing LaunchDaemon plist to avoid stale keys and extended
# attributes. Note: the plist is created with PlistBuddy instead of
# "defaults write", as defaults hands the write to cfprefsd which adds the
# com.apple.quarantine extended attribute to every file it creates. launchd
# refuses to load quarantined property list files on macOS 27 and higher.
rm -f "${launch_daemon_plist}"

# Create the LaunchDaemon
# - AssociatedBundleIdentifiers shows the app name in Login Items on
#   macOS 13 and higher instead of the developer name
"${plistbuddy}" \
  -c "Add :Label string ${launch_daemon}" \
  -c "Add :ProgramArguments array" \
  -c "Add :ProgramArguments:0 string ${privileged_helper_tool}" \
  -c "Add :MachServices dict" \
  -c "Add :MachServices:nl.root3.support.helper bool true" \
  -c "Add :AssociatedBundleIdentifiers array" \
  -c "Add :AssociatedBundleIdentifiers:0 string nl.root3.support" \
  "${launch_daemon_plist}" > /dev/null

# Add a SpawnConstraint on macOS 14 and higher so launchd only spawns this
# service when the binary is signed by Root3 with the expected signing
# identifier. This prevents an orphaned plist from launching a malicious
# binary placed at the same path.
if is-at-least 14.0 ${os_version}; then
  "${plistbuddy}" \
    -c "Add :SpawnConstraint dict" \
    -c "Add :SpawnConstraint:team-identifier string ${team_identifier}" \
    -c "Add :SpawnConstraint:signing-identifier string nl.root3.support.helper" \
    "${launch_daemon_plist}" > /dev/null
fi

# Just to be sure, remove the quarantine extended attribute if present
xattr -d com.apple.quarantine "${launch_daemon_plist}" &> /dev/null

# Set permissions
chown root:wheel "${launch_daemon_plist}"
chmod 644 "${launch_daemon_plist}"

# Unload the LaunchDaemon
if launchctl print "system/${launch_daemon}" &> /dev/null ; then
  launchctl bootout "system/${launch_daemon}" &> /dev/null
fi

# Load the LaunchDaemon
if ! launchctl print "system/${launch_daemon}" &> /dev/null ; then
  launchctl bootstrap system "/Library/LaunchDaemons/${launch_daemon}.plist"
fi