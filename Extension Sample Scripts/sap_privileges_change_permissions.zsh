#!/bin/zsh

# Support App Extension - SAP Privileges Change Permissions
#
#
# Copyright 2022 Root3 B.V. All rights reserved.
#
# Support App Extension to change user permissions with SAP Privileges.
#
# REQUIREMENTS:
# - Jamf Pro Binary
# - SAP Privileges: https://github.com/SAP/macOS-enterprise-privileges
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ---------------------    do not edit below this line    ----------------------

# Support App preference plist
preference_file_location="/Library/Preferences/nl.root3.support.plist"

# SAP Privileges CLI
sap_privileges_cli="/Applications/Privileges.app/Contents/macOS/PrivilegesCLI"

# Start spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingB -bool true

# Replace value with placeholder while loading
defaults write "${preference_file_location}" ExtensionValueB -string "KeyPlaceholder"

# Get the username and uid of the currently logged in user
username=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
uid=$(id -u "$username")

# Check if user is administrator
is_admin=$(dsmemberutil checkmembership -U "${username}" -G admin)

# Change permissions
if [[ ${is_admin} != *not* ]]; then
  launchctl asuser "$uid" sudo -u ${username} ${sap_privileges_cli} --remove
else
  launchctl asuser "$uid" sudo -u ${username} ${sap_privileges_cli} --add
fi

# Run Support App Extension to report new permission status
"/usr/local/bin/user_permissions.zsh"
