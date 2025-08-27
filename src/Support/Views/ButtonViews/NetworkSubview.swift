//
//  NetworkSubview.swift
//  Support
//
//  Created by Jordy Witteman on 17/03/2021.
//

import SwiftUI

struct NetworkSubview: View {
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
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
    
    // Link Network Preference Pane
    var networkLink: String {
        if #available(macOS 13, *) {
            return "x-apple.systempreferences:com.apple.Network-Settings.extension"
        } else {
            return "open /System/Library/PreferencePanes/Network.prefPane"
        }
    }
    
    // Link type for Network Preference Pane
    var networkLinkType: String {
        if #available(macOS 13, *) {
            return "URL"
        } else {
            return "Command"
        }
    }
    
    var body: some View {
        
        Item(title: computerinfo.networkName, subtitle: computerinfo.ipAddress, linkType: networkLinkType, link: networkLink, image: computerinfo.networkInterfaceSymbol, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadgeBool: computerinfo.selfSignedIP, hoverEffectEnable: true, hoverView: false, animate: false)
    }
}

struct NetworkSubview_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSubview()
    }
}
