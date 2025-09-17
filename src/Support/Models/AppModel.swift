//
//  AppModel.swift
//  Support
//
//  Created by Jordy Witteman on 25/08/2025.
//

import Foundation

struct AppModel: Codable, Hashable {
    
    var title: String?
    var logo: String?
    var logoDarkMode: String?
    var notificationIcon: String?
    var statusBarIcon: String?
    var statusBarIconAllowsColor: Bool?
    var statusBarIconSFSymbol: String?
    var statusBarIconNotifierEnabled: Bool?
    var updateText: String?
    var customColor: String?
    var customColorDarkMode: String?
    var errorMessage: String?
    var showWelcomeScreen: Bool?
    var footerText: String?
    var openAtLogin: Bool?
    var disablePrivilegedHelperTool: Bool?
    var disableConfiguratorMode: Bool?
    var uptimeDaysLimit: Int?
    var passwordType: String?
    var passwordExpiryLimit: Int?
    var passwordLabel: String?
    var storageLimit: Int?
    var rows: [Row]?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case logo = "Logo"
        case logoDarkMode = "LogoDarkMode"
        case notificationIcon = "NotificationIcon"
        case statusBarIcon = "StatusBarIcon"
        case statusBarIconAllowsColor = "StatusBarIconAllowsColor"
        case statusBarIconSFSymbol = "StatusBarIconSFSymbol"
        case statusBarIconNotifierEnabled = "StatusBarIconNotifierEnabled"
        case updateText = "UpdateText"
        case customColor = "CustomColor"
        case customColorDarkMode = "CustomColorDarkMode"
        case errorMessage = "ErrorMessage"
        case showWelcomeScreen = "ShowWelcomeScreen"
        case footerText = "FooterText"
        case openAtLogin = "OpenAtLogin"
        case disablePrivilegedHelperTool = "DisablePrivilegedHelperTool"
        case disableConfiguratorMode = "DisableConfiguratorMode"
        case uptimeDaysLimit = "UptimeDaysLimit"
        case passwordType = "PasswordType"
        case passwordExpiryLimit = "PasswordExpiryLimit"
        case passwordLabel = "PasswordLabel"
        case storageLimit = "StorageLimit"
        case rows = "Rows"
    }
}
