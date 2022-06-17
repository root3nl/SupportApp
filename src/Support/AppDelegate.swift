//
//  AppDelegate.swift
//  Root3 Support
//
//  Created by Jordy Witteman on 07/07/2020.
//

import Cocoa
import os
import SwiftUI

// Popover is based on: https://medium.com/@acwrightdesign/creating-a-macos-menu-bar-application-using-swiftui-54572a5d5f87

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var eventMonitor: EventMonitor?
    var timer: Timer?
    var timerFiveMinutes: Timer?
    let menu = NSMenu()
    var statusBarItem: NSStatusItem?
    
    // Unified logging for StatusBarItem
    let logger = Logger(subsystem: "nl.root3.support", category: "StatusBarItem")
    
    // Make standard UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Make UserDefaults easy to use with suite "com.apple.SoftwareUpdate"
    let ASUdefaults = UserDefaults(suiteName: "com.apple.SoftwareUpdate")
    
    // Make properties and preferences available
    var computerinfo = ComputerInfo()
    var userinfo = UserInfo()
    var preferences = Preferences()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Create the SwiftUI view that provides the window contents.
        let appView = AppView()

        // Create the popover. Setting a width is necessary to show the status bar icon in the middle of the app. Height is not necessary because the app resizes automatically. So we make it 100 because we have to set something.
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 382, height: 100)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: appView
                                                                .environmentObject(computerinfo)
                                                                .environmentObject(userinfo)
                                                                .environmentObject(preferences))
        self.popover = popover
        
        // Create the status item
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        
        // Observe changes for UserDefaults
        defaults.addObserver(self, forKeyPath: "StatusBarIcon", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StatusBarIconSFSymbol", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StatusBarIconNotifierEnabled", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "UptimeDaysLimit", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "StorageLimit", options: .new, context: nil)
        defaults.addObserver(self, forKeyPath: "PasswordExpiryLimit", options: .new, context: nil)
        ASUdefaults?.addObserver(self, forKeyPath: "LastUpdatesAvailable", options: .new, context: nil)
        
        // Receive notifications after uptime check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.uptimeDaysLimit, object: nil)
        
        // Receive notifications after network check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.networkState, object: nil)
        
        // Receive notification after password expiry check
        NotificationCenter.default.addObserver(self, selector: #selector(setStatusBarIcon), name: Notification.Name.passwordExpiryLimit, object: nil)
        
        // Run functions at startup
        runAtStartup()
        
        // Set Custom Notification Icon
        setNotificationIcon()
        
        // Create the menu bar icon
        setStatusBarIcon()
        
        // Start 5 minute timer to query value updates
        if defaults.bool(forKey: "StatusBarIconNotifierEnabled") {
            timerFiveMinutes = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { time in
                self.logger.debug("Running five minute timer...")
                self.computerinfo.kernelBootTime()
                self.computerinfo.getStorage()
                self.computerinfo.getIPAddress()
                Task {
                    await self.userinfo.getCurrentUserRecord()
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
        
        // Define the default menu bar icon
        let defaultSFSymbol = NSImage(systemSymbolName: "lifepreserver", accessibilityDescription: nil)
        let config = NSImage.SymbolConfiguration(textStyle: .body, scale: .large)
        let defaultSFSymbolImage = defaultSFSymbol?.withSymbolConfiguration(config)
        
        // Set the menu bar icon
        if let button = statusBarItem?.button {
            
            // Use custom status bar icon if set in UserDefaults with fallback to default icon
            if defaults.string(forKey: "StatusBarIcon") != nil {
                if let customIcon = NSImage(contentsOfFile: defaults.string(forKey: "StatusBarIcon")!) {
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
                logger.debug("No preference key is set, using default image...")
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
            
            // Show notification badge in menu bar icon when info item when needed
            if (computerinfo.updatesAvailable == 0 || !infoItemsEnabled.contains("MacOSVersion")) && ((computerinfo.uptimeLimitReached && infoItemsEnabled.contains("Uptime")) || (computerinfo.selfSignedIP && infoItemsEnabled.contains("Network")) || (userinfo.passwordExpiryLimitReached && infoItemsEnabled.contains("Password")) || (computerinfo.storageLimitReached && infoItemsEnabled.contains("Storage"))) && defaults.bool(forKey: "StatusBarIconNotifierEnabled") {
                                
                // Create NSTextAttachment to show orange dot image overlay in StatusBarItem. Probably not the best way currently available
                let image1Attachment = NSTextAttachment()
                image1Attachment.image  = NSImage(named: "MenuBarOrangeDot")?.resizedCopy(w: 22, h: 22)
                let attributeString = NSAttributedString(attachment: image1Attachment)
                button.attributedTitle = attributeString
               
            } else if (computerinfo.updatesAvailable > 0 && infoItemsEnabled.contains("MacOSVersion")) && defaults.bool(forKey: "StatusBarIconNotifierEnabled") {
                
                // Create NSTextAttachment to show red dot image overlay in StatusBarItem. Probably not the best way currently available
                let image1Attachment = NSTextAttachment()
                image1Attachment.image  = NSImage(named: "MenuBarRedDot")?.resizedCopy(w: 22, h: 22)
                let attributeString = NSAttributedString(attachment: image1Attachment)
                button.attributedTitle = attributeString
                
            // Disable notification badge in menu bar icon
            } else {
                
                // Remove NSTextAttachment
                let attributeString = NSAttributedString(string: "")
                button.attributedTitle = attributeString
                
                button.alignment = .right
            }
            
            // Action when clicked on the menu bar icon
            button.action = #selector(self.statusBarButtonClicked)
            
            // Monitor left or right clicks
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    // MARK: - Set Custom Notification Icon
    func setNotificationIcon() {
        // Set custom alert icon if specified
        if defaults.string(forKey: "NotificationIcon") != nil {
            logger.debug("Notification icon configured...")
            if let appIconImage = NSImage(contentsOfFile: defaults.string(forKey: "NotificationIcon") ?? "") {
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
            logger.debug("\(keyPath! as NSObject) changed to \(self.defaults.string(forKey: "StatusBarIcon") ?? "")")
        case "StatusBarIconSFSymbol":
            logger.debug("\(keyPath! as NSObject) changed to \(self.defaults.string(forKey: "StatusBarIconSFSymbol") ?? "")")
        case "StatusBarIconNotifierEnabled":
            logger.debug("\(keyPath! as NSObject) changed to \(self.defaults.bool(forKey: "StatusBarIconNotifierEnabled"))")
        case "UptimeDaysLimit":
            // Check uptime when key UptimeDaysLimit is changed
            logger.debug("\(keyPath! as NSObject) changed to \(self.preferences.uptimeDaysLimit), checking uptime...")
            self.computerinfo.kernelBootTime()
        case "StorageLimit":
            // Check storage when key StorageLimit is changed
            logger.debug("\(keyPath! as NSObject) changed to \(self.preferences.storageLimit), checking storage...")
            self.computerinfo.getStorage()
        case "PasswordExpiryLimit":
            // Check password expiry when key PasswordExpiryLimit is changed
            logger.debug("\(keyPath! as NSObject) change to \(self.preferences.passwordExpiryLimit), checking password expiry...")
            Task {
                await self.userinfo.getCurrentUserRecord()
            }
        case "LastUpdatesAvailable":
            logger.debug("\(keyPath! as NSObject) changed to \(self.ASUdefaults!.integer(forKey: "LastUpdatesAvailable"))")
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
            
            // add positioning view as a suview of sender, that is, `statusItem.button`.
            let positioningView = NSView(frame: button.bounds)
            
            // set an identifier for positioning view, so we can easily remove it later.
            positioningView.identifier = NSUserInterfaceItemIdentifier(rawValue: "positioningView")
            button.addSubview(positioningView)
            
            // Disable animation when popover opens
            self.popover.animates = false
            
            // show popover
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            
            // Enable animation again to avoid issues
            self.popover.animates = true
            
            // move positioning view away
            button.bounds = button.bounds.offsetBy(dx: 0, dy: button.bounds.height)
            
            // adjust the height to match control center
            if let popoverWindow = popover.contentViewController?.view.window {
                popoverWindow.setFrame(popoverWindow.frame.offsetBy(dx: 0, dy: 8), display: false)
            }
            
            // Start monitoring mouse clicks outside the popover
            eventMonitor?.start()
            
            // Run functions immediately when popover opens
            self.computerinfo.getHostname()
            self.computerinfo.kernelBootTime()
            self.computerinfo.getStorage()
            self.computerinfo.getIPAddress()
            Task {
                await self.userinfo.getCurrentUserRecord()
            }
            
            // Post Distributed Notification to trigger script for custom info items
            postDistributedNotification()
            
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
        }
        self.computerinfo.getStorage()
    }
    
    // MARK: - Close the popover
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        
        // Stop monitoring mouse clicks outside the popover
        eventMonitor?.stop()
        
        // Stop timer when popover closes
        timer?.invalidate()
    }

    // MARK: - Show the standard about window
    @objc func showAbout() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    // Post Distributed Notification
    func postDistributedNotification() {
        logger.debug("Posting Distributed Notification: nl.root3.support.SupportAppeared")
        
        // Initialize distributed notifications
        let nc = DistributedNotificationCenter.default()
        
        // Define the NSNotification name
        let name = NSNotification.Name("nl.root3.support.SupportAppeared")
        
        // Post the notification including all sessions to support LaunchDaemons
        nc.postNotificationName(name, object: nil, userInfo: nil, options: [.postToAllSessions, .deliverImmediately])

    }
}
