//
//  ItemConfigurationView.swift
//  Support
//
//  Created by Jordy Witteman on 13/04/2025.
//

import os
import SwiftUI

struct ItemConfigurationView: View {
    
    // Get computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    
    @EnvironmentObject var localPreferences: LocalPreferences
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
        
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
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
    
    @State private var item: SupportItem = SupportItem(type: "Button", title: "Preview", subtitle: nil, linkType: nil, link: nil, symbol: nil, extensionIdentifier: nil, onAppearAction: nil)
    @State private var selectedType: String = ""
    
    let typeOptions: [String] = [
        "ComputerName",
        "MacOSVersion",
        "Network",
        "Password",
        "Storage",
        "Uptime",
        "AppCatalog",
        "Button",
        "SmallButton",
        "CircleButton"
    ]
    
    var body: some View {
        
        Group {
            
            HStack {
                
                Button(action: {
                    preferences.showItemConfiguration = false
                }) {
                    Ellipse()
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                        .overlay(
                            Image(systemName: "chevron.backward")
                        )
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                
                Text(NSLocalizedString("ITEM_CONFIGURATION", comment: ""))
                    .font(.system(.headline, design: .rounded))
                
                Spacer()
                
                Button(action: {
                    // Save item
                    localPreferences.rows[localPreferences.currentConfiguredItem!.rowIndex].items?[localPreferences.currentConfiguredItem!.itemIndex] = item
                    
                    preferences.showItemConfiguration.toggle()
                }) {
                    Text(NSLocalizedString("SAVE", comment: ""))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.regular)
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .background(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
            }
            
            Divider()
                .padding(2)
            
            VStack {
                Text("ITEM_PREVIEW")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                switch item.type {
                case "ComputerName":
                    ComputerNameSubview()
                case "MacOSVersion":
                    MacOSVersionSubview()
                case "Network":
                    NetworkSubview()
                case "Password":
                    PasswordSubview()
                case "Storage":
                    StorageSubview()
                case "Uptime":
                    UptimeSubview()
                case "AppCatalog":
                    AppCatalogSubview()
                case "Button":
                    Item(title: item.title ?? "", subtitle: item.subtitle ?? "", linkType: item.linkType ?? "", link: item.link ?? "", image: item.symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                case "SmallButton":
                    ItemSmall(title: item.title ?? "", subtitle: item.subtitle ?? "", linkType: item.linkType ?? "", link: item.link ?? "", image: item.symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                case "CircleButton":
                    if #available(macOS 26, *) {
                        ItemCircle(title: item.title ?? "", subtitle: item.subtitle ?? "", linkType: item.linkType ?? "", link: item.link ?? "", image: item.symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                    }
                default:
                    Item(title: item.title ?? "", subtitle: item.subtitle ?? "", linkType: item.linkType ?? "", link: item.link ?? "", image: item.symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                }
                
            }
            
            Divider()
                .padding(2)
            
            VStack {
                
                Picker("ITEM_TYPE", selection: $selectedType, content: {
                    ForEach(typeOptions, id: \.self) { type in
                        Text(type).tag(type)
                    }
                })
                
            }
            
        }
        .padding(.horizontal)
        .unredacted()
        .onAppear {
            if let fetchedItem = localPreferences.rows[localPreferences.currentConfiguredItem!.rowIndex].items?[localPreferences.currentConfiguredItem!.itemIndex] {
                item = fetchedItem
                selectedType = item.type
            }
        }
        .onChange(of: selectedType) { newType in
            item = SupportItem(type: newType, title: "Preview", subtitle: nil, linkType: nil, link: nil, symbol: nil, extensionIdentifier: nil, onAppearAction: nil)
        }
    }
}

#Preview {
    ItemConfigurationView()
}
