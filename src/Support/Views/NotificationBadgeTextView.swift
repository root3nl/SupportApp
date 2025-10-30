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
        
        if #available(macOS 26, *) {
            Text("\(badgeCounter)")
                .font(Font.system(size: 12))
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
                .glassEffect(.regular.interactive().tint(.orange))
                .contentShape(.circle)
                .clipShape(.circle)
        } else {
//            VStack {
                
//                HStack {
                    
//                    Spacer()
                    
                    Circle()
                        .foregroundColor(.orange)
                        .overlay(
                            Text("\(badgeCounter)")
                                .foregroundColor(.white)
                                .font(Font.system(size: 12))
                        )
                        .frame(width: 18, height: 18)
                        .padding(4)
//                }
//                Spacer()
//            }
        }
    }
}
