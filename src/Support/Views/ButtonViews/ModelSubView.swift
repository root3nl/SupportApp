//
//  ModelSubView.swift
//  Support
//
//  Created by Jordy Witteman on 29/04/2021.
//

import SwiftUI

struct ModelSubView: View {
    
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
        
        Item(title: "Model", subtitle: "\(computerinfo.modelShortName) \(computerinfo.modelYear)", linkType: "App", link: "com.apple.AboutThisMacLauncher", image: computerinfo.computerNameIcon, symbolColor: color, configurationItem: configurationItem, hoverEffectEnable: true, animate: false)
    }
    
}

struct ModelSubView_Previews: PreviewProvider {
    static var previews: some View {
        ModelSubView()
    }
}
