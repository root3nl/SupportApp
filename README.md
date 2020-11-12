# macOS Support App

<img src="/Screenshots/root3_light_mode.png" width="450"> 

<img src="/Screenshots/example_light_mode.png" width="300"> <img src="/Screenshots/example_dark_mode.png" width="300">

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Download](#download)
- [Technologies](#technologies)
- [Features](#features)
  * [Title and logo](#title-and-logo)
  * [Color](#color)
  * [Diagnostic information](#diagnostic-information)
  * [App and Link shortcuts](#app-and-link-shortcuts)
- [Configuration](#configuration)
- [How to use SF Symbols](#how-to-use-sf-symbols)
- [MDM deployment](#mdm-deployment)
  * [Jamf Pro custom JSON Schema](#jamf-pro-custom-json-schema)
  * [Installer or app bundle](#app-and-link-shortcuts)
  * [Sample LaunchAgent](#app-and-link-shortcuts)
  * [Sample Configuration Profile](#app-and-link-shortcuts)
- [Known issues](#known-issues)
- [Changelog](#changelog)
- [Note and disclaimer](#note-and-disclaimer)

## Introduction
The Support app is a macOS menu bar app built for organizations to:
* Help users and helpdesks to see basic diagnostic information at a glance
* Offer shortcuts to easily access support channels or other company resources such as a website or a file server
* Give users a modern and native macOS app with your corporate identity

The app is developed by Root3, specialized in managing Apple devices. Root3 offers consultancy and support for organizations to get the most out of their Apple devices and is based in The Netherlands (Haarlem).

Root3 already had a basic in-house support app written in Objective-C and decided to completely rewrite it in Swift using SwiftUI with an all-new design that looks great on macOS Big Sur. We’ve learned that SwiftUI is the perfect way of creating great looking apps for all Apple platforms with minimal effort. In the development process we decided to make it generic so other organizations can take advantage of it and contribute to the Mac admins community.


The easiest and recommended way to configure the app is using a Configuration Profile and your MDM solution.

## Requirements
* macOS 11.0.1 or higher
* Any MDM solution supporting custom Configuration Profiles

## Download
Package Installer (includes LaunchAgent): [**Download**](https://github.com/root3nl/SupportApp/releases/download/v2.0-rc1/Support.2.0.RC1.pkg)

Application (zipped): [**Download**](https://github.com/root3nl/SupportApp/releases/download/v2.0-rc1/Support.zip)

See the MDM deployment section below for more info.

## Technologies
* Written in Swift using SwiftUI
* All icons are SF Symbols
* Built for and compatible with macOS 11.0 and higher
* Dark Mode support
* Colors are matched with your macOS accent color (blue by default)
* MDM support to configure your own branding such as a custom title, logo, SF Symbols and contact methods
* Notarized
* Sandboxed
* Localization in English and Dutch

## Features

### Title and logo
The row above the buttons allow a custom title and company logo. The logo supports several images types like PNG, JPEG and ICNS and will be resized to a maximum height of 48 points. The original aspect ratio will be retained. A PNG with alpha channel is advised to get variable transparency around your logo.

### Color
All the circles around the symbols have the macOS accent color and will dynamically change with the user setting. If desired, this color can be customized matching your corporate colors. We recommend keeping the macOS accent color when the color of your choice is too light, as text is be difficult to read.

### Diagnostic information
* **Computer Name**: The current computer name will be displayed here. Especially helpful when your organisation has a difficult naming convention and users want to do things like AirDrop.

* **macOS version**: The current version of macOS including major, minor and patch version as well as the marketing name. The marketing name will be easier to understand for your end users. Clicking on this item opens About This Mac.

* **Last Reboot**: The current uptime. When troubleshooting some issue, the first thing you would like to do is a reboot when the uptime is high.

* **Storage Used**: The storage percentage used on the boot drive. When hovering with the mouse, the available storage is shown. Clicking on this item opens the macOS built-in Storage Management app.


### App and link shortcuts
The buttons in the 3rd and 4th row behave as shortcuts to applications or links. You can configure five variables for every of these buttons:

* **Title**: Button label

* **Subtitle** (now shown if not configured): An extra string to display when the user hovers over the button

* **Type**: The link type the button should open, app or URL

* **Link**: Application (based on the bundle identifier) or Link to open

* **Symbol**: The symbol shown in the button, see the SF Symbols section how to use these symbols

The rows with configurable items are shown in the screenshot below:

<img src="/Screenshots/configurable_buttons.png" width="450">

## Configuration
The configuration of the Support app is optimized for use with your MDM solution. The easiest way to configure the app is using a Configuration Profile so you can use whatever MDM solution you like, as long as it supports custom Configuration Profiles.

Some preference keys like the icon and status bar icon point to a file location. Due to the sandboxed characteristic of the app, not all file locations are allowed. We suggest putting the files in a folder within Application Support such as `/Library/Application Support/Your Company/` where the app can read the contents. Other supported file locations can be found in Apple’s documentation about App Sandbox: https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html#//apple_ref/doc/uid/TP40011183-CH3-SW17

Below are all available preference keys:

| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| **General** |
| Title | String | Support | Text shown in the top left corner when the app opens. | “Your Company Name“, “IT Helpdesk“ etc. |
| Logo | String | App Icon | Path to the logo shown in the top right corner when the app opens. Scales to 48 points maximum height. | “ /Library/Application Support/Your Company/logo.png” |
| StatusBarIcon | String | Root3 Logo | Path to the status bar icon shown in the menu bar. Recommended: PNG, 16x16 points | “ /Library/Application Support/Your Company/statusbaricon.png” |
| CustomColor | String | macOS Accent Color | Custom color for all symbols. Leave empty to use macOS Accent Color. We recommend not to use a very light color as text may become hard to read | HEX color in RGB format like "#8cc63f" |
| HideFirstRow | Boolean | false | Hides the first row of configurable items. | true |
| HideSecondRow | Boolean | false | Hides the second row of configurable items. | true |
| **First row of configurable items: Item left** |
| FirstRowTitleLeft | String | Remote Support | The text shown in the button label. | “Share My Screen”, “TeamViewer“, “My core application” etc. |
| FirstRowSubtitleLeft | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open“, “Share your screen“ |
| FirstRowTypeLeft | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App** or **URL** |
| FirstRowLinkLeft | String | com.apple.ScreenSharing | The Bundle Identifier of the app or link that should be opened. | “com.teamviewer.TeamViewerQS“ |
| FirstRowSymbolLeft | String | cursorarrow | The SF Symbol shown in the button. | “binoculars.fill”, “cursorarrow.click.2” or any other SF Symbol. Please check the SF Symbols section. |
| **First row of configurable items: Item right** |
| FirstRowTitleRight | String | Company Store | The text shown in the button label. | “Self Service“, “App Store“ |
| FirstRowSubtitleRight | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open”, “Download apps“ |
| FirstRowTypeRight | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App** or **URL** |
| FirstRowLinkRight | String | com.apple.AppStore | The Bundle Identifier of the app or link that should be opened. | “com.jamfsoftware.selfservice.mac” |
| FirstRowSymbolRight | String | cart.fill | The SF Symbol shown in the button. | “briefcase.fill”, “bag.circle”, “giftcard.fill”, “gift.circle” or any other SF Symbol. Please check the SF Symbols section. |
| **Second row of configurable items: Item left**|
| SecondRowTitleLeft | String | Support Ticket | The text shown in the button label. | “Create ticket”, “Open incident“ |
| SecondRowSubtitleLeft | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “support.company.tld”, “Now”, “Create“ |
| SecondRowTypeLeft | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App** or **URL** |
| SecondRowLinkLeft | String | https://yourticketsystem.tld | The Bundle Identifier of the app or link that should be opened. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolLeft | String | ticket | The SF Symbol shown in the button. | “lifepreserver”, “person.fill.questionmark” or any other SF Symbol. Please check the SF Symbols section. |
| **Second row of configurable items: Item middle** |
| SecondRowTitleMiddle | String | Email | The text shown in the button label. | “Send email” |
| SecondRowSubtitleMiddle | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “support@company.tld”, “Now” |
| SecondRowTypeMiddle | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App** or **URL** |
| SecondRowLinkMiddle | String | mailto:support@company.tld | The Bundle Identifier of the app or link that should be opened. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
| SecondRowSymbolMiddle | String | envelope | The SF Symbol shown in the button. | “paperplane”, “arrowshape.turn.up.right.fill” or any other SF Symbol. Please check the SF Symbols section. |
| **Second row of configurable items: Item right** |
| SecondRowTitleRight | String | Phone | The text shown in the button label. | “Call Helpdesk“, “Phone“ |
| SecondRowSubtitleRight | String | - | Subtitle text will replace the title when the user hovers over the button. Ignored if left empty. | “+31 00 000 00 00”, “Now”, “Call“ |
| SecondRowTypeRight | String | URL | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App** or **URL** |
| SecondRowLinkRight | String | tel:+31000000000 | The Bundle Identifier of the app or link that should be opened. | “https://yourticketsystem.tld”, “mailto:support@company.tld”, “tel:+31000000000” or “smb://yourfileserver.tld” |
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
* Buttons may keep a hovered state when mouse cursor moves fast: FB8212902

## Changelog

## Note and disclaimer
* Root3 developed this application as a side project to add additional value for our customers
* The application can be used free of charge and is provided ‘as is’, without any warranty
* Comments and feature request are appreciated. Please email jordy.witteman@root3.nl
