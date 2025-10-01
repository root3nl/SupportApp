//
//  UptimeSubview.swift
//  Support
//
//  Created by Jordy Witteman on 17/03/2021.
//

import SwiftUI

struct UptimeSubview: View {
    
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
    
    // Boolean to show legacy uptime alert when clicked
    @State var uptimeAlert: Bool = false
    
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
    
    // Enable hover effect and tap gesture when UptimeDaysLimit is configured
    var hoverEffectEnabled: Bool {
        if preferences.uptimeDaysLimit > 0 {
            return true
        } else {
            return false
        }
    }
    
    // Set different legacy alert text when UptimeDaysLimit is set to 1
    var alertText: String {
        if preferences.uptimeDaysLimit > 1 {
           return NSLocalizedString("ADMIN_RECOMMENDS_RESTARTING_EVERY", comment: "") + " \(preferences.uptimeDaysLimit)" + NSLocalizedString(" days", comment: "")
        } else {
            return NSLocalizedString("ADMIN_RECOMMENDS_RESTARTING_EVERY_DAY", comment: "")
        }
    }
    
    var body: some View {
        
        if hoverEffectEnabled {
            InfoItem(title: NSLocalizedString("Last Reboot", comment: ""), subtitle: "\(computerinfo.uptimeRounded) \(computerinfo.uptimeText) " + NSLocalizedString("ago", comment: ""), image: "clock.fill", symbolColor: color, notificationBadgeBool: computerinfo.uptimeLimitReached, configurationItem: configurationItem, hoverEffectEnable: true)
                .onTapGesture {
                    if preferences.editModeEnabled {
                        guard let configurationItem else {
                            return
                        }
                        localPreferences.currentConfiguredItem = configurationItem
                        preferences.showItemConfiguration.toggle()
                    } else {
                        computerinfo.showUptimeAlert.toggle()
                    }
                }
        } else {
            InfoItem(title: NSLocalizedString("Last Reboot", comment: ""), subtitle: "\(computerinfo.uptimeRounded) \(computerinfo.uptimeText) " + NSLocalizedString("ago", comment: ""), image: "clock.fill", symbolColor: color, notificationBadgeBool: false, hoverEffectEnable: false)
                .onTapGesture {
                    if preferences.editModeEnabled {
                        guard let configurationItem else {
                            return
                        }
                        localPreferences.currentConfiguredItem = configurationItem
                        preferences.showItemConfiguration.toggle()
                    }
                }
        }
    }
}

struct UptimeSubview_Previews: PreviewProvider {
    static var previews: some View {
        UptimeSubview()
    }
}
