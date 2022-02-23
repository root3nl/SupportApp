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
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // FIXME: - Remove when Jamf Connect Password Change can be triggered
    // https://docs.jamf.com/jamf-connect/2.9.1/documentation/Jamf_Connect_URL_Scheme.html#ID-00005c31
    // Set preference suite to "com.jamf.connect.state"
    let defaultsJamfConnect = UserDefaults(suiteName: "com.jamf.connect.state")
    
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
    
    // FIXME: - Remove when Jamf Connect Password Change can be triggered
    // https://docs.jamf.com/jamf-connect/2.9.1/documentation/Jamf_Connect_URL_Scheme.html#ID-00005c31
    var linkType: String {
        if defaultsJamfConnect?.bool(forKey: "PasswordCurrent") ?? false && preferences.passwordType == "JamfConnect" {
            return "JamfConnectPasswordChangeException"
        } else {
            return "Command"
        }
    }
        
    var body: some View {

//        Item(title: "Mac " + NSLocalizedString("Password", comment: ""), subtitle: userinfo.userPasswordExpiryString, linkType: "Command", link: "open /System/Library/PreferencePanes/Accounts.prefPane", image: "key.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadgeBool: userinfo.passwordExpiryLimitReached, hoverEffectEnable: true, animate: false)
        
        // Option to show another subtitle offering to change the local Mac password
        
        ItemDouble(title: preferences.passwordLabel, secondTitle: preferences.passwordLabel, subtitle: userinfo.userPasswordExpiryString, secondSubtitle: userinfo.passwordChangeString, linkType: linkType, link: userinfo.passwordChangeLink, image: "key.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadgeBool: userinfo.passwordExpiryLimitReached, hoverEffectEnable: true)
        
        // Expirimental view with link to password change view
        
//        InfoItem(title: "Mac " + NSLocalizedString("Password", comment: ""), subtitle: userinfo.passwordString, image: "key.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: userinfo.passwordExpiryLimitReached, hoverEffectEnable: true)
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
