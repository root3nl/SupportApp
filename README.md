# macOS Support App

![GitHub release (latest by date)](https://img.shields.io/github/v/release/root3nl/SupportApp?color=success)
[![Static Badge](https://img.shields.io/badge/SwiftUI-524520?logo=swift)](https://developer.apple.com/xcode/swiftui/)
![Github](https://img.shields.io/badge/macOS-14%2B-green)

<img src="/Screenshots/hero_light.png" width="800">

<img src="/Screenshots/hero_dark.png" width="800">

- [Introduction](#introduction)
- [Advanced configuration](#advanced-configuration)
  * [Variables](#variables)
    * [Built-in local variables](#built-in-local-variables)
    * [MDM variables](#mdm-variables)
      * [Jamf Pro variables](#jamf-pro-variables)
  * [Privileged scripts](#privileged-scripts)
    * [Use Cases](#use-cases)
    * [Disabling or re-enabling](#disabling-or-re-enabling)
    * [File locations](#file-locations)
    * [Security Considerations](#security-considerations)
- [How to use SF Symbols](#how-to-use-sf-symbols)
- [MDM deployment](#mdm-deployment)
  * [Jamf Pro](#jamf-pro)
  * [Microsoft Intune](#microsoft-intune)
  * [Installer or app bundle](#installer-or-app-bundle)
  * [Sample LaunchAgent](#sample-launchagent)
  * [Sample Configuration Profile](#sample-configuration-profile)
  * [Managed Login Item](#managed-login-item)
- [Logging](#logging)

## Introduction
The Support App is a macOS menu bar app designed to assist organizations in various ways:

* **User and help desk support:** The app provides users and helpdesks with easy access to basic diagnostic information, enabling them to proactively address and resolve minor issues efficiently.
* **Access to support channels and resources:** Users can conveniently access support channels, company resources such as websites, applications, and file servers through the app.
* **Modern and native macOS app:** The app offers a visually appealing and native macOS experience, incorporating your corporate identity.

Support App is developed by Root3, an organization specialized in managing Apple devices based in Halfweg, The Netherlands. Root3 provides managed workplaces, consultancy, and support services to organizations, helping them maximize the benefits of their Apple devices.

Support App was publicly released in 2020 and had since then become a popular tool and used within organizations all over the world.

The most straightforward and recommended way to configure the app is through a Configuration Profile and your Device Management Service.

### Privileged scripts
To allow scripts to be executed with elevated privileges, the Support App has a built-in Privileged Helper Tool. This upgrade over the deprecated SupportHelper makes sure communication is transmitted more securely between the main app the the built-in Privileged Helper Tools with additional checks such as code requirement and scripts must have proper permissions and owner. The script must me owned by `root` and have 755 permissions. Additionally, only paths to a script set in a Configuration Profile will be executed. Values set with `defaults write` are not supported.

> **Warning**
> Because the script permissions are checked before execution, commands are not supported anymore as of version 2.6.

Below an example to force a MDM check-in using a custom script:

<img src="/Screenshots/generic_version_2.4_beta.gif" width="800">

#### Use Cases
There are a couple of use cases where privileged scripts can help. For example run a command or script with root privileges:
* Every time the Support App popover appears, populate Support App Extensions using `OnAppearAction`
* Extension Attributes (Jamf Pro) by adding the commands to populate the Support App Extension to the EA:
  * Show device compliance information, such as the macOS Security Compliance Project Failed Results Count
* Executing a background task by clicking on a configurable button. Some examples:
  * Request an MDM check-in or inventory depending on your MDM solution
  * Requesting temporary admin permissions (for example in conjuntion with SAP Privileges)
  * Collecting logs such as `sudo sysdiagnose` and sending the output somewhere else
  * Run device compliance remediation, such as the macOS Security Compliance Project Remediation Script
  * Any other action requiring root privileges, especially when users have standard permissions

#### Disabling or re-enabling
By default, the Privileged Helper Tool is automatically enabled when using the PKG installer. To opt-out, set the key `DisablePrivilegedHelperTool` to `true` during the time of installation. Also at launch of the Support App, the Privileged Helper Tool will be removed when the key is set. Please also note that for the App Catalog integration, the Privileged Helper Tool is a requirement.

Additionally the Support App app bundle comes with scripts to manually disable or re-enable the Privileged Helper Tool. For example when you accidentaly used or misconfigured the `DisablePrivilegedHelperTool` key, or chose to (not) use it at a later time:
* Disable: `/Applications/Support.app/Contents/Resources/uninstall_privileged_helper_tool.zsh`
* Re-enable: `/Applications/Support.app/Contents/Resources/install_privileged_helper_tool.zsh`

For example, you can run those scripts locally of by your MDM solution. You can verify the Privileged Helper Tool is enabled by checking the file locations mentioned in [File locations](#file-locations).

#### File locations
The Support App installs some files related to the Privileged Helper Tool:

Privileged Helper Tool: `/Library/PrivilegedHelperTools/nl.root3.support.helper`

LaunchDaemon: `/Library/LaunchDaemons/nl.root3.support.helper.plist`

#### Security considerations
As the Support App is able to execute scripts elevated privileges, it needs to be used responsibly. Usually it is only needed for more advanced workflows such as querying additional information in real time, interact with other applications and more. Treat it carefully and only use the `PrivilegedScript` key when you really need elevated privileged.

> **Note**
> Only values from a Configuration Profile will be used. Values set by `defaults write` will be ignored as it imposes a potential security risk.

### Variables

You can use variables to dynamically populate text fields, like the title, footer, buttons or any other text field. You have the option to use Local Variables built-in the Support App and are MDM agnostic, or use MDM specific variables if available in your MDM solution.

> **Note**
> Using Built-in Local Variables or MDM variables depends on the use case you want to achieve or the available variables and you may use both if needed.

#### Built-in local variables
The Support App supports local variables with device and user details and work independently from your MDM solution.

The following built-in local variables are available with an example:
* **$LocalComputerName**: the current computer name/hostname
* **$LocalModelName**: the model name, like MacBook Air (M2, 2022). Apple Silicon only
* **$LocalModelShortName**: the short model name like MacBook or iMac
* **$LocalFullName**: the full name of the local macOS user account
* **$LocalUserName**: the username of the local macOS user account
* **$LocalMacosVersion**: the macOS version, like 13.4.1
* **$LocalMacosVersionName**:  the macOS version marketing name, like Ventura or Sonoma
* **$LocalSerialNumber**: the devices serial number
* **$LocalIpAddress**: the current IP address
* **$LocalUpdatesAvailable**: the number of updates available

Examples
* Set `title` to: "Hi $LocalFullName!"
* Set `FooterText` to: "Provided by IT with ❤️\nSerial Number: $LocalSerialNumber"
* Set `UpdateText` including Markdown features to: "Your $LocalModelShortName has \**$LocalUpdatesAvailable update(s)** available. Please update as soon as possible.\n\[More info](https://LINK-TO-UPDATE-POLICY)"

> **Note**
> Built-in local variables are case **sensitive**

#### MDM variables

##### Jamf Pro variables
When using Jamf Pro as the MDM solution, variables from Jamf Pro can also be used in the Configuration Profile values to dynamically populate text fields.

Example
* Set `title` to "Hi $FULLNAME!"

More information about Jamf variables: https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Computer_Configuration_Profiles.html

## How to use SF Symbols
We choose to go all the way with SF Symbols as these good looking icons are designed by Apple and give the app a native look and feel. All icons have a symbol name which you can use in the Configuration Profile. As these icons are built into macOS, it automatically shows the correct icon.

* Download SF Symbols [**here**](https://developer.apple.com/sf-symbols/)
* Select the icon you’d like to use
* Copy the symbol name and paste into your Configuration Profile

<img src="/Screenshots/how_to_use_sf_symbols.png" width="800">

## MDM deployment
It is recommended to deploy the Configuration Profile first before installing the Support app.

### Jamf Pro
A Jamf Pro Manifest for Jamf Pro is provided for easy configuration of all the preference keys without creating/modifying a custom Configuration Profile in XML format. Download the JSON file [**here**](https://github.com/root3nl/SupportApp/blob/master/Jamf%20Pro%20Custom%20Schema/Jamf%20Pro%20Custom%20Schema.json)

More information about the JSON Schema feature in Jamf Pro: https://docs.jamf.com/technical-papers/jamf-pro/json-schema/10.19.0/Overview.html

<img src="/Screenshots/jamf_pro_custom_schema.png" width="800">

### Microsoft Intune
Configuring the Support App for Microsoft Intune is the easiest with the following steps:
* Prepare the plist file with your key values and save as nl.root3.support.plist. Check the example file below:

```
<key>Title</key>
<string>Hi $LocalFullName!</string>
<key>Logo</key>
<string>/PATH/TO/IMAGE</string>
<key>LogoDarkMode</key>
<string>/PATH/TO/IMAGE</string>
<key>NotificationIcon</key>
<string>/PATH/TO/IMAGE</string>
<key>StatusBarIconNotifierEnabled</key>
<true/>
...
```

* Log into intune.microsoft.com > Devices > macOS > Configuration > Create > New Policy
* Choose for Templates > Preference file
* Set the preference domain to `nl.root3.support`
* Upload the property list
* Complete the Assignments and Save

<img width="1158" alt="microsoft_intune_configuration" src="https://github.com/user-attachments/assets/5a69e347-2019-4316-a688-635e0285e0c4">

### Installer or app bundle
Depending on your preference or MDM solution you can use either the installer or zipped app bundle. The installer includes a LaunchAgent and is the recommended method to make sure the app stays open and relaunches automatically.

### Sample LaunchAgent
A sample LaunchAgent to always keep the app alive is provided [**here**](https://github.com/root3nl/SupportApp/blob/master/LaunchAgent%20Sample/nl.root3.support.plist)

### Sample Configuration Profile
A sample Configuration Profile you can edit to your preferences is provided [**here**](https://github.com/root3nl/SupportApp/blob/master/Configuration%20Profile%20Samples/Support%20App%20Configuration%20Sample.mobileconfig)

### Managed Login Item
A sample Configuration Profile is provided (both signed and unsigned) for macOS 13 and higher to avoid users from disabling the LaunchAgent in System Settings > General > Login Items. The profile uses the Root3 Team ID to only allow signed software from Root3. [**Samples**](https://github.com/root3nl/SupportApp/blob/master/Configuration%20Profile%20Samples/Background%20Item%20Management)

## Logging
Logs can be viewed from Console or Terminal by filtering the subsystems `nl.root3.support` (Support App), `nl.root3.support.helper` (Privileged Helper Tool) and `nl.root3.catalog` (App Catalog).

An example to stream current logs in Terminal for troubleshooting:
```
log stream --debug --info --predicate 'subsystem CONTAINS "nl.root3.support"'
```

Or get logs from the last hour:
```
log show --last 24h --debug --info --predicate 'subsystem CONTAINS "nl.root3.support"'
```
