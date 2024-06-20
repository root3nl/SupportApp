#!/bin/zsh --no-rcs

# Build Support App Package
#
#
# Copyright 2024 Root3 B.V. All rights reserved.
#
# This script will build the Support App package
#
# USAGE:
# - GitHub Actions
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

# Current directory
current_directory=$(dirname $0)

# App Version
version=$1

# Apple ID used to notarize the package
apple_id=$2

# Apple ID password
apple_id_app_specific_password=$3

# App Name
app_name="Support"

# App Bundle Identifier
bundle_identifier="nl.root3.support"

# Path to folder with payload
payload="${current_directory}/pkgbuild/payload"

# Path to folder with scripts
scripts="${current_directory}/pkgbuild/scripts"

# Path to Component plist
component_plist="${current_directory}/pkgbuild/Support-component.plist"

# Requirements plist
requirements_plist="${current_directory}/pkgbuild/requirements.plist"

# Distribution xml
distribution_xml="${current_directory}/pkgbuild/distribution.xml"

# Install location
install_location="/Applications"

# Developer ID Installer certificate from Keychain
signing_identity="Developer ID Installer: Root3 B.V. (98LJ4XBGYK)"

# Name of the Keychain profile used for notarytool
keychain_profile="Root3"

# ---------------------    do not edit below this line    ----------------------

# Set Xcode version to latest version available
xcode_version=$(ls -d /Applications/Xcode*.app 2>/dev/null | sort -V | tail -n 1)
echo "Path to latest Xcode version: ${xcode_version}"

# Create directory
mkdir -p "${current_directory}/${app_name}"

# Create directory
if [[ ! -d "${payload}" ]]; then
    echo "Creating ${payload}"
    mkdir "${payload}"
fi

# Move app bundle to payload folder
cp -r "${current_directory}/build/${app_name}.app" "${payload}"

# Set credentials for notarization
"${xcode_version}/Contents/Developer/usr/bin/notarytool" store-credentials --apple-id "${apple_id}" --team-id "98LJ4XBGYK" --password "${apple_id_app_specific_password}" "${keychain_profile}"

# Build and sign pkg
pkgbuild --component-plist "${component_plist}" \
    --root "${payload}" \
    --scripts "${scripts}" \
    --install-location "${install_location}" \
    --identifier "${bundle_identifier}" \
    --version "${version}" \
    "${current_directory}/${app_name}/${app_name}_component.pkg"

# Create distribution package to support InstallApplication MDM command
productbuild --distribution "${distribution_xml}" \
    --package-path "${current_directory}/${app_name}/" \
    "${current_directory}/${app_name}/${app_name} ${version}_dist.pkg"

# Sign package
productsign --sign "${signing_identity}" \
    "${current_directory}/${app_name}/${app_name} ${version}_dist.pkg" \
    "${current_directory}/${app_name}/${app_name} ${version}.pkg"

# Submit pkg to notarytool
"${xcode_version}/Contents/Developer/usr/bin/notarytool" submit "${current_directory}/${app_name}/${app_name} ${version}.pkg" \
    --keychain-profile "${keychain_profile}" \
    --wait

# Staple the notarization ticket to the pkg
"${xcode_version}/Contents/Developer/usr/bin/stapler" staple "${current_directory}/${app_name}/${app_name} ${version}.pkg"

# Check the notarization ticket validity
spctl --assess -vv --type install "${current_directory}/${app_name}/${app_name} ${version}.pkg"

# Move package to build folder
mv "${current_directory}/${app_name}/${app_name} ${version}.pkg" "${current_directory}/build"