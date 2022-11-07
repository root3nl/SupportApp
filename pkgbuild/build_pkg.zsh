#!/bin/zsh

# Build Support App Package
#
#
# Copyright 2022 Root3 B.V. All rights reserved.
#
# This script will build the Support App Package
#
# USAGE:
# - Make sure an Keychain profile is stored for notarytool
# - Export .app to pkguild folder
# - Navigate to folder: pkgbuild/payload
# - Run the script
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# ------------------    edit the variables below this line    ------------------

# Exit on error
set -e

# App Name
app_name="Support"

# App Bundle Identifier
bundle_identifier="nl.root3.support"

# App Version
version="2.4.2"

# Path to folder with payload
payload="payload"

# Path to folder with scripts
scripts="scripts"

# Path to Component plist
component_plist="Support-component.plist"

# Install location
install_location="/Applications"

# Developer ID Installer certificate from Keychain
signing_identity="Developer ID Installer: Root3 B.V. (98LJ4XBGYK)"

# Name of the Keychain profile used for notarytool
keychain_profile="Root3"

# ---------------------    do not edit below this line    ----------------------

# Get the username of the currently logged in user
username=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# NFS Home Directory of user
nfs_home_directory=$(dscl . read /Users/${username} NFSHomeDirectory | awk '{print $2}')

# Build, sign and export pkg to Downloads folder
pkgbuild --component-plist "${component_plist}" \
    --root "${payload}" \
    --scripts "${scripts}" \
    --install-location "${install_location}" \
    --identifier "${bundle_identifier}" \
    --sign "${signing_identity}" \
    --version "${version}" \
    "${nfs_home_directory}/Downloads/${app_name} ${version}.pkg"

# Submit pkg to notarytool
xcrun notarytool submit "${nfs_home_directory}/Downloads/${app_name} ${version}.pkg" \
    --keychain-profile "${keychain_profile}" \
    --wait

# Staple the notarization ticket to the pkg
xcrun stapler staple "${nfs_home_directory}/Downloads/${app_name} ${version}.pkg"

# Check the notarization ticket validity
spctl --assess -vv --type install "${nfs_home_directory}/Downloads/${app_name} ${version}.pkg"
