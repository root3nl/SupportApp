//
//  AppCatalogSubview.swift
//  Support
//
//  Created by Jordy Witteman on 18/10/2023.
//

import SwiftUI

struct AppCatalogSubview: View {

    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get App Catalog information
    @EnvironmentObject var appCatalogController: AppCatalogController
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var localPreferences: LocalPreferences

    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Boolean to show AppUpdatesView as popover
    @State var showAppCatalogPopover: Bool = false
    
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
    
    var updatesString: String {
        if !appCatalogController.catalogInstalled() {
            return NSLocalizedString("APP_CATALOG_NOT_CONFIGURED", comment: "")
        } else {
            if appCatalogController.appUpdates > 0 {
                return NSLocalizedString("UPDATES_AVAILABLE", comment: "")
            } else {
                return NSLocalizedString("UP_TO_DATE", comment: "")
            }
        }
    }
    
    var body: some View {
        
        InfoItem(title: NSLocalizedString("APPS", comment: ""), subtitle: updatesString, image: "arrow.down.app.fill", symbolColor: color, notificationBadge: appCatalogController.appUpdates, notificationBadgeBool: appCatalogController.catalogInstalled() ? false : true, loading: appCatalogController.appsUpdating.isEmpty ? false : true, hoverEffectEnable: true)
            .onTapGesture {
                self.appCatalogController.showAppUpdates.toggle()
            }
    }
    
}

//#Preview {
//    AppCatalogSubview()
//}
