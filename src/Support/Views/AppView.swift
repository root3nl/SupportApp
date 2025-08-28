//
//  AppView.swift
//  Support
//
//  Created by Jordy Witteman on 17/05/2021.
//

import os
import SwiftUI

struct AppView: View {
    
    // Unified Logging
    let logger = Logger(subsystem: "nl.root3.support", category: "Preferences")
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
    
    @EnvironmentObject var computerinfo: ComputerInfo
    @EnvironmentObject var userinfo: UserInfo
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var appCatalogController: AppCatalogController
    @EnvironmentObject var localPreferences: LocalPreferences
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Simple property wrapper boolean to visualize data loading when app opens
    @State private var placeholdersEnabled = true
    @State private var showExportOptions: Bool = false
        
    // Version and build number
    var version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
    var build = Bundle.main.infoDictionary!["CFBundleVersion"]! as! String
    
    // Local preferences for Configurator Mode or (managed) UserDefaults
    var activePreferences: PreferencesProtocol {
        preferences.configuratorModeEnabled ? localPreferences : preferences
    }

    var body: some View {
        
        // MARK: - ZStack with blur effect
        ZStack {
//            EffectsView(material: NSVisualEffectView.Material.fullScreenUI, blendingMode: NSVisualEffectView.BlendingMode.behindWindow)
            
            // We need to provide Quit option for Apple App Review approval
            if !preferences.hideQuit {
                QuitButton()
            }
            
            // Show "Beta" in the top left corner for beta releases
            if preferences.betaRelease {
                HStack {
                    
                    VStack {
                        Text("Beta release \(version) (\(build))")
                            .font(.system(.subheadline, design: .rounded))
                            .opacity(0.5)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.leading, 16.0)
                .padding(.top, 10)
            }
            
            VStack(spacing: 12) {
                
                // MARK: - Horizontal stack with Title and Logo
                HeaderView()
                
                if preferences.showWelcomeScreen && !preferences.hasSeenWelcomeScreen {
                    WelcomeView()
                } else {
                    if appCatalogController.showAppUpdates {
                        AppUpdatesView()
                    } else if computerinfo.showMacosUpdates {
                        UpdateView()
                    } else if computerinfo.showUptimeAlert {
                        UptimeAlertView()
                    } else if preferences.showItemConfiguration {
                        ItemConfigurationView()
                    } else {
                        ContentView()
                    }
                }
                
                // MARK: - Footnote
                if activePreferences.footerText != "" {
                    HStack {
                        
                        
                        // Supports for markdown through a variable:
                        // https://blog.eidinger.info/3-surprises-when-using-markdown-in-swiftui
                        Text(.init(activePreferences.footerText.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo)))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                            .textSelection(.enabled)
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal, 10)
                    // Workaround to support multiple lines
                    .frame(minWidth: 388, idealWidth: 388, maxWidth: 388)
                    .fixedSize()
                }
                
                if preferences.configuratorModeEnabled {
                
                    VStack(alignment: .leading) {
                        
                        HStack {
                            
                            if preferences.editModeEnabled {
                                SettingsLink(label: {
                                    Label("Settings", systemImage: "gear")
                                        .labelStyle(.titleOnly)
                                })
                            }
                            
                            Spacer()
                            
                            Button {
                                showExportOptions.toggle()
                            } label: {
                                Label("Export", systemImage: "square.and.arrow.up")
                                    .labelStyle(.titleOnly)
                            }
                            .confirmationDialog("Export options", isPresented: $showExportOptions) {
                                Button("Export as Property List") {
                                    exportPropertyList()
                                }
                                Button("Export as Configuration Profile") {
                                    exportMobileConfig()
                                }
                            } message: {
                                Text("Select your preferred format")
                            }
                            
                            if preferences.editModeEnabled && !preferences.showItemConfiguration {
                                Button {
                                    preferences.editModeEnabled.toggle()
                                    
                                    // Persist preferences
                                    saveUserDefaults()
                                } label: {
                                    Label("Done", systemImage: "")
                                        .labelStyle(.titleOnly)
                                }
                            } else if !preferences.showItemConfiguration {
                                Button {
                                    preferences.editModeEnabled.toggle()
                                } label: {
                                    Label("Edit", systemImage: "")
                                        .labelStyle(.titleOnly)
                                }
                            }
                        }
                        Text("Configurator Mode enabled")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                }
            }
            .padding(.bottom, 10)
        }
//        .background(EffectsView(material: NSVisualEffectView.Material.fullScreenUI, blendingMode: NSVisualEffectView.BlendingMode.behindWindow))
        .background(colorScheme == .dark ? Color.clear : Color.primary.opacity(0.1))
        // Set default popover width
        .frame(minWidth: 388, idealWidth: 388, maxWidth: 388)
        // MARK: - Run functions when ContentView appears for the first time
        .onAppear {
            dataLoadingEffect()
        }
        // MARK: - Show placeholders while loading
        .redacted(reason: placeholdersEnabled ? .placeholder : .init())
    }
    
    // MARK: - Start app with placeholders and show data after 0.4 seconds to visualize data loading.
    func dataLoadingEffect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            placeholdersEnabled = false
        }
    }
    
    // MARK: - Export all preferences to a property list
    func exportPropertyList() {
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml

            let appConfiguration = AppModel(title: localPreferences.title, logo: localPreferences.logo, logoDarkMode: localPreferences.logoDarkMode, notificationIcon: localPreferences.notificationIcon, statusBarIcon: localPreferences.statusBarIcon, statusBarIconSFSymbol: localPreferences.statusBarIconSFSymbol, statusBarIconNotifierEnabled: localPreferences.statusBarIconNotifierEnabled, updateText: localPreferences.updateText, customColor: localPreferences.customColor, customColorDarkMode: localPreferences.customColorDarkMode, errorMessage: localPreferences.errorMessage, showWelcomeScreen: localPreferences.showWelcomeScreen, footerText: localPreferences.footerText, openAtLogin: localPreferences.openAtLogin, disablePrivilegedHelperTool: activePreferences.disablePrivilegedHelperTool, uptimeDaysLimit: localPreferences.uptimeDaysLimit, passwordType: localPreferences.passwordType, passwordExpiryLimit: localPreferences.passwordExpiryLimit, passwordLabel: localPreferences.passwordLabel, storageLimit: Int(localPreferences.storageLimit), rows: localPreferences.rows)
            let data = try encoder.encode(appConfiguration)
            
            // Hide popover to provide the best export experience and activate the save window 
            appDelegate.togglePopover(nil)

            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.propertyList]
            savePanel.nameFieldStringValue = "nl.root3.support.plist"
            savePanel.canCreateDirectories = true

            if savePanel.runModal() == .OK, let url = savePanel.url {
                try data.write(to: url)
            }
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    // MARK: - Export all preferences to a valid Configuration Profile (.mobileconfig)
    func exportMobileConfig() {
        
    }
    
    // MARK: - Save settings from Configurator Mode
    func saveUserDefaults() {
        do {
            // Build the configuration model from current state
            let appConfiguration = AppModel(title: localPreferences.title, logo: localPreferences.logo, logoDarkMode: localPreferences.logoDarkMode, notificationIcon: localPreferences.notificationIcon, statusBarIcon: localPreferences.statusBarIcon, statusBarIconSFSymbol: localPreferences.statusBarIconSFSymbol, statusBarIconNotifierEnabled: localPreferences.statusBarIconNotifierEnabled, updateText: localPreferences.updateText, customColor: localPreferences.customColor, customColorDarkMode: localPreferences.customColorDarkMode, errorMessage: localPreferences.errorMessage, showWelcomeScreen: localPreferences.showWelcomeScreen, footerText: localPreferences.footerText, openAtLogin: localPreferences.openAtLogin, disablePrivilegedHelperTool: activePreferences.disablePrivilegedHelperTool, uptimeDaysLimit: localPreferences.uptimeDaysLimit, passwordType: localPreferences.passwordType, passwordExpiryLimit: localPreferences.passwordExpiryLimit, passwordLabel: localPreferences.passwordLabel, storageLimit: Int(localPreferences.storageLimit), rows: localPreferences.rows)

            // Encode to a property list-compatible Data
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let data = try encoder.encode(appConfiguration)

            // Convert encoded Data into a Foundation property list (Dictionary)
            let plistObject = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

            guard let dict = plistObject as? [String: Any] else {
                logger.error("Failed to convert encoded AppModel to [String: Any] for UserDefaults persistent domain")
                return
            }

            // Write to the nl.root3.support UserDefaults domain
            let defaults = UserDefaults.standard
            defaults.setPersistentDomain(dict, forName: "nl.root3.support")
            
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    // MARK: - Function to create a complete Configuration Profile
    func createMobileConfig() {
        let mobileConfig = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>PayloadContent</key>
            <array>
                <dict>
                    <key>PayloadDescription</key>
                    <string></string>
                    <key>PayloadDisplayName</key>
                    <string>Custom</string>
                    <key>PayloadEnabled</key>
                    <true/>
                    <key>PayloadIdentifier</key>
                    <string>E07B484A-FC4A-450B-A0E9-3BC0B737974B</string>
                    <key>PayloadOrganization</key>
                    <string>Root3</string>
                    <key>PayloadType</key>
                    <string>nl.root3.support</string>
                    <key>PayloadUUID</key>
                    <string>E07B484A-FC4A-450B-A0E9-3BC0B737974B</string>
                    <key>PayloadVersion</key>
                    <integer>1</integer>
                </dict>
            </array>
            <key>PayloadDescription</key>
            <string></string>
            <key>PayloadDisplayName</key>
            <string>Support App Configuration</string>
            <key>PayloadEnabled</key>
            <true/>
            <key>PayloadIdentifier</key>
            <string>BDA1AE71-4F70-4D93-9924-F8E77E8F0F10</string>
            <key>PayloadOrganization</key>
            <string>Root3</string>
            <key>PayloadRemovalDisallowed</key>
            <true/>
            <key>PayloadScope</key>
            <string>System</string>
            <key>PayloadType</key>
            <string>Configuration</string>
            <key>PayloadUUID</key>
            <string>164671D3-3656-41FF-A387-E3229001BB9B</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
        </plist>
        """
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
