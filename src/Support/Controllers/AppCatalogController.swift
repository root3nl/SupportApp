//
//  AppCatalogController.swift
//  Support
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation
import os

class AppCatalogController: ObservableObject {
    
    // Unified Logging
    var logger = Logger(subsystem: "nl.root3.support", category: "AppCatalog")
    
    // Current apps updating
    @Published var appsUpdating: [String] = []
    
    // Show app updates
    @Published var showAppUpdates: Bool = false
    
    // Array containing app details
    @Published var updateDetails: [InstalledAppItem] = []
    
    func getAppUpdates() {
        let defaults = UserDefaults(suiteName: "nl.root3.catalog")
        
        // Check available app updates
        checkAppUpdates()
        
        if let encodedAppUpdates = defaults?.object(forKey: "UpdateDetails") as? Data {
            let decoder = JSONDecoder()
            if let decodedAppUpdates = try? decoder.decode([InstalledAppItem].self, from: encodedAppUpdates) {
                DispatchQueue.main.async {
                    self.updateDetails = decodedAppUpdates
                }
            }
        }
    }
    
    //    // MARK: - Function to get latest app updates from Root3 App Catalog
    private func checkAppUpdates() {
        
        logger.log("Checking app updates...")
        
        let command = """
            /usr/local/bin/catalog --check-updates
            """
        
        let connectionToService = NSXPCConnection(serviceName: "nl.root3.support.xpc")
        
        connectionToService.remoteObjectInterface = NSXPCInterface(with: SupportXPCProtocol.self)
        connectionToService.resume()
        
        if let proxy = connectionToService.remoteObjectProxy as? SupportXPCProtocol {
            do {
                try proxy.executeScript(command: command) { exitCode in
                    
                    if exitCode == 0 {
                        self.logger.log("Successfully checked app updates")
                    } else {
                        self.logger.error("Failed to check app updates")
                    }
                    
                }
            } catch {
                logger.error("Error: \(error.localizedDescription, privacy: .public)")
            }
        }
        
        connectionToService.invalidate()
        
    }
    
}
