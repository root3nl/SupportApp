//
//  HeaderView.swift
//  Support
//
//  Created by Jordy Witteman on 11/07/2022.
//

import SwiftUI

struct HeaderView: View {
    
    // Get computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    
    // Get local preferences for Configurator Mode
    @EnvironmentObject var localPreferences: LocalPreferences
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Local preferences or (managed) UserDefaults
    var activePreferences: PreferencesProtocol {
        preferences.configuratorModeEnabled ? localPreferences : preferences
    }
    
    var body: some View {
        
        // MARK: - Horizontal stack with Title and Logo
        HStack(spacing: 10) {
            
            // Supports for markdown through a variable:
            Text(.init(activePreferences.title.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo)))
                .font(.system(size: 20, design: .rounded))
                .fontWeight(.medium)
                .fixedSize()

            Spacer()
            
            // Logo shown in the top right corner
            if colorScheme == .light && defaults.string(forKey: "Logo") != nil {
                LogoView(logo: defaults.string(forKey: "Logo")!)
            // Show different logo in Dark Mode when LogoDarkMode is also set
            } else if colorScheme == .dark && defaults.string(forKey: "Logo") != nil {
                if defaults.string(forKey: "LogoDarkMode") != nil {
                    LogoView(logo: defaults.string(forKey: "LogoDarkMode")!)
                } else if defaults.string(forKey: "Logo") != nil && defaults.string(forKey: "LogoDarkMode") == nil {
                    LogoView(logo: defaults.string(forKey: "Logo")!)
                } else {
                    LogoView(logo: "default")
                }
            // Show default logo in all other cases
            } else {
                LogoView(logo: "default")
            }
            
        }
        .foregroundColor(Color.primary)
        .padding(.leading, 16.0)
        .padding(.trailing, 10.0)
        .padding(.top, 10.0)
        .unredacted()
    }
}
