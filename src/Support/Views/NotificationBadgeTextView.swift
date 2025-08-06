//
//  NotificationBadgeTextView.swift
//  Support
//
//  Created by Jordy Witteman on 12/04/2021.
//

import SwiftUI

struct NotificationBadgeTextView: View {
    
    var badgeCounter: String
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Spacer()
                
                Circle()
                    .foregroundColor(.orange)
                    .overlay(
                        Text("\(badgeCounter)")
                            .foregroundColor(.white)
                            .font(Font.system(size: 16))
                    )
                    .frame(width: 24, height: 24)
//                    .padding(4)
            }
            Spacer()
        }
    }
}
