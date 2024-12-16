//
//  AppDelegate.swift
//  Root3 Support
//
//  Created by Jordy Witteman on 07/07/2020.
//

import Cocoa
import os
import ServiceManagement
import SwiftUI

// Popover is based on: https://medium.com/@acwrightdesign/creating-a-macos-menu-bar-application-using-swiftui-54572a5d5f87

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    var popover: NSPopover!
    var eventMonitor: EventMonitor?
    var timer: Timer?
    var timerFiveMinutes: Timer?
    var timerEightHours: Timer?
    let menu = NSMenu()
    var statusBarItem: NSStatusItem?
    
    // Unified logging for StatusBarItem
    let logger = Logger(subsystem: "nl.root3.support", category: "StatusBarItem")
    
    // Unified logging for LaunchAgent using SMAppService
    let launchAgentLogger = Logger(subsystem: "nl.root3.support", category: "LaunchAgent")
    
    // Unified logging for Privileged Helper Tool
    let privilegedHelperToolLogger = Logger(subsystem: "nl.root3.support.helper", category: "SupportHelper")
    
    // Make standard UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Make UserDefaults easy to use with suite "com.apple.SoftwareUpdate"
    let ASUdefaults = UserDefaults(suiteName: "com.apple.SoftwareUpdate")
    
    // Make UserDefaults easy to use with suite "com.apple.applicationaccess"
    let restrictionsDefaults = UserDefaults(suiteName: "com.apple.applicationaccess")
    
    // Make UserDefaults easy to use with suite "nl.root3.catalog"
    let catalogDefaults = UserDefaults(suiteName: "nl.root3.catalog")
    
    // Make properties and preferences available
    var computerinfo = ComputerInfo()
    var userinfo = UserInfo()
    var preferences = Preferences()
    var appCatalogController = AppCatalogController()
    
    // Create red notification badge view
    // https://github.com/DeveloperMaris/ToolReleases/blob/master/ToolReleases/PopoverController.swift
    lazy var redBadge: NSView = {
        StatusItemBadgeView(frame: .zero, color: .systemRed)
    }()
    
    // Create orange notification badge view
    // https://github.com/DeveloperMaris/ToolReleases/blob/master/ToolReleases/PopoverController.swift
    lazy var orangeBadge: NSView = {
        StatusItemBadgeView(frame: .zero, color: .systemOrange)
    }()
    
    // Save current URL to StatusBarItem. While the app runs we detect if the URL is still the same during reloads of the StatusBarItem. Only if it changes, the image should be downloaded again.
    @AppStorage("LastKnownStatusBarItemUrl") var lastKnownStatusBarItemUrl: String = ""
    
    // Save current URL to Notification icon. While the app runs we detect if the URL is still the same during reloads of the StatusBarItem. Only if it changes, the image should be downloaded again.
    @AppStorage("LastKnownNotificationIconUrl") var lastKnownNotificationIconUrl: String = ""
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Configure LaunchAgent using SMAppService if available
        configureLaunchAgent()
        
        // Create the SwiftUI view and hosting controller that provides the window contents.
        let appView = AppView()
        let content = NSHostingController(rootView: appView
            .environmentObject(computerinfo)
            .environmentObject(userinfo)
            .environmentObject(preferences)
            .environmentObject(appCatalogController)
            .environmentObject(self))

        let popover = NSPopover()
        
        // Remove popover arrow
        // https://stackoverflow.com/questions/68744895/swift-ui-macos-menubar-nspopover-no-arrow
        popover.setValue(true, forKeyPath: "shouldHideAnchor")
        
        // Make the popover auto resizing for macOS 13 and later. macOS 12 may leave empty space some views are too large
        if #available(macOS 13.0, *) {
            content.sizingOptions = .preferredContentSize
        } else {
            // Fallback on earlier versions
            popover.contentSize = content.view.intrinsicContentSize
        }
        
        // Set popover size
        popover.behavior = .transient
        popover.contentViewController = content
        self.popover = popover
        
        // Create the status item
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        
        // Add notification badges as subviews
        if let button = statusBarItem?.button {
            button.addSubview(redBadge)
            button.addSubview(orangeBadge)
            
            // Set layout contraints
            NSLayoutConstraint.activate([
                redBadge.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -2),
                redBadge.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -12),
                redBadge.widthAnchor.constraint(equalToConstant: 8),
                redBadge.heightAnchor.constraint(equalToConstant: 8)
            ])
            
            // Set layout contraints
            NSLayoutConstraint.activate([
                orangeBadge.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -2),
                orangeBadge.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -12),
                orangeBadge.widthAnchor.constraint(equalToConstant: 8),
                orangeBadge.heightAnchor.constraint(equalToConstant: 8)
            ])
        }
        
        // Observe changes for UserDefaults
        defaults.addObserver(self, forKeyPath: "StatusBarIcon", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StatusBarIconSFSymbol", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StatusBarIconNotifierEnabled", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "UptimeDaysLimit", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StorageLimit", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "PasswordExpiryLimit", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "OpenAtLogin", options: .new, context: nil)
        restrictionsDefaults?.addObserver(self, forKeyPath: "forceDelayedMajorSoftwareUpdates", options: .new, context: nil)
        ASUdefaults?.addObserver(self, forKeyPath: "LastUpdatesAvailable", options: .new, context: nil)
        ASUdefaults?.addObserver(self, forKeyPath: "RecommendedUpdates", options: .new, context: nil)
        
        // Observe changes for Extensions A and B
        defaults.addObserver(self, forKeyPath: "ExtensionAlertA", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "ExtensionAlertB", options: .new, context: nil)
        
        // Observe changes for App Catalog
        catalogDefaults?.addObserver(self, forKeyPath: "Updates", options: .new, context: nil)
        
        // Receive notifications after uptime check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.uptimeDaysLimit, object: nil)
        
        // Receive notifications after network check
//        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.networkState, object: nil)
        
        // Receive notification after storage check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.storageLimit, object: nil)
        
        // Receive notification after password expiry check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.passwordExpiryLimit, object: nil)
        
        // Receive notification after major macOS update check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.majorVersionUpdates, object: nil)
        
        // Run functions at startup
        runAtStartup()
        
        // Set Custom Notification Icon
        setNotificationIcon()
        
        // Create the menu bar icon
        setStatusBarIcon()
        
        // Run background functions to update Status Bar Item when badges are enabled
        if defaults.bool(forKey: "StatusBarIconNotifierEnabled") {
            // Start 5 minute timer to query value updates
            timerFiveMinutes = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { time in
                self.logger.debug("Running five minute timer...")
                self.computerinfo.kernelBootTime()
                self.computerinfo.getStorage()
                self.computerinfo.getIPAddress()
                Task {
                    await self.userinfo.getCurrentUserRecord()
                }
            }
            
            // Start 8 hour timer to query app updates
            timerEightHours = Timer.scheduledTimer(withTimeInterval: 28800, repeats: true) { time in
                // Only run when App Catalog is installed
                if self.appCatalogController.catalogInstalled() {
                    self.appCatalogController.getAppUpdates()
                }
            }
            
        }
        
        // Create menu items for right click
        menu.addItem(NSMenuItem(title: NSLocalizedString("About Support", comment: ""), action: #selector(AppDelegate.showAbout), keyEquivalent: "i"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("Quit Support", comment: ""), action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "q"))
                
        // Event monitor to hide popover when clicked outside the popover.
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }
    
    // MARK: - Set and update the menu bar icon
    @objc func setStatusBarIcon() {
        
        logger.debug("Setting StatusBarItem")
        
        // Define the default menu bar icon
        let defaultSFSymbol = NSImage(systemSymbolName: "lifepreserver", accessibilityDescription: nil)
        let config = NSImage.SymbolConfiguration(textStyle: .body, scale: .large)
        let defaultSFSymbolImage = defaultSFSymbol?.withSymbolConfiguration(config)
        
        // Set the menu bar icon
        if let button = statusBarItem?.button {
            
            // Hide notification badge
            redBadge.isHidden = true
            orangeBadge.isHidden = true
            
            // Use custom Notification Icon if set in UserDefaults with fallback to default icon
            if let defaultsStatusBarIcon = defaults.string(forKey: "StatusBarIcon") {
                
                // Empty initializer with URL to local Notification Icon, either directly from the Configuration Profile or the local download location for remote image
                var localIconURL: String = ""
                
                // If image is a remote URL, download the image and store in container Documents folder
                if defaultsStatusBarIcon.hasPrefix("https") {
                                        
                    do {
                        
                        // Boolean new URL
                        var newURL: Bool
                        
                        // Detect if the URL changed to check whether to download the image again
                        if defaultsStatusBarIcon != lastKnownStatusBarItemUrl {
                            newURL = true
                        } else {
                            newURL = false
                        }
                        
                        if let downloadedIconURL = try getRemoteImage(url: defaultsStatusBarIcon, newURL: newURL, filename: "menu_bar_icon", logName: "StatusBarIcon") {
                            localIconURL = downloadedIconURL.path
                        }
                        
                    } catch {
                        logger.error("Failed to download StatusBarIcon")
                        logger.error("\(error.localizedDescription)")
                    }
                    
                    // Set current URL
                    lastKnownStatusBarItemUrl = defaultsStatusBarIcon
                    
                } else {
                    // Set image to file URL from Configuration Profile
                    logger.debug("StatusBarIcon is local file")
                    
                    localIconURL = defaultsStatusBarIcon
                }
                
                if let customIcon = NSImage(contentsOfFile: localIconURL) {
                    
                    // When custom image is larger than 22 point, we should resize to 16x16 points as recommended icon size
                    // https://bjango.com/articles/designingmenubarextras/
                    // The aspect ratio will be preserved
                    let maxSize: CGFloat = 22
                    let targetSize: CGFloat = 16

                    if customIcon.size.width > maxSize || customIcon.size.height > maxSize {
                        var newWidth = targetSize
                        var newHeight = targetSize
                        
                        if customIcon.size.width > customIcon.size.height {
                            newHeight = (targetSize / customIcon.size.width) * customIcon.size.height
                        } else {
                            newWidth = (targetSize / customIcon.size.height) * customIcon.size.width
                        }
                        
                        customIcon.size = NSSize(width: newWidth, height: newHeight)
                    }
                    
                    // Set status bar icon to custom image
                    button.image = customIcon
                    
                    // Render as template to make icon white and match system default
                    button.image?.isTemplate = true
                    logger.debug("StatusBarIcon preference key is set")
                    
                } else {
                    button.image = defaultSFSymbolImage
                    logger.error("StatusBarIcon preference key is set, but no valid image was found. Please check file path/name or permissions. Falling back to default image...")
                }
                // Use custom status bar icon using SF Symbols if set in UserDefaults with fallback to default icon
            } else if defaults.string(forKey: "StatusBarIconSFSymbol") != nil && defaults.string(forKey: "StatusBarIcon") == nil {
                
                // https://developer.apple.com/videos/play/wwdc2020/10207/
                if let customSFSymbol = NSImage(systemSymbolName: defaults.string(forKey: "StatusBarIconSFSymbol")!, accessibilityDescription: nil) {
                    
                    // Configure SF Symbol bigger and more bold to match other Menu Bar Extras
                    let config = NSImage.SymbolConfiguration(textStyle: .body, scale: .large)
                    let customSFSymbolImage = customSFSymbol.withSymbolConfiguration(config)
                    button.image = customSFSymbolImage
                    logger.debug("StatusBarIconSFSymbol preference key is set")
                    
                } else {
                    button.image = defaultSFSymbolImage
                    logger.error("StatusBarIconSFSymbol preference key is set, but no valid SF Symbol name was found. Falling back to default image...")
                }
                
                // Use default icon in all other cases
            } else {
                button.image = defaultSFSymbolImage
                logger.debug("No custom Status Bar Item icon is set, using default image...")
            }
            
            // Set notification counter next to the menu bar icon if enabled. https://www.hackingwithswift.com/example-code/system/how-to-insert-images-into-an-attributed-string-with-nstextattachment
            
            // Create array with configured info items. Disabled info items should not show a notification badge in the menu bar icon
            let infoItemsEnabled: [String] = [
                preferences.infoItemOne,
                preferences.infoItemTwo,
                preferences.infoItemThree,
                preferences.infoItemFour,
                preferences.infoItemFive,
                preferences.infoItemSix
            ]
            
            // If configured, ignore major macOS version updates
            if computerinfo.forceDelayedMajorSoftwareUpdates {
                logger.debug("forceDelayedMajorSoftwareUpdates is enabled, hiding \(self.computerinfo.majorVersionUpdates) major macOS updates")
            }
            
            // Check if StatusBarItem notifier is enabled
            if defaults.bool(forKey: "StatusBarIconNotifierEnabled") {
                // Show notification badge in menu bar icon when info item when needed
                if ((computerinfo.updatesAvailableToShow == 0 || !infoItemsEnabled.contains("MacOSVersion")) && (appCatalogController.appUpdates == 0 || !infoItemsEnabled.contains("AppCatalog"))) && ((computerinfo.uptimeLimitReached && infoItemsEnabled.contains("Uptime")) || (computerinfo.selfSignedIP && infoItemsEnabled.contains("Network")) || (userinfo.passwordExpiryLimitReached && infoItemsEnabled.contains("Password")) || (computerinfo.storageLimitReached && infoItemsEnabled.contains("Storage")) || (preferences.extensionAlertA && infoItemsEnabled.contains("ExtensionA")) || (preferences.extensionAlertB && infoItemsEnabled.contains("ExtensionB"))) {
                    
                    // Create orange notification badge
                    orangeBadge.isHidden = false
                    
                } else if (computerinfo.updatesAvailableToShow > 0 && infoItemsEnabled.contains("MacOSVersion")) || (appCatalogController.appUpdates > 0 && infoItemsEnabled.contains("AppCatalog")) {
                    
                    // Create red notification badge
                    redBadge.isHidden = false
                    
                }
            }
            
            // Force redrawing the button
            button.display()

            // Action when clicked on the menu bar icon
            button.action = #selector(self.statusBarButtonClicked)
            
            // Monitor left or right clicks
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    // MARK: - Set Custom Notification Icon
    func setNotificationIcon() {
        
        // Set custom alert icon if specified
        if let defaultsNotificationIcon = defaults.string(forKey: "NotificationIcon") {
            
            logger.debug("Notification icon configured...")
            
            // Empty initializer with URL to local Status Bar Item, either directly from the Configuration Profile or the local download location for remote image
            var localNotificationIconURL: String = ""
            
            // If image is a remote URL, download the image and store in container Documents folder
            if defaultsNotificationIcon.hasPrefix("https") {
                                    
                do {
                    
                    // Boolean new URL
                    var newURL: Bool
                    
                    // Detect if the URL changed to check whether to download the image again
                    if defaultsNotificationIcon != lastKnownNotificationIconUrl {
                        newURL = true
                    } else {
                        newURL = false
                    }
                    
                    if let downloadedIconURL = try getRemoteImage(url: defaultsNotificationIcon, newURL: newURL, filename: "notification_icon", logName: "Notification Icon") {
                        localNotificationIconURL = downloadedIconURL.path
                    }
                    
                    // Set current URL
                    lastKnownNotificationIconUrl = defaultsNotificationIcon
                    
                } catch {
                    logger.error("Failed to download Notification Icon")
                    logger.error("\(error.localizedDescription)")
                }
                
            } else {
                // Set image to file URL from Configuration Profile
                logger.debug("Notification Icon is local file")
                
                localNotificationIconURL = defaultsNotificationIcon
            }
            
            if let appIconImage = NSImage(contentsOfFile: localNotificationIconURL) {
                appIconImage.setName("NSApplicationIcon")
                NSApplication.shared.applicationIconImage = appIconImage
            } else {
                logger.error("Invalid custom alert icon...")
            }
        }
    }
    
    // MARK: - Reload StatusBarItem when changes are observed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case "StatusBarIcon":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.defaults.string(forKey: "StatusBarIcon") ?? "", privacy: .public)")
        case "StatusBarIconSFSymbol":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.defaults.string(forKey: "StatusBarIconSFSymbol") ?? "", privacy: .public)")
        case "StatusBarIconNotifierEnabled":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.defaults.bool(forKey: "StatusBarIconNotifierEnabled"), privacy: .public)")
        case "UptimeDaysLimit":
            // Check uptime when key UptimeDaysLimit is changed
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.preferences.uptimeDaysLimit, privacy: .public), checking uptime...")
            self.computerinfo.kernelBootTime()
        case "StorageLimit":
            // Check storage when key StorageLimit is changed
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.preferences.storageLimit, privacy: .public), checking storage...")
            self.computerinfo.getStorage()
        case "PasswordExpiryLimit":
            // Check password expiry when key PasswordExpiryLimit is changed
            logger.debug("\(keyPath! as NSObject, privacy: .public) change to \(self.preferences.passwordExpiryLimit, privacy: .public), checking password expiry...")
            Task {
                await self.userinfo.getCurrentUserRecord()
            }
        case "LastUpdatesAvailable":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.ASUdefaults!.integer(forKey: "LastUpdatesAvailable"), privacy: .public)")
        case "RecommendedUpdates":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed, checking update contents...")
            self.computerinfo.getRecommendedUpdates()
        case "OpenAtLogin":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.defaults.bool(forKey: "OpenAtLogin"), privacy: .public)")
            self.configureLaunchAgent()
        case "forceDelayedMajorSoftwareUpdates":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.restrictionsDefaults!.bool(forKey: "forceDelayedMajorSoftwareUpdates"), privacy: .public)")
            self.computerinfo.getRecommendedUpdates()
        case "ExtensionAlertA":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.preferences.extensionAlertA, privacy: .public)")
        case "ExtensionAlertB":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.preferences.extensionAlertB, privacy: .public)")
        case "Updates":
            if appCatalogController.ignoreUpdateChange {
                appCatalogController.ignoreUpdateChange.toggle()
            } else {
                logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.appCatalogController.appUpdates, privacy: .public)")
                appCatalogController.getAppUpdates()
            }
        default:
            logger.debug("Some other change detected...")
        }
        
        // Always reload the StatusBarItem when other changes are detected
        logger.debug("Reloading StatusBarItem")
        setStatusBarIcon()
    
    }

    // MARK: - Process left and right clicks. https://samoylov.eu/2016/09/14/handling-left-and-right-click-at-nsstatusbar-with-swift-3/
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        // Show menu for right click
        if event.type == NSEvent.EventType.rightMouseUp {
            logger.debug("Right mouse button clicked...")
            closePopover(sender: nil)

            // FIXME: Old deprecated API
            statusBarItem?.popUpMenu(menu)
            
            // FIXME: Could not get new API to work correctly
//            statusBarItem.menu = menu // add menu to button...
//            statusBarItem.button?.performClick(nil) // ...and click
                           
        // Show Popover for left click
        } else {
            logger.debug("Left mouse button clicked...")
            togglePopover(nil)
        }
    }
    
    // FIXME: Could not get new API to work correctly
