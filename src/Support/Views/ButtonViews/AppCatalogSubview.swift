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
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Boolean to show AppUpdatesView as popover
    @State var showAppCatalogPopover: Bool = false
    
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
        
        InfoItem(title: NSLocalizedString("APPS", comment: ""), subtitle: updatesString, image: "arrow.down.app.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: appCatalogController.appUpdates, notificationBadgeBool: appCatalogController.catalogInstalled() ? false : true, loading: appCatalogController.appsUpdating.isEmpty ? false : true, hoverEffectEnable: true)
            .modify {
                if #available(macOS 13, *) {
                    $0.onTapGesture {
                        self.appCatalogController.showAppUpdates.toggle()
                    }
                } else {
                    $0.onTapGesture {
                        showAppCatalogPopover.toggle()
                    }
                }
            }
        // Legacy popover for macOS 12
            .popover(isPresented: $showAppCatalogPopover, arrowEdge: .leading) {
                AppUpdatesView()
            }
    }
    
}

//#Preview {
//    AppCatalogSubview()
//}
