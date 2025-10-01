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
    @Published var logo: String = ""
    @Published var logoDarkMode: String = ""
    @Published var notificationIcon: String = ""
    @Published var statusBarIcon: String = ""
    @Published var statusBarIconAllowsColor: Bool = false
    @Published var statusBarIconSFSymbol: String = ""
    @Published var statusBarIconNotifierEnabled: Bool = false
    @Published var updateText: String = ""
    @Published var customColor: String = ""
    @Published var customColorDarkMode: String = ""
    @Published var errorMessage: String = ""
    @Published var showWelcomeScreen: Bool = false
    @Published var footerText: String = ""
    @Published var openAtLogin: Bool = false
    @Published var disablePrivilegedHelperTool: Bool = false
    @Published var disableConfiguratorMode: Bool = false
    @Published var uptimeDaysLimit: Int = 0
    @Published var passwordType: String = ""
    @Published var passwordExpiryLimit: Int = 0
    @Published var passwordLabel: String = ""
    @Published var storageLimit: Double = 0
    
    // Rows from local configuration
    @Published var rows: [Row] = []
    
    // Current item in configuration view
    @Published var currentConfiguredItem: ConfiguredItem?
    
}

protocol PreferencesProtocol {
    var title: String { get }
    var logo: String { get }
    var logoDarkMode: String { get }
    var notificationIcon: String { get }
    var statusBarIcon: String { get }
    var statusBarIconAllowsColor: Bool { get }
    var statusBarIconSFSymbol: String { get }
    var statusBarIconNotifierEnabled: Bool { get }
    var updateText: String { get }
    var customColor: String { get }
    var customColorDarkMode: String { get }
    var errorMessage: String { get }
    var showWelcomeScreen: Bool { get }
    var footerText: String { get }
    var openAtLogin: Bool { get }
    var disablePrivilegedHelperTool: Bool { get }
    var disableConfiguratorMode: Bool { get }
    var uptimeDaysLimit: Int { get }
    var passwordType: String { get }
    var passwordExpiryLimit: Int { get }
    var passwordLabel: String { get }
    var storageLimit: Double { get }
}

extension Preferences: PreferencesProtocol {}
extension LocalPreferences: PreferencesProtocol {}

