#!/bin/zsh --no-rcs

# Support App Extension - Jamf Pro Last Check-In Time
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# Support App Extension to get the Jamf Pro Last Check-In Time
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

# ------------------    edit the variables below this line    ------------------

# Enable 24 hour clock format. 12 hour clock enabled by default
twenty_four_hour_format="true"

# ---------------------    do not edit below this line    ----------------------

# Support App preference plist
preference_file_location="/Library/Preferences/nl.root3.support.plist"

# Start spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingA -bool true

# Replace value with placeholder while loading
defaults write "${preference_file_location}" ExtensionValueA -string "Checking in..."

# Perform a Jamf Pro check-in
/usr/local/bin/jamf policy

# Run script to populate new values in Extension
/usr/local/bin/jamf_last_check-in_time.zsh