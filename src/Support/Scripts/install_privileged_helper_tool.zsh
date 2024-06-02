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

# Add AssociatedBundleIdentifiers to show app name in Login Items on 
# macOS 13 and higher instead of developer name
defaults write "/Library/LaunchDaemons/${launch_daemon}.plist" AssociatedBundleIdentifiers -array -string "nl.root3.support"
# Set the Label and ProgramArguments
defaults write "/Library/LaunchDaemons/${launch_daemon}.plist" Label -string "${launch_daemon}"
defaults write "/Library/LaunchDaemons/${launch_daemon}.plist" ProgramArguments -array -string "${privileged_helper_tool}"
# Set MachServices
defaults write "/Library/LaunchDaemons/${launch_daemon}.plist" MachServices -dict -string "nl.root3.support.helper" -bool true
# Set permissions
chown root:wheel "/Library/LaunchDaemons/${launch_daemon}.plist"
chmod 644 "/Library/LaunchDaemons/${launch_daemon}.plist"

# Unload the LaunchDaemon
if launchctl print "system/${launch_daemon}" &> /dev/null ; then
  launchctl bootout "system/${launch_daemon}" &> /dev/null
fi

# Load the LaunchDaemon
if ! launchctl print "system/${launch_daemon}" &> /dev/null ; then
  launchctl bootstrap system "/Library/LaunchDaemons/${launch_daemon}.plist"
fi