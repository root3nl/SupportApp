//
//  SupportApp.swift
//  Support
//
//  Created by Jordy Witteman on 01/08/2025.
//

import SwiftUI

@main
struct SupportApp: App {
    
    // App Delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            ConfiguratorSettingsView()
                .environmentObject(appDelegate.localPreferences)
                .environmentObject(appDelegate.preferences)
        }
    }
}
