//
//  GlassEffectModifier.swift
//  Support
//
//  Created by Jordy Witteman on 06/08/2025.
//

import SwiftUI

@available(macOS 26, *)
struct GlassEffectModifier: ViewModifier {
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    var hoverView: Bool
    var hoverEffectEnable: Bool
    
    func body(content: Content) -> some View {
        
        if colorScheme == .dark {
            content
                .glassEffect(hoverView && hoverEffectEnable ? .clear.tint(.white.opacity(0.1)) : .clear)
        } else {
            content
                .glassEffect(hoverView && hoverEffectEnable ? .clear.tint(.primary.opacity(0.2)) : .clear.tint(.primary.opacity(0.3)))
        }
    }
}
