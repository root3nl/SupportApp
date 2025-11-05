//
//  UptimeAlertView.swift
//  Support
//
//  Created by Jordy Witteman on 15/03/2024.
//

import SwiftUI

struct UptimeAlertView: View {
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var localPreferences: LocalPreferences
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    @State private var restarting: Bool = false
    
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
    
    // Set different alert text when UptimeDaysLimit is set to 1
    var alertText: String {
        if preferences.uptimeDaysLimit > 1 {
           return NSLocalizedString("ADMIN_RECOMMENDS_RESTARTING_EVERY", comment: "") + " \(preferences.uptimeDaysLimit)" + NSLocalizedString(" days", comment: "")
        } else {
            return NSLocalizedString("ADMIN_RECOMMENDS_RESTARTING_EVERY_DAY", comment: "")
        }
    }
    
    var body: some View {
        
        Group {
            
            HStack {
                
                Button(action: {
                    computerinfo.showUptimeAlert.toggle()
                }) {
                    BackButton()
                }
                .modify {
                    if #available(macOS 26, *) {
                        $0
                            .buttonStyle(.glass)
                            .buttonBorderShape(.circle)
                    } else {
                        $0
                            .buttonStyle(.plain)
                    }
                }
                
                Text(NSLocalizedString("Last Reboot", comment: ""))
                    .font(.system(.headline, design: .rounded))
                
                Spacer()
                
            }
            
            Divider()
                .padding(2)
            
            VStack(alignment: .center, spacing: 20) {
                
                Image(systemName: computerinfo.uptimeLimitReached ? "clock.badge.exclamationmark.fill" : "clock.badge.checkmark.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.primary, computerinfo.uptimeLimitReached ? .orange : color)
                
                Text(computerinfo.uptimeLimitReached ? NSLocalizedString("RESTART_NOW", comment: "") : NSLocalizedString("RESTART_REGULARLY", comment: ""))
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(alertText)
                // Set frame to 250 to allow multiline text
                    .frame(width: 250)
                    .font(.system(.title3, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                                    
                if restarting  {
                    
                    ProgressView()
                        .frame(height: 20)
                    
                } else {
                    
                    Button(action: {
                        restarting = true
                        restartMac()
                    }) {
                        Text(NSLocalizedString("RESTART", comment: ""))
//                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .modify {
                        if #available(macOS 26, *) {
                            $0
                                .buttonStyle(.glassProminent)
                        } else {
                            $0
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .tint(color)
                    .buttonBorderShape(.capsule)
                    .controlSize(.extraLarge)
                }
                                    
            }
            .padding(.vertical, 40)
            
        }
        .padding(.horizontal)
        .unredacted()
    }
    
    // MARK: - Function to restart Mac gracefully using AppleScript
    func restartMac() {
        let restartScript = """
        tell application "System Events"
            restart
        end tell
        """
        
        var error: NSDictionary?
        
        DispatchQueue.global().async {
            if let scriptObject = NSAppleScript(source: restartScript) {
                scriptObject.executeAndReturnError(&error)
                if let error = error {
                    computerinfo.logger.error("Error while restarting Mac: \(error)")
                }
            }
        }
    }
}

//#Preview {
//    UptimeAlertView()
//}
