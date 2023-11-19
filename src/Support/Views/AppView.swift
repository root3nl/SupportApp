//
//  AppView.swift
//  Support
//
//  Created by Jordy Witteman on 17/05/2021.
//

import SwiftUI

struct AppView: View {
    
    @EnvironmentObject var computerinfo: ComputerInfo
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var appCatalogController: AppCatalogController

    var body: some View {
        
        if preferences.showWelcomeScreen && !preferences.hasSeenWelcomeScreen {
            WelcomeView()
        } else {
            if appCatalogController.showAppUpdates {
                AppUpdatesView(updateCounter: computerinfo.appUpdates)
            } else {
                ContentView()
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
