# macOS Support App

![GitHub release (latest by date)](https://img.shields.io/github/v/release/root3nl/SupportApp?color=success)
![Github](https://img.shields.io/badge/macOS-11%2B-green)
[![Github](https://img.shields.io/badge/Join-TestFlight-blue)](https://testflight.apple.com/join/asmgJsAM)

<img src="/Screenshots/generic_version_2.4.png" width="800">

<img src="/Screenshots/generic_version_2.1_small.png" width="450"> <img src="/Screenshots/generic_light_mode_cropped.png" width="450"> <img src="/Screenshots/generic_version_2.3_small_dark.png" width="450">

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Download](#download)
  * [TestFlight](#testflight)
- [Technologies](#technologies)
- [Features](#features)
  * [Menu Bar Icon](#menu-bar-icon)
  * [Title and logo](#title-and-logo)
  * [Color](#color)
  * [Diagnostic information](#diagnostic-information)
  * [App, link or command shortcuts](#app-link-or-command-shortcuts)
  * [Footer Text](#footer-text)
  * [Notification Icon](#notification-icon)
  * [Welcome Screen](#welcome-screen)
- [Configuration](#configuration)
- [Advanced configuration](#advanced-configuration)
  * [How to populate Support App Extensions](#how-to-populate-support-app-extensions)
  * [Jamf Pro variables](#jamf-pro-variables)
  * [Privileged commands or scripts (SupportHelper)](#privileged-commands-or-scripts-supporthelper)
    * [File locations](#file-locations)
    * [Security Considerations](#security-considerations)
- [How to use SF Symbols](#how-to-use-sf-symbols)
- [MDM deployment](#mdm-deployment)
  * [Jamf Pro custom JSON Schema](#jamf-pro-custom-json-schema)
  * [Installer or app bundle](#installer-or-app-bundle)
  * [Sample LaunchAgent](#sample-launchagent)
  * [Sample Configuration Profile](#sample-configuration-profile)
- [Logging](#logging)
- [Known issues](#known-issues)
- [Changelog](#changelog)
- [Privacy policy](#privacy-policy)
- [Note and disclaimer](#note-and-disclaimer)

## Introduction
The Support app is a macOS menu bar app built for organizations to:
* Help users and helpdesks to see basic diagnostic information at a glance and proactively notify them to easily fix small issues.
* Offer shortcuts to easily access support channels or other company resources such as a website or a file server
* Give users a modern and native macOS app with your corporate identity

The app is developed by Root3, specialized in managing Apple devices. Root3 offers consultancy and support for organizations to get the most out of their Apple devices and is based in The Netherlands (Halfweg).

Root3 already had a basic in-house support app written in Objective-C and decided to completely rewrite it in Swift using SwiftUI with an all-new design that looks great on macOS Big Sur. We’ve learned that SwiftUI is the perfect way of creating great looking apps for all Apple platforms with minimal effort. In the development process we decided to make it generic so other organizations can take advantage of it and contribute to the Mac admins community.


The easiest and recommended way to configure the app is using a Configuration Profile and your MDM solution.

## Requirements
* macOS 11.0.1 or higher
* Any MDM solution supporting custom Configuration Profiles

## Download

### Support App
Package Installer (includes LaunchAgent): [**Download**](https://github.com/root3nl/SupportApp/releases/latest)

Application (zipped): [**Download**](https://github.com/root3nl/SupportApp/releases/latest)

See the MDM deployment section below for more info.

### SupportHelper
Package Installer (includes LaunchDaemon): [**Download**](https://github.com/root3nl/SupportApp/releases/latest)

### TestFlight
You can participate in beta versions of Support App using TestFlight. This requires macOS 12 or higher.

[**Join TestFlight**](https://testflight.apple.com/join/asmgJsAM)

Note: There may not always be a TestFlight version available.

## Technologies
* Written in Swift using SwiftUI
* All icons are SF Symbols
* Built for and compatible with macOS 11.0 and higher
* Native support for Apple Silicon
* Dark Mode support
* Colors are matched with your macOS accent color (blue by default)
* MDM support to configure your own branding such as a custom title, logo, SF Symbols and contact methods
* Notarized
* Sandboxed
* Localized in English, Dutch, French and German

## Features

### Menu Bar Icon
The Menu Bar Icon can be customized to your own PNG with Alpha Channel or using an SF Symbol. Any image will be shown as template to match the rest of the Menu Bar Extras. Optionally a notification badge can overlay the icon to attract the user's attention when an Apple Software Update is available or any other warning was triggered. Please check the preference key "StatusBarIconNotifierEnabled".

### Title and logo
The row above the buttons allow a custom title and company logo. The title supports both text and Emoji. On macOS Monterey and higher, it supports Markdown as well. The logo supports several images types like PNG, JPEG and ICNS and will be resized to a maximum height of 48 points. The original aspect ratio will be retained. A PNG with alpha channel is advised to get variable transparency around your logo.

### Color
All the circles around the symbols have the macOS accent color and will dynamically change with the user's setting in System Preferences --> General. If desired, this color can be customised matching your corporate colors. We recommend keeping the macOS accent color when the color of your choice is too light, as text will be difficult to read.

### Diagnostic information
There are a couple of info items with diagnostics available to choose from. A total of four items will be displayed in the top four buttons. Available items:

* **Computer Name** (default): The current computer name will be displayed here. Especially helpful when your organisation has a difficult naming convention and users want to do things like AirDrop.

* **macOS version** (default): The current version of macOS including major, minor and patch version as well as the marketing name. The marketing name will be easier to understand for your end users. A notification badge will be shown when an Apple Software Update is available. Clicking on this item opens the Software Update preference pane.

* **Last Reboot** (default): The current uptime. When troubleshooting some issue, the first thing you would like to do is a reboot when the uptime is high. The optional preference key ‘UptimeDaysLimit’ can be used to configure the maximum amount of uptime days recommended by the organization. Exceeding this limit results in a badge counter with exclamation mark in the info item.

* **Storage Used** (default): The storage percentage used on the boot drive. When hovering with the mouse, the available storage is shown. Clicking on this item opens the macOS built-in Storage Management app. The optional preference key ‘StorageLimit’ can be used to configure the maximum percentage of used storage recommended by the organization. Exceeding this limit results in a badge counter with exclamation mark in the info item.

* **Network**: The current SSID or Ethernet along with the local IPv4 address. The icon indicates the connection type, Wi-Fi or Ethernet. Clicking on this item opens the Network preference pane in System Preferences.

* **Mac Password**: Shows when the user's password expires and supports both local and Active Directory accounts by default. Alternative supported user sources are Jamf Connect, Kerberos SSO Extension and NoMAD. Shows a warning when the expiry reaches the value set in the optional key 'PasswordExpiryLimit'. The text label in the item can be modified using the preference key ‘PasswordLabel’.

* **Extension A and B**: Support App Extensions to show any information. The title, icon must be configured and optionally a link to open an App, URL, User Command or Privileged Command/Script. The value below the title must be populated by setting a preference key using a script. See [How to populate Support App Extensions](#how-to-populate-support-app-extensions) for more information.

### App, link or command shortcuts
The buttons in the 3rd and 4th row behave as shortcuts to applications or links. Both rows are flexible and can show two or three buttons. The total amount of configurable buttons is possible: 0, 2, 3, 4, 5, 6. You can configure five variables for every of these buttons:

* **Title**: Button label

* **Subtitle** (now shown if not configured): An extra string to display when the user hovers over the button

* **Type**: The link type the button should open. The following action types are available:
  * App
  * URL
  * Command

* **Link**: Application, URL or command/script to execute:
  * App: Bundle Identifier of the app
  * URL: Link to a webpage or other links that would normaly work like PROTOCOL://URL
  * Command: Zsh command or path to a script. Be aware that this will be executed as the user and therefore has its limitations
  * DistributedNotification: Zsh command or path to a script to run with elevated privileges (requires SupportHelper)

* **Symbol**: The symbol shown in the button, see the SF Symbols section how to use these symbols

The rows with all configurable items enabled are shown in the screenshot below:
* Info items and Support App Extensions in **GREEN**
* Buttons in **RED**

<img src="/Screenshots/configurable_buttons_2.4.png" width="450">

### Footer Text
A footer text can optionally be used to put some additional text at the bottom of the Support App. This supports both text and Emoji. On macOS Monterey and higher, it supports Markdown.

### Notification Icon
The icon shown in alerts and the about window can be modified by using the preference key 'NotificationIcon'.

See an example below:

<img src="/Screenshots/custom_alert.png" width="350">

**Note**: modifying the app icon when it is not running would compromise the App Sandbox and we decided not to implement this. We suggest hiding the app by running the following command: `sudo chflags hidden "/Applications/Support.app"`

### Welcome Screen
An informational window can optionally be shown when the Support App is opened for the first time. It explains the key features to the user before all data is shown. This can be set using the preference key ‘ShowWelcomeScreen’.

See an example below:

<img src="/Screenshots/welcome_screen.png" width="500">

## Configuration
The configuration of the Support app is optimized for use with your MDM solution. The easiest way to configure the app is using a Configuration Profile so you can use whatever MDM solution you like, as long as it supports custom Configuration Profiles.

Some preference keys like the icon and status bar icon point to a file location. Due to the sandboxed characteristic of the app, not all file locations are allowed. We suggest putting the files in a folder within Application Support such as `/Library/Application Support/Your Company/` where the app can read the contents. Other supported file locations can be found in Apple’s documentation about App Sandbox: https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html#//apple_ref/doc/uid/TP40011183-CH3-SW17

**Preference domain**: `nl.root3.support`

Below are all available preference keys:

### General
All general settings
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| Title | String | Support | Text shown in the top left corner when the app opens. | “Your Company Name“, “IT Helpdesk“ etc. |
| Logo | String | App Icon | Path to the logo shown in the top right corner when the app opens. Scales to 48 points maximum height. A subfolder in `/Library/Application Support/` is the recommended location due to sandboxing | `/Library/Application Support/Your Company/logo.png` |
| LogoDarkMode | String | App Icon | Path to the logo shown in the top right corner when the app opens for Dark Mode. Scales to 48 points maximum height. A subfolder in `/Library/Application Support/` is the recommended location due to sandboxing | `/Library/Application Support/Your Company/logo_darkmode.png` |
| NotificationIcon | String | App Icon | Path to a custom square image to be shown in alerts and the about window. | `/Library/Application Support/Your Company/logo.png` |
| StatusBarIcon | String | Root3 Logo | Path to the status bar icon shown in the menu bar. Recommended: PNG, 16x16 points. A subfolder in `/Library/Application Support/` is the recommended location due to sandboxing | `/Library/Application Support/Your Company/statusbaricon.png` |
| StatusBarIconSFSymbol | String | Root3 Logo | Custom status bar icon using an SF Symbol. Ignored when StatusBarIcon is also set | “lifepreserver” |
| StatusBarIconNotifierEnabled | Boolean | false | Shows a small notification badge in the Status Bar Icon when an info items triggers a warning or notification | true |
| CustomColor | String | macOS Accent Color | Custom color for all symbols. Leave empty to use macOS Accent Color. We recommend not to use a very light color as text may become hard to read | HEX color in RGB format like "#8cc63f" |
| CustomColorDarkMode | String | macOS Accent Color | Custom color for all symbols in Dark Mode. Leave empty to use macOS Accent Color or CustomColor if specified. We recommend not to use a very dark color as text may become hard to read | HEX color in RGB format like "#8cc63f" |
| HideFirstRow | Boolean | false | Hides the first row of configurable items. | true |
| HideSecondRow | Boolean | false | Hides the second row of configurable items. | true |
| ErrorMessage | String | Please contact IT support | Shown when clicking an action results in an error | "Please contact the servicedesk", "Please contact COMPANY_NAME" |
| ShowWelcomeScreen | Boolean | false | Shows the welcome screen when the Support App is opened for the first time. | true |
| FooterText | String | - | Text shown at the bottom as footnote | "Provided by your **IT department** with ❤️" |
| OpenAtLogin | Boolean | true | Launch Support automatically at login and keep it open (macOS 13 and higher). This setting is ignored if a legacy LaunchAgent is installed/active. Disable this if you don't want to open Support at login or use your own LaunchAgent | false |

### Info items
Configuration of the top four items with diagnostic information.
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| InfoItemOne | String | ComputerName | Info item shown in the upper left corner | "ComputerName", "MacOSVersion", "Network", "Password", "Storage", "Uptime", "ExtensionA" or "ExtensionB" |
| InfoItemTwo | String | MacOSVersion | Info item shown in the upper right corner | "ComputerName", "MacOSVersion", "Network", "Password", "Storage", "Uptime", "ExtensionA" or "ExtensionB" |
| InfoItemThree | String | Uptime | Info item shown in the second row left | "ComputerName", "MacOSVersion", "Network", "Password", "Storage", "Uptime", "ExtensionA" or "ExtensionB" |
| InfoItemFour | String | Storage | Info item shown in the second row right | "ComputerName", "MacOSVersion", "Network", "Password", "Storage", "Uptime", "ExtensionA" or "ExtensionB" |
| InfoItemFive | String | - | Info item shown in the third row left | "ComputerName", "MacOSVersion", "Network", "Password", "Storage", "Uptime", "ExtensionA" or "ExtensionB" |
| InfoItemSix | String | - | Info item shown in the third row right | "ComputerName", "MacOSVersion", "Network", "Password", "Storage", "Uptime", "ExtensionA" or "ExtensionB" |
| UptimeDaysLimit | Integer | 0 (Disabled) | Days of uptime after which a notification badge is shown, disabled by default | 7 |
| PasswordType | String | Apple | The account type to use with the Password info item: local user account (Apple), Jamf Connect, Kerberos SSO Extension or NoMAD | "Apple", "JamfConnect", "KerberosSSO" or "Nomad" |
| PasswordExpiryLimit| Integer | 0 (Disabled) | Days until password expiry after which a notification badge is shown, disabled by default | 14 |
| PasswordLabel| String | Mac Password | Alternative text label shown in the Password info item | "AD Password", "Company Password" |
| StorageLimit | Integer | 0 (Disabled) | Percentage of storage used after which a notification badge is shown, disabled by default | 80 |

### First row of configurable items: Item left
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| FirstRowTitleLeft | String | Remote Support | The text shown in the button label. | “Share My Screen”, “TeamViewer“, “Software Updates“ “My core application” etc. |
| FirstRowSubtitleLeft | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open“, “Share your screen“ |
| FirstRowTypeLeft | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **DistributedNotification** (Privileged command/script)|
| FirstRowLinkLeft | String | com.apple.ScreenSharing | The Bundle Identifier of the App, URL or command to open. | “com.teamviewer.TeamViewerQS“ (App), “x-apple.systempreferences:com.apple.preferences.softwareupdate“ (URL) |
| FirstRowSymbolLeft | String | cursorarrow | The SF Symbol shown in the button. | “binoculars.fill”, “cursorarrow.click.2” or any other SF Symbol. Please check the SF Symbols section. |

### First row of configurable items: Item middle
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| FirstRowTitleMiddle | String | - | The text shown in the button label. | “Self Service“, “App Store“ |
| FirstRowSubtitleMiddle | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open”, “Download apps“ |
| FirstRowTypeMiddle | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **DistributedNotification** (Privileged command/script)|
| FirstRowLinkMiddle | String | - | The Bundle Identifier of the App, URL or command to open. | “com.jamfsoftware.selfservice.mac” |
| FirstRowSymbolMiddle | String | - | The SF Symbol shown in the button. | “briefcase.fill”, “bag.circle”, “giftcard.fill”, “gift.circle” or any other SF Symbol. Please check the SF Symbols section. |

### First row of configurable items: Item right
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| FirstRowTitleRight | String | Company Store | The text shown in the button label. | “Self Service“, “App Store“ |
| FirstRowSubtitleRight | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open”, “Download apps“ |
| FirstRowTypeRight | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **DistributedNotification** (Privileged command/script)|
| FirstRowLinkRight | String | com.apple.AppStore | The Bundle Identifier of the App, URL or command to open. | “com.jamfsoftware.selfservice.mac” |
| FirstRowSymbolRight | String | cart.fill | The SF Symbol shown in the button. | “briefcase.fill”, “bag.circle”, “giftcard.fill”, “gift.circle” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item left
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleLeft | String | Support Ticket | The text shown in the button label. | “Create ticket”, “Open incident“ |
| SecondRowSubtitleLeft | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “support.company.tld”, “Now”, “Create“ |
| SecondRowTypeLeft | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **DistributedNotification** (Privileged command/script)|
| SecondRowLinkLeft | String | https://yourticketsystem.tld | The Bundle Identifier of the App, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolLeft | String | ticket | The SF Symbol shown in the button. | “lifepreserver”, “person.fill.questionmark” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item middle
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleMiddle | String | - | The text shown in the button label. | “Send email” |
| SecondRowSubtitleMiddle | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “support@company.tld”, “Now” |
| SecondRowTypeMiddle | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **DistributedNotification** (Privileged command/script)|
| SecondRowLinkMiddle | String | - | The Bundle Identifier of the App, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolMiddle | String | - | The SF Symbol shown in the button. | “paperplane”, “arrowshape.turn.up.right.fill” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item right
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleRight | String | Phone | The text shown in the button label. | “Call Helpdesk“, “Phone“ |
| SecondRowSubtitleRight | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “+31 00 000 00 00”, “Now”, “Call“ |
| SecondRowTypeRight | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **DistributedNotification** (Privileged command/script)|
| SecondRowLinkRight | String | tel:+31000000000 | The Bundle Identifier of the App, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolRight | String | phone | The SF Symbol shown in the button. | “iphone.homebutton”, “megaphone” or any other SF Symbol. Please check the SF Symbols section. |

## Advanced configuration

### Support App Extensions

Support App Extensions enable administrators to create custom info items and populate those with output from scripts or commands. You can use your MDM solution to run scripts or commands to populate the Support App Extensions. Optionally we provide SupportHelper to run scripts or commands everytime the Support App popover appears to make sure data is up to date. Please read [Privileged commands or scripts (SupportHelper)](#privileged-commands-or-scripts-supporthelper) down below for more info.

Below are the preference keys to enable Support App Extensions:
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| ExtensionTitleA | String | - | The title shown in the extension. | "Last Check-In" |
| ExtensionSymbolA | String | - | The SF Symbol shown in the extension. | "clock.badge.checkmark.fill" |
| ExtensionTypeA | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **DistributedNotification** (Privileged command/script)|
| ExtensionLinkA | String | - | The Bundle Identifier of the App, URL or command to open. | `defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool true; /usr/local/bin/jamf policy; /usr/local/bin/jamf_last_check-in_time.zsh` |
| ExtensionTitleB | String | - | The title shown in the extension. | "Account Privileges" |
| ExtensionSymbolB | String | - | The SF Symbol shown in the extension. | "wallet.pass.fill" |
| ExtensionTypeB | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **DistributedNotification** (Privileged command/script)|
| ExtensionLinkB | String | - | The Bundle Identifier of the App, URL or command to open. | `/usr/local/bin/sap_privileges_change_permissions.zsh` |
| OnAppearAction | String | - | Path to script script or command to be executed when the Support App is opened by clicking on the menu bar item. The SupportHelper is required for this feature. | `/usr/local/bin/runs_when_support_appears.zsh` |

#### How to populate Support App Extensions
Support App Extensions must be populated by setting the value in a preference key within the preference domain `nl.root3.support`. This can be achieved by running custom scripts from your MDM solution or using the `OnAppearAction` combined with SupportHelper. This last option will allow you to update the Support App Extension values every time the Support App popover appears by running the script.

* Create a custom script and populate the desired value by running the following command: `sudo defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueA -string "OUTPUT_VALUE_HERE"`
* Add the following command to show a placeholder while getting the value: `sudo defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueA -string "KeyPlaceholder"`
* Add the following command at the **beginning of the script** to show a spinning indicator while getting the value: `sudo defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool true`
* Add the following command at the **end of the script** to stop the spinning indicator view: `sudo defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool false`

Below a simple example script including loading effect and placeholder while loading
```
#!/bin/zsh

# Start spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool true

# Show placeholder value while loading
defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueA -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Get output value
command_output=$(PUT_COMMAND_TO_GET_OUTPUT_HERE)

# Set output value
defaults write /Library/Preferences/nl.root3.support.plist ExtensionValueA -string "${command_output}"

# Stop spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool false
```

:information_source: When using more than one Support App Extension combined with `OnAppearAction`, it's best to update the values in one script instead of chaining multiple scripts to have the best experience

:information_source: Please do not forget to make the script executable: `sudo chmod +x /PATH/TO/SCRIPT`

### Privileged commands or scripts (SupportHelper)
To allow commands or scripts to be executed with root privileges, the SupportHelper is available optionally. This utility is built on Distributed Notifications to allow inter-app communication between the Support App and the SupportHelper. The Support App notifies SupportHelper and the message contains the preference key set in the Configuration Profile with the command or path to the script. SupportHelper listens for new messages using a LaunchDaemon and executes the command or script by requesting the command or path to the script from the Configuration Profile.

Below an example to force a MDM check-in using SupportHelper and a custom script:

<img src="/Screenshots/generic_version_2.4_beta.gif" width="800">

More information about Distributed Notifications: https://developer.apple.com/documentation/foundation/distributednotificationcenter

#### Use Cases
There are a couple of use cases SupportHelper can help with. For example run a command or script with root privileges:
* Every time the Support App popover appears to populate Support App Extensions using `OnAppearAction`
* Extension Attributes (Jamf Pro) by adding the commands to populate the Support App Extension to the EA
* By clicking on a configurable button

#### File locations
The SupportHelper installer places two files:

LaunchDaemon: `/Library/LaunchDaemons/nl.root3.support.helper.plist`

Binary: `/usr/local/bin/SupportHelper`

#### Security considerations
As SupportHelper is able to execute scripts or commands with root privileges, it needs to be used responsibly. For most deployments, SupportHelper will not be needed and we recommend deploying the Support App without SupportHelper. If you're unsure or unfamiliar with this concept, DO NOT use SupportHelper. This utility is separated from the Support App to avoid compromising the app-sandbox as well.

:information_source: Only values from a Configuration Profile will be used. Values set by `defaults write` will be ignored as it imposes a security risk.

### Jamf Pro variables
When using Jamf Pro as the MDM solution, variables from Jamf Pro can be used in the Configuration Profile values to dynamically populate text like the title, footer or any other text field.

Example
* Set `title` to "Hi $FULLNAME!"

More information about Jamf variables: https://docs.jamf.com/10.36.0/jamf-pro/documentation/Computer_Configuration_Profiles.html

## How to use SF Symbols
We choose to go all the way with SF Symbols as these good looking icons are designed by Apple and give the app a native look and feel. All icons have a symbol name which you can use in the Configuration Profile. As these icons are built into macOS, it automatically shows the correct icon.

* Download SF Symbols [**here**](https://developer.apple.com/sf-symbols/)
* Select the icon you’d like to use
* Copy the symbol name and paste into your Configuration Profile

<img src="/Screenshots/how_to_use_sf_symbols.png" width="800">

## MDM deployment
It is recommended to deploy the Configuration Profile first before installing the Support app.

### Jamf Pro custom JSON schema
A JSON Schema for Jamf Pro is provided for easy configuration of all the preference keys without creating/modifying a custom Configuration Profile in XML format. Download the JSON file [**here**](https://github.com/root3nl/SupportApp/blob/master/Jamf%20Pro%20Custom%20Schema/Jamf%20Pro%20Custom%20Schema.json)

More information about the JSON Schema feature in Jamf Pro: https://docs.jamf.com/technical-papers/jamf-pro/json-schema/10.19.0/Overview.html

<img src="/Screenshots/jamf_pro_custom_schema.png" width="800">

### Installer or app bundle
Depending on your preference or MDM solution you can use either the installer or zipped app bundle. The installer includes a LaunchAgent and is the recommended method.

### Sample LaunchAgent
A sample LaunchAgent to always keep the app alive is provided [**here**](https://github.com/root3nl/SupportApp/blob/master/LaunchAgent%20Sample/nl.root3.support.plist)

### Sample Configuration Profile
A sample Configuration Profile you can edit to your preferences is provided [**here**](https://github.com/root3nl/SupportApp/blob/master/Configuration%20Profile%20Sample/Support%20App%20Configuration%20Sample.mobileconfig)

## Logging
Logs can be viewed from Console or Terminal by filtering the subsystems `nl.root3.support` (Support App) and `nl.root3.support.helper` (SupportHelper).

An example to stream current logs in Terminal for troubleshooting:
```
log stream --debug --info --predicate 'subsystem contains "nl.root3.support"'
```

## Known issues
* Buttons may keep a hovered state when mouse cursor moves fast: FB8212902 (**resolved in macOS Monterey**)
* When Jamf Connect is used as password type, clicking "Change Now" does not allow the user to open the Jamf Connect change password window, but instead triggers an alert. Jamf Connect does not support a URL Scheme for opening the Change Password window. Please upvote this feature request: https://ideas.jamf.com/ideas/JN-I-16087

## Changelog

**Version 2.4**
* Support App Extensions: introducing a new way to make your own custom info items and provide relevant information to your end users and create actions. Extensions can show anything you want and can be populated using scripts or commands, for example using your MDM solution. There is support for two Extensions to use in the info item rows.
* SupportHelper (separately available): there is now support for privileged scripts and commands to run directly from a button in the Support App while preserving the App Sandbox. An optional utility called SupportHelper will be required and handles the execution on behalf of the Support App. This is built on the Distributed Notifications framework to allow inter-app communication. SupportHelper is a separate installer and is not included in the standard Support App installer.
* Optional info items row: an extra row with info items or Extensions can now be enabled. When enabling this third row, it will show the Password and Network info items by default. The row can show any info item or Extension.
* New password sources: the Password info item can now be configured to show password expiry information from Jamf Connect, Apple’s Kerberos SSO Extension or NoMAD. Set preference key "PasswordType" to "JamfConnect", "KerberosSSO" or "Nomad".
* The title text now supports markdown just like the footer text.
* Items no longer show a hover effect when no link is configured, allowing buttons to be static without a clickable action. This applies to both configurable buttons and Extensions

**Version 2.3**
* Welcome Screen: an informational window can now optionally be shown when the Support App is opened for the first time. It explains the key features to the user.
* Preference key ‘StorageLimit’ added to configure the maximum percentage of used storage recommended by the organization. When the limit is reached, a badge counter with exclamation mark will be shown in the Storage tile. Also a little orange notification badge can overlay the menu bar icon when the preference key ‘StatusBarIconNotifierEnabled’ is set to ‘true’.
* The Network info item now shows either the current SSID or Ethernet as the title instead of ‘IP Address’.
* Preference key ‘NotificationIcon’ added to configure a custom square image to be shown in alerts and the about window.
* The notification badge in the StatusBarItem can now show either orange or red, depending on the current state. An available software update will overrule orange warnings and will show a red notification badge.
* A footer option is added to put some additional text at the bottom of the Support App. This supports both text and Emoji. On macOS Monterey and higher, it supports Markdown.
* French localization is added
* macOS Monterey compatibility
* Bug fixes and improvements

**Version 2.2**
* Modulair info items: you can now configure any of the top four info items to any of the six available options:
  * IP Address (NEW)
  * Mac Password(NEW)
  * Computer Name
  * macOS Version
  * Last Reboot
  * Storage
* IP Address is added as a configurable info item. It shows the current IPv4 address. The icon will show the connection type, Wi-Fi or Ethernet. Clicking the item will open Network in System Preferences.
* Mac Password is added as a configurable info item. It shows the days until the Mac password expires. Clicking the item will open Accounts in System Preferences. Local accounts and Active Directory accounts are supported. The text label in the item can be modified using the preference key ‘PasswordLabel’.
* Preference key ‘UptimeDaysLimit’ added to configure the maximum amount of uptime days recommended by the organization. When the limit is reached, a badge counter with exclamation mark will be shown in the Last Reboot tile. Also a little notification badge can overlay the menu bar icon when the preference key ‘StatusBarIconNotifierEnabled’ is set to ‘true’
* Preference key ‘PasswordExpiryLimit’ added to configure the minimum amount of days before the user should change the Mac password. When the limit is reached, a badge counter with exclamation mark will be shown in the Mac Password tile. Also a little notification badge can overlay the menu bar icon when the preference key ‘StatusBarIconNotifierEnabled’ is set to ‘true’.
* Flexible rows of for App, URL or Command: The middle button is now optional, offering a two or three button row. The middle button are enabled by setting the following keys: FirstRowTitleMiddle or SecondRowTitleMiddle. Together with HideFirstRow and HideSecondRow, the total amount of configurable buttons is possible: 0, 2, 3, 4, 5, 6. As a result, keys for the middle buttons no longer have default values and the app shows two buttons by default;
* Computer Name info item: The Mac model name and introduction year is shown when hovering over Computer Name. Clicking the item opens ‘About This Mac’
* Small UI tweaks for Dark Mode. Buttons now have a small border and are more distinguishable
* Performance improvements and bug fixes

**Version 2.1**
* Preference key LogoDarkMode is added to provide a separate logo for Dark Mode
* Preference key CustomColorDarkMode is added to set a separate custom color for Dark Mode
* The number of available Apple Software Updates will now be shown in a badge counter in the macOS version tile. Also a little notification badge can overlay the menu bar icon when the preference key ‘StatusBarIconNotifierEnabled’ is set to ‘true’
* Clicking on the macOS version tile will now open the Software Update preference pane in System Preferences
* Running basic zsh commands as the user can now be used as an action by setting the LinkType to “Command”
* Changes to the menu bar icon will now be observed and will automatically be applied without restarting the app
* Preference key ErrorMessage is added to provide a custom error message when clicking an App, URL or Command results in an error
* The app’s icon is changed to a more generic looking icon
* Default error message is improved
* Unified logging is implemented for the subsystem “nl.root3.support” to be able to capture errors when using commands or scripts
* Fixed a localization issue for error alerts
* Fixed an issue where some functions kept running in the background, causing more CPU time than required

## Privacy policy
We value your privacy. To protect your privacy, the Support App does not collect or send any personal data. The only outgoing network request is to send the computer's serial number to an Apple API to request the model's marketing name. This information is only kept within the app and is never collected elsewhere.

## Note and disclaimer
* Root3 developed this application as a side project to add additional value for our customers
* The application can be used free of charge and is provided ‘as is’, without any warranty
* Comments and feature request are appreciated. Please file an issue on Github
