//
//  AppUpdatesView.swift
//  Support
//
//  Created by Jordy Witteman on 21/10/2023.
//

import os
import SwiftUI

struct AppUpdatesView: View {
    
    // Unified Logging
    var logger = Logger(subsystem: "nl.root3.support", category: "AppCatalog")
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
        
    // Get computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get App Catalog information
    @EnvironmentObject var appCatalogController: AppCatalogController
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
        
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Set the custom color for all symbols depending on Light or Dark Mode.
    var customColor: String {
        if colorScheme == .light && defaults.string(forKey: "CustomColor") != nil {
            return preferences.customColor
        } else if colorScheme == .dark && defaults.string(forKey: "CustomColorDarkMode") != nil {
            return preferences.customColorDarkMode
        } else {
            return preferences.customColor
        }
    }
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    // Update counter
    var updateCounter: Int
            
    var body: some View {
        
        Group {
            
            HStack {
                
                Button(action: {
                    withAnimation {
                        appCatalogController.showAppUpdates.toggle()
                    }
                }) {
                    Ellipse()
                        .foregroundColor(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "chevron.backward")
                        )
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                
                Text(updateCounter > 0 ? NSLocalizedString("UPDATES_AVAILABLE", comment: "") : NSLocalizedString("NO_UPDATES_AVAILABLE", comment: ""))
                    .font(.system(.headline, design: .rounded))
                
                Spacer()
                
                Button(action: {
                    print("Updating all apps...")
                }) {
                    Text(NSLocalizedString("UPDATE_ALL", comment: ""))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.regular)
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
            }
            .transition(.move(edge: .leading))
            
            if updateCounter > 0 {
                
                Divider()
                    .padding(2)
                
                ForEach(appCatalogController.updateDetails, id: \.self) { update in
                    
                    HStack {
                        
                        if let icon = update.icon {
                            
                            AsyncImage(url: URL(string: icon), transaction: Transaction(animation: .spring(response: 0.5, dampingFraction: 0.6))) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .transition(.move(edge: .leading))
                                case .failure(_):
                                    Image(systemName: "exclamationmark.circle")
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 40)

                                
//                                if let image = phase.image {
//                                    image
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(height: 40)
//                                        .transition(.scale(scale: 0.1, anchor: .center))
//
//                                } else if phase.error != nil {
//                                    
//                                } else {
//                                    Image("DefaultLogo")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .cornerRadius(6)
//                                        .redacted(reason: .placeholder)
//                                        .overlay(
//                                            ProgressView()
//                                        )
//                                        .frame(width: 40, height: 40)
//                                }
//                            }
                                
//                            } placeholder: {
//                                Image("DefaultLogo")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .cornerRadius(6)
//                                    .redacted(reason: .placeholder)
//                                    .overlay(
//                                        ProgressView()
//                                    )
//                                    .frame(width: 40, height: 40)
//                            }
                        }
                        
                        VStack(alignment: .leading) {
                            
                            Text(update.name ?? "")
                                .font(.system(.headline, design: .rounded))
                            
                            Text(update.version ?? "")
                                .foregroundColor(.secondary)
                                .font(.system(.subheadline, design: .rounded))
                            
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            updateApp(bundleID: update.id)
                        }) {
                            if appCatalogController.appsUpdating.contains(update.id) {
                                Ellipse()
                                    .foregroundColor(Color.gray.opacity(0.2))
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.5)
                                    )
                                    .frame(width: 26, height: 26)
                                    .padding(.leading, 10)
                            } else {
                                Ellipse()
                                    .foregroundColor(Color.gray.opacity(0.2))
                                    .overlay(
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    )
                                    .frame(width: 26, height: 26)
                                    .padding(.leading, 10)
                            }
                        }
                        .buttonStyle(.plain)
                        
                    }
                    
                }
                
            } else {
                
                HStack {
                    
                    Spacer()
                    
                    VStack {
                        
                        Text(NSLocalizedString("ALL_APPS_UP_TO_DATE", comment: ""))
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.medium)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                        
                    }
                    
                    Spacer()
                    
                }
                
            }
            Spacer()
        }
        .padding(.horizontal)
        .unredacted()
    }
    
    // Open application with given Bundle Identifier
    func openAppCatalog() {
        
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "nl.root3.catalog")
                // Show alert when there is an error
        else {
            return
        }
        let configuration = NSWorkspace.OpenConfiguration()
        
        NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
        
        // Close popover
        appDelegate.togglePopover(nil)
    }
    
    // MARK: - Function to check updates as the current user
    func checkAppUpdates() {
        
        // Command to check app updates
        let command = "/usr/local/bin/catalog --check-updates"
        
        do {
            try ExecutionService.executeScript(command: command) { exitCode in
                
                if exitCode == 0 {
                    logger.log("Successfully checked app updates")
                } else {
                    logger.error("Failed to check app updates...")
                }
                
            }
        } catch {
            logger.error("Failed to check app updates...")
        }
        
    }
    
    // MARK: - Function to update app using App Catalog
    func updateApp(bundleID: String) {
        
        // Command to update app
        let command = "/usr/local/bin/catalog -i \(bundleID)"
        
        // Add bundle ID to apps currently updating
        appCatalogController.appsUpdating.append(bundleID)
        
        do {
            try ExecutionService.executeScript(command: command) { exitCode in
                
                if exitCode == 0 {
                    logger.log("App \(bundleID) successfully updated")
                } else {
                    logger.error("Failed to update app \(bundleID)")
                }
                
                // Stop update spinner
                if appCatalogController.appsUpdating.contains(bundleID) {
                    if let index = appCatalogController.appsUpdating.firstIndex(of: bundleID) {
                        DispatchQueue.main.async {
                            appCatalogController.appsUpdating.remove(at: index)
                        }
                    }
                }
                
                checkAppUpdates()
                
            }
        } catch {
            logger.log("Failed to update app \(bundleID). Error in PrivilegedHelperTool")
            
            // Stop update spinner
            if appCatalogController.appsUpdating.contains(bundleID) {
                if let index = appCatalogController.appsUpdating.firstIndex(of: bundleID) {
                    DispatchQueue.main.async {
                        appCatalogController.appsUpdating.remove(at: index)
                    }
                }
            }
        }
        
    }
    
}
