#!/bin/zsh

# Support App Extension - Battery Condition
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# Support App Extension to get the battery condition and publish to
# Extension B.
#
# REQUIREMENTS:
# - Jamf Pro Binary
#
# EXAMPLE:
# Here's an example how to configure the Support App preferences for Extension A
# - ExtensionTitleA: Battery Condition
# - ExtensionSymbolA: battery.75percent
# - ExtensionTypeA: PrivilegedScript
# - ExtensionLinkA: -
# - OnAppearAction: /usr/local/bin/battery_condition.zsh
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

# Get the battery condition
battery_condition=$(system_profiler SPPowerDataType | sed -n -e 's/^.*Condition: //p')

# Write output to Support App preference plist
defaults write "${preference_file_location}" ExtensionValueB -string "${battery_condition}"

# Stop spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingB -bool false
