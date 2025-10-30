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
        
        if #available(macOS 26, *) {
            Text("\(badgeCounter)")
                .font(Font.system(size: 12))
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
                .glassEffect(.regular.interactive().tint(.red))
                .contentShape(.circle)
                .clipShape(.circle)
        } else {
//            VStack {
                
//                HStack {
                    
//                    Spacer()
                    
                    Circle()
                        .foregroundColor(.red)
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
