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
    
    // Boolean to show UpdateView as popover
    @State var showUpdatePopover: Bool = false
    
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
    
    // Calculate number of updates to show
    var updatesAvailable: Int {
        if preferences.hideMajorUpdates {
            return computerinfo.updatesAvailable - computerinfo.majorVersionUpdates
        } else {
            return computerinfo.updatesAvailable
        }
    }
    
    var body: some View {
        
        Group {
            if computerinfo.systemVersionPatch == 0 {
                InfoItem(title: "macOS \(computerinfo.macOSVersionName)", subtitle: "\(computerinfo.systemVersionMajor).\(computerinfo.systemVersionMinor)" + " \(computerinfo.rapidSecurityResponseVersion)", image: "applelogo", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: updatesAvailable, hoverEffectEnable: true)
            } else {
                InfoItem(title: "macOS \(computerinfo.macOSVersionName)", subtitle: "\(computerinfo.systemVersionMajor).\(computerinfo.systemVersionMinor).\(computerinfo.systemVersionPatch)" + " \(computerinfo.rapidSecurityResponseVersion)", image: "applelogo", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: updatesAvailable, hoverEffectEnable: true)
            }
        }
        .onTapGesture {
            self.showUpdatePopover.toggle()
        }
        .popover(isPresented: $showUpdatePopover, arrowEdge: .leading) {
            UpdateView(updateCounter: updatesAvailable)
        }
    }
}

struct MacOSVersionSubview_Previews: PreviewProvider {
    static var previews: some View {
        MacOSVersionSubview()
    }
}
