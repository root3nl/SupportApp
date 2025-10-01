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

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    var popover: NSPopover!
    var eventMonitor: EventMonitor?
    var timer: Timer?
    var timerFiveMinutes: Timer?
    var timerEightHours: Timer?
    let menu = NSMenu()
    var statusBarItem: NSStatusItem?
    
    var configuratorMenuItem: NSMenuItem?
    
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
    let computerinfo = ComputerInfo()
    let userinfo = UserInfo()
    let preferences = Preferences()
    let appCatalogController = AppCatalogController()
    let localPreferences = LocalPreferences()
    let popoverLifecycle = PopoverLifecycle()
    
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
            .environmentObject((localPreferences))
            .environmentObject(popoverLifecycle)
            .environmentObject(self))

        let popover = NSPopover()
        
        // Remove popover arrow
        // https://stackoverflow.com/questions/68744895/swift-ui-macos-menubar-nspopover-no-arrow
        popover.setValue(true, forKeyPath: "shouldHideAnchor")
        
        // Make the popover auto resizing
        content.sizingOptions = .preferredContentSize
        
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
        defaults.addObserver(self, forKeyPath: "StatusBarIconAllowsColor", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StatusBarIconSFSymbol", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StatusBarIconNotifierEnabled", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "UptimeDaysLimit", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StorageLimit", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "PasswordExpiryLimit", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "OpenAtLogin", options: .new, context: nil)
        restrictionsDefaults?.addObserver(self, forKeyPath: "forceDelayedMajorSoftwareUpdates", options: .new, context: nil)
        ASUdefaults?.addObserver(self, forKeyPath: "RecommendedUpdates", options: .new, context: nil)
        
        // Observe changes for Extensions A and B
        defaults.addObserver(self, forKeyPath: "ExtensionAlertA", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "ExtensionAlertB", options: .new, context: nil)
        
        // Observer changes to 'Rows'
        defaults.addObserver(self, forKeyPath: "Rows", options: .new, context: nil)

        // Receive notifications after uptime check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.uptimeDaysLimit, object: nil)
        
        // Receive notifications after network check
//        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.networkState, object: nil)
        
        // Receive notification after storage check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.storageLimit, object: nil)
        
        // Receive notification after password expiry check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.passwordExpiryLimit, object: nil)
        
        // Receive notification after macOS update check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.recommendedUpdates, object: nil)
        
        // Decode app updates and reload status bar item when Catalog Agent or App completed an update check
        DistributedNotificationCenter.default().addObserver(forName: Notification.Name.updateCheckCompleted, object: nil, queue: .main) { _ in
            // Decode app updates
            self.appCatalogController.decodeAppUpdates()
            
            // Reload Status bar icon
            self.setStatusBarIcon()
        }
        
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
        
        // MARK: - Create menu items for right click
        // About button
        let aboutItem = NSMenuItem(title: NSLocalizedString("About Support", comment: ""), action: #selector(AppDelegate.showAbout), keyEquivalent: "i")
        aboutItem.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)
        menu.addItem(aboutItem)

        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // Configurator Mode button
        let configuratorItem = NSMenuItem(title: NSLocalizedString("Configurator Mode", comment: ""),
                                          action: #selector(AppDelegate.configuratorMode),
                                          keyEquivalent: "c")
        configuratorItem.image = NSImage(systemSymbolName: "switch.2", accessibilityDescription: nil)
        configuratorItem.target = self
        configuratorItem.state = preferences.configuratorModeEnabled ? .on : .off
        // Disable Configutor Mode when configured
        configuratorItem.isHidden = preferences.disableConfiguratorMode && defaults.objectIsForced(forKey: "DisableConfiguratorMode")
        menu.addItem(configuratorItem)
        
        self.configuratorMenuItem = configuratorItem
        menu.addItem(NSMenuItem.separator())
        
        // Quit button
        let quitItem = NSMenuItem(title: NSLocalizedString("Quit Support", comment: ""), action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "q")
        quitItem.image = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: nil)
        menu.addItem(quitItem)
                
        // Event monitor to hide popover when clicked outside the popover.
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                if !strongSelf.preferences.configuratorModeEnabled {
                    strongSelf.closePopover(sender: event)
                }
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
            if !preferences.statusBarIcon.isEmpty {
                
                // Empty initializer with URL to local Notification Icon, either directly from the Configuration Profile or the local download location for remote image
                var localIconURL: String = ""
                
                // If image is a remote URL, download the image and store in container Documents folder
                if preferences.statusBarIcon.hasPrefix("https") {
                                        
                    do {
                        
                        // Boolean new URL
                        var newURL: Bool
                        
                        // Detect if the URL changed to check whether to download the image again
                        if preferences.statusBarIcon != lastKnownStatusBarItemUrl {
                            newURL = true
                        } else {
                            newURL = false
                        }
                        
                        if let downloadedIconURL = try getRemoteImage(url: preferences.statusBarIcon, newURL: newURL, filename: "menu_bar_icon", logName: "StatusBarIcon") {
                            localIconURL = downloadedIconURL.path
                        }
                        
                    } catch {
                        logger.error("Failed to download StatusBarIcon")
                        logger.error("\(error.localizedDescription)")
                    }
                    
                    // Set current URL
                    DispatchQueue.main.async {
                        self.lastKnownStatusBarItemUrl = self.preferences.statusBarIcon
                    }
                    
                } else {
                    // Set image to file URL from Configuration Profile
                    logger.debug("StatusBarIcon is local file")
                    
                    DispatchQueue.main.async {
                        localIconURL = self.preferences.statusBarIcon
                    }
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
                    if preferences.statusBarIconAllowsColor {
                        button.image?.isTemplate = false
                    } else {
                        button.image?.isTemplate = true
                    }
                    logger.debug("StatusBarIcon preference key is set")
                    
                } else {
                    button.image = defaultSFSymbolImage
                    logger.error("StatusBarIcon preference key is set, but no valid image was found. Please check file path/name or permissions. Falling back to default image...")
                }
                // Use custom status bar icon using SF Symbols if set in UserDefaults with fallback to default icon
            } else if !preferences.statusBarIconSFSymbol.isEmpty && preferences.statusBarIcon.isEmpty {
                
                // https://developer.apple.com/videos/play/wwdc2020/10207/
                if let customSFSymbol = NSImage(systemSymbolName: preferences.statusBarIconSFSymbol, accessibilityDescription: nil) {
                    
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
            var infoItemsEnabled: [String] = [
                preferences.infoItemOne,
                preferences.infoItemTwo,
                preferences.infoItemThree,
                preferences.infoItemFour,
                preferences.infoItemFive,
                preferences.infoItemSix
            ]
            
            // Append all types from new structure
            if !preferences.rows.isEmpty {
                for row in preferences.rows {
                    if let items = row.items {
                        let allTypes = items.compactMap { $0.type }
                        infoItemsEnabled.append(contentsOf: allTypes)
                    }
                }
            }
            
            // Create array with extension alert booleans
            var extensionAlerts: [Bool] = []
            
            if !preferences.rows.isEmpty {
                for row in preferences.rows {
                    if let items = row.items {
                        let extensions = items.filter { $0.type == "Extension" }
                        for extensionItem in extensions {
                            if let extID = extensionItem.extensionIdentifier {
                                let alertKey = "\(extID)_alert"
                                let value = defaults.bool(forKey: alertKey)
                                extensionAlerts.append(value)
                            }
                        }
                    }
                }
            }
                        
            // If configured, ignore major macOS version updates
            if computerinfo.forceDelayedMajorSoftwareUpdates {
                logger.debug("forceDelayedMajorSoftwareUpdates is enabled, hiding \(self.computerinfo.majorVersionUpdates) major macOS updates")
            }
            
            // Check if StatusBarItem notifier is enabled
            if defaults.bool(forKey: "StatusBarIconNotifierEnabled") {
                // Show notification badge in menu bar icon when info item when needed
                if ((computerinfo.recommendedUpdates.count == 0 || !infoItemsEnabled.contains("MacOSVersion")) && (appCatalogController.appUpdates == 0 || !infoItemsEnabled.contains("AppCatalog"))) && ((computerinfo.uptimeLimitReached && infoItemsEnabled.contains("Uptime")) || (computerinfo.selfSignedIP && infoItemsEnabled.contains("Network")) || (userinfo.passwordExpiryLimitReached && infoItemsEnabled.contains("Password")) || (computerinfo.storageLimitReached && infoItemsEnabled.contains("Storage")) || (preferences.extensionAlertA && infoItemsEnabled.contains("ExtensionA")) || (preferences.extensionAlertB && infoItemsEnabled.contains("ExtensionB")) || extensionAlerts.contains(true)) {
                    
                    // Create orange notification badge
                    orangeBadge.isHidden = false
                    
                } else if (computerinfo.recommendedUpdates.count > 0 && infoItemsEnabled.contains("MacOSVersion")) || (appCatalogController.appUpdates > 0 && infoItemsEnabled.contains("AppCatalog")) {
                    
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
        case "StatusBarIconAllowsColor":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed to \(self.defaults.string(forKey: "StatusBarIconAllowsColor") ?? "", privacy: .public)")
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
        case "Rows":
            logger.debug("\(keyPath! as NSObject, privacy: .public) changed, decoding rows...")
            self.decodeRows()
        case let key where key?.hasSuffix("_alert") == true:
            logger.debug("\(key! as NSObject, privacy: .public) changed")
        default:
            logger.debug("Some other change detected...")
        }
        
        // Always reload the StatusBarItem when other changes are detected
        logger.debug("Reloading StatusBarItem")
        setStatusBarIcon()
    
    }

    // MARK: - Process left and right clicks. https://samoylov.eu/2016/09/14/handling-left-and-right-click-at-nsstatusbar-with-swift-3/
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            logger.debug("No event available, assuming accessibility or Voice Control click...")
            togglePopover(nil)
            return
        }
        
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
            
//            if let popoverWindow = popover.contentViewController?.view.window {
//                popoverWindow.isOpaque = false
//                popoverWindow.backgroundColor = .clear
//                popoverWindow.hasShadow = false // Optional: Remove shadow if you want
//            }
            
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
            
            // Create new presentation token ID
            popoverLifecycle.bump()
            
        }
        // Necessary to make the view active without having to do an extra click
        self.popover.contentViewController?.view.window?.becomeKey()
    }
    
    // MARK: - Run functions at startup
    func runAtStartup() {
        // Run uptime and storage once at startup
        self.loadLocalPreferences()
        self.decodeRows()
        
        self.computerinfo.kernelBootTime()
        Task {
            await self.userinfo.getCurrentUserRecord()
            await self.computerinfo.getSerialNumber()
        }
        self.computerinfo.getStorage()
        self.computerinfo.getRecommendedUpdates()
        self.computerinfo.getModelName()
        self.computerinfo.getRSRVersion()
        
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
    
    //
    @objc func configuratorMode() {
        preferences.configuratorModeEnabled.toggle()
        configuratorMenuItem?.state = preferences.configuratorModeEnabled ? .on : .off
        
        if preferences.configuratorModeEnabled {
            preferences.editModeEnabled = true
            
            // Make sure the popover stays open when configurator mode and settings are presented
            popover.behavior = .applicationDefined
        } else {
            preferences.editModeEnabled = false
            
            // Make sure the popover is set back to transient and hides when needed
            popover.behavior = .transient
        }
        
        togglePopover(nil)
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
    
    // MARK: - Function to fetch remote image to container Documents folder
    func getRemoteImage(url: String, newURL: Bool, filename: String, logName: String) throws -> URL? {
                     
        guard let url = URL(string: url) else {
            return nil
        }

        // Path to App Sandbox container
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsFolder = paths.first else {
            return nil
        }
        let fileURL = documentsFolder.appendingPathComponent("\(filename).\(url.pathExtension)")
        
        // Remove file if it already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            
            // Just return the URL and avoid downloading the image again
            if !newURL {
                logger.debug("URL for \(logName, privacy: .public) is unchanged, no need to download image again")
                return fileURL
            }
            
            do {
                logger.debug("Removing \(logName)")
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                logger.error("\(error.localizedDescription)")
            }
        }
        
        logger.debug("Downloading remote \(logName, privacy: .public) from URL")
                        
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
    
    // MARK: - Load all current preferences to Configurator Mode
    func loadLocalPreferences() {
        logger.debug("Loading current prefences to Configurator Mode")
        
        DispatchQueue.main.async {
            self.localPreferences.title = self.preferences.title
            self.localPreferences.logo = self.preferences.logo
            self.localPreferences.logoDarkMode = self.preferences.logoDarkMode
            self.localPreferences.notificationIcon = self.preferences.notificationIcon
            self.localPreferences.statusBarIcon = self.preferences.statusBarIcon
            self.localPreferences.statusBarIconAllowsColor = self.preferences.statusBarIconAllowsColor
            self.localPreferences.statusBarIconSFSymbol = self.preferences.statusBarIconSFSymbol
            self.localPreferences.statusBarIconNotifierEnabled = self.preferences.statusBarIconNotifierEnabled
            self.localPreferences.updateText = self.preferences.updateText
            self.localPreferences.customColor = self.preferences.customColor
            self.localPreferences.customColorDarkMode = self.preferences.customColorDarkMode
            self.localPreferences.errorMessage = self.preferences.errorMessage
            self.localPreferences.showWelcomeScreen = self.preferences.showWelcomeScreen
            self.localPreferences.footerText = self.preferences.footerText
            self.localPreferences.openAtLogin = self.preferences.openAtLogin
            self.localPreferences.disablePrivilegedHelperTool = self.preferences.disablePrivilegedHelperTool
            self.localPreferences.disableConfiguratorMode = self.preferences.disableConfiguratorMode
            self.localPreferences.uptimeDaysLimit = self.preferences.uptimeDaysLimit
            self.localPreferences.passwordType = self.preferences.passwordType
            self.localPreferences.passwordExpiryLimit = self.preferences.passwordExpiryLimit
            self.localPreferences.passwordLabel = self.preferences.passwordLabel
            self.localPreferences.storageLimit = self.preferences.storageLimit
        }
    }
    
    // MARK: - Function to load configuration profile
    func decodeRows() {
        
        logger.debug("Loading rows from Configuration Profile...")
        
        // Check if "Rows" has data
        guard let rowsDefaults = UserDefaults.standard.array(forKey: "Rows") else {
            logger.error("No data found for key: \"Rows\".")
            return
        }
        
        // Try to decode "Rows"
        do {
            let data = try JSONSerialization.data(withJSONObject: rowsDefaults)
            let decoder = JSONDecoder()
            
            let dedodedItems = try? decoder.decode([Row].self, from: data)
            
            if let rows = dedodedItems {
                DispatchQueue.main.async {
                    self.preferences.rows = rows
                    self.localPreferences.rows = rows
                }
                
                // Register any Extension alert observers
                self.registerExtensionObservers(rows: rows)
            }
                        
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }

    // MARK: - Start observing alerts for extensions
    func registerExtensionObservers(rows: [Row]) {
        logger.debug("Registering extension observers")
        
        for row in rows {
            if let items = row.items {
                let extensions = items.filter { $0.type == "Extension" }
                for extensionItem in extensions {
                    if let extID = extensionItem.extensionIdentifier {
                        let alertKey = "\(extID)_alert"
                        logger.debug("Observing extension alert key: \(alertKey, privacy: .public)")
                        defaults.addObserver(self, forKeyPath: alertKey, options: .new, context: nil)
                    }
                }
            }
        }
    }
}

