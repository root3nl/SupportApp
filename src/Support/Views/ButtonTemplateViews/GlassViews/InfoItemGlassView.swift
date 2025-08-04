//
//  InfoItemGlassView.swift
//  Support
//
//  Created by Jordy Witteman on 04/08/2025.
//

import SwiftUI

@available(macOS 26, *)
struct InfoItemGlassView: View {
    var title: String
    var subtitle: String
    var image: String
    var symbolColor: Color
    var notificationBadge: Int?
    var notificationBadgeBool: Bool?
    var loading: Bool?
    
    // Vars to activate hover effect
    @State var hoverEffectEnable: Bool
    @State var hoverView = false
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            
            HStack {
                if loading ?? false {
                    Ellipse()
                        .foregroundColor(.white)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.5)
                        )
                        .frame(width: 36, height: 36)
                        .padding(.leading, 10)
                } else {
                    Ellipse()
                        .foregroundColor(.white)
                        .overlay(
                            Image(systemName: image)
                                .foregroundColor((hoverView && hoverEffectEnable) ? .primary : symbolColor)
                                .font(.system(size: 18))
                        )
                        .frame(width: 36, height: 36)
                        .padding(.leading, 10)
                }
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(.body, design: .default))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    
                    Text(subtitle)
                        .font(.system(.subheadline, design: .default))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                }
                Spacer()
            }
            
            // Optionally show notification badge with counter
            if notificationBadge != nil && notificationBadge! > 0 {
                NotificationBadgeView(badgeCounter: notificationBadge!)
            }
            
            // Optionally show notification badge with warning
            if notificationBadgeBool ?? false {
                NotificationBadgeTextView(badgeCounter: "!")
            }

        }
        .frame(width: 176, height: 60)
        .glassEffect(.clear.tint(colorScheme == .dark ? .clear : .secondary.opacity(0.6)))
    }
}

//#Preview {
//    InfoItemGlassView()
//}
