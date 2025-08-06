//
//  NotificationBadgeView.swift
//  Support
//
//  Created by Jordy Witteman on 30/12/2020.
//

import SwiftUI

struct NotificationBadgeView: View {
    
    var badgeCounter: Int
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Spacer()
                
                Circle()
                    .foregroundColor(.red)
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
