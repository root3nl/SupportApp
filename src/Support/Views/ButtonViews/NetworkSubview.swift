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
    @EnvironmentObject var localPreferences: LocalPreferences

    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
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
    
    var body: some View {
        
        Item(title: computerinfo.networkName, subtitle: computerinfo.ipAddress, linkType: "URL", link: "x-apple.systempreferences:com.apple.Network-Settings.extension", image: computerinfo.networkInterfaceSymbol, symbolColor: color, notificationBadgeBool: computerinfo.selfSignedIP, hoverEffectEnable: true, hoverView: false, animate: false)
            .accessibilityValue(NSLocalizedString("NETWORK_IP_ADDRESS", comment: ""))
            .accessibilityLabel(computerinfo.ipAddress)
    }
}

struct NetworkSubview_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSubview()
    }
}
