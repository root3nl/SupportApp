//
//  ItemExtension.swift
//  Support
//
//  Created by Jordy Witteman on 30/12/2020.
//

import os
import SwiftUI

struct ItemExtension: View {
    var title: String
    var subtitle: String?
    var linkType: String?
    var link: String?
    var image: String
    var symbolColor: Color
    var notificationBadge: Int?
    var notificationBadgeBool: Bool?
    var loading: Bool?
    var linkPrefKey: String?
    var extensionIdentifier: String
    var onAppearAction: String?
    var configurationItem: ConfiguredItem?
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
    
    // Get computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Declare unified logging
    let logger = Logger(subsystem: "nl.root3.support", category: "Action")
    
    // Vars to activate hover effect
    @State var hoverEffectEnable: Bool
    @State var hoverView = false
    @State var showSubtitle = false
    @State var showingAlert = false
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    
    // Get local preferences for Configurator Mode
    @EnvironmentObject var localPreferences: LocalPreferences
    
    // Get unique presentation token on every appearance
    @EnvironmentObject var popoverLifecycle: PopoverLifecycle
    
    let defaults = UserDefaults.standard
    
    // Enable animation
    var animate: Bool
    
    @AppStorage private var extensionValue: String?
    @AppStorage private var extensionLoading: Bool?
    @AppStorage private var extensionAlert: Bool?

