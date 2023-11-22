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
    
    // Array containing app details
    @Published var updateDetails: [InstalledAppItem] = []
    
    func getAppUpdates() {
        let defaults = UserDefaults(suiteName: "nl.root3.catalog")
        
        if let encodedAppUpdates = defaults?.object(forKey: "UpdateDetails") as? Data {
            let decoder = JSONDecoder()
            if let decodedAppUpdates = try? decoder.decode([InstalledAppItem].self, from: encodedAppUpdates) {
                DispatchQueue.main.async {
                    self.updateDetails = decodedAppUpdates
                }
            }
        }
    }
    
}
