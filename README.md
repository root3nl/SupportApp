# Support App

## Introduction
The Support app is a macOS menu bar app built for organizations to:
* Help users and helpdesks to see basic diagnostic information at a glance
* Offer shortcuts to easily access support channels or other company resources such as a website or a file server
* Give users a modern and native macOS app with your corporate identity


Root3 already had a basic in-house support app written in Objective-C and decided to completely rewrite it in Swift using SwiftUI with an all-new design that looks great on macOS Big Sur. We’ve learned that SwiftUI is the perfect way of creating great looking apps for all Apple platforms with minimal effort. In the development process we decided to make it generic so other organizations can take advantage of it and contribute to the Mac admins community.


The easiest and recommended way to configure the app is using a Configuration Profile and your MDM solution.

## Requirements
* macOS 11.0 or higher is required
* Any MDM solution supporting custom Configuration Profiles

## Download
Package Installer (includes LaunchAgent):

Application (Zipped):

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

### Diagnostic information
* **Computer Name**: The current computer name will be displayed here. Especially helpful when your organisation has a difficult naming convention and users want to do things like AirDrop.

* **macOS version**: The current version of macOS including major, minor and patch version as well as the marketing name. The marketing name will be easier to understand for your end users. Clicking on this item opens About This Mac.

* **Last Reboot**: The current uptime. When troubleshooting some issue, the first thing you would like to do is a reboot when the uptime is high.

* **Storage Used**: The storage percentage used on the boot drive. When hovering with the mouse, the available storage is shown. Clicking on this item opens the macOS built-in Storage Management app.


### App/Link shortcuts
The buttons in the 3rd and 4th row behave as shortcuts to applications or links. You can configure five variables for every of these buttons:

* **Title**: Button label

* **Subtitle** (now shown if not configured): An extra string to display when the user hovers over the button

* **Type**: The link type the button should open, app or URL

* **Link**: Application (based on the bundle identifier) or Link to open

* **Symbol**: The symbol shown in the button, see the SF Symbols section how to use these symbols

The rows with configurable items are shown in the screenshot below:

### Configuration
The configuration of the Support app is optimized for use with your MDM solution. The easiest way to configure the app is using a Configuration Profile so you can use whatever MDM solution you like, as long as it supports custom Configuration Profiles.

Some preference keys like the icon and status bar icon point to a file location. Due to the sandboxed characteristic of the app, not all file locations are allowed. We suggest putting the files in a folder within Application Support such as `/Library/Application Support/Your Company/` where the app can read the contents. Other supported file locations can be found in Apple’s documentation about App Sandbox: https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html#//apple_ref/doc/uid/TP40011183-CH3-SW17

Below are all available preference keys:

| Preference key | Type | Default value | Description | Example |
| --- | --- | --- | --- | --- |
| **General** |
| Title | String | Support | Text shown in the top left corner when the app opens. | “Your Company Name“, “IT Helpdesk“ etc. |
| Logo | String | App Icon | Path to the logo shown in the top right corner when the app opens. Scales to 48 points maximum height. | “ /Library/Application Support/Your Company/logo.png” |
| StatusBarIcon | String | Root3 Logo | Path to the status bar icon shown in the menu bar. Recommended: PNG, 16x16 points | “ /Library/Application Support/Your Company/statusbaricon.png” |
| HideFirstRow | Boolean | false | Hides the first row of configurable items. | true |
| HideSecondRow | Boolean | false | Hides the second row of configurable items. | true |
| **First row of configurable items: Item left** |
| FirstRowTitleLeft | String | Remote Support | The text shown in the button label. | “Share My Screen”, “TeamViewer“, “My core application” etc. |
| FirstRowSubtitleLeft | String | - | Subtitle text will appear under title when the user hovers over the button. Ignored if left empty. | “Click to open“, “Share your screen“ |
| FirstRowTypeLeft | String | App | Type of link the item should open. Can be anything like screen sharing tools, company stores, file servers or core applications in your organization. | **App** or **URL** |
| FirstRowLinkLeft | String | com.apple.ScreenSharing | The Bundle Identifier of the app or link that should be opened. | “com.teamviewer.TeamViewerQS“ |
| FirstRowSymbolLeft | String | cursorarrow | The SF Symbol shown in the button. | “binoculars.fill”, “cursorarrow.click.2” or any other SF Symbol. Please check the SF Symbols section. |
| **First row of configurable items: Item right** |
