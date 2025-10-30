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
        .frame(width: 500)
    }
}

struct GeneralSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        Form {
            TextField("Title", text: $localPreferences.title, prompt: Text("Example: IT Support"))
            TextField("Footer text", text: $localPreferences.footerText, prompt: Text("Example: Provided by your IT department with ❤️"))
            TextField("Error message", text: $localPreferences.errorMessage, prompt: Text("Example: Please contact IT support"))
            Toggle("Welcome screen", isOn: $localPreferences.showWelcomeScreen)
            Toggle("Menu Bar notifier", isOn: $localPreferences.statusBarIconNotifierEnabled)
        }
        .disabled(!preferences.editModeEnabled)
    }
}

struct BrandingSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        Form {
            TextField("Logo", text: $localPreferences.logo, prompt: Text("URL or file path to logo"))
            TextField("Logo dark mode", text: $localPreferences.logoDarkMode, prompt: Text("URL or file path to logo for dark mode"))
            TextField("Notification icon", text: $localPreferences.notificationIcon, prompt: Text("URL or file path to icon"))
            TextField("Status Bar icon", text: $localPreferences.statusBarIcon, prompt: Text("URL or file path to icon"))
            Toggle("Status Bar Icon Allows Color", isOn: $localPreferences.statusBarIconAllowsColor)
            TextField("Status Bar icon (SF Symbol)", text: $localPreferences.statusBarIconSFSymbol, prompt: Text("SF Symbol name"))
            TextField("Custom color", text: $localPreferences.customColor, prompt: Text("HEX color code"))
            TextField("Custom dark mode", text: $localPreferences.customColorDarkMode, prompt: Text("HEX color code"))
        }
        .disabled(!preferences.editModeEnabled)
    }
}

struct InfoItemSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        Form {
            TextField("Uptime days limit", value: $localPreferences.uptimeDaysLimit, format: .number, prompt: Text("Example: 14"))
            
            Picker("Password type", selection: $localPreferences.passwordType) {
                Text("Apple").tag("Apple")
                Text("Jamf Connect").tag("JamfConnect")
                Text("Kerberos SSO").tag("KerberosSSO")
                Text("Nomad").tag("Nomad")
            }
            TextField("Password expiry limit", value: $localPreferences.passwordExpiryLimit, format: .number, prompt: Text("Example: 14"))
            TextField("Password label", text: $localPreferences.passwordLabel, prompt: Text("Example: Company Password"))
            
            Slider(value: $localPreferences.storageLimit, in: 0...100, step: 5) {
                Text("Storage limit")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            }
            Text("\(Int(localPreferences.storageLimit))%")
            TextField("Update text", text: $localPreferences.updateText, prompt: Text("Example: Your organization requires you to update as soon as possible"))
        }
        .disabled(!preferences.editModeEnabled)
    }
}

struct AdvancedSettingsView: View {
    
    @EnvironmentObject var localPreferences: LocalPreferences
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var appDelegate: AppDelegate
        
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        Form {
            Toggle("Open at login (non-PKG version)", isOn: $localPreferences.openAtLogin)
            Toggle("Disable Privileged Helper Tool", isOn: $localPreferences.disablePrivilegedHelperTool)
            Toggle("Disable Configurator Mode", isOn: $localPreferences.disableConfiguratorMode)
            TextField("On appear action", text: $localPreferences.onAppearAction, prompt: Text("Path to script"))
            
            Divider()
            
            Section {
                Button {
                    showDeleteConfirmation.toggle()
                } label: {
                    Label("Remove preferences", systemImage: "trash.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .confirmationDialog("", isPresented: $showDeleteConfirmation) {
                    Button(role: .destructive) {
                        if let bundleID = Bundle.main.bundleIdentifier {
                            let defaults = UserDefaults.standard
                            
                            // Remove all preferences
                            defaults.removePersistentDomain(forName: bundleID)
                            
                            // Clear values in memory
                            preferences.rows = []
                            localPreferences.clear()
                        }
                        
                        // Disable configurator mode
                        appDelegate.configuratorMode()
                    } label: {
                        Text("Remove", comment: "")
                    }
                } message: {
                    Text("Are you sure you want to remove all preferences? Any managed preferences will be preserved.")
                }
            } footer: {
                HStack {
                    Text("Removes all app preferences including preferences set in Configurator Mode.")
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .disabled(!preferences.editModeEnabled)
    }
}

#Preview {
    ConfiguratorSettingsView()
}
