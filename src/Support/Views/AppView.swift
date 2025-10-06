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
    
    @Environment(\.openSettings) private var openSettings
    
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
    
    // Set the custom color for all symbols depending on Light or Dark Mode.
    var color: Color {
        if colorScheme == .dark && !activePreferences.customColorDarkMode.isEmpty {
            return Color(NSColor(hex: "\(activePreferences.customColorDarkMode)") ?? NSColor.controlAccentColor)
        } else if !activePreferences.customColor.isEmpty {
            return Color(NSColor(hex: "\(activePreferences.customColor)") ?? NSColor.controlAccentColor)
        } else {
            return .accentColor
        }
    }
    
    var appConfiguration: AppModel {
        return AppModel(
            title: localPreferences.title,
            logo: localPreferences.logo.nilIfEmpty,
            logoDarkMode: localPreferences.logoDarkMode.nilIfEmpty,
            notificationIcon: localPreferences.notificationIcon.nilIfEmpty,
            statusBarIcon: localPreferences.statusBarIcon.nilIfEmpty,
            statusBarIconAllowsColor: localPreferences.statusBarIconAllowsColor,
            statusBarIconSFSymbol: localPreferences.statusBarIconSFSymbol.nilIfEmpty,
            statusBarIconNotifierEnabled: localPreferences.statusBarIconNotifierEnabled,
            updateText: localPreferences.updateText.nilIfEmpty,
            customColor: localPreferences.customColor.nilIfEmpty,
            customColorDarkMode: localPreferences.customColorDarkMode.nilIfEmpty,
            errorMessage: localPreferences.errorMessage.nilIfEmpty,
            showWelcomeScreen: localPreferences.showWelcomeScreen,
            footerText: localPreferences.footerText.nilIfEmpty,
            openAtLogin: localPreferences.openAtLogin,
            disablePrivilegedHelperTool: activePreferences.disablePrivilegedHelperTool,
            disableConfiguratorMode: activePreferences.disableConfiguratorMode,
            uptimeDaysLimit: localPreferences.uptimeDaysLimit.nilIfZero,
            passwordType: localPreferences.passwordType.nilIfEmpty,
            passwordExpiryLimit: localPreferences.passwordExpiryLimit.nilIfZero,
            passwordLabel: localPreferences.passwordLabel.nilIfEmpty,
            storageLimit: Int(localPreferences.storageLimit).nilIfZero,
            onAppearAction: localPreferences.onAppearAction,
            rows: localPreferences.rows
        )
    }

    var body: some View {
        
        // MARK: - ZStack with blur effect
        ZStack {
            
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
            
            VStack(spacing: 10) {
                
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
                        // Show new structure when rows are not empty or Configurator Mode is enabled
                        if !preferences.rows.isEmpty || preferences.editModeEnabled {
                            ContentView()
                        } else {
                            LegacyContentView()
                        }
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
                    .frame(minWidth: 382, idealWidth: 382, maxWidth: 382)
                    .fixedSize()
                }
                
                if preferences.configuratorModeEnabled {
                
//                    VStack(alignment: .leading) {
                        
                        HStack {
                            
                            Spacer()
                            
                            if preferences.editModeEnabled {
                                Button {
                                    NSApplication.shared.activate(ignoringOtherApps: true)
                                    openSettings()
                                    NSApplication.shared.activate(ignoringOtherApps: true)
                                } label: {
//                                SettingsLink(label: {
                                    Label("Settings", systemImage: "gear")
                                        .labelStyle(.titleOnly)
                                }
                                .modify {
                                    if #available(macOS 26, *) {
                                        $0
                                            .buttonStyle(.glass)
                                            .buttonBorderShape(.capsule)
                                            .controlSize(.large)
                                    } else {
                                        $0
                                    }
                                }
                            } else {
                            
//                            Spacer()
                            
//                            if !preferences.editModeEnabled {
                                Button {
                                    showExportOptions.toggle()
                                } label: {
                                    Label("Export", systemImage: "square.and.arrow.up")
                                        .labelStyle(.titleOnly)
                                }
                                .modify {
                                    if #available(macOS 26, *) {
                                        $0
                                            .buttonStyle(.glass)
                                            .buttonBorderShape(.capsule)
                                            .controlSize(.large)
                                    } else {
                                        $0
                                    }
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
                            }
                            
                                if preferences.editModeEnabled && !preferences.showItemConfiguration {
                                    Button {
//                                        withAnimation {
                                            preferences.editModeEnabled.toggle()
//                                        }
                                        
                                        // Persist preferences
                                        preferences.saveUserDefaults(appConfiguration: appConfiguration)
                                    } label: {
                                        Label("Done", systemImage: "")
                                            .labelStyle(.titleOnly)
                                    }
                                    .modify {
                                        if #available(macOS 26, *) {
                                            $0
                                                .buttonStyle(.glassProminent)
                                                .tint(color)
                                                .buttonBorderShape(.capsule)
                                                .controlSize(.large)
                                        } else {
                                            $0
                                        }
                                    }
                                } else if !preferences.showItemConfiguration {
                                    Button {
//                                        withAnimation {
                                            preferences.editModeEnabled.toggle()
//                                        }
                                    } label: {
                                        Label("Edit", systemImage: "")
                                            .labelStyle(.titleOnly)
                                    }
                                    .modify {
                                        if #available(macOS 26, *) {
                                            $0
                                                .buttonStyle(.glassProminent)
                                                .buttonBorderShape(.capsule)
                                                .controlSize(.large)
                                        } else {
                                            $0
                                        }
                                    }
                                }
                        }
                        .glassContainerIfAvailable(spacing: 0)
                        .animation(.easeInOut, value: preferences.editModeEnabled)
                        .padding(.horizontal, 10)
                        
