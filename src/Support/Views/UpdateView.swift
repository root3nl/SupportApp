//
//  UpdateView.swift
//  Support
//
//  Created by Jordy Witteman on 13/06/2023.
//

import os
import SwiftUI

struct UpdateView: View {
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.openURL) var openURL

    // Set the custom color for all symbols depending on Light or Dark Mode.
    var customColor: String {
        if colorScheme == .light && defaults.string(forKey: "CustomColor") != nil {
            return preferences.customColor
        } else if colorScheme == .dark && defaults.string(forKey: "CustomColorDarkMode") != nil {
            return preferences.customColorDarkMode
        } else {
            return preferences.customColor
        }
    }
    
    var body: some View {
        
        Group {
            
            HStack {
                
                Button(action: {
                    computerinfo.showMacosUpdates.toggle()
                }) {
                    Ellipse()
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                        .overlay(
                            Image(systemName: "chevron.backward")
                        )
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                
                Text(NSLocalizedString("MACOS_UPDATES", comment: ""))
                    .font(.system(.headline, design: .rounded))
                
                Spacer()
                
                if computerinfo.recommendedUpdates.count > 0 {
                    
                    Button(action: {
                        openSoftwareUpdate()
                    }) {
                        Text(NSLocalizedString("UPDATE_NOW", comment: ""))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.regular)
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                            .background(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                }
                
            }
            
            Divider()
                .padding(2)
            
            if computerinfo.recommendedUpdates.count > 0 {
                
                ForEach(computerinfo.recommendedUpdates, id: \.self) { update in
                    
                    HStack {
                        
                        Ellipse()
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                            .overlay(
                                Image(systemName: "gear")
                            )
                            .frame(width: 26, height: 26)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text(update.displayName)
                                .font(.system(.headline, design: .rounded))
                            
                            Text(update.displayVersion ?? "")
                                .foregroundColor(.secondary)
                                .font(.system(.subheadline, design: .rounded))
                            
                            if computerinfo.softwareUpdateDeclarationDeadline != nil && update.displayVersion == computerinfo.softwareUpdateDeclarationVersion {
                                
                                Text(NSLocalizedString("ENFORCED_ON", comment: "") + " " + "\(computerinfo.softwareUpdateDeclarationDeadline?.formatted(date: .abbreviated, time: .shortened) ?? "")")
                                    .foregroundStyle(.secondary)
                                    .font(.system(.subheadline, design: .rounded))
                                
                            }
                            
                        }
                        
                        Spacer()
                        
                        if computerinfo.softwareUpdateDeclarationURL != nil && update.displayVersion == computerinfo.softwareUpdateDeclarationVersion {
                            Button(action: {
                                openURL(URL(string: computerinfo.softwareUpdateDeclarationURL ?? "")!)
                                
                                // Close popover
                                appDelegate.togglePopover(nil)
                            }) {
                                Text(NSLocalizedString("DETAILS", comment: ""))
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.regular)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal)
                                    .background(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .help(computerinfo.softwareUpdateDeclarationURL ?? "")
                        }
                    }
                    
                }
                
                if preferences.updateText != "" {
                    
                    Divider()
                        .padding(2)
                    
                    HStack(alignment: .top) {
                        
                        // Supports for markdown through a variable:
                        // https://blog.eidinger.info/3-surprises-when-using-markdown-in-swiftui
                        Text(.init(preferences.updateText.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo)))
                            .font(.system(.body, design: .rounded))
                        
                        Spacer()
                    }
                }
                
            } else {
                
                VStack(alignment: .center, spacing: 20) {
                    
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                    
                    Text(NSLocalizedString("YOUR_MAC_IS_UP_TO_DATE", comment: ""))
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.medium)
                    
                }
                .padding(.vertical, 40)
                
            }
        }
        .padding(.horizontal)
        .unredacted()
        .task {
            if !computerinfo.recommendedUpdates.isEmpty {
                self.computerinfo.getUpdateDeclaration()
            }
        }
    }
    
    // Open URL
    func openSoftwareUpdate() {
        
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate") else {
            return
        }

        NSWorkspace.shared.open(url)
        
        // Close popover
        appDelegate.togglePopover(nil)

    }
}

struct UpdateViewLegacy: View {
    
    let logger = Logger(subsystem: "nl.root3.support", category: "SoftwareUpdate")
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
      
    // State of UpdateView popover
    @State private var showPopover: Bool = false
    
    // Update counter
    var updateCounter: Int
    var color: Color
            
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            if computerinfo.recommendedUpdates.count > 0 {
                
                HStack {
                    
                    Text(updateCounter > 0 ? NSLocalizedString("UPDATES_AVAILABLE", comment: "") : NSLocalizedString("NO_UPDATES_AVAILABLE", comment: ""))
                        .font(.system(.headline, design: .rounded))
                    
                    Spacer()
                    
                    Button(action: {
                        showPopover = false
                        openSoftwareUpdate()
                    }) {
                        if #available(macOS 13, *) {
                            Text(NSLocalizedString("SYSTEM_SETTINGS", comment: ""))
                        } else {
                            Text(NSLocalizedString("SYSTEM_PREFERENCES", comment: ""))
                        }
                    }
                    .modify {
                        if #available(macOS 12, *) {
                            $0.buttonStyle(.borderedProminent)
                        }
                    }
                }
                
                Divider()
                    .padding(2)
                
                ForEach(computerinfo.recommendedUpdates, id: \.self) { update in
                    
                    Text("•\t\(update.displayName)")
                        .font(.system(.body, design: .rounded))
                    
                }
                
                if preferences.updateText != "" {
                    
                    Divider()
                        .padding(2)
                    
                    HStack(alignment: .top) {
                        
                        Image(systemName: "info.circle.fill")
                            .font(.headline)
                            .imageScale(.large)
                            .foregroundColor(color)
                        
                        // Supports for markdown through a variable:
                        // https://blog.eidinger.info/3-surprises-when-using-markdown-in-swiftui
                        Text(.init(preferences.updateText.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo)))
                            .font(.system(.body, design: .rounded))
                        
                        Spacer()
                    }
                }
                
            } else {
                
                HStack {
                    
                    Spacer()
                    
                    VStack {
                        
                        Text(NSLocalizedString("YOUR_MAC_IS_UP_TO_DATE", comment: ""))
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.medium)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .modify {
                                if #available(macOS 12, *) {
                                    $0.symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, color)
                                } else {
                                    $0.foregroundColor(color)

                                }
                            }
                        
                    }
                    
                    Spacer()
                    
                }
                
            }
        }
        // Set frame to 250 to allow multiline text
        .frame(width: 300)
        .fixedSize()
        .padding()
        .unredacted()
    }
    
    // Open URL
    func openSoftwareUpdate() {
        
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate") else {
            return
        }

        NSWorkspace.shared.open(url)
        
        // Close the popover
        NSApp.deactivate()

    }
}
