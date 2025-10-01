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
        
        VStack(alignment: .leading) {
            
            FeatureView(image: "stethoscope", title: NSLocalizedString("Mac diagnosis", comment: ""), subtitle: NSLocalizedString("MAC_DIAGNOSIS_TEXT", comment: ""), color: color)
            
            FeatureView(image: "briefcase", title: NSLocalizedString("Easy access", comment: ""), subtitle: NSLocalizedString("EASY_ACCESS_TEXT", comment: ""), color: color)
            
            FeatureView(image: "lifepreserver", title: NSLocalizedString("Get in touch", comment: ""), subtitle: NSLocalizedString("GET_IN_TOUCH_TEXT", comment: ""), color: color)
            
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
        .tint(color)
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
