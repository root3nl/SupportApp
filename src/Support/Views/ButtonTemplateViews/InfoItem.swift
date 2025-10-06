//
//  InfoItem.swift
//  Support
//
//  Created by Jordy Witteman on 30/12/2020.
//

import SwiftUI

struct InfoItem: View {
    var title: String
    var subtitle: String
    var image: String
    var symbolColor: Color
    var notificationBadge: Int?
    var notificationBadgeBool: Bool?
    var loading: Bool?
    var configurationItem: ConfiguredItem?
    
    // Vars to activate hover effect
    @State var hoverEffectEnable: Bool
    @State var hoverView = false
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    
    // Get local preferences for Configurator Mode
//    @EnvironmentObject var localPreferences: LocalPreferences
    
    var body: some View {
        
        if #available(macOS 26, *) {
            ZStack {
                
                HStack {
                    if loading ?? false {
                        Ellipse()
                            .foregroundColor(.white.opacity(0.5))
                            .overlay(
                                ProgressView()
                                    .controlSize(.small)
                            )
                            .frame(width: 36, height: 36)
                            .padding(.leading, 14)
                            .accessibilityHidden(true)
                    } else {
                        Ellipse()
                            .foregroundColor(.white)
                            .overlay(
                                Image(systemName: image)
                                    .foregroundColor(symbolColor)
                                    .font(.system(size: 18))
                            )
                            .frame(width: 36, height: 36)
                            .padding(.leading, 14)
                            .accessibilityHidden(true)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.system(.body, design: .default))
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        
                        Text(subtitle)
                            .font(.system(.subheadline, design: .default))
//                            .foregroundStyle(.white.opacity(0.8))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                    .accessibilityElement(children: .ignore)
                    
                    Spacer()
                }
                
                // Optionally show notification badge with counter
                if notificationBadge != nil && notificationBadge! > 0 {
                    NotificationBadgeView(badgeCounter: notificationBadge!)
                        .accessibilityHidden(true)
                }
                
                // Optionally show notification badge with warning
                if notificationBadgeBool ?? false {
                    NotificationBadgeTextView(badgeCounter: "!")
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 176, height: 64)
            .contentShape(Capsule())
            .accessibilityLabel(title + ", " + subtitle)
            .onHover() { hover in
                self.hoverView = hover
            }
            .modifier(GlassEffectModifier(hoverView: hoverView, hoverEffectEnable: hoverEffectEnable))
            .overlay(alignment: .topLeading) {
                // Optionally show remove item button
                if preferences.editModeEnabled && !preferences.showItemConfiguration {
                    RemoveItemButtonView(configurationItem: configurationItem)
                }
            }
            .animation(.bouncy, value: hoverView)
        } else {
            
            ZStack {
                
                HStack {
                    if loading ?? false {
                        Ellipse()
                            .foregroundColor(Color.gray.opacity(0.5))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.5)
                            )
                            .frame(width: 26, height: 26)
                            .padding(.leading, 10)
                    } else {
                        Ellipse()
                            .foregroundColor((hoverView && hoverEffectEnable) ? .primary : symbolColor)
                            .overlay(
                                Image(systemName: image)
                                    .foregroundColor((hoverView && hoverEffectEnable) ? Color("hoverColor") : Color.white)
                            )
                            .frame(width: 26, height: 26)
                            .padding(.leading, 10)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(title).font(.system(.body, design: .rounded)).fontWeight(.medium)
                            .lineLimit(2)
                        
                        Text(subtitle).font(.system(.subheadline, design: .rounded))
                            .lineLimit(2)
                    }
                    .accessibilityElement(children: .ignore)
                    
                    Spacer()
                }
                
                // Optionally show notification badge with counter
                if notificationBadge != nil && notificationBadge! > 0 {
                    NotificationBadgeView(badgeCounter: notificationBadge!)
                        .accessibilityHidden(true)
                }
                
                // Optionally show notification badge with warning
                if notificationBadgeBool ?? false {
                    NotificationBadgeTextView(badgeCounter: "!")
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 176, height: 60)
            .accessibilityLabel(title + ", " + subtitle)
            .background(hoverView && hoverEffectEnable ? EffectsView(material: NSVisualEffectView.Material.windowBackground, blendingMode: NSVisualEffectView.BlendingMode.withinWindow) : EffectsView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
            .cornerRadius(10)
            // Apply gray and black border in Dark Mode to better view the buttons like Control Center
            .modifier(DarkModeBorder())
            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
            .onHover() {
                hover in self.hoverView = hover
            }
            .overlay(alignment: .topLeading) {
                // Optionally show remove item button
                if preferences.editModeEnabled && !preferences.showItemConfiguration {
                    RemoveItemButtonView(configurationItem: configurationItem)
                }
            }
        }
    }
}
