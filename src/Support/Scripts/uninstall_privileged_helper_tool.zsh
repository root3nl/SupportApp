#!/bin/zsh --no-rcs

# Uninstall Privileged Helper Tool
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# This script will uninstall the Privileged Helper Tool.
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

# Remove Privileged Helper Tool
if [[ -f "${privileged_helper_tool}" ]]; then
	rm -f "${privileged_helper_tool}"
fi

# Unload LaunchDaemon
if launchctl print "system/${launch_daemon}" &> /dev/null ; then
  launchctl bootout "system/${launch_daemon}" &> /dev/null
fi

# Remove LaunchDaemon
if [[ -f "/Library/LaunchDaemons/${launch_daemon}.plist" ]]; then
  rm -f "/Library/LaunchDaemons/${launch_daemon}.plist"
fi