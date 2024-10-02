#!/bin/zsh --no-rcs

# Install Support App Extension - User Permissions
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
# - ExtensionTitleA: Account Privileges
# - ExtensionSymbolA: wallet.pass.fill
# - ExtensionTypeA: PrivilegedScript
# - ExtensionLinkA: /usr/local/bin/user_permissions.zsh
# - OnAppearAction: /usr/local/bin/user_permissions.zsh
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ------------------    edit the variables below this line    ------------------

# Local script path to create
path_to_script="/usr/local/bin/user_permissions.zsh"

# Set Support App Extension A or B
extension_label="B"

# ---------------------    do not edit below this line    ----------------------

# Script directory
script_directory=$(dirname "${path_to_script}")

# Create directory if it doesn't exist yet
if [[ ! -d "${script_directory}" ]]; then
  mkdir -p "${script_directory}"
fi

# Write local script
cat > "${path_to_script}" <<EOF

#!/bin/zsh --no-rcs

# Support App Extension - User Permissions
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# Support App Extension to get the current user permission schema.
#
# REQUIREMENTS: -
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
defaults write "\${preference_file_location}" ExtensionLoading${extension_label} -bool true

# Replace value with placeholder while loading
defaults write "\${preference_file_location}" ExtensionValue${extension_label} -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Get the username of the currently logged in user
username=\$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print \$3 }')

# Check if user is administrator
is_admin=\$(dsmemberutil checkmembership -U "\${username}" -G admin)

# Set Extension value
if [[ \${is_admin} != *not* ]]; then
  defaults write "\${preference_file_location}" ExtensionValue${extension_label} -string "Administrator"
else
  defaults write "\${preference_file_location}" ExtensionValue${extension_label} -string "Standard User"
fi

# Stop spinning indicator
defaults write "\${preference_file_location}" ExtensionLoading${extension_label} -bool false

EOF

# Set owner and permissions
chown root:wheel "${path_to_script}"
chmod 755 "${path_to_script}"