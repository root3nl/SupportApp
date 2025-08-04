//
//  ProgressBarItemGlassView.swift
//  Support
//
//  Created by Jordy Witteman on 04/08/2025.
//

import os
import SwiftUI

@available(macOS 26, *)
struct ProgressBarItemGlassView: View {
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
    @ObservedObject var preferences = Preferences()
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            
            HStack {
                Ellipse()
                    .foregroundColor(.white)
                    .overlay(
                        Image(systemName: image)
                            .foregroundColor(hoverView ? .primary : symbolColor)
                            .font(.system(size: 18))
                    )
                    .frame(width: 36, height: 36)
                    .padding(.leading, 10)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(hoverView ? storageAvailable : percentageUsed)
                            .font(.system(.body, design: .default))
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
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
                Spacer()
            }
            
            if notificationBadgeBool ?? false {
                NotificationBadgeTextView(badgeCounter: "!")
            }
        }
        .frame(width: 176, height: 60)
        .glassEffect(.clear.tint(colorScheme == .dark ? .clear : .secondary.opacity(0.6)))
    }
}

//#Preview {
//    ProgressBarItemGlassView()
//}
