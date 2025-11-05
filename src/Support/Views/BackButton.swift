//
//  BackButton.swift
//  Support
//
//  Created by Jordy Witteman on 05/11/2025.
//

import SwiftUI

struct BackButton: View {
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if #available(macOS 26, *) {
            Label(NSLocalizedString("BACK", comment: ""), systemImage: "chevron.backward")
                .labelStyle(.iconOnly)
                .font(.system(size: 12))
                .frame(width: 12, height: 12)
                .padding(4)
        } else {
            Ellipse()
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                .overlay(
                    Image(systemName: "chevron.backward")
                )
                .frame(width: 26, height: 26)
                .accessibilityLabel(NSLocalizedString("BACK", comment: ""))
        }
    }
}

#Preview {
    BackButton()
}
