//
//  PopoverLifecycle.swift
//  Support
//
//  Created by Jordy Witteman on 03/09/2025.
//

import Foundation

class PopoverLifecycle: ObservableObject {
    // Unique presentation token to pass to SwiftUI task ID. This make sure tasks can run on every appearance instead of just once because the view is only initialized once hosted by NSPopover
    @Published var presentationToken = UUID()
    
    // Create new presentation token
    func bump() {
        presentationToken = UUID()
    }
}
