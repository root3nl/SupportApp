//
//  AddIconButtonStyle.swift
//  Support
//
//  Created by Jordy Witteman on 01/09/2025.
//

import SwiftUI

struct AddIconButtonStyle: ButtonStyle {
        
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 20, height: 20)
            .contentShape(.circle)
            .modify {
                if #available(macOS 26, *) {
                    $0
                        .glassEffect(.regular.interactive().tint(.green))
                        .controlSize(.small)
                        .buttonBorderShape(.circle)
                } else {
                    $0
                        .foregroundStyle(.primary)
                        .background(.green)
                        .clipShape(.circle)
                        .controlSize(.small)
                        .buttonBorderShape(.circle)
                }
            }
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}
