#!/bin/zsh --no-rcs

# Install Support App Extension - macOS Security Compliance Project Failed 
# Results Count
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# This script will install the Support App Extension script to get the current 
# user permission schema. Use this script with your management solution to 
# install it locally on the Mac and set the proper permissions.
#
# REQUIREMENTS:
# - An active mSCP baseline
#
# EXAMPLE:
# Here's an example how to configure the Support App preferences for Extension A
# - ExtensionTitleA: Compliance
# - ExtensionSymbolA: lock.fill
# - ExtensionTypeA: PrivilegedScript
# - ExtensionLinkA: /usr/local/bin/mscp_compliance_status.sh
# - OnAppearAction: /usr/local/bin/mscp_run_remediation.zsh
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ------------------    edit the variables below this line    ------------------

# Local script path to create. Script to check Jamf Pro last check-in time.
path_to_check_script="/usr/local/bin/mscp_compliance_status.sh"

# Local script path to create. Script to perform Jamf Pro check-in
path_to_action_script="/usr/local/bin/mscp_run_remediation.zsh"

# Set Support App Extension A or B
extension_label="B"

# -----------------   Install script to check mSCP status    -------------------

# Script directory
script_directory=$(dirname "${path_to_check_script}")

# Create directory if it doesn't exist yet
if [[ ! -d "${script_directory}" ]]; then
  mkdir -p "${script_directory}"
fi

# Write local script
cat > "${path_to_check_script}" <<EOF

#!/bin/bash

# Support App Extension - macOS Security Compliance Project Failed Results Count
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
# This script is based on a script copyrighted by Jamf Software, LLC (2022).
# Original project: https://github.com/usnistgov/macos_security 
#
# Support App Extension to show the number of issues from a macOS Security
# Compliance Project Baseline. Result is published to Extension A and triggers
# a warning in the menu bar icon and extension when there are 1 or more issues.
#
# REQUIREMENTS:
# - An active mSCP baseline
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ---------------------    do not edit below this line    ----------------------

audit=\$(ls -l /Library/Preferences | /usr/bin/grep 'org.*.audit.plist' | /usr/bin/awk '{print \$NF}')
EXEMPT_RULES=()
FAILED_RULES=()

if [[ ! -z "\$audit" ]]; then

    count=\$(echo "\$audit" | /usr/bin/wc -l | /usr/bin/xargs)
    if [[ "\$count" == 1 ]]; then
    
        # Get the Exemptions
        exemptfile="/Library/Managed Preferences/\${audit}"
        if [[ ! -e "\$exemptfile" ]];then
            exemptfile="/Library/Preferences/\{audit}"
        fi

        rules=(\$(/usr/libexec/PlistBuddy -c "print :" "\${exemptfile}" | /usr/bin/awk '/Dict/ { print \$1 }'))
        
        for rule in \${rules[*]}; do
            if [[ \$rule == "Dict" ]]; then
                continue
            fi
            EXEMPTIONS=\$(/usr/libexec/PlistBuddy -c "print :\$rule:exempt" "\${exemptfile}" 2>/dev/null)
            if [[ "\$EXEMPTIONS" == "true" ]]; then
                EXEMPT_RULES+=(\$rule)
            fi
        done
        
        unset \$rules

        # Get the Findings
        auditfile="/Library/Preferences/\${audit}"
        rules=(\$(/usr/libexec/PlistBuddy -c "print :" "\${auditfile}" | /usr/bin/awk '/Dict/ { print \$1 }'))
        
        for rule in \${rules[*]}; do
            if [[ \$rule == "Dict" ]]; then
                continue
            fi
            FINDING=\$(/usr/libexec/PlistBuddy -c "print :\$rule:finding" "\${auditfile}")
            if [[ "\$FINDING" == "true" ]]; then
                FAILED_RULES+=(\$rule)
            fi
        done
        # count items only in Findings
        count=0
        for finding in \${FAILED_RULES[@]}; do
            if [[ ! " \${EXEMPT_RULES[*]} " =~ " \${finding} " ]] ;then
                ((count=count+1))
            fi
        done
    else
        count="-2"
    fi
else
    count="-1"
fi

#### Support App integration ####

# Start spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoading${extension_label} -bool true

# Show placeholder value while loading
defaults write /Library/Preferences/nl.root3.support.plist ExtensionValue${extension_label} -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Set compliance status. If there are 1 or more issues, show the issue count and trigger warning in menu bar icon and info item
if [[ \${count} -gt 0 ]]; then
    defaults write "/Library/Preferences/nl.root3.support.plist" ExtensionValue${extension_label} "Your \\\$LocalModelShortName has \${count} issues"
    defaults write "/Library/Preferences/nl.root3.support.plist" ExtensionAlert${extension_label} -bool true
else
    defaults write "/Library/Preferences/nl.root3.support.plist" ExtensionValue${extension_label} "Your \\\$LocalModelShortName is secure"
    defaults write "/Library/Preferences/nl.root3.support.plist" ExtensionAlert${extension_label} -bool false
fi

# Stop loading effect
defaults write "/Library/Preferences/nl.root3.support.plist" ExtensionLoading${extension_label} -bool false

EOF

# Set owner and permissions
chown root:wheel "${path_to_check_script}"
chmod 755 "${path_to_check_script}"

# ---------------    Install script to run mSCP remediation    -----------------

# Script directory
script_directory=$(dirname "${path_to_action_script}")

# Create directory if it doesn't exist yet
if [[ ! -d "${script_directory}" ]]; then
  mkdir -p "${script_directory}"
fi

# Write local script
cat > "${path_to_action_script}" <<EOF

#!/bin/zsh --no-rcs

# Support App Extension - macOS Security Compliance Project Remediation
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# Support App Extension to run macOS Security Compliance Project Remediation.
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

# Policy custom trigger
custom_trigger="mscp_remediation"

# ---------------------    do not edit below this line    ----------------------

# Support App preference plist
preference_file_location="/Library/Preferences/nl.root3.support.plist"

# Start spinning indicator
defaults write "\${preference_file_location}" ExtensionLoading${extension_label} -bool true

# Replace value with placeholder while loading
defaults write "\${preference_file_location}" ExtensionValue${extension_label} -string "Remediating..."

# Call the Jamf Pro custom trigger with remediation policy
/usr/local/bin/jamf policy -event \${custom_trigger}

# Run script to populate new values in Extension
"${path_to_check_script}"

EOF

# Set owner and permissions
chown root:wheel "${path_to_action_script}"
chmod 755 "${path_to_action_script}"