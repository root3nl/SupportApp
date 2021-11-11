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

//        Item(title: "Mac " + NSLocalizedString("Password", comment: ""), subtitle: userinfo.userPasswordExpiryString, linkType: "Command", link: "open /System/Library/PreferencePanes/Accounts.prefPane", image: "key.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadgeBool: userinfo.passwordExpiryLimitReached, hoverEffectEnable: true, animate: false)
        
        // Option to show another subtitle offering to change the local Mac password
        
        ItemDouble(title: preferences.passwordLabel, secondTitle: preferences.passwordLabel, subtitle: userinfo.passwordString, secondSubtitle: userinfo.passwordChangeString, linkType: "Command", link: userinfo.passwordChangeLink, image: "key.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadgeBool: userinfo.passwordExpiryLimitReached, hoverEffectEnable: true)
        
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
