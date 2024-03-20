//
//  UptimeSubview.swift
//  Support
//
//  Created by Jordy Witteman on 17/03/2021.
//

import SwiftUI

struct UptimeSubview: View {
    
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
    
    // Enable hover effect and tap gesture when UptimeDaysLimit is configured
    var hoverEffectEnabled: Bool {
        if preferences.uptimeDaysLimit > 0 {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        
        if hoverEffectEnabled {
            InfoItem(title: NSLocalizedString("Last Reboot", comment: ""), subtitle: "\(computerinfo.uptimeRounded) \(computerinfo.uptimeText) " + NSLocalizedString("ago", comment: ""), image: "clock.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadgeBool: computerinfo.uptimeLimitReached, hoverEffectEnable: true)
                .onTapGesture {
                    if hoverEffectEnabled {
                        computerinfo.showUptimeAlert.toggle()
                    }
                }
        } else {
            InfoItem(title: NSLocalizedString("Last Reboot", comment: ""), subtitle: "\(computerinfo.uptimeRounded) \(computerinfo.uptimeText) " + NSLocalizedString("ago", comment: ""), image: "clock.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadgeBool: false, hoverEffectEnable: false)
        }
    }
}

struct UptimeSubview_Previews: PreviewProvider {
    static var previews: some View {
        UptimeSubview()
    }
}