//                        Text("Configurator Mode")
//                            .foregroundStyle(.secondary)
//                    }
//                    .padding(.horizontal, 10)
                }
            }
            .padding(.bottom, 10)
        }
        .background(colorScheme == .dark ? Color.clear : Color.primary.opacity(0.1))
        // Set default popover width
        .frame(minWidth: 382, idealWidth: 382, maxWidth: 382)
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
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let appData = try encoder.encode(appConfiguration)

            // Turn encoded data into a Foundation property list dictionary
            let plistObject = try PropertyListSerialization.propertyList(from: appData, options: [], format: nil)
            guard var appDict = plistObject as? [String: Any] else {
                logger.error("Failed to convert encoded AppModel to [String: Any] for mobileconfig export")
                return
            }

            // Compose a proper Configuration Profile
            let innerUUID = UUID().uuidString
            let outerUUID = UUID().uuidString

            // Add required keys
            appDict["PayloadDescription"] = ""
            appDict["PayloadDisplayName"] = "Custom"
            appDict["PayloadEnabled"] = true
            appDict["PayloadIdentifier"] = "nl.root3.support.\(innerUUID)"
            appDict["PayloadOrganization"] = "Root3"
            appDict["PayloadType"] = "nl.root3.support"
            appDict["PayloadUUID"] = innerUUID
            appDict["PayloadVersion"] = 1

            let profileDict: [String: Any] = [
                "PayloadContent": [appDict],
                "PayloadDescription": "",
                "PayloadDisplayName": "Support App Configuration",
                "PayloadEnabled": true,
                "PayloadIdentifier": "nl.root3.support.profile.\(outerUUID)",
                "PayloadOrganization": "Root3",
                "PayloadRemovalDisallowed": true,
                "PayloadScope": "System",
                "PayloadType": "Configuration",
                "PayloadUUID": outerUUID,
                "PayloadVersion": 1
            ]

            let profileData = try PropertyListSerialization.data(fromPropertyList: profileDict, format: .xml, options: 0)

            appDelegate.togglePopover(nil)

            // Save as .mobileconfig
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.init(filenameExtension: "mobileconfig")!]
            savePanel.nameFieldStringValue = "nl.root3.support.mobileconfig"
            savePanel.canCreateDirectories = true

            if savePanel.runModal() == .OK, let url = savePanel.url {
                try profileData.write(to: url)
            }
        } catch {
            logger.error("Exporting .mobileconfig failed: \(error.localizedDescription)")
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