//    @objc func menuDidClose(_ menu: NSMenu) {
//        statusBarItem.menu = nil // remove menu so button works as before
//        logger.debug("menuDidClose")
//    }
    
    // MARK: - Close or open popover depending on current state
    @objc func togglePopover(_ sender: Any?) {
      if popover.isShown {
        logger.debug("Closing popover...")
        
        closePopover(sender: sender)
      } else {
        logger.debug("Opening popover...")

        showPopover(sender: sender)
      }
    }
    
    // Popover arrow is hidden using this trick: https://nyrra33.com/2018/08/08/a-small-trick-to-hide-nspopovers-arrow/
    
    // Popover is hidden when clicked outside the frame using EventMonitor: https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos
    
    // MARK: - Show the popover
    func showPopover(sender: Any?) {
        
        if let button = statusBarItem?.button {
            
            // Disable animation when popover opens
            self.popover.animates = false
            
            // show popover
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            
            // Enable animation again to avoid issues
            self.popover.animates = true
            
            // Start monitoring mouse clicks outside the popover
            eventMonitor?.start()
            
            // MARK: - Run functions immediately when popover opens
            self.computerinfo.getHostname()
            self.computerinfo.kernelBootTime()
            self.computerinfo.getStorage()
            self.computerinfo.getIPAddress()
            
            Task {
                await self.userinfo.getCurrentUserRecord()
            }
                        
            // Post Distributed Notification to trigger script for custom info items
            if defaults.string(forKey: "OnAppearAction") != nil {
                Task {
                    await runOnAppearAction()
                }
            }
            
        }
        // Necessary to make the view active without having to do an extra click
        self.popover.contentViewController?.view.window?.becomeKey()
    }
    
    // MARK: - Run functions at startup
    func runAtStartup() {
        // Run uptime and storage once at startup
        self.computerinfo.kernelBootTime()
        Task {
            await self.userinfo.getCurrentUserRecord()
            await self.computerinfo.getSerialNumber()
        }
        self.computerinfo.getStorage()
        self.computerinfo.getRecommendedUpdates()
        self.computerinfo.getModelName()
        if #available(macOS 13, *) {
            self.computerinfo.getRSRVersion()
        }
        
        // Only run when App Catalog is installed
        if appCatalogController.catalogInstalled() {
            self.appCatalogController.getAppUpdates()
        }
        
        // Uninstall Privileged Helper Tool if configured
        if defaults.bool(forKey: "DisablePrivilegedHelperTool") {
            self.uninstallPrivilegedHelperTool()
        }
    }
    
    // MARK: - Close the popover
    func closePopover(sender: Any?) {
//        popover.performClose(sender)
        popover.close()
        
        // Stop monitoring mouse clicks outside the popover
        eventMonitor?.stop()
        
        // Stop timer when popover closes
        timer?.invalidate()
        
        // Show default popover view with more relevant info
        self.appCatalogController.showAppUpdates = false
        self.computerinfo.showMacosUpdates = false
        self.computerinfo.showUptimeAlert = false
    }

    // MARK: - Show the standard about window
    @objc func showAbout() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    // MARK: - Function to uninstall Privileged Helper Tool
    func uninstallPrivilegedHelperTool() {
        
        privilegedHelperToolLogger.log("Uninstalling Privileged Helper Tool...")
        
        // Check if Privileged Helper Tool exists
        let privilegedHelperToolPath = "/Library/PrivilegedHelperTools/nl.root3.support.helper"
        guard FileUtilities().fileOrFolderExists(path: privilegedHelperToolPath) else {
            privilegedHelperToolLogger.log("Privileged Helper Tool was already uninstalled")
            return
        }
        
        // Get path to uninstall script
        guard let uninstallScript = Bundle.main.path(forResource: "uninstall_privileged_helper_tool", ofType: "zsh") else {
            privilegedHelperToolLogger.error("Uninstall script not found")
            return
        }
        
        // Verify permissions
        guard FileUtilities().verifyPermissions(pathname: uninstallScript) else {
            return
        }
        
        do {
            try ExecutionService.executeScript(command: uninstallScript) { exitCode in
                
                if exitCode == 0 {
                    self.privilegedHelperToolLogger.debug("Uninstalled Privileged Helper Tool successfully")
                } else {
                    self.privilegedHelperToolLogger.error("Error while uninstalling Privileged Helper Tool. Exit code: \(exitCode, privacy: .public)")
                }

            }
        } catch {
            privilegedHelperToolLogger.log("Error while uninstalling Privileged Helper Tool. Error: \(error.localizedDescription, privacy: .public)")
        }
        
    }
    
    // MARK: - Function to run OnAppearAction
    func runOnAppearAction() async {
        
        logger.log("Running OnAppearAction...")
        
        let defaults = UserDefaults.standard
        
        // Exit when no command or script was found
        guard let privilegedScript = defaults.string(forKey: "OnAppearAction") else {
            logger.error("OnAppearAction was not found")
            return
        }
        
        // Check value comes from a Configuration Profile. If not, the command or script may be maliciously set and needs to be ignored
        guard defaults.objectIsForced(forKey: "OnAppearAction") == true else {
            logger.error("OnAppearAction is not set by an administrator and is not trusted. Action will not be executed")
            return
        }
        
        // Verify permissions
        guard FileUtilities().verifyPermissions(pathname: privilegedScript) else {
            return
        }
        
        do {
            try ExecutionService.executeScript(command: privilegedScript) { exitCode in
                
                if exitCode == 0 {
                    self.logger.debug("Privileged script ran successfully with exit code 0")
                } else {
                    self.logger.error("Error while running privileged script. Exit code: \(exitCode, privacy: .public)")
                }

            }
        } catch {
            logger.log("Failed to run privileged script or command. Error: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    // Use SMAppService to handle LaunchAgent on macOS 13 and higher
    func configureLaunchAgent() {
        if #available(macOS 13.0, *) {
            
            // Set LaunchAgent PLIST name
            let agent = SMAppService.agent(plistName: "nl.root3.support.plist")
            launchAgentLogger.debug("LaunchAgent status: \(agent.status.rawValue)")
            
            // Set Legacy LaunchAgent file path URL
            let legacyLAStatus = SMAppService.statusForLegacyPlist(at: URL(filePath: "/Library/LaunchAgents/nl.root3.support.plist"))
            launchAgentLogger.debug("Legacy LaunchAgent status: \(legacyLAStatus.rawValue)")
            
            // Don't register SMAppService when Legacy LaunchAgent is active
            guard legacyLAStatus != .enabled else {
                launchAgentLogger.debug("Legacy LaunchAgent is active")
                return
            }
            
            // Try to register LaunchAgent unless disabled in Configuration Profile
            if preferences.openAtLogin {
                
                switch agent.status {
                case .enabled:
                    launchAgentLogger.debug("LaunchAgent is already registered and enabled")
                case .notFound:
                    launchAgentLogger.error("LaunchAgent not found")
                    // Try to register LaunchAgent
                    do {
                        try agent.register()
                        launchAgentLogger.debug("LaunchAgent was successfully registered")
                        
                        // Terminate the application to avoid running multiple instances of the app
                        NSApplication.shared.terminate(self)
                    } catch {
                        launchAgentLogger.error("Error registering LaunchAgent")
                        launchAgentLogger.error("\(error, privacy: .public)")
                    }
                case .notRegistered:
                    launchAgentLogger.debug("LaunchAgent is not registered, trying to register...")
                    // Try to register LaunchAgent
                    do {
                        try agent.register()
                        launchAgentLogger.debug("LaunchAgent was successfully registered")
                        
                        // Terminate the application to avoid running multiple instances of the app
                        NSApplication.shared.terminate(self)
                    } catch {
                        launchAgentLogger.error("Error registering LaunchAgent")
                        launchAgentLogger.error("\(error, privacy: .public)")
                    }
                case .requiresApproval:
                    launchAgentLogger.debug("LaunchAgent requires user approval")
                    SMAppService.openSystemSettingsLoginItems()
                    
                    // Terminate the application to avoid running multiple instances of the app
                    NSApplication.shared.terminate(self)
                default:
                    launchAgentLogger.error("Unknown error with LaunchAgent")
                }
            } else {
                
                guard agent.status != .notRegistered else {
                    launchAgentLogger.debug("LaunchAgent is already unregistered")
                    return
                }
                
                // Try to unregister LaunchAgent when disabled in Configuration Profile
                agent.unregister(completionHandler: { error in
                    if let error = error {
                        self.launchAgentLogger.error("Error unregistering LaunchAgent: \(error, privacy: .public)")
                    } else {
                        self.launchAgentLogger.debug("LaunchAgent successfully unregistered")
                    }
                })
            }
        }
    }
    
    // MARK: - Function to fetch remote image to container Documents folder
    func getRemoteImage(url: String, newURL: Bool, filename: String, logName: String) throws -> URL? {
                     
        guard let url = URL(string: url) else {
            return nil
        }
        
        // Path to App Sandbox container
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "nl.root3.support") else {
            return nil
        }
        
        let documentsFolder = container.appendingPathComponent("Documents", isDirectory: true)
        let fileURL = documentsFolder.appendingPathComponent("\(filename).\(url.pathExtension)")
        
        // Remove file if it already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            
            // Just return the URL and avoid downloading the image again
            if !newURL {
                logger.debug("URL for \(logName) is unchanged, no need to download image again")
                return fileURL
            }
            
            do {
                logger.debug("Removing \(logName)")
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                logger.error("\(error.localizedDescription)")
            }
        }
        
        logger.debug("Downloading remote \(logName) from URL")
                        
        // Create a semaphore to wait for the file removal
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.downloadTask(with: url) { data, response, error in
            
            if let data = data {
                
                do {
                    try FileManager.default.moveItem(atPath: data.path, toPath: fileURL.path)
                }
                catch {
                    self.logger.error("\(error.localizedDescription)")
                }
            }
            
            // Signal the semaphore to continue
            semaphore.signal()
            
        }
        .resume()
        
        // Wait for the semaphore to be signaled
        semaphore.wait()
        
        return fileURL
    }
}
