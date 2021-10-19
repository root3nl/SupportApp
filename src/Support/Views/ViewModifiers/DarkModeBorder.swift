//
//  DarkModeBorder.swift
//  Support
//
//  Created by Jordy Witteman on 05/05/2021.
//

import SwiftUI

// Apply gray and black border in Dark Mode to better view the buttons like Control Center
struct DarkModeBorder: ViewModifier {
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        
        if colorScheme == .dark {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white, lineWidth: 0.5, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .opacity(0.15))
                .shadow(color: .black, radius: 0.5, x: 0, y: 0)
        } else {
            content
        }
    }
}
