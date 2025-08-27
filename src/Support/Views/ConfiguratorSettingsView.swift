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
            
            BrandingSettingsView()
                .tabItem {
                    Label("Branding", systemImage: "photo.on.rectangle")
                }
                .tag(1)
            
            
            InfoItemSettingsView()
                .tabItem {
                    Label("Info items", systemImage: "info.circle")
                }
                .tag(2)
            
            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
                .tag(3)
        }
        .scenePadding()
//        .frame(maxWidth: 350, minHeight: 100)
        .frame(width: 400)
    }
}

struct GeneralSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        Form {
                TextField("Title", text: $localPreferences.title)
                TextField("Footer text", text: $localPreferences.footerText)
                TextField("Error message", text: $localPreferences.errorMessage)
                Toggle("Welcome screen", isOn: $localPreferences.showWelcomeScreen)
            
                Toggle("Menu Bar notifier", isOn: $localPreferences.statusBarIconNotifierEnabled)
            
                TextField("Update text", text: $localPreferences.updateText)
        }
        .disabled(!preferences.editModeEnabled)
    }
}

struct BrandingSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        Form {
            TextField("Logo", text: $localPreferences.logo)
            TextField("Logo dark mode", text: $localPreferences.logoDarkMode)
            TextField("Notification icon", text: $localPreferences.notificationIcon)
            TextField("Status Bar icon", text: $localPreferences.statusBarIcon)
            TextField("Status Bar icon (SF Symbol)", text: $localPreferences.statusBarIconSFSymbol)
            TextField("Custom color", text: $localPreferences.customColor)
            TextField("Custom dark mode", text: $localPreferences.customColorDarkMode)
        }
        .disabled(!preferences.editModeEnabled)
    }
}

struct InfoItemSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        Form {
            TextField("Uptime days limit", value: $localPreferences.uptimeDaysLimit, format: .number)
            
            Picker("Password type", selection: $localPreferences.passwordType) {
                Text("Apple").tag("Apple")
                Text("Jamf Connect").tag("JamfConnect")
                Text("Kerberos SSO").tag("KerberosSSO")
                Text("Nomad").tag("Nomad")
            }
            TextField("Password expiry limit", value: $localPreferences.passwordExpiryLimit, format: .number)
            TextField("Password label", text: $localPreferences.passwordLabel)
            
            Slider(value: $localPreferences.storageLimit, in: 0...100, step: 5) {
                Text("Storage limit")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            }
            Text("\(Int(localPreferences.storageLimit))%")
        }
        .disabled(!preferences.editModeEnabled)
    }
}

struct AdvancedSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        Form {
            Toggle("Open at login (non-PKG version)", isOn: $localPreferences.openAtLogin)
            Toggle("Disable Privileged Helper Tool", isOn: $localPreferences.disablePrivilegedHelperTool)
        }
        .disabled(!preferences.editModeEnabled)
    }
}

#Preview {
    ConfiguratorSettingsView()
}
