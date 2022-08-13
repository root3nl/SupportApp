//
//  ComputerNameSubview.swift
//  Support
//
//  Created by Jordy Witteman on 17/03/2021.
//

import SwiftUI

struct ComputerNameSubview: View {
    
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
    
    // Link to About This Mac
    var aboutLink: String {
        if #available(macOS 13, *) {
            return "x-apple.systempreferences:com.apple.SystemProfiler.AboutExtension"
        } else {
            return "com.apple.AboutThisMacLauncher"
        }
    }
    
    // Link type for About This Mac
    var aboutLinkType: String {
        if #available(macOS 13, *) {
            return "URL"
        } else {
            return "App"
        }
    }
    
    var body: some View {
        
//        InfoItem(title: NSLocalizedString("Computer Name", comment: ""), subtitle: computerinfo.hostname, image: computerinfo.computerNameIcon, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: false)
        ItemDouble(title: NSLocalizedString("Computer Name", comment: ""), secondTitle: NSLocalizedString("Model", comment: ""), subtitle: computerinfo.hostname, secondSubtitle: computerinfo.modelNameString, linkType: aboutLinkType, link: aboutLink, image: computerinfo.computerNameIcon, symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), hoverEffectEnable: true)
        
    }
}

struct ComputerNameSubview_Previews: PreviewProvider {
    static var previews: some View {
        ComputerNameSubview()
    }
}
