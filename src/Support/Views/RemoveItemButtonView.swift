//
//  RemoveItemButtonView.swift
//  Support
//
//  Created by Jordy Witteman on 01/10/2025.
//

import SwiftUI

struct RemoveItemButtonView: View {
    
    var configurationItem: ConfiguredItem?

    // Get local preferences for Configurator Mode
    @EnvironmentObject var localPreferences: LocalPreferences
    
    var body: some View {
        HStack {
            VStack {
                Button {
                    guard let configurationItem else {
                        return
                    }
                    localPreferences.rows[configurationItem.rowIndex].items?.remove(at: configurationItem.itemIndex)
                    
                    // Remove if row is empty to avoid empty/invisible rows taking up space
                    if localPreferences.rows[configurationItem.rowIndex].items?.count == 0 {
                        localPreferences.rows.remove(at: configurationItem.itemIndex)
                    }
                } label: {
                    Label("Remove item", systemImage: "minus")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(AddIconButtonStyle(color: .red))
                
                Spacer()
            }
            Spacer()
        }
        .padding(.trailing, 4)    }
}
