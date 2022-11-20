//
//  MacOSVersionSubview.swift
//  Support
//
//  Created by Jordy Witteman on 17/03/2021.
//

import SwiftUI

struct MacOSVersionSubview: View {
    
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
    
    // Calculate remaining deferrals
    var deferralsRemaining: Int? {
        
        var remaining: Int?
        
        if let maximumManagedDoItLaterDeferralCount = computerinfo.maximumManagedDoItLaterDeferralCount, let managedDoItLaterDeferralCount = computerinfo.managedDoItLaterDeferralCount {
            
            let remainingNumber = maximumManagedDoItLaterDeferralCount - managedDoItLaterDeferralCount
            
            if remainingNumber >= 0 {
                remaining = remainingNumber
            }
        }
        return remaining
    }
    
    var body: some View {
        
        if computerinfo.systemVersionPatch == 0 {
            Item(title: "macOS \(computerinfo.macOSVersionName)", subtitle: "\(computerinfo.systemVersionMajor).\(computerinfo.systemVersionMinor)", linkType: "URL", link: "x-apple.systempreferences:com.apple.preferences.softwareupdate", image: "applelogo", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: computerinfo.updatesAvailable, deferralsRemaining: deferralsRemaining, hoverEffectEnable: true, animate: false)
        } else {
            Item(title: "macOS \(computerinfo.macOSVersionName)", subtitle: "\(computerinfo.systemVersionMajor).\(computerinfo.systemVersionMinor).\(computerinfo.systemVersionPatch)", linkType: "URL", link: "x-apple.systempreferences:com.apple.preferences.softwareupdate", image: "applelogo", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: computerinfo.updatesAvailable, deferralsRemaining: deferralsRemaining, hoverEffectEnable: true, animate: false)
        }
        
    }
}

struct MacOSVersionSubview_Previews: PreviewProvider {
    static var previews: some View {
        MacOSVersionSubview()
    }
}
