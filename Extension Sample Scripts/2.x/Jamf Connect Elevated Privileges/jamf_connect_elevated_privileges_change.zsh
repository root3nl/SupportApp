#!/bin/zsh --no-rcs

# Support App Extension - Jamf Connect Elevated Privileges Change
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# Support App Extension to change the Jamf Connect Elevated Privileges Status
#
# REQUIREMENTS:
# - Jamf Connect
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

# Start spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingB -bool true

# Replace value with placeholder while loading
defaults write "${preference_file_location}" ExtensionValueB -string "KeyPlaceholder"

# Get the username of the currently logged in user
username=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# Check if user is administrator
is_admin=$(dsmemberutil checkmembership -U "${username}" -G admin)

# Change permissions
if [[ ${is_admin} != *not* ]]; then
  sudo -u ${username} /usr/local/bin/jamfconnect acc-promo --demote
else
  sudo -u ${username} /usr/local/bin/jamfconnect acc-promo --elevate
fi

# Run script to populate new values in Extension
/usr/local/bin/user_permissions.zsh
