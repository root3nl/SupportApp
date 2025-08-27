//
//  LocalPreferences.swift
//  Support
//
//  Created by Jordy Witteman on 26/08/2025.
//

import Foundation

class LocalPreferences: ObservableObject {
    
    // MARK: - All preferences used for local configuration
    
    @Published var title: String = ""
    @Published var logo: String?
    @Published var logoDarkMode: String?
    @Published var notificationIcon: String?
    @Published var statusBarIcon: String?
    @Published var statusBarIconSFSymbol: String?
    @Published var statusBarIconNotifierEnabled: Bool?
    @Published var updateText: String?
    @Published var customColor: String?
    @Published var customColorDarkMode: String?
    @Published var errorMessage: String?
    @Published var showWelcomeScreen: Bool?
    @Published var footerText: String?
    @Published var openAtLogin: Bool?
    @Published var disablePrivilegedHelperTool: Bool?
    @Published var uptimeDaysLimit: Int?
    @Published var passwordType: String?
    @Published var passwordExpiryLimit: Int?
    @Published var passwordLabel: String?
    @Published var storageLimit: String?
    
    // Rows from local configuration
    @Published var rows: [Row] = []
    
    // Current item in configuration view
    @Published var currentConfiguredItem: ConfiguredItem?
    
}

protocol PreferencesProtocol {
    var title: String { get }
    // add any shared properties you need
}

extension Preferences: PreferencesProtocol {}
extension LocalPreferences: PreferencesProtocol {}

