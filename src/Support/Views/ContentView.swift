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
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
        
    // Simple property wrapper boolean to visualize data loading when app opens
    @State var placeholdersEnabled = true
    
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
        
    var body: some View {
        
        // MARK: - ZStack with blur effect
        ZStack {
            EffectsView(material: NSVisualEffectView.Material.fullScreenUI, blendingMode: NSVisualEffectView.BlendingMode.behindWindow)

            // We need to provide Quit option for Apple App Review approval
            if !preferences.hideQuit {
                QuitButton()
            }
            
//            HStack {
//                Spacer()
//
//                VStack {
//                    Spacer()
//                    Image(systemName: "ellipsis.circle.fill")
//                        .imageScale(.large)
//                }
//            }
//            .padding(8)
            
            VStack(spacing: 10) {
                
                // MARK: - Horizontal stack with Title and Logo
                HStack(spacing: 10) {
                    
                    Text(preferences.title).font(.system(size: 20, design: .rounded)).fontWeight(.medium)

                    Spacer()
                    
                    // Logo shown in the top right corner
                    if colorScheme == .light && defaults.string(forKey: "Logo") != nil {
                        Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "Logo")!) ?? NSImage(named: "DefaultLogo"))!)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 48)
                    // Show different logo in Dark Mode when LogoDarkMode is also set
                    } else if colorScheme == .dark && defaults.string(forKey: "Logo") != nil {
                        if defaults.string(forKey: "LogoDarkMode") != nil {
                            Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "LogoDarkMode")!) ?? NSImage(named: "DefaultLogo"))!)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                        } else if defaults.string(forKey: "Logo") != nil && defaults.string(forKey: "LogoDarkMode") == nil {
                            Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "Logo")!) ?? NSImage(named: "DefaultLogo"))!)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                        } else {
                            Image("DefaultLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                        }
                    // Show default logo in all other cases
                    } else {
                        Image("DefaultLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                    }
                    
                }
                .foregroundColor(Color.primary)
                .padding(.leading, 16.0)
                .padding(.trailing, 10.0)
                .padding(.top, 10.0)
                .unredacted()
                
                // MARK: - First horizontal stack with Computer Name and macOS version as defaults
                HStack(spacing: 10) {
                    
                    // Item left
                    switch preferences.infoItemOne {
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
                    default:
                        ComputerNameSubview()
                    }
                    
                    // Item right
                    switch preferences.infoItemTwo {
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
                    default:
                        MacOSVersionSubview()
                    }
                    
                }
                .padding(.horizontal, 10)
                
                // MARK: - Second horizontal stack with Uptime and StorageView as defaults
                HStack(spacing: 10) {
                    
                    // Item left
                    switch preferences.infoItemThree {
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
                    default:
                        UptimeSubview()
                    }
                    
                    // Item right
                    switch preferences.infoItemFour {
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
                    default:
                        StorageSubview()
                    }
                }
                .padding(.horizontal, 10)
                   
                // MARK: - Hide row if specified in configuration
                if !defaults.bool(forKey: "HideFirstRow") {

                    // MARK: - Horizontal stack with 2 or 3 configurable action buttons
                    HStack(spacing: 10) {
                        
                        if preferences.firstRowTitleMiddle != "" {
                            ItemSmall(title: preferences.firstRowTitleLeft, subtitle: preferences.firstRowSubtitleLeft, linkType: preferences.firstRowTypeLeft, link: preferences.firstRowLinkLeft, image: preferences.firstRowSymbolLeft, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                            ItemSmall(title: preferences.firstRowTitleMiddle, subtitle: preferences.firstRowSubtitleMiddle, linkType: preferences.firstRowTypeMiddle, link: preferences.firstRowLinkMiddle, image: preferences.firstRowSymbolMiddle, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                            ItemSmall(title: preferences.firstRowTitleRight, subtitle: preferences.firstRowSubtitleRight, linkType: preferences.firstRowTypeRight, link: preferences.firstRowLinkRight, image: preferences.firstRowSymbolRight, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                        } else {
                            Item(title: preferences.firstRowTitleLeft, subtitle: preferences.firstRowSubtitleLeft, linkType: preferences.firstRowTypeLeft, link: preferences.firstRowLinkLeft, image: preferences.firstRowSymbolLeft, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                            Item(title: preferences.firstRowTitleRight, subtitle: preferences.firstRowSubtitleRight, linkType: preferences.firstRowTypeRight, link: preferences.firstRowLinkRight, image: preferences.firstRowSymbolRight, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
                // MARK: - Hide row if specified in configuration
                if !defaults.bool(forKey: "HideSecondRow") {
                
                    // MARK: - Horizontal stack with 2 or 3 configurable action buttons
                    HStack(spacing: 10) {
                        
                        if preferences.secondRowTitleMiddle != "" {
                            ItemSmall(title: preferences.secondRowTitleLeft, subtitle: preferences.secondRowSubtitleLeft, linkType: preferences.secondRowTypeLeft, link: preferences.secondRowLinkLeft, image: preferences.secondRowSymbolLeft, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                            ItemSmall(title: preferences.secondRowTitleMiddle, subtitle: preferences.secondRowSubtitleMiddle, linkType: preferences.secondRowTypeMiddle, link: preferences.secondRowLinkMiddle, image: preferences.secondRowSymbolMiddle, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                            ItemSmall(title: preferences.secondRowTitleRight, subtitle: preferences.secondRowSubtitleRight, linkType: preferences.secondRowTypeRight, link: preferences.secondRowLinkRight, image: preferences.secondRowSymbolRight, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                        } else {
                            Item(title: preferences.secondRowTitleLeft, subtitle: preferences.secondRowSubtitleLeft, linkType: preferences.secondRowTypeLeft, link: preferences.secondRowLinkLeft, image: preferences.secondRowSymbolLeft, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                            Item(title: preferences.secondRowTitleRight, subtitle: preferences.secondRowSubtitleRight, linkType: preferences.secondRowTypeRight, link: preferences.secondRowLinkRight, image: preferences.secondRowSymbolRight, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true, animate: true)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
                // MARK: - Footnote
                if preferences.footerText != "" {
                    HStack {
                        
                        if #available(macOS 12, *) {
                            Text((try? AttributedString(markdown: preferences.footerText)) ?? AttributedString())
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                        } else {
                            // Fallback on earlier versions
                            Text(preferences.footerText)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal, 10)
                    // Workaround to support multiple lines
                    .frame(minWidth: 382, idealWidth: 382, maxWidth: 382)
                    .fixedSize()
                }
            }
            .padding(.bottom, 10)
        }
        // MARK: - Run functions the ContentView appears for the first time
        .onAppear {
            computerinfo.getModelIdentifier()
            computerinfo.getModelName()
            computerinfo.getmacOSVersionName()
            dataLoadingEffect()
        }
        .redacted(reason: placeholdersEnabled ? .placeholder : .init())
    }
    
    // MARK: - Start app with placeholders and show data after 0.4 seconds to visualize data loading.
    func dataLoadingEffect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            placeholdersEnabled = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
