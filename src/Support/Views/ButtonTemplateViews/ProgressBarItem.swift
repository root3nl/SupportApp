//
//  StorageView.swift
//  Support
//
//  Created by Jordy Witteman on 30/12/2020.
//

import os
import SwiftUI

struct ProgressBarItem: View {
    var percentageUsed: String
    var storageAvailable: String
    var image: String
    var symbolColor: Color
    var notificationBadgeBool: Bool?
    var percentage: CGFloat
    
    // Declare unified logging
    let logger = Logger(subsystem: "nl.root3.support", category: "Action")
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
    
    // Vars to activate hover effect
    @State var hoverEffectEnable: Bool
    @State var hoverView = false
    
    // Var to show alert when no or invalid BundleID is given
    @State private var showingAlert = false
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        
        if #available(macOS 26, *) {
            ZStack {
                
                HStack {
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

                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(hoverView ? storageAvailable : percentageUsed)
                                .font(.system(.body, design: .default))
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        
                        ProgressView(value: percentage , total: 120)
                            .padding(.trailing, 14)
                            .accessibilityHidden(true)
                        
                    }
                    .accessibilityElement(children: .combine)
                    
                    Spacer()
                }
                
                if notificationBadgeBool ?? false {
                    NotificationBadgeTextView(badgeCounter: "!")
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 176, height: 64)
            .contentShape(Capsule())
            .onHover() {
                hover in self.hoverView = hover
            }
            .onTapGesture() {
                openStorageManagement()
            }
//            .glassEffect(.clear.tint(colorScheme == .dark ? .clear : .secondary.opacity(0.6)))
//            .glassEffect(hoverView && hoverEffectEnable ? .regular.tint(colorScheme == .dark ? .clear : .secondary.opacity(0.6)) : .clear.tint(colorScheme == .dark ? .clear : .secondary.opacity(0.6)))
            .modifier(GlassEffectModifier(hoverView: hoverView, hoverEffectEnable: hoverEffectEnable))
            .animation(.bouncy, value: hoverView)
        } else {
            
            ZStack {
                
                HStack {
                    Ellipse()
                        .foregroundColor(hoverView ? .primary : symbolColor)
                        .overlay(
                            Image(systemName: image)
                                .foregroundColor(hoverView ? Color("hoverColor") : Color.white)
                        )
                        .frame(width: 26, height: 26)
                        .padding(.leading, 10)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(hoverView ? storageAvailable : percentageUsed)
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                        
                        ZStack(alignment: .leading) {
                            
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: 120, height: 4).foregroundColor(.white)
                            
                            // Show red bar if more than 90% of 120 points (108)
                            if percentage >= 108 {
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: percentage, height: 4).foregroundColor(.red)
                                
                                // Animation when loading app
                                    .animation(.easeInOut, value: percentage)
                                    .transition(.scale)
                                // Show orange bar if optional storageLimit is reached and still below 90%
                            } else if notificationBadgeBool ?? false && percentage < 108 {
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: percentage, height: 4).foregroundColor(.orange)
                                
                                // Animation when loading app
                                    .animation(.easeInOut, value: percentage)
                                    .transition(.scale)
                                
                                // Show accentColor in all other cases
                            } else {
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: percentage, height: 4).foregroundColor(symbolColor)
                                
                                // Animation when loading app
                                    .animation(.easeInOut, value: percentage)
                                    .transition(.scale)
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                    
                    Spacer()
                }
                
                if notificationBadgeBool ?? false {
                    NotificationBadgeTextView(badgeCounter: "!")
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 176, height: 60)
            .background(hoverView && hoverEffectEnable ? EffectsView(material: NSVisualEffectView.Material.windowBackground, blendingMode: NSVisualEffectView.BlendingMode.withinWindow) : EffectsView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
            .cornerRadius(10)
            // Apply gray and black border in Dark Mode to better view the buttons like Control Center
            .modifier(DarkModeBorder())
            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(NSLocalizedString("An error occurred", comment: "")), message: Text(preferences.errorMessage), dismissButton: .default(Text("OK")))
            }
            .onHover() {
                hover in self.hoverView = hover
            }
            .onTapGesture() {
                openStorageManagement()
            }
        }
    }
    
    // Open Storage Management
    func openStorageManagement() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.settings.Storage") else {
            self.showingAlert.toggle()
            return }
        NSWorkspace.shared.open(url)
        
        // Close popover
        appDelegate.togglePopover(nil)
    }
}
