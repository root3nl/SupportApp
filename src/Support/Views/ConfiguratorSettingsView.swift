//
//  ConfiguratorSettingsView.swift
//  Support
//
//  Created by Jordy Witteman on 27/08/2025.
//

import SwiftUI

struct ConfiguratorSettingsView: View {
    
    @State var selectedTab: Int = 0
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(0)
            
            InfoItemSettingsView()
                .tabItem {
                    Label("Info items", systemImage: "info.circle")
                }
                .tag(1)
            
            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "hourglass")
                }
                .tag(2)
        }
        .scenePadding()
        .frame(maxWidth: 350, minHeight: 100)
    }
}

struct GeneralSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    
    var body: some View {
        Form {
            TextField("Title", text: $localPreferences.title)
        }
    }
}

struct InfoItemSettingsView: View {
    var body: some View {
        Text("Hello, world!")
    }
}

struct AdvancedSettingsView: View {
    var body: some View {
        Text("Hello, world!")
    }
}

#Preview {
    ConfiguratorSettingsView()
}
