# macOS Support App

<img src="/Screenshots/generic_version_2.3.png" width="800">

<img src="/Screenshots/generic_version_2.1.png" width="800">

<img src="/Screenshots/generic_version_2.1_small.png" width="450"> <img src="/Screenshots/generic_light_mode_cropped.png" width="450"> <img src="/Screenshots/generic_version_2.3_small_dark.png" width="450">

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Download](#download)
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
- [How to use SF Symbols](#how-to-use-sf-symbols)
- [MDM deployment](#mdm-deployment)
  * [Jamf Pro custom JSON Schema](#jamf-pro-custom-json-schema)
  * [Installer or app bundle](#installer-or-app-bundle)
  * [Sample LaunchAgent](#sample-launchagent)
  * [Sample Configuration Profile](#sample-configuration-profile)
- [Known issues](#known-issues)
- [Changelog](#changelog)
- [Privacy policy](#privacy-policy)
- [Note and disclaimer](#note-and-disclaimer)

## Introduction
The Support app is a macOS menu bar app built for organizations to:
* Help users and helpdesks to see basic diagnostic information at a glance and proactively notify them to easily fix small issues.
* Offer shortcuts to easily access support channels or other company resources such as a website or a file server
* Give users a modern and native macOS app with your corporate identity

The app is developed by Root3, specialized in managing Apple devices. Root3 offers consultancy and support for organizations to get the most out of their Apple devices and is based in The Netherlands (Haarlem).

Root3 already had a basic in-house support app written in Objective-C and decided to completely rewrite it in Swift using SwiftUI with an all-new design that looks great on macOS Big Sur. We’ve learned that SwiftUI is the perfect way of creating great looking apps for all Apple platforms with minimal effort. In the development process we decided to make it generic so other organizations can take advantage of it and contribute to the Mac admins community.


The easiest and recommended way to configure the app is using a Configuration Profile and your MDM solution.

## Requirements
* macOS 11.0.1 or higher
* Any MDM solution supporting custom Configuration Profiles

## Download
Package Installer (includes LaunchAgent): [**Download**](https://github.com/root3nl/SupportApp/releases/latest)

Application (zipped): [**Download**](https://github.com/root3nl/SupportApp/releases/latest)

See the MDM deployment section below for more info.

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
The row above the buttons allow a custom title and company logo. The logo supports several images types like PNG, JPEG and ICNS and will be resized to a maximum height of 48 points. The original aspect ratio will be retained. A PNG with alpha channel is advised to get variable transparency around your logo.

### Color
All the circles around the symbols have the macOS accent color and will dynamically change with the user's setting in System Preferences --> General. If desired, this color can be customised matching your corporate colors. We recommend keeping the macOS accent color when the color of your choice is too light, as text will be difficult to read.

### Diagnostic information
There are a couple of info items with diagnostics available to choose from. A total of four items will be displayed in the top four buttons. Available items:

* **Computer Name** (default): The current computer name will be displayed here. Especially helpful when your organisation has a difficult naming convention and users want to do things like AirDrop.

* **macOS version** (default): The current version of macOS including major, minor and patch version as well as the marketing name. The marketing name will be easier to understand for your end users. A notification badge will be shown when an Apple Software Update is available. Clicking on this item opens the Software Update preference pane.

* **Last Reboot** (default): The current uptime. When troubleshooting some issue, the first thing you would like to do is a reboot when the uptime is high. The optional preference key ‘UptimeDaysLimit’ can be used to configure the maximum amount of uptime days recommended by the organization. Exceeding this limit results in a badge counter with exclamation mark in the info item.

* **Storage Used** (default): The storage percentage used on the boot drive. When hovering with the mouse, the available storage is shown. Clicking on this item opens the macOS built-in Storage Management app. The optional preference key ‘StorageLimit’ can be used to configure the maximum percentage of used storage recommended by the organization. Exceeding this limit results in a badge counter with exclamation mark in the info item.

* **Network**: The current SSID or Ethernet along with the local IPv4 address. The icon indicates the connection type, Wi-Fi or Ethernet. Clicking on this item opens the Network preference pane in System Preferences.

* **Mac Password**: Shows when the user's password expires and supports both local and Active Directory accounts. Shows a warning when the expiry reaches the value set in the optional key 'PasswordExpiryLimit'. The text label in the item can be modified using the preference key ‘PasswordLabel’.

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

* **Symbol**: The symbol shown in the button, see the SF Symbols section how to use these symbols

The rows with configurable items are shown in the screenshot below:

<img src="/Screenshots/configurable_buttons.png" width="450">

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

### Info items
Configuration of the top four items with diagnostic information.
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| InfoItemOne | String | ComputerName | Info item shown in the upper left corner | "ComputerName", "MacOSVersion", "Network", "Password", "Storage" or "Uptime" |
| InfoItemTwo | String | MacOSVersion | Info item shown in the upper right corner | "ComputerName", "MacOSVersion", "Network", "Password", "Storage" or "Uptime" |
| InfoItemThree | String | Uptime | Info item shown in the second row left | "ComputerName", "MacOSVersion", "Network", "Password", "Storage" or "Uptime" |
| InfoItemFour | String | Storage | Info item shown in the second row right | "ComputerName", "MacOSVersion", "Network", "Password", "Storage" or "Uptime" |
| UptimeDaysLimit | Integer | 0 (Disabled) | Days of uptime after which a notification badge is shown, disabled by default | 7 |
| PasswordExpiryLimit| Integer | 0 (Disabled) | Days until password expiry after which a notification badge is shown, disabled by default | 14 |
| PasswordLabel| String | Mac Password | Alternative text label shown in the Password info item | "AD Password", "Company Password" |
| StorageLimit | Integer | 0 (Disabled) | Percentage of storage used after which a notification badge is shown, disabled by default | 80 |

### First row of configurable items: Item left
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| FirstRowTitleLeft | String | Remote Support | The text shown in the button label. | “Share My Screen”, “TeamViewer“, “Software Updates“ “My core application” etc. |
| FirstRowSubtitleLeft | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open“, “Share your screen“ |
| FirstRowTypeLeft | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL** or **Command** |
| FirstRowLinkLeft | String | com.apple.ScreenSharing | The Bundle Identifier of the app, URL or command to open. | “com.teamviewer.TeamViewerQS“ (App), “x-apple.systempreferences:com.apple.preferences.softwareupdate“ (URL) |
| FirstRowSymbolLeft | String | cursorarrow | The SF Symbol shown in the button. | “binoculars.fill”, “cursorarrow.click.2” or any other SF Symbol. Please check the SF Symbols section. |

### First row of configurable items: Item middle
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| FirstRowTitleMiddle | String | - | The text shown in the button label. | “Self Service“, “App Store“ |
| FirstRowSubtitleMiddle | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open”, “Download apps“ |
| FirstRowTypeMiddle | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL** or **Command** |
| FirstRowLinkMiddle | String | - | The Bundle Identifier of the app, URL or command to open. | “com.jamfsoftware.selfservice.mac” |
| FirstRowSymbolMiddle | String | - | The SF Symbol shown in the button. | “briefcase.fill”, “bag.circle”, “giftcard.fill”, “gift.circle” or any other SF Symbol. Please check the SF Symbols section. |

### First row of configurable items: Item right
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| FirstRowTitleRight | String | Company Store | The text shown in the button label. | “Self Service“, “App Store“ |
| FirstRowSubtitleRight | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open”, “Download apps“ |
| FirstRowTypeRight | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL** or **Command** |
| FirstRowLinkRight | String | com.apple.AppStore | The Bundle Identifier of the app, URL or command to open. | “com.jamfsoftware.selfservice.mac” |
| FirstRowSymbolRight | String | cart.fill | The SF Symbol shown in the button. | “briefcase.fill”, “bag.circle”, “giftcard.fill”, “gift.circle” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item left
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleLeft | String | Support Ticket | The text shown in the button label. | “Create ticket”, “Open incident“ |
| SecondRowSubtitleLeft | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “support.company.tld”, “Now”, “Create“ |
| SecondRowTypeLeft | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL** or **Command** |
| SecondRowLinkLeft | String | https://yourticketsystem.tld | The Bundle Identifier of the app, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolLeft | String | ticket | The SF Symbol shown in the button. | “lifepreserver”, “person.fill.questionmark” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item middle
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleMiddle | String | - | The text shown in the button label. | “Send email” |
| SecondRowSubtitleMiddle | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “support@company.tld”, “Now” |
| SecondRowTypeMiddle | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL** or **Command** |
| SecondRowLinkMiddle | String | - | The Bundle Identifier of the app, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolMiddle | String | - | The SF Symbol shown in the button. | “paperplane”, “arrowshape.turn.up.right.fill” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item right**
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleRight | String | Phone | The text shown in the button label. | “Call Helpdesk“, “Phone“ |
| SecondRowSubtitleRight | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “+31 00 000 00 00”, “Now”, “Call“ |
| SecondRowTypeRight | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL** or **Command** |
| SecondRowLinkRight | String | tel:+31000000000 | The Bundle Identifier of the app, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolRight | String | phone | The SF Symbol shown in the button. | “iphone.homebutton”, “megaphone” or any other SF Symbol. Please check the SF Symbols section. |

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

## Known issues
* Buttons may keep a hovered state when mouse cursor moves fast: FB8212902 (**resolved on macOS Monterey**)

## Changelog

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
