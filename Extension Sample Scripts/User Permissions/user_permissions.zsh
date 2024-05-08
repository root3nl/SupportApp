#!/bin/zsh --no-rcs

# Support App Extension - User Permissions
#
#
# Copyright 2022 Root3 B.V. All rights reserved.
#
# Support App Extension to get the current user permission schema.
#
# REQUIREMENTS:
# - Jamf Pro Binary
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

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Get the username of the currently logged in user
username=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# Check if user is administrator
is_admin=$(dsmemberutil checkmembership -U "${username}" -G admin)

# Change permissions
if [[ ${is_admin} != *not* ]]; then
  defaults write "${preference_file_location}" ExtensionValueB -string "Administrator"
else
  defaults write "${preference_file_location}" ExtensionValueB -string "Standard User"
fi

# Stop spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingB -bool false
