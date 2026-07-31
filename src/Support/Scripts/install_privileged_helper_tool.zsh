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

# Directory containing this script and the LaunchDaemon property list shipped
# alongside it in the app bundle
script_directory="$(cd -- "$(dirname -- "$0")" && pwd -P)"

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

# Path to the LaunchDaemon property list shipped alongside this script
launch_daemon_plist_source="${script_directory}/${launch_daemon}.plist"

# Path to the LaunchDaemon property list
launch_daemon_plist="/Library/LaunchDaemons/${launch_daemon}.plist"

# Install the LaunchDaemon. The property list is a static file shipped inside
# the app bundle and is only copied into place, never generated here. Earlier
# versions created it with "defaults write", which hands the write to cfprefsd
# and adds the com.apple.quarantine extended attribute to every file it
# creates. launchd refuses to load quarantined property list files on macOS 27
# and higher.
if [[ ! -f "${launch_daemon_plist_source}" ]]; then
  echo "Missing ${launch_daemon_plist_source}, keeping the existing LaunchDaemon"
  exit 1
fi

# Remove any existing property list first. Overwriting in place reuses the
# existing inode and keeps its extended attributes, including a quarantine
# attribute left behind by an earlier version of this script.
rm -f "${launch_daemon_plist}"

# Copy without extended attributes or resource forks. The source comes from the
# signed and notarized app bundle and is not quarantined, -X guarantees nothing
# is carried over.
cp -X "${launch_daemon_plist_source}" "${launch_daemon_plist}"

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