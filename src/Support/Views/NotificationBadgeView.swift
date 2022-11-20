//
//  NotificationBadgeView.swift
//  Support
//
//  Created by Jordy Witteman on 30/12/2020.
//

import SwiftUI

struct NotificationBadgeView: View {
    
    var badgeCounter: Int
    var deferralsRemaining: Int?
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Spacer()
                
                Circle()
                    .foregroundColor(.red)
                    .overlay(
                        Text("\(badgeCounter)")
                            .foregroundColor(.white)
                            .font(Font.system(size: 12))
                    )
                    .frame(width: 18, height: 18)
                    .padding(4)
            }
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                // Show deferrals remaining from ScheduleOSUpdate MDM command on macOS 12 and higher
                if deferralsRemaining != nil {
                    if #available(macOS 12.0, *) {
                        Text("\(deferralsRemaining!) " + NSLocalizedString("DEFERRALS", comment: ""))
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .background(.ultraThickMaterial)
//                            .background(Color.orange)
                            .clipShape(Capsule())
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.orange, lineWidth: 1)
                            )
                            .padding(4)
                    }
                }
            }
        }
    }
}
