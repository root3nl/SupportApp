//
//  StorageSubview.swift
//  Support
//
//  Created by Jordy Witteman on 17/03/2021.
//

import SwiftUI

struct StorageSubview: View {
    
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
        
        ProgressBarItem(percentageUsed: "\(computerinfo.capacityPercentageRounded)% " + NSLocalizedString("Used", comment: ""), storageAvailable: "\(computerinfo.capacityRounded) " + NSLocalizedString("Available", comment: ""), image: "internaldrive.fill", symbolColor: color, notificationBadgeBool: computerinfo.storageLimitReached, percentage: computerinfo.capacityPercentage, hoverEffectEnable: true)
            .accessibilityValue(NSLocalizedString("STORAGE", comment: ""))
    }
}

struct StorageSubview_Previews: PreviewProvider {
    static var previews: some View {
        StorageSubview()
    }
}
