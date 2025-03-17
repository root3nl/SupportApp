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
    
    // Rows
    var rows: [Row]
        
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    
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
    
    @State private var rowsTest: [Row] = []
    let supportItem = SupportItem(type: "AppCatalog", title: nil, subtitle: nil, linkType: nil, link: nil, symbol: nil, extensionIdentifier: nil, onAppearAction: nil)
        
    var body: some View {
        
//        if UserDefaults.standard.object(forKey: "RowsTest") != nil {
//        if UserDefaults.standard.object(forKey: "Rows") != nil {
            
            VStack {
                ForEach(rowsTest.indices, id: \.self) { index in
//                    if row.items.count >= 2 && row.items.filter({ $0.type == "Button" }).count > 2 {
//                        VStack {
//                            Text("Unsupported number of items")
//                                .font(.system(.headline, design: .rounded))
//                            Link(destination: URL(string: "https://github.com/root3nl/SupportApp")!) {
//                                Text("Documentation")
//                                    .font(.system(.subheadline, design: .rounded))
//                            }
//                        }
//                        .padding()
//                    } else if row.items.count >= 3 && row.items.filter({ $0.type == "SmallButton" }).count > 3 {
//                        VStack {
//                            Text("Unsupported number of items")
//                                .font(.system(.headline, design: .rounded))
//                            Link(destination: URL(string: "https://github.com/root3nl/SupportApp")!) {
//                                Text("Documentation")
//                                    .font(.system(.subheadline, design: .rounded))
//                            }
//                        }
//                        .padding()
//                    } else {
                        HStack(spacing: 10) {
                            if let rowItems = rowsTest[index].items {
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
                                        case "Button":
                                            Item(title: rowItems[itemIndex].title ?? "", subtitle: rowItems[itemIndex].subtitle ?? "", linkType: rowItems[itemIndex].linkType ?? "", link: rowItems[itemIndex].link ?? "", image: rowItems[itemIndex].symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                                        case "SmallButton":
                                            ItemSmall(title: rowItems[itemIndex].title ?? "", subtitle: rowItems[itemIndex].subtitle ?? "", linkType: rowItems[itemIndex].linkType ?? "", link: rowItems[itemIndex].link ?? "", image: rowItems[itemIndex].symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                                        case "Divider":
                                            VStack {
                                                Divider()
                                            }
                                        case "Spacer":
                                            Spacer()
                                        default:
                                            Item(title: rowItems[itemIndex].title ?? "", subtitle: rowItems[itemIndex].subtitle ?? "", linkType: rowItems[itemIndex].linkType ?? "", link: rowItems[itemIndex].link ?? "", image: rowItems[itemIndex].symbol ?? "", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                                        }
                                        
//                                        // Button to remove item
//                                        Image(systemName: "minus.circle.fill")
//                                            .imageScale(.large)
//                                            .foregroundStyle(.red)
//                                            .onTapGesture {
//                                                print("Remove row \(index)")
////                                                withAnimation {
//                                                    rowsTest[index].items?.remove(at: itemIndex)
////                                                }
//                                            }
//                                            .offset(x: 85, y: -30)
//                                        
//                                        // Button to add additional item
//                                        Image(systemName: "plus.circle.fill")
//                                            .imageScale(.large)
//                                            .foregroundStyle(.secondary)
//                                            .onTapGesture {
//                                                // Add item
//                                                if rowsTest[index].items == nil {
//                                                    rowsTest[index].items = []
//                                                }
////                                                withAnimation {
//                                                    rowsTest[index].items?.append(supportItem)
////                                                }
//                                            }
//                                            .offset(x: 85, y: 0)

                                    }
                                    .contextMenu {
                                        Button {
                                            rowsTest[index].items?.remove(at: itemIndex)
                                        } label: {
                                            Label("Remove", systemImage: "minus.circle.fill")
                                        }
                                    }
//                                    .animation(.default, value: rowItems)
                                }
//                            } else {
//                                
//                                // View to add first item in row
//                                ZStack {
//                                    
//                                    Image(systemName: addItemButtonHovered && (addRowButtonHoveredIndex == index) ? "plus.circle.fill" : "plus.circle")
//                                        .foregroundStyle(.secondary)
//                                        .imageScale(.large)
//                                        .onHover { hover in
//                                            withAnimation(.easeOut) {
//                                                addItemButtonHovered = hover
//                                            }
//                                        }
//                                        .onHover { _ in
//                                            addRowButtonHoveredIndex = index
//                                        }
//                                        .frame(width: 360, height: 60)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .strokeBorder(style: StrokeStyle(lineWidth: 1))
//                                                .foregroundStyle(.secondary)
//                                                .opacity(0.5)
//                                        )
//                                        .onTapGesture {
//                                            // Add item
//                                            if rowsTest[index].items == nil {
//                                                rowsTest[index].items = []
//                                            }
//                                            rowsTest[index].items?.append(supportItem)
//                                            print(rowsTest)
//                                        }
//                                    
//                                    HStack {
//                                        
//                                        Spacer()
//                                        
//                                        VStack {
//                                            
//                                            Image(systemName: "minus.circle.fill")
//                                                .imageScale(.large)
//                                                .foregroundStyle(.red)
//                                                .onTapGesture {
//                                                    print("Remove row \(index)")
//                                                    rowsTest.remove(at: index)
//                                                }
//                                                .offset(x: 5, y: -10)
//                                            
//                                            Spacer()
//                                            
//                                        }
//                                    }
//                                }
                            }
//                        }
                    }
                }
                // Add row divider and plus button
                HStack {
                    VStack {
                        Divider()
                    }
                    Image(systemName: addRowButtonHovered ? "plus.circle.fill" : "plus.circle")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                        .onHover { hover in
                            withAnimation(.easeOut) {
                                addRowButtonHovered = hover
                            }
                        }
                        .onTapGesture {
                            // Add row
                            print("Adding row")
                            rowsTest.append(Row(items: [supportItem]))
                        }
                    VStack {
                        Divider()
                    }
                }
            }
            .frame(minWidth: 362, idealWidth: 362, maxWidth: 362)
//        } else {
//            
//            // MARK: - First horizontal stack with Computer Name and macOS version as defaults
//            if !preferences.hideFirstRowInfoItems {
//                HStack(spacing: 10) {
//                    
//                    // Item left
//                    switch preferences.infoItemOne {
//                    case "ComputerName":
//                        ComputerNameSubview()
//                    case "MacOSVersion":
//                        MacOSVersionSubview()
//                    case "Network":
//                        NetworkSubview()
//                    case "Password":
//                        PasswordSubview()
//                    case "Storage":
//                        StorageSubview()
//                    case "Uptime":
//                        UptimeSubview()
//                    case "ExtensionA":
//                        ExtensionASubview()
//                    case "ExtensionB":
//                        ExtensionBSubview()
//                    case "AppCatalog":
//                        AppCatalogSubview()
//                    default:
//                        ComputerNameSubview()
//                    }
//                    
//                    // Item right
//                    switch preferences.infoItemTwo {
//                    case "ComputerName":
//                        ComputerNameSubview()
//                    case "MacOSVersion":
//                        MacOSVersionSubview()
//                    case "Network":
//                        NetworkSubview()
//                    case "Password":
//                        PasswordSubview()
//                    case "Storage":
//                        StorageSubview()
//                    case "Uptime":
//                        UptimeSubview()
//                    case "ExtensionA":
//                        ExtensionASubview()
//                    case "ExtensionB":
//                        ExtensionBSubview()
//                    case "AppCatalog":
//                        AppCatalogSubview()
//                    default:
//                        MacOSVersionSubview()
//                    }
//                    
//                }
//                .padding(.horizontal, 10)
//            }
//            
//            // MARK: - Second horizontal stack with Uptime and StorageView as defaults
//            if !preferences.hideSecondRowInfoItems {
//                HStack(spacing: 10) {
//                    
//                    // Item left
//                    switch preferences.infoItemThree {
//                    case "ComputerName":
//                        ComputerNameSubview()
//                    case "MacOSVersion":
//                        MacOSVersionSubview()
//                    case "Network":
//                        NetworkSubview()
//                    case "Password":
//                        PasswordSubview()
//                    case "Storage":
//                        StorageSubview()
//                    case "Uptime":
//                        UptimeSubview()
//                    case "ExtensionA":
//                        ExtensionASubview()
//                    case "ExtensionB":
//                        ExtensionBSubview()
//                    case "AppCatalog":
//                        AppCatalogSubview()
//                    default:
//                        UptimeSubview()
//                    }
//                    
//                    // Item right
//                    switch preferences.infoItemFour {
//                    case "ComputerName":
//                        ComputerNameSubview()
//                    case "MacOSVersion":
//                        MacOSVersionSubview()
//                    case "Network":
//                        NetworkSubview()
//                    case "Password":
//                        PasswordSubview()
//                    case "Storage":
//                        StorageSubview()
//                    case "Uptime":
//                        UptimeSubview()
//                    case "ExtensionA":
//                        ExtensionASubview()
//                    case "ExtensionB":
//                        ExtensionBSubview()
//                    case "AppCatalog":
//                        AppCatalogSubview()
//                    default:
//                        StorageSubview()
//                    }
//                }
//                .padding(.horizontal, 10)
//            }
//            
//            // MARK: - Third optional horizontal stack with Password and Network as defaults
//            if preferences.infoItemFive != "" || preferences.infoItemSix != "" {
//                if !preferences.hideThirdRowInfoItems {
//                    HStack(spacing: 10) {
//                        
//                        // Item left
//                        switch preferences.infoItemFive {
//                        case "ComputerName":
//                            ComputerNameSubview()
//                        case "MacOSVersion":
//                            MacOSVersionSubview()
//                        case "Network":
//                            NetworkSubview()
//                        case "Password":
//                            PasswordSubview()
//                        case "Storage":
//                            StorageSubview()
//                        case "Uptime":
//                            UptimeSubview()
//                        case "ExtensionA":
//                            ExtensionASubview()
//                        case "ExtensionB":
//                            ExtensionBSubview()
//                        case "AppCatalog":
//                            AppCatalogSubview()
//                        default:
//                            PasswordSubview()
//                        }
//                        
//                        // Item right
//                        switch preferences.infoItemSix {
//                        case "ComputerName":
//                            ComputerNameSubview()
//                        case "MacOSVersion":
//                            MacOSVersionSubview()
//                        case "Network":
//                            NetworkSubview()
//                        case "Password":
//                            PasswordSubview()
//                        case "Storage":
//                            StorageSubview()
//                        case "Uptime":
//                            UptimeSubview()
//                        case "ExtensionA":
//                            ExtensionASubview()
//                        case "ExtensionB":
//                            ExtensionBSubview()
//                        case "AppCatalog":
//                            AppCatalogSubview()
//                        default:
//                            NetworkSubview()
//                        }
//                        
//                    }
//                    .padding(.horizontal, 10)
//                }
//            }
//            
//            // MARK: - Hide row if specified in configuration
//            // MARK: - Key 'HideFirstRow' is deprecated, please use 'HideFirstRowButtons'
//            if !defaults.bool(forKey: "HideFirstRow") && !preferences.hideFirstRowButtons {
//                
//                // MARK: - Horizontal stack with 2 or 3 configurable action buttons
//                HStack(spacing: 10) {
//                    
//                    if preferences.firstRowTitleMiddle != "" {
//                        ItemSmall(title: preferences.firstRowTitleLeft, subtitle: preferences.firstRowSubtitleLeft, linkType: preferences.firstRowTypeLeft, link: preferences.firstRowLinkLeft, image: preferences.firstRowSymbolLeft, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.firstRowLoadingLeft, linkPrefKey: Preferences.firstRowLinkLeftKey)
//                        ItemSmall(title: preferences.firstRowTitleMiddle, subtitle: preferences.firstRowSubtitleMiddle, linkType: preferences.firstRowTypeMiddle, link: preferences.firstRowLinkMiddle, image: preferences.firstRowSymbolMiddle, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.firstRowLoadingMiddle, linkPrefKey: Preferences.firstRowLinkMiddleKey)
//                        ItemSmall(title: preferences.firstRowTitleRight, subtitle: preferences.firstRowSubtitleRight, linkType: preferences.firstRowTypeRight, link: preferences.firstRowLinkRight, image: preferences.firstRowSymbolRight, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.firstRowLoadingRight, linkPrefKey: Preferences.firstRowLinkRightKey)
//                    } else {
//                        Item(title: preferences.firstRowTitleLeft, subtitle: preferences.firstRowSubtitleLeft, linkType: preferences.firstRowTypeLeft, link: preferences.firstRowLinkLeft, image: preferences.firstRowSymbolLeft, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.firstRowLoadingLeft, linkPrefKey: Preferences.firstRowLinkLeftKey, hoverEffectEnable: true, animate: true)
//                        Item(title: preferences.firstRowTitleRight, subtitle: preferences.firstRowSubtitleRight, linkType: preferences.firstRowTypeRight, link: preferences.firstRowLinkRight, image: preferences.firstRowSymbolRight, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.firstRowLoadingRight, linkPrefKey: Preferences.firstRowLinkRightKey, hoverEffectEnable: true, animate: true)
//                    }
//                }
//                .padding(.horizontal, 10)
//            }
//            
//            // MARK: - Hide row if specified in configuration
//            // MARK: - Key 'HideSecondRow' is deprecated, please use 'HideSecondRowButtons'
//            if !defaults.bool(forKey: "HideSecondRow") && !preferences.hideSecondRowButtons {
//                
//                // MARK: - Horizontal stack with 2 or 3 configurable action buttons
//                HStack(spacing: 10) {
//                    
//                    if preferences.secondRowTitleMiddle != "" {
//                        ItemSmall(title: preferences.secondRowTitleLeft, subtitle: preferences.secondRowSubtitleLeft, linkType: preferences.secondRowTypeLeft, link: preferences.secondRowLinkLeft, image: preferences.secondRowSymbolLeft, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.secondRowLoadingLeft, linkPrefKey: Preferences.secondRowLinkLeftKey)
//                        ItemSmall(title: preferences.secondRowTitleMiddle, subtitle: preferences.secondRowSubtitleMiddle, linkType: preferences.secondRowTypeMiddle, link: preferences.secondRowLinkMiddle, image: preferences.secondRowSymbolMiddle, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.secondRowLoadingMiddle, linkPrefKey: Preferences.secondRowLinkMiddleKey)
//                        ItemSmall(title: preferences.secondRowTitleRight, subtitle: preferences.secondRowSubtitleRight, linkType: preferences.secondRowTypeRight, link: preferences.secondRowLinkRight, image: preferences.secondRowSymbolRight, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.secondRowLoadingRight, linkPrefKey: Preferences.secondRowLinkRightKey)
//                    } else {
//                        Item(title: preferences.secondRowTitleLeft, subtitle: preferences.secondRowSubtitleLeft, linkType: preferences.secondRowTypeLeft, link: preferences.secondRowLinkLeft, image: preferences.secondRowSymbolLeft, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.secondRowLoadingLeft, linkPrefKey: Preferences.secondRowLinkLeftKey, hoverEffectEnable: true, animate: true)
//                        Item(title: preferences.secondRowTitleRight, subtitle: preferences.secondRowSubtitleRight, linkType: preferences.secondRowTypeRight, link: preferences.secondRowLinkRight, image: preferences.secondRowSymbolRight, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), loading: preferences.secondRowLoadingRight, linkPrefKey: Preferences.secondRowLinkRightKey, hoverEffectEnable: true, animate: true)
//                    }
//                }
//                .padding(.horizontal, 10)
//            }
//        }
    }
}
