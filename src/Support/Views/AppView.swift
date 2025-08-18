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
    let logger = Logger(subsystem: "nl.root3.support", category: "RowDecoder")
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
    
    @EnvironmentObject var computerinfo: ComputerInfo
    @EnvironmentObject var userinfo: UserInfo
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var appCatalogController: AppCatalogController
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Simple property wrapper boolean to visualize data loading when app opens
    @State var placeholdersEnabled = true
        
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
                    .frame(minWidth: 382, idealWidth: 382, maxWidth: 382)
                    .fixedSize()
                }
                
                HStack {
                    
                    Spacer()

                    if preferences.editModeEnabled {
                        Button {
                            preferences.editModeEnabled.toggle()
                        } label: {
                            Label("Done", systemImage: "")
                                .labelStyle(.titleOnly)
                        }
                    } else {
                        Button {
                            preferences.editModeEnabled.toggle()
                        } label: {
                            Label("Edit", systemImage: "")
                                .labelStyle(.titleOnly)
                        }
                    }
                }
                .padding(.trailing, 10)
            }
            .padding(.bottom, 10)
        }
//        .background(EffectsView(material: NSVisualEffectView.Material.fullScreenUI, blendingMode: NSVisualEffectView.BlendingMode.behindWindow))
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
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
