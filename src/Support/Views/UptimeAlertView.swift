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
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
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
    
    // Set different alert text when UptimeDaysLimit is set to 1
    var alertText: String {
        if preferences.uptimeDaysLimit > 1 {
           return NSLocalizedString("ADMIN_RECOMMENDS_RESTARTING_EVERY", comment: "") + " \(preferences.uptimeDaysLimit)" + NSLocalizedString(" days", comment: "")
        } else {
            return NSLocalizedString("ADMIN_RECOMMENDS_RESTARTING_EVERY", comment: "") + NSLocalizedString(" day", comment: "")
        }
    }
    
    var body: some View {
        
        Group {
            
            HStack {
                
                Button(action: {
                    computerinfo.showUptimeAlert.toggle()
                }) {
                    Ellipse()
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                        .overlay(
                            Image(systemName: "chevron.backward")
                        )
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                
                Text(NSLocalizedString("Last Reboot", comment: ""))
                    .font(.system(.headline, design: .rounded))
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text(NSLocalizedString("RESTART", comment: ""))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.regular)
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .background(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
            }
            
            Divider()
                .padding(2)
            
            VStack(alignment: .center, spacing: 20) {
                
                Image(systemName: computerinfo.uptimeLimitReached ? "clock.badge.exclamationmark.fill" : "clock.badge.checkmark.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.primary, computerinfo.uptimeLimitReached ? .orange : Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                
                Text(computerinfo.uptimeLimitReached ? NSLocalizedString("RESTART_NOW", comment: "") : NSLocalizedString("RESTART_REGULARLY", comment: ""))
                // Set frame to 250 to allow multiline text
//                    .frame(width: 250)
//                    .fixedSize()
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.medium)

                Text(alertText)
                // Set frame to 250 to allow multiline text
                    .frame(width: 300)
                    .fixedSize()
                    .font(.system(.title2, design: .rounded))
                    .foregroundStyle(.secondary)
                
            }
            .padding(.vertical, 40)
            
        }
        .padding(.horizontal)
        .unredacted()
    }
}

#Preview {
    UptimeAlertView()
}
