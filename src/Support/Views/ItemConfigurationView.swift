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
    
    @State private var item: SupportItem = SupportItem(type: "Button", title: nil, subtitle: nil, linkType: nil, link: nil, symbol: nil, extensionIdentifier: nil, onAppearAction: nil)
    @State private var selectedType: String = ""
    @State private var title: String = "Title Example"
    @State private var subtitle: String = "Subtitle Example"
    @State private var linkType: String = "App"
    @State private var link: String = ""
    @State private var symbol: String = "cart.fill.badge.plus"
    @State private var extensionIdentifier: String = ""
    @State private var onAppearAction: String = ""

    let typeOptions: [String: String] = [
        "ComputerName" : "Info Item - Computer name",
        "MacOSVersion" : "Info Item - macOS version",
        "Network" : "Info Item - Network",
        "Password" : "Info Item - Password",
        "Storage" : "Info Item - Storage",
        "Uptime" : "Info Item - Uptime",
        "AppCatalog" : "Info Item - App Catalog",
        "Extension" : "Extension",
        "Button" : "Button - Regular",
        "ButtonMedium" : "Button - Medium",
        "ButtonSmall" : "Button - Small"
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
                    if item.type.contains("Button") {
                        localPreferences.rows[localPreferences.currentConfiguredItem!.rowIndex].items?[localPreferences.currentConfiguredItem!.itemIndex] = SupportItem(type: selectedType, title: title, subtitle: subtitle, linkType: linkType, link: link, symbol: symbol, extensionIdentifier: nil, onAppearAction: nil)
                    } else if item.type == "Extension" {
                        localPreferences.rows[localPreferences.currentConfiguredItem!.rowIndex].items?[localPreferences.currentConfiguredItem!.itemIndex] = SupportItem(type: selectedType, title: title, subtitle: nil, linkType: linkType, link: link, symbol: symbol, extensionIdentifier: extensionIdentifier, onAppearAction: onAppearAction)
                    } else {
                        localPreferences.rows[localPreferences.currentConfiguredItem!.rowIndex].items?[localPreferences.currentConfiguredItem!.itemIndex] = SupportItem(type: selectedType, title: nil, subtitle: nil, linkType: nil, link: nil, symbol: nil, extensionIdentifier: nil, onAppearAction: nil)

                    }
                    
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
                case "Extension":
                    Item(title: title, subtitle: subtitle, linkType: linkType, link: link, image: symbol, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: false)
                case "Button":
                    Item(title: title, subtitle: subtitle, linkType: linkType, link: link, image: symbol, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                case "ButtonMedium":
                    ItemSmall(title: title, subtitle: subtitle, linkType: linkType, link: link, image: symbol, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                case "ButtonSmall":
                    if #available(macOS 26, *) {
                        ItemCircle(title: title, subtitle: subtitle, linkType: linkType, link: link, image: symbol, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                    }
                default:
                    Item(title: title, subtitle: subtitle, linkType: linkType, link: link, image: symbol, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                }
                
            }
            
            Divider()
                .padding(2)
            
            Form {
                
                Picker("ITEM_TYPE", selection: $selectedType) {
                    ForEach(typeOptions.sorted(by: { $0.value < $1.value }), id: \.key) { key, value in
                        Text(value).tag(key)
                    }
                }
                
                if item.type.contains("Button") || item.type == "Extension" {
                    TextField("Title", text: $title)
                    if item.type != "Extension" {
                        TextField("Subtitle", text: $subtitle)
                    }
                    Picker("Link Type", selection: $linkType) {
                        Text("None").tag("None")
                        Text("App").tag("App")
                        Text("URL").tag("URL")
                        Text("Command").tag("Command")
                        Text("Privileged Script").tag("PrivilegedScript")
                    }
                    TextField("Link", text: $link)
                    TextField("SF Symbol", text: $symbol)
                    if item.type == "Extension" {
                        TextField("Extension Identifier", text: $extensionIdentifier)
                        TextField("On appear action", text: $onAppearAction)
                    }
                }
                
            }
            
        }
        .padding(.horizontal)
        .unredacted()
        .onAppear {
            if let fetchedItem = localPreferences.rows[localPreferences.currentConfiguredItem!.rowIndex].items?[localPreferences.currentConfiguredItem!.itemIndex] {
                item = fetchedItem
                
                selectedType = item.type
                if let title = item.title {
                    self.title = title
                }
                if let subtitle = item.subtitle {
                    self.subtitle = subtitle
                }
                if let linkType = item.linkType {
                    self.linkType = linkType
                }
                if let link = item.link {
                    self.link = link
                }
                if let symbol = item.symbol {
                    self.symbol = symbol
                }
                if let extensionIdentifier = item.extensionIdentifier {
                    self.extensionIdentifier = extensionIdentifier
                }
                if let onAppearAction = item.onAppearAction {
                    self.onAppearAction = onAppearAction
                }
            }
        }
        .onChange(of: selectedType) { _, newValue in
            item = SupportItem(type: newValue, title: title, subtitle: nil, linkType: nil, link: nil, symbol: nil, extensionIdentifier: nil, onAppearAction: nil)
        }
    }
}

#Preview {
    ItemConfigurationView()
}
