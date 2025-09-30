//
//  PasswordSubview.swift
//  Support
//
//  Created by Jordy Witteman on 16/05/2021.
//

import SwiftUI

struct PasswordSubview: View {
    
    // Get computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var localPreferences: LocalPreferences

    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // FIXME: - Remove when Jamf Connect Password Change can be triggered
    // https://docs.jamf.com/jamf-connect/2.9.1/documentation/Jamf_Connect_URL_Scheme.html#ID-00005c31
    // Set preference suite to "com.jamf.connect.state"
    let defaultsJamfConnect = UserDefaults(suiteName: "com.jamf.connect.state")
    
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
    
    // Link type for Password item
    var linkType: String {
        if preferences.passwordType == "Apple" {
            return "URL"
        } else if preferences.passwordType == "KerberosSSO"  {
            if userinfo.networkUnavailable {
                return "KerberosSSOExtensionUnavailable"
            } else {
                return "Command"
            }
        } else if preferences.passwordType == "Nomad" {
            return "Command"
        } else if preferences.passwordType == "JamfConnect" {
            // FIXME: - Remove when Jamf Connect Password Change can be triggered
            // https://docs.jamf.com/jamf-connect/2.9.1/documentation/Jamf_Connect_URL_Scheme.html#ID-00005c31
            if defaultsJamfConnect?.bool(forKey: "PasswordCurrent") ?? false {
                return "JamfConnectPasswordChangeException"
            } else {
                return "Command"
            }
        } else {
            return "URL"
        }
    }
    
    var passwordLabel: String {
        if !activePreferences.passwordLabel.isEmpty {
            return activePreferences.passwordLabel
        } else {
            return "Mac " + NSLocalizedString("Password", comment: "")
        }
    }
        
    var body: some View {

//        Item(title: "Mac " + NSLocalizedString("Password", comment: ""), subtitle: userinfo.userPasswordExpiryString, linkType: "Command", link: "open /System/Library/PreferencePanes/Accounts.prefPane", image: "key.fill", symbolColor: color, notificationBadgeBool: userinfo.passwordExpiryLimitReached, hoverEffectEnable: true, animate: false)
        
        // Option to show another subtitle offering to change the local Mac password
        
        ItemDouble(title: passwordLabel, secondTitle: passwordLabel, subtitle: userinfo.userPasswordExpiryString, secondSubtitle: userinfo.passwordChangeString, linkType: linkType, link: userinfo.passwordChangeLink, image: "key.fill", symbolColor: color, notificationBadgeBool: userinfo.passwordExpiryLimitReached, hoverEffectEnable: true)
        
        // Expirimental view with link to password change view
        
//        InfoItem(title: "Mac " + NSLocalizedString("Password", comment: ""), subtitle: userinfo.passwordString, image: "key.fill", symbolColor: color, notificationBadge: userinfo.passwordExpiryLimitReached, hoverEffectEnable: true)
//            .onTapGesture {
//                computerinfo.showPasswordChange.toggle()
//            }
        
    }
}

struct PasswordSubview_Previews: PreviewProvider {
    static var previews: some View {
        PasswordSubview()
    }
}
