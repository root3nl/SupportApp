//
//  AppCatalogController.swift
//  Support
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation

class AppCatalogController: ObservableObject {
    
    // Current apps updating
    @Published var appsUpdating: [String] = []
    
    // Show app updates
    @Published var showAppUpdates: Bool = false
    
}
