//
//  ExtensionASubview.swift
//  Support
//
//  Created by Jordy Witteman on 13/11/2021.
//

import SwiftUI

struct ExtensionASubview: View {
        
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
        
        Item(title: preferences.extensionTitleA, subtitle: preferences.extensionValueA, linkType: preferences.extensionTypeA, link: preferences.extensionLinkA, image: preferences.extensionSymbolA, symbolColor: color, notificationBadgeBool: preferences.extensionAlertA, loading: preferences.extensionLoadingA, linkPrefKey: Preferences.extensionLinkAKey, hoverEffectEnable: true, hoverView: false, animate: false)
    }
}
