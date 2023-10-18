//
//  AppCatalogSubview.swift
//  Support
//
//  Created by Jordy Witteman on 18/10/2023.
//

import SwiftUI

struct AppCatalogSubview: View {

    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
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
    
    var updatesString: String {
        if computerinfo.appUpdates > 0 {
            return "Updates available"
        } else {
            return "No updates available"
        }
    }
    
    var body: some View {
        
        InfoItem(title: "App Updates", subtitle: updatesString, image: "app.badge.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: computerinfo.appUpdates, hoverEffectEnable: true)

    }
    
}

#Preview {
    AppCatalogSubview()
}
