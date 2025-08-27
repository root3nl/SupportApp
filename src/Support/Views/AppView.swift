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
                if preferences.footerText != "" {
                    HStack {
                        
                        
                        // Supports for markdown through a variable:
                        // https://blog.eidinger.info/3-surprises-when-using-markdown-in-swiftui
                        Text(.init(preferences.footerText.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo)))
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
                                    Label("Other settings", systemImage: "gear")
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

            let appConfiguration = AppModel(title: localPreferences.title, rows: localPreferences.rows)
            let data = try encoder.encode(appConfiguration)

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
            let appConfiguration = AppModel(title: preferences.title, rows: localPreferences.rows)

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
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