    init(title: String,
         subtitle: String? = nil,
         linkType: String? = nil,
         link: String? = nil,
         image: String,
         symbolColor: Color,
         notificationBadge: Int? = nil,
         notificationBadgeBool: Bool? = nil,
         loading: Bool? = nil,
         linkPrefKey: String? = nil,
         extensionIdentifier: String,
         onAppearAction: String? = nil,
         hoverEffectEnable: Bool = true,
         animate: Bool = true,
         configurationItem: ConfiguredItem? = nil) {
        
        self.title = title
        self.subtitle = subtitle
        self.linkType = linkType
        self.link = link
        self.image = image
        self.symbolColor = symbolColor
        self.notificationBadge = notificationBadge
        self.notificationBadgeBool = notificationBadgeBool
        self.loading = loading
        self.linkPrefKey = linkPrefKey
        self.extensionIdentifier = extensionIdentifier
        self.onAppearAction = onAppearAction
        self.configurationItem = configurationItem
        self.hoverEffectEnable = hoverEffectEnable
        self.animate = animate
        
        self._extensionValue = AppStorage(extensionIdentifier, store: .standard)
        self._extensionLoading = AppStorage("\(extensionIdentifier)_loading", store: .standard)
        self._extensionAlert = AppStorage("\(extensionIdentifier)_alert", store: .standard)
    }

    
    var body: some View {
        
        if #available(macOS 26, *) {
            ZStack {
                
                HStack {
                    if loading ?? false || extensionLoading ?? false {
                        Ellipse()
                            .foregroundColor(.white.opacity(0.5))
                            .overlay(
                                ProgressView()
                                    .controlSize(.small)
                            )
                            .frame(width: 36, height: 36)
                            .padding(.leading, 14)
                            .accessibilityHidden(true)
                    } else {
                        Ellipse()
                            .foregroundColor(.white)
                            .overlay(
                                Image(systemName: image)
                                    .foregroundColor(symbolColor)
                                    .font(.system(size: 18))
                            )
                            .frame(width: 36, height: 36)
                            .padding(.leading, 14)
                            .accessibilityHidden(true)
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text(title.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo))
                            .font(.system(.body, design: .default))
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        
                        if let extensionValue {
                            // Always show the subtitle when hover animation is disabled
                            Text(extensionValue.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo))
                                .font(.system(.subheadline, design: .default))
//                                .foregroundStyle(.white.opacity(0.8))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            // Show placeholder when no initial value is set for Custom Info Items
                                .redacted(reason: (extensionValue == "KeyPlaceholder") ? .placeholder: .init())
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    
                    Spacer()
                }
                
//                // Optionally show notification badge with warning
//                if extensionAlert ?? false {
//                    NotificationBadgeTextView(badgeCounter: "!")
//                        .accessibilityHidden(true)
//                }
            }
            .frame(width: 176, height: 64)
            .contentShape(Capsule())
            .accessibilityLabel(title + ", " + (subtitle ?? ""))
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(NSLocalizedString("An error occurred", comment: "")), message: Text(preferences.errorMessage), dismissButton: .default(Text("OK")))
            }
            .onHover() { hover in
                self.hoverView = hover
                
                // Animation when hovering
                if animate {
                    withAnimation(.easeInOut) {
                        self.showSubtitle.toggle()
                    }
                }
            }
            .onTapGesture() {
                if preferences.editModeEnabled {
                    guard let configurationItem else {
                        return
                    }
                    localPreferences.currentConfiguredItem = configurationItem
                    preferences.showItemConfiguration.toggle()
                    
                } else {
                    tapGesture()
                }
            }
            .task(id: popoverLifecycle.presentationToken) {
                guard let onAppearAction else {
                    return
                }
                await runPrivilegedCommand(command: onAppearAction, key: "OnAppearAction")
            }
            .modifier(GlassEffectModifier(hoverView: hoverView, hoverEffectEnable: hoverEffectEnable))
            .overlay(alignment: .topTrailing) {
                // Optionally show notification badge with warning
                if extensionAlert ?? false {
                    NotificationBadgeTextView(badgeCounter: "!")
                        .accessibilityHidden(true)
                }
            }
            .overlay(alignment: .topLeading) {
                // Optionally show remove item button
                if preferences.editModeEnabled && !preferences.showItemConfiguration {
                    RemoveItemButtonView(configurationItem: configurationItem)
                }
            }
            .animation(.bouncy, value: hoverView)
        } else {
            
            ZStack {
                
                HStack {
                    if loading ?? false || extensionLoading ?? false {
                        Ellipse()
                            .foregroundColor(Color.gray.opacity(0.5))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.5)
                            )
                            .frame(width: 26, height: 26)
                            .padding(.leading, 10)
                            .accessibilityHidden(true)
                    } else {
                        Ellipse()
                            .foregroundColor(hoverView && link != "" ? .primary : symbolColor)
                            .overlay(
                                Image(systemName: image)
                                    .foregroundColor(hoverView && link != "" ? Color("hoverColor") : Color.white)
                            )
                            .frame(width: 26, height: 26)
                            .padding(.leading, 10)
                            .accessibilityHidden(true)
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text(title.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo))
                            .font(.system(.body, design: .rounded)).fontWeight(.medium)
                            .lineLimit(2)
                        
                        if let extensionValue {
                            // Always show the subtitle when hover animation is disabled
                            Text(extensionValue.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo))
                                .font(.system(.subheadline, design: .rounded))
                                .lineLimit(2)
                            // Show placeholder when no initial value is set for Custom Info Items
                                .redacted(reason: (extensionValue == "KeyPlaceholder") ? .placeholder: .init())
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    
                    Spacer()
                }
                
