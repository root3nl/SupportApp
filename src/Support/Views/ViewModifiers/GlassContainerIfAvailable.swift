//
//  GlassContainerIfAvailable.swift
//  Support
//
//  Created by Jordy Witteman on 25/08/2025.
//

import SwiftUI

// Conditionally wrap content in GlassEffectContainer on macOS 26+
struct GlassContainerIfAvailable: ViewModifier {
    var spacing: CGFloat
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            content
        }
    }
}

extension View {
    /// Wraps the view in GlassEffectContainer on macOS 26+, otherwise returns the content unchanged.
    func glassContainerIfAvailable(spacing: CGFloat) -> some View {
        self.modifier(GlassContainerIfAvailable(spacing: spacing))
    }
}
