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
    
    // Vars to activate hover effect
    @State var hoverEffectEnable: Bool
    @State var hoverView = false
    
    var body: some View {
        
        ZStack {
            
            HStack {
                Ellipse()
                    .foregroundColor((hoverView && hoverEffectEnable) ? .primary : symbolColor)
                    .overlay(
                        Image(systemName: image)
                            .foregroundColor((hoverView && hoverEffectEnable) ? Color("hoverColor") : Color.white)
                    )
                    .frame(width: 26, height: 26)
                    .padding(.leading, 10)
                
                VStack(alignment: .leading) {
                    Text(title).font(.system(.body, design: .rounded)).fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text(subtitle).font(.system(.subheadline, design: .rounded))
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
        .background(hoverView && hoverEffectEnable ? EffectsView(material: NSVisualEffectView.Material.windowBackground, blendingMode: NSVisualEffectView.BlendingMode.withinWindow) : EffectsView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
        .cornerRadius(10)
        // Apply gray and black border in Dark Mode to better view the buttons like Control Center
        .modifier(DarkModeBorder())
        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
        .onHover() {
            hover in self.hoverView = hover
        }
    }
}