//                // Optionally show notification badge with warning
//                if extensionAlert ?? false {
//                    NotificationBadgeTextView(badgeCounter: "!")
//                        .accessibilityHidden(true)
//                }
            }
            .frame(width: 176, height: 60)
            .accessibilityLabel(title + ", " + (subtitle ?? ""))
            .background(hoverView && hoverEffectEnable && link != "" ? EffectsView(material: NSVisualEffectView.Material.windowBackground, blendingMode: NSVisualEffectView.BlendingMode.withinWindow) : EffectsView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
            .cornerRadius(10)
            // Apply gray and black border in Dark Mode to better view the buttons like Control Center
            .modifier(DarkModeBorder())
            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(NSLocalizedString("An error occurred", comment: "")), message: Text(preferences.errorMessage), dismissButton: .default(Text("OK")))
            }
            .onHover() {
                hover in self.hoverView = hover
                
                // Animation when hovering
                if animate {
                    withAnimation(.easeInOut) {
                        self.showSubtitle.toggle()
                    }
                }
            }
            .onTapGesture() {
                if preferences.editModeEnabled {
                    guard let configurationItem else {
                        return
                    }
                    localPreferences.currentConfiguredItem = configurationItem
                    preferences.showItemConfiguration.toggle()
                    
                } else {
                    tapGesture()
                }
            }
            .task(id: popoverLifecycle.presentationToken) {
                guard let onAppearAction else {
                    return
                }
                await runPrivilegedCommand(command: onAppearAction, key: "OnAppearAction")
            }
            .overlay(alignment: .topTrailing) {
                // Optionally show notification badge with warning
                if extensionAlert ?? false {
                    NotificationBadgeTextView(badgeCounter: "!")
                        .accessibilityHidden(true)
                }
            }
            .overlay(alignment: .topLeading) {
                // Optionally show remove item button
                if preferences.editModeEnabled && !preferences.showItemConfiguration {
                    RemoveItemButtonView(configurationItem: configurationItem)
                }
            }
        }
    }
    
    func tapGesture() {
        // Don't do anything when no link is specified
        guard link != "" else {
            logger.debug("No link specified for \(title, privacy: .public), button disabled...")
            return
        }
        
        if linkType == "App" {
            openApp()
        } else if linkType == "URL" {
            openLink()
        } else if linkType == "Command" {
            runCommand()
            // MARK: - DistributedNotification is deprecated, use PrivilegedScript instead
        } else if linkType == "DistributedNotification" || linkType == "PrivilegedScript" {
            guard let link else {
                return
            }
            Task {
                await runPrivilegedCommand(command: link, key: "Action")
            }
        } else {
            self.showingAlert.toggle()
            logger.error("Invalid Link Type: \(linkType!)")
        }
    }
    
    // Open application with given Bundle Identifier
    func openApp() {
        
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: link ?? "")
                // Show alert when there is an error
        else {
            self.showingAlert.toggle()
            return }
        let configuration = NSWorkspace.OpenConfiguration()
        
        NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
        
        // Close popover
        appDelegate.togglePopover(nil)
    }
    
    // Open URL
    func openLink() {
        guard let url = URL(string: link ?? "")
                // Show alert when there is an error
        else {
            self.showingAlert.toggle()
            return }
        NSWorkspace.shared.open(url)
        
        // Close the popover
//        NSApp.deactivate()
        
        // Close popover
        appDelegate.togglePopover(nil)

    }
    
    // Run a command as the user
    func runCommand() {
        let task = Process()
        let pipe = Pipe()
        
        let command = link?.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo)
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", "\(command ?? "")"]
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        if !task.isRunning {
            let status = task.terminationStatus
            if status == 0 {
                logger.debug("\(output)")
            } else {
                logger.error("\(output)")
                self.showingAlert.toggle()
            }
        }
        
        // Close the popover
//        NSApp.deactivate()
        
        // Close popover
        appDelegate.togglePopover(nil)
    }
    
    // MARK: - Function to run privileged script
    func runPrivilegedCommand(command: String, key: String) async {
        
        logger.log("Trying to run privileged script...")
        
        // Check that the entire "Rows" payload is enforced by a configuration profile
        let isManaged = defaults.objectIsForced(forKey: "Rows")

        // Get bundle ID
        let bundleID = Bundle.main.bundleIdentifier
        guard let bundleID else {
            return
        }
        
        // Read only the managed domain version of "Rows" (bypasses user defaults)
        let managedRows = CFPreferencesCopyAppValue("Rows" as CFString,
                                                    bundleID as CFString) as? [[String: Any]]

        // Try to find an Action entry matching the command
        let containsAction = managedRows?.flatMap { $0["Items"] as? [[String: Any]] ?? [] }.contains { ($0[key] as? String) == command } ?? false

        guard isManaged, containsAction else {
            logger.error("Action \(command, privacy: .public) is not managed via Configuration Profile. Ignored.")
            return
        }
        
        // Verify permissions
        guard FileUtilities().verifyPermissions(pathname: command) else {
            return
        }
        
        do {
            try ExecutionService.executeScript(command: command) { exitCode in
                
                if exitCode == 0 {
                    self.logger.debug("Privileged script ran successfully with exit code 0")
                } else {
                    self.logger.error("Error while running privileged script. Exit code: \(exitCode, privacy: .public)")
                }

            }
        } catch {
            logger.log("Failed to run privileged script. Error: \(error.localizedDescription, privacy: .public)")
        }
    }
}

