# macOS Support App

![GitHub release (latest by date)](https://img.shields.io/github/v/release/root3nl/SupportApp?color=success)
![Github](https://img.shields.io/badge/macOS-12%2B-green)
[![Github](https://img.shields.io/badge/Join-TestFlight-blue)](https://testflight.apple.com/join/asmgJsAM)

<img src="/Screenshots/generic_version_2.6.png" width="800">

<img src="/Screenshots/generic_version_2.4.png" width="800">

<img src="/Screenshots/generic_light_mode_cropped.png" height="300"> <img src="/Screenshots/generic_version_2.3_small_dark.png" height="300">

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Download](#download)
  * [TestFlight](#testflight)
- [Technologies](#technologies)
- [Features](#features)
  * [Menu Bar Icon](#menu-bar-icon)
  * [Title and logo](#title-and-logo)
    * [Logo options](#logo-options)
  * [Color](#color)
  * [Diagnostic information](#diagnostic-information)
  * [App, link or command shortcuts](#app-link-or-command-shortcuts)
  * [Footer Text](#footer-text)
  * [Notification Icon](#notification-icon)
  * [Welcome Screen](#welcome-screen)
  * [Software Update integration](#software-update-integration)
  * [App Catalog integration](#app-catalog-integration)
    * [PPPC requirement](#pppc-requirement)
  * [Last Reboot](#last-reboot)
- [Configuration](#configuration)
- [Advanced configuration](#advanced-configuration)
  * [Support App Extensions](#support-app-extensions)
    * [How to populate Support App Extensions](#how-to-populate-support-app-extensions)
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
* Offer shortcuts to easily access support channels, company resources such as websites, applications or file servers
* Give users a modern and native macOS app with your corporate identity

The app is developed by Root3, specialized in managing Apple devices. Root3 offers managed workplaces, consultancy and support for organizations to get the most out of their Apple devices and is based in The Netherlands (Halfweg).

Root3 already had a basic in-house support app written in Objective-C and decided to completely rewrite it in Swift using SwiftUI with an all-new design that looks great on macOS Big Sur. We’ve learned that SwiftUI is the perfect way of creating great looking apps for all Apple platforms with minimal effort. In the development process we decided to make it generic so other organizations can take advantage of it and contribute to the Mac admins community.

The easiest and recommended way to configure the app is using a Configuration Profile and your MDM solution.

## Requirements
* macOS 12 or higher
* Any MDM solution supporting custom Configuration Profiles

## Download

### Support App
Package Installer (includes LaunchAgent): [**Download**](https://github.com/root3nl/SupportApp/releases/latest)

Application (zipped): [**Download**](https://github.com/root3nl/SupportApp/releases/latest)

See the MDM deployment section below for more info.

### TestFlight
You can participate in beta versions of Support App using TestFlight. This requires macOS 12 or higher.

[**Join TestFlight**](https://testflight.apple.com/join/asmgJsAM)

> **Note**
> There may not always be a TestFlight version available.

## Technologies
* Written in Swift using SwiftUI
* All icons are SF Symbols
* Built for and compatible with macOS 12 and higher
* Native support for Apple Silicon
* Dark Mode support
* Colors are matched with your macOS accent color (blue by default)
* MDM support to configure your own branding such as a custom title, logo, SF Symbols and contact methods
* Notarized
* Sandboxed
* Localized in English, Dutch, French, German and Spanish

## Features

### Menu Bar Icon
The Menu Bar Icon can be customized to your own image such as a PNG with Alpha Channel, an image from URL or an SF Symbol. Any image will be shown as template to match the rest of the Menu Bar Extras. Icons larger than 22 points will automatically be resized to the recommended 16 points and the aspect ration will be preserved. Optionally a notification badge can overlay the icon to attract the user's attention when an Apple Software Update is available or any other warning was triggered. Please check the preference key `StatusBarIconNotifierEnabled`.

> **Note**
> When using a local file, make sure to put the image in a folder accessible from the App Sandbox. We recommend a subfolder in `/Library/Application Support/` such as `/Library/Application Support/MyOrganization`

> **Note**
> When using an file from URL, the image will be downloaded once when the Support App opens and will be used for subsequent launches of the app, to avoid unnecessary downloads and use cases where the Mac has no internet connection at startup. To use a new icon, the URL must be changed for the Support App to trigger a new download.

### Title and logo
The row above the buttons allow a custom title and company logo. The title supports both text and Emoji. On macOS Monterey and higher, it supports Markdown as well. The logo supports a remote URL, an SF Symbol and several local images types like PNG, JPEG and ICNS and will be resized to a maximum height of 48 points. The original aspect ratio will be retained. A PNG with alpha channel is advised to get variable transparency around your logo.

#### Logo options
Here are the available for the Logo:
* **Remote URL**: `https://URL_TO_IMAGE`
* **SF Symbol**: `SF=SF_SYMBOL_NAME_HERE` or `SF=SF_SYMBOL_NAME_HERE,color=COLOR_OPTION_HERE`. Available color options: `auto`, `multicolor`, `hierarchical` or a custom HEX color code such as `#9ACEA4`
* **Local file**: `/PATH_TO_LOCAL_FILE`

> **Note**
> When using a local file, make sure to put the image in a folder accessible from the App Sandbox. We recommend a subfolder in `/Library/Application Support/` such as `/Library/Application Support/MyOrganization`

### Color
All the circles around the symbols have the macOS accent color and will dynamically change with the user's setting in System Preferences --> General. If desired, this color can be customised matching your corporate colors. We recommend keeping the macOS accent color when the color of your choice is too light, as text will be difficult to read.

### Diagnostic information
There are a couple of info items with diagnostics available to choose from. A total of four items will be displayed in the top four buttons. Available items:

* **Computer Name** (default): The current computer name will be displayed here. Especially helpful when your organisation has a difficult naming convention and users want to do things like AirDrop.

* **macOS version** (default): The current version of macOS including major, minor and patch version as well as the marketing name. The marketing name will be easier to understand for your end users. A notification badge will be shown when an Apple Software Update is available. Clicking on this item shows more details and allows the user to initiate the update in System Settings. Additionally there is support for updates enforced by Declarative Device Management and the enforcement date/time is shown if a valid update declaration is detected.

* **Last Reboot** (default): The current uptime. When troubleshooting some issue, the first thing you would like to do is a reboot when the uptime is high. The optional preference key `UptimeDaysLimit` can be used to configure the maximum amount of uptime days recommended by the organization. Exceeding this limit results in a badge counter with exclamation mark in the info item. Users can also restart the Mac gracefully from this info item.

* **Storage Used** (default): The storage percentage used on the boot drive. When hovering with the mouse, the available storage is shown. Clicking on this item opens the macOS built-in Storage Management app. The optional preference key `StorageLimit` can be used to configure the maximum percentage of used storage recommended by the organization. Exceeding this limit results in a badge counter with exclamation mark in the info item.

* **Network**: The active network interface type (Wi-Fi or Ethernet) along with the local IPv4 address. The icon indicates the connection type, Wi-Fi or Ethernet. Clicking on this item opens the Network preference pane in System Preferences. On macOS 13 or earlier, the current SSID name is shown. Due to privacy restrictions, macOS 14 and later show "Wi-Fi" instead of the SSID name.

* **Mac Password**: Shows when the user's password expires and supports both local and Active Directory accounts by default. Alternative supported user sources are Jamf Connect, Kerberos SSO Extension and NoMAD. Shows a warning when the expiry reaches the value set in the optional key `PasswordExpiryLimit`. The text label in the item can be modified using the preference key `PasswordLabel`.

* **Extension A and B**: Support App Extensions to show any information. The title, icon must be configured and optionally a link to open an App, URL, User Command or Privileged Command/Script. The value below the title of the Extension must be populated by setting a preference key using a script or command. Extensions can also trigger an orange notification badge alert in both the Extension and menu bar icon. See [How to populate Support App Extensions](#how-to-populate-support-app-extensions) for more information.

* **App Catalog**: Show available app updates driven by [Root3's App Catalog](https://appcatalog.cloud). It allow users to quickly update applications and show when the automatic update schedule will run next. This integration requires a valid App Catalog subscription and a [free trial](http://appcatalog.cloud/#trial) is available.

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
  * PrivilegedScript: Path to script to be executed with elevated privileges

> **Note**
> The key `DistributedNotification` is deprecated and replaced with `PrivilegedScript`

* **Symbol**: The symbol shown in the button, see the SF Symbols section how to use these symbols

The rows with all configurable items enabled are shown in the screenshot below:
* Info items and Support App Extensions in **GREEN**
* Buttons in **ORANGE**

<img src="/Screenshots/configurable_buttons_2.4.png" width="450">

### Footer Text
A footer text can optionally be used to put some additional text at the bottom of the Support App. This supports both text and Emoji. On macOS Monterey and higher, it supports Markdown. Also a great way to put additional information using [Built-in local variables](https://github.com/root3nl/SupportApp?tab=readme-ov-file#built-in-local-variables) Use the preference key `FooterText` to configure the footer.

### Notification Icon
The icon shown the about window can be modified by using the preference key `NotificationIcon`.

See an example below:

<img src="/Screenshots/custom_alert.png" width="350">

> **Note**
> When using a local file, make sure to put the image in a folder accessible from the App Sandbox. We recommend a subfolder in `/Library/Application Support/` such as `/Library/Application Support/MyOrganization`

> **Note**
> When using an file from URL, the image will be downloaded once when the Support App opens and will be used for subsequent launches of the app, to avoid unnecessary downloads and use cases where the Mac has no internet connection at startup. To use a new icon, the URL must be changed for the Support App to trigger a new download.

> **Note**
> Modifying the app icon when it is not running would compromise the App Sandbox and we decided not to implement this. We suggest hiding the app by running the following command: `sudo chflags hidden "/Applications/Support.app"`

### Welcome Screen
An informational window can optionally be shown when the Support App is opened for the first time. It explains the key features to the user before all data is shown. This can be set using the preference key `ShowWelcomeScreen`.

<img src="/Screenshots/welcome_screen.png" width="500">

### Software Update integration
The Support App shows the current version of macOS and a notification badge if there is an update or upgrade available. Clicking the info item shows more details like the name of the update(s) available and also allows organizations to add a custom text. This can be used to provide more context and explain the user about the organization's update policy or anything else. The text string supports Markdown to style it further and include links. Please check [Built-in local variables](#built-in-local-variables) for an example using Markdown and variables.

It allows the user to open System Settings and install the update or upgrade. If there is no update or upgrade available, the popover simply shows "Your Mac is up to date".

If an update declaration is sent using [Declarative Device Management](https://developer.apple.com/documentation/devicemanagement/softwareupdateenforcementspecific) (macOS 14 and higher), the available update will show the enforcement date and time for the update. If present in the declaration, the `DetailsURL` will also show a button "Details" and opens the `DetailsURL` link. 

<img src="/Screenshots/software_update_integration.png" width="600">

> **Note**
> When a deferral is set using the preference key `forceDelayedMajorSoftwareUpdates` in the domain `com.apple.applicationaccess`, major macOS updates will automatically be hidden indefinitely until the key is removed or set to `false`. The amount of days configured for the deferral are ignored. Due to limitations and complexity, it is not supported to automatically show the macOS major update once the deferral days are passed. This behaviour replaces the `HideMajorUpdates` key, previously available in version 2.5 and earlier. More info here: https://developer.apple.com/documentation/devicemanagement/restrictions

### App Catalog integration
The Support App integrates with [Root3's App Catalog](https://appcatalog.cloud). The App Catalog is an automated patch management solution for third party macOS applications. It provides unique features such as a daily update schedule, updating both managed and unmanaged apps and a user facing app to quickly install new applications. As some app updates require user interaction, users may defer an update and want to update at a more convenient time. The Support App periodically checks for available app updates and allows the user to update apps whenever they prefer in an accessible way. The menu bar icon also shows a red notification badge when an update is available to inform the user, similar to macOS updates when `StatusBarIconNotifierEnabled` is set to `true`.

<img src="/Screenshots/app_catalog_integration.png" width="600">

#### PPPC requirements
The Support App requires additional permissions to be able to perform app updates. Therefore you need to explicitely grant the `SystemPolicyAllFiles` (Full Disk Access) permission in a Privacy Preference Policy Control profile (PPPC):

- **Allowed**: `true`
- **Identifier**: `nl.root3.support`
- **IdentifierType**: Bundle ID
- **CodeRequirement**: `anchor apple generic and identifier "nl.root3.support" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = "98LJ4XBGYK")`

- **Allowed**: `true`
- **Identifier**: `/Library/PrivilegedHelperTools/nl.root3.support.helper`
- **IdentifierType**: Path
- **CodeRequirement**: `anchor apple generic and identifier "nl.root3.support.helper" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = "98LJ4XBGYK")`

A sample Configuration Profile is provided [**here**](https://github.com/root3nl/SupportApp/blob/master/Configuration%20Profile%20Samples/PPPC/PPPC%20-%20Support%20App.mobileconfig)

### Last Reboot
If `UptimeDaysLimit` is set and the user click on the Last Reboot Info Item, a view is shown where the administrators reboot recommendation is shown. It also provides a button to quickly perform a graceful restart without leaving the Support App.

<img src="/Screenshots/last_reboot.png" width="600">

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
| Logo | String | App Icon | Remote URL, SF Symbol or path to the logo shown in the top right corner when the app opens. Scales to 48 points maximum height. A subfolder in `/Library/Application Support/` is the recommended location due to sandboxing | `/Library/Application Support/Your Company/logo.png` or `https://domain.tld/url_to_image.png`|
| LogoDarkMode | String | App Icon | Remote URL, SF Symbol or path to the logo shown in the top right corner when the app opens for Dark Mode. Scales to 48 points maximum height. A subfolder in `/Library/Application Support/` is the recommended location due to sandboxing | `/Library/Application Support/Your Company/logo_darkmode.png` or `https://domain.tld/url_to_image.png` |
| NotificationIcon | String | App Icon | Remote URL or path to a custom square image to be shown in alerts and the about window. | `/Library/Application Support/Your Company/logo.png` or `https://domain.tld/url_to_image.png` |
| StatusBarIcon | String | Root3 Logo | Remote URL or path to the status bar icon shown in the menu bar. Recommended: PNG, 16x16 points. Icons larger than 22 points will automatically be resized to 16 points. A subfolder in `/Library/Application Support/` is the recommended location due to sandboxing | `/Library/Application Support/Your Company/statusbaricon.png` or `https://domain.tld/url_to_image.png` |
| StatusBarIconSFSymbol | String | Root3 Logo | Custom status bar icon using an SF Symbol. Ignored when StatusBarIcon is also set | “lifepreserver” |
| StatusBarIconNotifierEnabled | Boolean | false | Shows a small notification badge in the Status Bar Icon when an info items triggers a warning or notification | true |
| UpdateText | String | - | The text shown below the software update details popover | "Your organization requires you to update as soon as possible. [More info...](https://URL_TO_YOUR_UPDATE_POLICY)" |
| CustomColor | String | macOS Accent Color | Custom color for all symbols. Leave empty to use macOS Accent Color. We recommend not to use a very light color as text may become hard to read | HEX color in RGB format like "#8cc63f" |
| CustomColorDarkMode | String | macOS Accent Color | Custom color for all symbols in Dark Mode. Leave empty to use macOS Accent Color or CustomColor if specified. We recommend not to use a very dark color as text may become hard to read | HEX color in RGB format like "#8cc63f" |
| HideFirstRowInfoItems | Boolean | false | Hides the first row of info items. | true |
| HideSecondRowInfoItems | Boolean | false | Hides the second row of info items. | true |
| HideThirdRowInfoItems | Boolean | false | Hides the third row of info items. | true |
| HideFirstRowButtons | Boolean | false | Hides the first row of configurable items. | true |
| HideSecondRowButtons | Boolean | false | Hides the second row of configurable items. | true |
| ErrorMessage | String | Please contact IT support | Shown when clicking an action results in an error | "Please contact the servicedesk", "Please contact COMPANY_NAME" |
| ShowWelcomeScreen | Boolean | false | Shows the welcome screen when the Support App is opened for the first time. | true |
| FooterText | String | - | Text shown at the bottom as footnote | "Provided by your **IT department** with ❤️" |
| OpenAtLogin | Boolean | false | Launch Support (non-PKG) automatically at login and keep it open (macOS 13 and higher). This setting is ignored if a legacy LaunchAgent is installed/active. Keep disabled if you don't want to open Support at login or use your own LaunchAgent | false |
| DisablePrivilegedHelperTool | Boolean | false | Disable the Privileged Helper Tool for the PKG installer during the time of installation or at launch of the Support App | true |

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
| FirstRowTypeLeft | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **PrivilegedScript** (Privileged script)|
| FirstRowLinkLeft | String | com.apple.ScreenSharing | The Bundle Identifier of the App, URL or command to open. | “com.teamviewer.TeamViewerQS“ (App), “x-apple.systempreferences:com.apple.preferences.softwareupdate“ (URL) |
| FirstRowSymbolLeft | String | cursorarrow | The SF Symbol shown in the button. | “binoculars.fill”, “cursorarrow.click.2” or any other SF Symbol. Please check the SF Symbols section. |

### First row of configurable items: Item middle
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| FirstRowTitleMiddle | String | - | The text shown in the button label. | “Self Service“, “App Store“ |
| FirstRowSubtitleMiddle | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open”, “Download apps“ |
| FirstRowTypeMiddle | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **PrivilegedScript** (Privileged script)|
| FirstRowLinkMiddle | String | - | The Bundle Identifier of the App, URL or command to open. | “com.jamfsoftware.selfservice.mac” |
| FirstRowSymbolMiddle | String | - | The SF Symbol shown in the button. | “briefcase.fill”, “bag.circle”, “giftcard.fill”, “gift.circle” or any other SF Symbol. Please check the SF Symbols section. |

### First row of configurable items: Item right
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| FirstRowTitleRight | String | Company Store | The text shown in the button label. | “Self Service“, “App Store“ |
| FirstRowSubtitleRight | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open”, “Download apps“ |
| FirstRowTypeRight | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **PrivilegedScript** (Privileged script)|
| FirstRowLinkRight | String | com.apple.AppStore | The Bundle Identifier of the App, URL or command to open. | “com.jamfsoftware.selfservice.mac” |
| FirstRowSymbolRight | String | cart.fill | The SF Symbol shown in the button. | “briefcase.fill”, “bag.circle”, “giftcard.fill”, “gift.circle” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item left
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleLeft | String | Support Ticket | The text shown in the button label. | “Create ticket”, “Open incident“ |
| SecondRowSubtitleLeft | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “support.company.tld”, “Now”, “Create“ |
| SecondRowTypeLeft | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **PrivilegedScript** (Privileged script)|
| SecondRowLinkLeft | String | https://yourticketsystem.tld | The Bundle Identifier of the App, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolLeft | String | ticket | The SF Symbol shown in the button. | “lifepreserver”, “person.fill.questionmark” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item middle
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleMiddle | String | - | The text shown in the button label. | “Send email” |
| SecondRowSubtitleMiddle | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “support@company.tld”, “Now” |
| SecondRowTypeMiddle | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **PrivilegedScript** (Privileged script)|
| SecondRowLinkMiddle | String | - | The Bundle Identifier of the App, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolMiddle | String | - | The SF Symbol shown in the button. | “paperplane”, “arrowshape.turn.up.right.fill” or any other SF Symbol. Please check the SF Symbols section. |

### Second row of configurable items: Item right
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| SecondRowTitleRight | String | Phone | The text shown in the button label. | “Call Helpdesk“, “Phone“ |
| SecondRowSubtitleRight | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “+31 00 000 00 00”, “Now”, “Call“ |
| SecondRowTypeRight | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **PrivilegedScript** (Privileged script)|
| SecondRowLinkRight | String | tel:+31000000000 | The Bundle Identifier of the App, URL or command to open. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolRight | String | phone | The SF Symbol shown in the button. | “iphone.homebutton”, “megaphone” or any other SF Symbol. Please check the SF Symbols section. |

## Advanced configuration

### Support App Extensions

Support App Extensions enable administrators to create custom info items and populate those with output from scripts or commands. You can use your MDM solution to run scripts or commands to populate the Support App Extensions. The Support App can also run scripts with elevated privileges everytime the Support App popover appears to make sure data is up to date. Extensions show a placeholder by default is no value is set. Once 
Please read [Privileged scripts](#privileged-scripts) down below for more info.

Below are the preference keys to enable Support App Extensions:
| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| ExtensionTitleA | String | - | The title shown in the extension. | "Last Check-In", "Compliance" |
| ExtensionSymbolA | String | - | The SF Symbol shown in the extension. | "clock.badge.checkmark.fill",  |
| ExtensionTypeA | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **PrivilegedScript** (Privileged script)|
| ExtensionLinkA | String | - | The Bundle Identifier of the App, URL or command to open. | `defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool true; /usr/local/bin/jamf policy; `[`/usr/local/bin/jamf_last_check-in_time.zsh`](https://github.com/root3nl/SupportApp/blob/master/Extension%20Sample%20Scripts/jamf_last_check-in_time.zsh) or any other action you prefer by clicking on the Extension |
| ExtensionValueA | String | `KeyPlaceholder` | The output of the Extension set by script or MDM. If nothing is set, it is shown as placeholder UI element | Anything you want to show here |
| ExtensionTitleB | String | - | The title shown in the extension. | "Account Privileges" |
| ExtensionSymbolB | String | - | The SF Symbol shown in the extension. | "wallet.pass.fill" |
| ExtensionTypeB | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App**, **URL**, **Command** or **PrivilegedScript** (Privileged script)|
| ExtensionLinkB | String | - | The Bundle Identifier of the App, URL or command to open. | [`/usr/local/bin/sap_privileges_change_permissions.zsh`](https://github.com/root3nl/SupportApp/blob/master/Extension%20Sample%20Scripts/sap_privileges_change_permissions.zsh) or any other action you prefer by clicking on the Extension |
| ExtensionValueB | String | `KeyPlaceholder` | The output of the Extension set by script or MDM. If nothing is set, it is shown as placeholder UI element | Anything you want to show here |
| OnAppearAction | String | - | Path to script script or command to be executed when the Support App is opened by clicking on the menu bar item. The SupportHelper is required for this feature. | `/usr/local/bin/runs_when_support_appears.zsh` such as [`/usr/local/bin/user_permissions.zsh`](https://github.com/root3nl/SupportApp/blob/master/Extension%20Sample%20Scripts/user_permissions.zsh) or [`/usr/local/bin/jamf_last_check-in_time.zsh`](https://github.com/root3nl/SupportApp/blob/master/Extension%20Sample%20Scripts/jamf_last_check-in_time.zsh) or [`/usr/local/bin/mscp_compliance_status.sh`](https://github.com/root3nl/SupportApp/blob/master/Extension%20Sample%20Scripts/mscp_compliance_status.sh) |

> **Warning**
> Both Support App Extensions have other preference keys `ExtensionValueA` and `ExtensionValueB` but those keys are meant to be dynamically set and changed by a script or command, not by MDM. Once set, the default placeholder will disappear and show the output from the preference keys.

#### How to populate Support App Extensions
Support App Extensions must be populated by setting the value in a preference key within the preference domain `nl.root3.support`. This can be achieved by running custom scripts from your MDM solution or using the `OnAppearAction` key. This last option will allow you to update the Support App Extension values every time the Support App popover appears by running the script.

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

# Trigger an orange warning notification badge depending on the output you decide
if [[ "${command_output}" == "OUTPUT_IS_BAD" ]]; then
 defaults write /Library/Preferences/nl.root3.support.plist ExtensionAlertA -bool true
else
 defaults write /Library/Preferences/nl.root3.support.plist ExtensionAlertA -bool false
fi

# Stop spinning indicator
defaults write /Library/Preferences/nl.root3.support.plist ExtensionLoadingA -bool false
```

> **Note**
> When using more than one Support App Extension combined with `OnAppearAction`, it's best to update the values in one script instead of chaining multiple scripts to have the best experience

> **Note**
> Please do not forget to make the script executable: `sudo chmod +x /PATH/TO/SCRIPT`

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

### Jamf Pro custom JSON schema
A JSON Schema for Jamf Pro is provided for easy configuration of all the preference keys without creating/modifying a custom Configuration Profile in XML format. Download the JSON file [**here**](https://github.com/root3nl/SupportApp/blob/master/Jamf%20Pro%20Custom%20Schema/Jamf%20Pro%20Custom%20Schema.json)

More information about the JSON Schema feature in Jamf Pro: https://docs.jamf.com/technical-papers/jamf-pro/json-schema/10.19.0/Overview.html

<img src="/Screenshots/jamf_pro_custom_schema.png" width="800">

### Installer or app bundle
Depending on your preference or MDM solution you can use either the installer or zipped app bundle. The installer includes a LaunchAgent and is the recommended method to make sure the app stays open and relaunches automatically.

### Sample LaunchAgent
A sample LaunchAgent to always keep the app alive is provided [**here**](https://github.com/root3nl/SupportApp/blob/master/LaunchAgent%20Sample/nl.root3.support.plist)

### Sample Configuration Profile
A sample Configuration Profile you can edit to your preferences is provided [**here**](https://github.com/root3nl/SupportApp/blob/master/Configuration%20Profile%20Samples/Support%20App%20Configuration%20Sample.mobileconfig)

#### Background Item Management
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

## Known issues
* All available software updates (minor and major) are shown in the menu bar icon and the macOS version info item, even when the update is deferred using a Restrictions Configuration Profile from MDM. macOS collects all available updates in `/Library/Preferences/com.apple.SoftwareUpdate.plist` regardless of any deferral configurations. Only major OS updates can be hidden using the `HideMajorUpdates` key for macOS 12.3 and later.
* When Jamf Connect is used as password type, clicking "Change Now" does not allow the user to open the Jamf Connect change password window, but instead triggers an alert. Jamf Connect does not support a URL Scheme for opening the Change Password window. Please upvote this feature request: https://ideas.jamf.com/ideas/JN-I-16087

## Changelog

**Version 2.6**
* **Scripts with elevated privileged**: There is now built-in support for executing scripts with elevated privileges. A new Privileged Helper Tool is now part of the Support App and no longer requires the separate SupportHelper package. A Privileged Helper Tool is integrated, more secure and easier to configure. Additionally, script permission checks are performed to only allow scripts owned by root with the proper permissions.
  * The Privileged Helper Tool is automatically installed and enabled when the PKG installer is used
  * The key value DistributedNotification for keys like FirstRowTypeLeft is now deprecated and replaced with PrivilegedScript
  * **BREAKING CHANGE**: Using commands instead of a script path is no longer supported due to the increased security mechanisms. Please migrate commands to a script instead.
* **Root3 App Catalog integration**: A new Info Item App Catalog is added to integrate with Root3's App Catalog solution for automated patch management for third party macOS applications. It provides unique features such as a daily update schedule, updating both managed and unmanaged apps and a user facing app to quickly install new applications. As some app updates require user interaction, users may defer an update and want to update at a more convenient time. The Support App periodically checks for available app updates and allows the user to update apps whenever they prefer in an accessible way. To enable this integration, set the key AppCatalog for one of the Info Items and it requires a valid subscription or trial.
* **Declarative Device Management update information**: If an update declaration is sent using Declarative Device Management (macOS 14 and higher), the available update will show the enforcement date and time for the update in the macOS version Info Item. If present in the declaration, the DetailsURL will also show a button "Details" and opens the DetailsURL link.
* **Restart from Support App**: The Last Reboot Info Item now allows to immediately perform a graceful restart as requested in the text. The user no longer needs to leave the app and restart via the Apple-logo in the menu bar.
* **New standardized UI**: Certain Info Items now have a standard UI such as for macOS updates, uptime and the new App Catalog integration. The previously used popover is replaced with a window filling UI and back button (macOS 13 and higher).
* macOS 12 is now the minimum supported macOS version
* Several bug fixes and improvements

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
