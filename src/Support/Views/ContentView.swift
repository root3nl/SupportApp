//
//  ContentView.swift
//  Root3 Support
//
//  Created by Jordy Witteman on 07/07/2020.
//

import Foundation
import os
import SwiftUI

// The main view
struct ContentView: View {
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    
    // Get local preferences for Configurator Mode
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
    
    @State private var addRowButtonHovered: Bool = false
    @State private var addItemButtonHovered: Bool = false
    @State private var addRowButtonHoveredIndex: Int?
    @State private var showItemConfigurationPopover = false
    
    let supportItem = SupportItem(type: "Button", title: "Title", subtitle: "Subtitle", linkType: nil, link: nil, symbol: "cart.fill.badge.plus", extensionIdentifier: nil, onAppearAction: nil)
    
    // Local preferences or (managed) UserDefaults
    var rows: [Row] {
        if preferences.configuratorModeEnabled {
            return localPreferences.rows
        } else {
            return preferences.rows
        }
    }
    
    var body: some View {
        
        VStack(spacing: 10) {
            ForEach(rows.indices, id: \.self) { index in
                ZStack {
                    HStack(spacing: 10) {
                        if let rowItems = rows[index].items {
                            ForEach(rowItems.indices, id: \.self) { itemIndex in
                                
                                ZStack {
                                    switch rowItems[itemIndex].type {
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
                                        Item(title: rowItems[itemIndex].title ?? "", subtitle: nil, linkType: rowItems[itemIndex].linkType ?? "", link: rowItems[itemIndex].link ?? "", image: rowItems[itemIndex].symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), extensionIdentifier: rowItems[itemIndex].extensionIdentifier ?? "", onAppearAction: rowItems[itemIndex].onAppearAction, hoverEffectEnable: true, animate: false)
                                    case "Button":
                                        Item(title: rowItems[itemIndex].title ?? "", subtitle: rowItems[itemIndex].subtitle ?? "", linkType: rowItems[itemIndex].linkType ?? "", link: rowItems[itemIndex].link ?? "", image: rowItems[itemIndex].symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                                    case "ButtonMedium":
                                        ItemSmall(title: rowItems[itemIndex].title ?? "", subtitle: rowItems[itemIndex].subtitle ?? "", linkType: rowItems[itemIndex].linkType ?? "", link: rowItems[itemIndex].link ?? "", image: rowItems[itemIndex].symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                                    case "ButtonSmall":
                                        if #available(macOS 26, *) {
                                            ItemCircle(title: rowItems[itemIndex].title ?? "", subtitle: rowItems[itemIndex].subtitle ?? "", linkType: rowItems[itemIndex].linkType ?? "", link: rowItems[itemIndex].link ?? "", image: rowItems[itemIndex].symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                                        }
                                    default:
                                        Item(title: rowItems[itemIndex].title ?? "", subtitle: rowItems[itemIndex].subtitle ?? "", linkType: rowItems[itemIndex].linkType ?? "", link: rowItems[itemIndex].link ?? "", image: rowItems[itemIndex].symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                                    }
                                }
                                .contextMenu {
                                    if preferences.editModeEnabled {
                                        Button {
                                            localPreferences.currentConfiguredItem = ConfiguredItem(rowIndex: index, itemIndex: itemIndex)
                                            preferences.showItemConfiguration.toggle()
                                        } label: {
                                            Label("Edit", systemImage: "slider.horizontal.3")
                                        }
                                        
                                        Button {
                                            localPreferences.rows[index].items?.remove(at: itemIndex)
                                            
                                            // Remove if row is empty to avoid empty/invisible rows taking up space
                                            if localPreferences.rows[index].items?.count == 0 {
                                                localPreferences.rows.remove(at: index)
                                            }
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .glassContainerIfAvailable()
                    
                    // Add row divider and plus button
                    if preferences.editModeEnabled {
                        HStack {
                            Spacer()
                            
                            VStack {
                                
                                Button {
                                    // Add item
                                    if localPreferences.rows[index].items == nil {
                                        localPreferences.rows[index].items = []
                                    }
                                    withAnimation {
                                        localPreferences.rows[index].items?.append(supportItem)
                                    }
                                } label: {
                                    Label("Add item", systemImage: "plus")
                                        .labelStyle(.iconOnly)
                                }
                                .buttonStyle(AddIconButtonStyle())
                            }
                        }
                        .padding(.trailing, 4)
                    }
                }
            }
            // Add row divider and plus button
            if preferences.editModeEnabled {
                HStack {
                    VStack {
                        Divider()
                            .padding(.leading)
                    }
                    Button {
                        localPreferences.rows.append(Row(items: [supportItem]))
                    } label: {
                        Label("Add row", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(AddIconButtonStyle())
                    VStack {
                        Divider()
                            .padding(.trailing)
                    }
                }
            }
        }
        .frame(minWidth: 382, idealWidth: 382, maxWidth: 382)
        .animation(.snappy, value: preferences.editModeEnabled)
    }
}
