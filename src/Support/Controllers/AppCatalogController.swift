//
//  AppCatalogController.swift
//  Support
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation
import os
import SwiftUI

class AppCatalogController: ObservableObject {
    
    // Unified Logging
    var logger = Logger(subsystem: "nl.root3.support", category: "AppCatalog")
    
    // Setup UserDefaults
    let defaults = UserDefaults(suiteName: "nl.root3.catalog")
    
    // App Catalog authorization code
    @AppStorage("authorization", store: UserDefaults(suiteName: "nl.root3.catalog")) var catalogAuthorization: String = ""
    
    // Get available app updates from App Catalog
    @AppStorage("Updates", store: UserDefaults(suiteName: "nl.root3.catalog")) var appUpdates: Int = 0
    
    // Get update interval
    @AppStorage("UpdateInterval", store: UserDefaults(suiteName: "nl.root3.catalog")) var updateInterval: Int = 0
    
    // Get last update date epoch
    @AppStorage("LastUpdated", store: UserDefaults(suiteName: "nl.root3.catalog.agent")) var lastUpdated: Int = 0
    
    // Current apps updating
    @Published var appsUpdating: [String] = []
    
    // Show app updates
    @Published var showAppUpdates: Bool = false
    
    // Array containing app details
    @Published var updateDetails: [InstalledAppItem] = []
    
    // Boolean to ignore a value change for "Updates" just once to avoid KVO in AppDelegate to trigger twice
    var ignoreUpdateChange: Bool = false
    
    // Calculate when next update schedule will run
    var nextUpdateDate: String {
        let fromDate = Date(timeIntervalSince1970: Double(lastUpdated))
        var toDate = fromDate.addingTimeInterval(Double(updateInterval) * 86400)
        
        // If next update is not in the future, show within the next hour
        // If next update if within on hour, show within the next hour as we don't know exactly when the LaunchDaemon will run
        if toDate < .now.addingTimeInterval(3600) {
            toDate = .now.addingTimeInterval(3600)
        }
        
        // Format the next update schedule in relative style
        var formatter = Date.RelativeFormatStyle()
        formatter.presentation = .numeric
        let relativeDate = toDate.formatted(formatter)
        
        return relativeDate
    }
    
    func getAppUpdates() {
        
        // Check available app updates
        logger.log("Checking app updates...")
        
        let command = "'/usr/local/bin/catalog --check-updates'"
        
        // Move to background thread
        DispatchQueue.global().async {
            
            // Setup XPC connection
            let connectionToService = NSXPCConnection(serviceName: "nl.root3.support.xpc")
            connectionToService.remoteObjectInterface = NSXPCInterface(with: SupportXPCProtocol.self)
            connectionToService.resume()
            
            // Run command when connection is successful. Run XPC synchronously and decode app updates once completed
            if let proxy = connectionToService.synchronousRemoteObjectProxyWithErrorHandler( { error in
                self.logger.error("\(error.localizedDescription, privacy: .public)")
            }) as? SupportXPCProtocol {
                proxy.executeScript(command: command) { exitCode in
                    
                    if exitCode == 0 {
                        self.logger.log("Successfully checked app updates")
                    } else {
                        self.logger.error("Failed to check app updates")
                    }
                    
                }
            } else {
                self.logger.error("Failed to connect to SupportXPC service")
            }
            
            // Invalidate connection
            connectionToService.invalidate()
            
            // Decode app updates
            if let encodedAppUpdates = self.defaults?.object(forKey: "UpdateDetails") as? Data {
                let decoder = JSONDecoder()
                if let decodedAppUpdates = try? decoder.decode([InstalledAppItem].self, from: encodedAppUpdates) {
                    DispatchQueue.main.async {
                        self.logger.debug("Successfully decoded app updates")
                        self.updateDetails = decodedAppUpdates
                    }
                } else {
                    self.logger.error("Failed to decode app updates: Invalid format")
                }
            } else {
                self.logger.error("Failed to decode app updates: Key 'UpdateDetails' does not exist")
            }
        }

    }
    
    // MARK: - Function to check if App Catalog is installed
    func catalogInstalled() -> Bool {
        
        let fileManager = FileManager.default
        
        // Path to app bundle
        let appURL = URL(fileURLWithPath: "/Applications/Catalog.app")
        
        // Path to binary symlink
        let cliURL = URL(fileURLWithPath: "/usr/local/bin/catalog")
        
        if fileManager.fileExists(atPath: appURL.path) && fileManager.fileExists(atPath: cliURL.path) && catalogAuthorization != "" {
            return true
        } else {
            return false
        }
    }
}
