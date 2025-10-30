//
//  MacOSVersionSubview.swift
//  Support
//
//  Created by Jordy Witteman on 17/03/2021.
//

import SwiftUI

struct MacOSVersionSubview: View {
    
    var configurationItem: ConfiguredItem?
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var localPreferences: LocalPreferences

    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Boolean to show UpdateViewLegacy as popover
    @State var showUpdatePopover: Bool = false
    
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
        
        InfoItem(title: "macOS \(computerinfo.macOSVersionName)", subtitle: computerinfo.macOSVersion, image: "applelogo", symbolColor: color, notificationBadge: computerinfo.recommendedUpdates.count, configurationItem: configurationItem, hoverEffectEnable: true)
            .onTapGesture {
                if preferences.editModeEnabled {
                    guard let configurationItem else {
                        return
                    }
                    localPreferences.currentConfiguredItem = configurationItem
                    preferences.showItemConfiguration.toggle()
                } else {
                    computerinfo.showMacosUpdates.toggle()
                }
            }
    }
}

struct MacOSVersionSubview_Previews: PreviewProvider {
    static var previews: some View {
        MacOSVersionSubview()
    }
}
