#!/bin/zsh --no-rcs

# Install Support App Extension - Jamf Last Check-in
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# This script will install the Support App Extension script to get the current 
# user permission schema. Use this script with your management solution to 
# install it locally on the Mac and set the proper permissions.
#
# REQUIREMENTS: -
#
# EXAMPLE:
# Here's an example how to configure the Support App preferences for Extension A
# - ExtensionTitleA: Last Check-In
# - ExtensionSymbolA: clock.badge.checkmark.fill
# - ExtensionTypeA: PrivilegedScript
# - ExtensionLinkA: /usr/local/bin/jamf_check-in.zsh
# - OnAppearAction: /usr/local/bin/jamf_last_check-in_time.zsh
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ------------------    edit the variables below this line    ------------------

# Local script path to create. Script to check Jamf Pro last check-in time.
path_to_check_script="/usr/local/bin/jamf_last_check-in_time.zsh"

# Local script path to create. Script to perform Jamf Pro check-in
path_to_action_script="/usr/local/bin/jamf_check-in.zsh"

# Set Support App Extension A or B
extension_label="A"

# ----------    Install script to check Jamf Pro last check-in    --------------

# Script directory
script_directory=$(dirname "${path_to_check_script}")

# Create directory if it doesn't exist yet
if [[ ! -d "${script_directory}" ]]; then
  mkdir -p "${script_directory}"
fi

# Write local script
cat > "${path_to_check_script}" <<EOF

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
defaults write "\${preference_file_location}" ExtensionLoading${extension_label} -bool true

# Replace value with placeholder while loading
defaults write "\${preference_file_location}" ExtensionValue${extension_label} -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Get last Jamf Pro check-in time from jamf.log
last_check_in_time=\$(grep "Checking for policies triggered by \"recurring check-in\"" "/private/var/log/jamf.log" | tail -n 1 | awk '{ print \$2,\$3,\$4 }')

# Convert last Jamf Pro check-in time to epoch
last_check_in_time_epoch=\$(date -j -f "%b %d %T" "\${last_check_in_time}" +"%s")

# Convert last Jamf Pro epoch to something easier to read
if [[ "\${twenty_four_hour_format}" == "true" ]]; then
  # Outputs 24 hour clock format
  last_check_in_time_human_reable=\$(date -r "\${last_check_in_time_epoch}" "+%A %H:%M")
else
  # Outputs 12 hour clock format
  last_check_in_time_human_reable=\$(date -r "\${last_check_in_time_epoch}" "+%A %I:%M %p")
fi

# Write output to Support App preference plist
defaults write "\${preference_file_location}" ExtensionValue${extension_label} -string "\${last_check_in_time_human_reable}"

# Stop spinning indicator
defaults write "\${preference_file_location}" ExtensionLoading${extension_label} -bool false

EOF

# Set owner and permissions
chown root:wheel "${path_to_check_script}"
chmod 755 "${path_to_check_script}"

# -------------    Install script to perform Jamf Pro check-in    --------------

# Script directory
script_directory=$(dirname "${path_to_action_script}")

# Create directory if it doesn't exist yet
if [[ ! -d "${script_directory}" ]]; then
  mkdir -p "${script_directory}"
fi

# Write local script
cat > "${path_to_action_script}" <<EOF

#!/bin/zsh --no-rcs

# Support App Extension - Jamf Pro Check-in
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# Support App Extension to perform a Jamf Pro check-in
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
defaults write "\${preference_file_location}" ExtensionLoading${extension_label} -bool true

# Replace value with placeholder while loading
defaults write "\${preference_file_location}" ExtensionValue${extension_label} -string "Checking in..."

# Perform a Jamf Pro check-in
/usr/local/bin/jamf policy

# Run script to populate new values in Extension
"${path_to_check_script}"

EOF

# Set owner and permissions
chown root:wheel "${path_to_action_script}"
chmod 755 "${path_to_action_script}"