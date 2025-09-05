//
//  WelcomeView.swift
//  Support
//
//  Created by Jordy Witteman on 23/06/2021.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var computerinfo: ComputerInfo
    @EnvironmentObject var userinfo: UserInfo
    
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
        
        VStack(alignment: .leading) {
            
            FeatureView(image: "stethoscope", title: NSLocalizedString("Mac diagnosis", comment: ""), subtitle: NSLocalizedString("MAC_DIAGNOSIS_TEXT", comment: ""), color: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
            
            FeatureView(image: "briefcase", title: NSLocalizedString("Easy access", comment: ""), subtitle: NSLocalizedString("EASY_ACCESS_TEXT", comment: ""), color: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
            
            FeatureView(image: "lifepreserver", title: NSLocalizedString("Get in touch", comment: ""), subtitle: NSLocalizedString("GET_IN_TOUCH_TEXT", comment: ""), color: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
            
        }
        
        Button {
            preferences.hasSeenWelcomeScreen.toggle()
        } label: {
            Text(NSLocalizedString("Continue", comment: ""))
                .fontWeight(.bold)
        }
        .modify {
            if #available(macOS 26, *) {
                $0
                    .buttonStyle(.glassProminent)
            } else {
                $0
                    .buttonStyle(.borderedProminent)
            }
        }
        .tint(Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
        .buttonBorderShape(.capsule)
        .controlSize(.extraLarge)
        .padding(.vertical)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
