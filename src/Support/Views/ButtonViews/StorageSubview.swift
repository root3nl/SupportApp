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
    
    var body: some View {
        
        ProgressBarItem(percentageUsed: "\(computerinfo.capacityPercentageRounded)% " + NSLocalizedString("Used", comment: ""), storageAvailable: "\(computerinfo.capacityRounded) " + NSLocalizedString("Available", comment: ""), image: "internaldrive.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadgeBool: computerinfo.storageLimitReached, percentage: computerinfo.capacityPercentage, hoverEffectEnable: true)
            .accessibilityValue(NSLocalizedString("STORAGE", comment: ""))
    }
}

struct StorageSubview_Previews: PreviewProvider {
    static var previews: some View {
        StorageSubview()
    }
}
