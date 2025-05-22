//
//  AppUpdatesView.swift
//  Support
//
//  Created by Jordy Witteman on 21/10/2023.
//

import os
import SwiftUI

struct AppUpdatesView: View {
    
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
    
    // Update cancel hover state
    @State private var hoveredCancelButton: Bool = false
    @State private var hoveredItem: String?
            
    var body: some View {
        
        Group {
            
            HStack {
                
                if #available(macOS 13, *) {
                    
                    Button(action: {
                        appCatalogController.showAppUpdates.toggle()
                    }) {
                        Ellipse()
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                            .overlay(
                                Image(systemName: "chevron.backward")
                            )
                            .frame(width: 26, height: 26)
                    }
                    .buttonStyle(.plain)
                    
                }
                    
                    Text(NSLocalizedString("APP_UPDATES", comment: ""))
                        .font(.system(.headline, design: .rounded))
                                    
                Spacer()
                
                if appCatalogController.updateDetails.count > 0 {
                    Button(action: {
                        Task {
                            for app in appCatalogController.updateDetails {
                                // Validate Catalog Agent code requirement
                                guard verifyAppCatalogCodeRequirement() else {
                                    return
                                }
                                
                                // Append app to queue
                                await MainActor.run() {
                                    appCatalogController.appsQueued.append(app.id)
                                }
                                
                                // Update app
                                await InstallTaskQueue.shared.submit(id: app.id) {
                                    await updateApp(bundleID: app.id)
                                }
                            }
                            
                            // Validate updates
//                            appCatalogController.getAppUpdates()
                        }
                    }) {
                        Text(NSLocalizedString("UPDATE_ALL", comment: ""))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.regular)
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                            .background(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(appCatalogController.appsUpdating.isEmpty && FileUtilities().fileOrFolderExists(path: "/Library/PrivilegedHelperTools/nl.root3.support.helper") ? false : true)
                }
                
            }
            .modify {
                if #unavailable(macOS 13) {
                    $0.padding(.top)
                } else {
                    $0
                }
            }
            
            Divider()
                .padding(2)
            
            VStack {
                
                if !appCatalogController.catalogInstalled() {
                    
                    VStack(alignment: .center, spacing: 20) {
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .orange)
                        
                        Text(NSLocalizedString("APP_CATALOG_NOT_CONFIGURED", comment: ""))
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                        
                        Link(NSLocalizedString("DOCUMENTATION", comment: ""), destination: URL(string: "https://docs.appcatalog.cloud")!)
                        
                    }
                    .padding(.vertical, 40)
                    
                } else {
                    
                    if !FileUtilities().fileOrFolderExists(path: "/Library/PrivilegedHelperTools/nl.root3.support.helper") {
                        
                        VStack(alignment: .center, spacing: 20) {
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .orange)
                            
                            Text(NSLocalizedString("PRIVILEGED_HELPER_TOOL_NOT_INSTALLED", comment: ""))
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                            
                            Link(NSLocalizedString("DOCUMENTATION", comment: ""), destination: URL(string: "https://github.com/root3nl/SupportApp")!)
                            
                        }
                        .padding(.vertical, 40)
                        
                    } else {
                        
                        if appCatalogController.updateDetails.count > 0 {
                            
                            ForEach(appCatalogController.updateDetails, id: \.self) { update in
                                
                                HStack {
                                    
                                    if let icon = update.icon {
                                        
                                        AsyncImage(url: URL(string: icon)) { phase in
                                            switch phase {
                                            case .empty:
                                                Image(systemName: "app.dashed")
                                                    .font(.system(size: 30))
                                                    .foregroundStyle(.secondary)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            case .failure(_):
                                                Image(systemName: "exclamationmark.circle")
                                                    .font(.system(size: 30))
                                                    .foregroundStyle(.secondary)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(width: 40, height: 40)
                                        
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        
                                        Text(update.name ?? "")
                                            .font(.system(.headline, design: .rounded))
                                        
                                        if update.version != nil && update.newVersion != nil {
                                            Text("\(update.version ?? "") → \(update.newVersion ?? "")")
                                                .foregroundColor(.secondary)
                                                .font(.system(.subheadline, design: .rounded))
                                        }
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        Task {
                                            // Validate Catalog Agent code requirement
                                            guard verifyAppCatalogCodeRequirement() else {
                                                return
                                            }
                                            
                                            // Append app to queue
                                            await MainActor.run() {
                                                appCatalogController.appsQueued.append(update.id)
                                            }
                                            
                                            // Update app
                                            await InstallTaskQueue.shared.submit(id: update.id) {
                                                await updateApp(bundleID: update.id)
                                            }
                                        }
                                    }) {
                                        if appCatalogController.appsUpdating.contains(update.id) {
                                            ProgressView()
                                                .scaleEffect(0.6)
                                                .frame(width: 26, height: 26)
                                                .padding(.leading, 10)
                                        } else if appCatalogController.appsQueued.contains(update.id) {
                                            Image(systemName: hoveredCancelButton && (hoveredItem == update.id) ? "xmark.circle.fill" : "clock")
                                                .font(.system(size: 16))
                                                .frame(width: 26, height: 26)
                                                .onHover { hover in
                                                    hoveredCancelButton = hover
                                                }
                                                .animation(.easeOut(duration: 0.2), value: hoveredCancelButton && (hoveredItem == update.id))
                                                .onTapGesture {
                                                    Task {
                                                        await InstallTaskQueue.shared.cancel(taskID: update.id)
                                                        await MainActor.run {
                                                            appCatalogController.appsQueued.removeAll(where: { $0 == update.id })
                                                        }
                                                        appCatalogController.logger.debug("App \(update.id, privacy: .public) update cancelled")
                                                    }
                                                }
                                        } else {
                                            Image(systemName: "icloud.and.arrow.down")
                                                .font(.system(size: 16, weight: .medium))
                                                .frame(width: 26, height: 26)
                                                .padding(.leading, 10)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    
                                }
                                .onHover {_ in
                                    hoveredItem = update.id
                                }
                            }
                            
                            // Show update schedule information when configured
                            if appCatalogController.updateInterval > 0 {
                                
                                Divider()
                                    .padding(2)
                                
                                HStack(alignment: .top) {
                                    
                                    Text("\(NSLocalizedString("APPS_WILL_BE_UPDATED_AUTOMATICALLY_DESCRIPTION", comment: "")) \(appCatalogController.nextUpdateDate)")
                                        .font(.system(.body, design: .rounded))
                                    //                                .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                }
                            }
                            
                        } else {
                            
                            VStack(alignment: .center, spacing: 20) {
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
                                
                                Text(NSLocalizedString("ALL_APPS_UP_TO_DATE", comment: ""))
                                    .font(.system(.title, design: .rounded))
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                
                                if appCatalogController.updateInterval > 0 {
                                    
                                    Text("\(NSLocalizedString("APPS_WILL_BE_UPDATED_AUTOMATICALLY_DESCRIPTION", comment: "")) \(appCatalogController.nextUpdateDate)")
                                    // Set frame to 250 to allow multiline text
                                        .frame(width: 250)
                                        .font(.system(.title3, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.secondary)
                                    
                                }
                                
                            }
                            .padding(.vertical, 40)
                        }
                    }
                }
            }
            .modify {
                if #unavailable(macOS 13) {
                    $0.padding(.bottom)
                } else {
                    $0
                }
            }
        }
        .modify {
            if #unavailable(macOS 13) {
                $0.frame(minWidth: 300)
            } else {
                $0
            }        }
        .padding(.horizontal)
        .unredacted()
    }
    
    func verifyAppCatalogCodeRequirement() -> Bool {
        
        // Set default Catalog Agent validation to false
        var catalogAgentValidated = false
        
        // Setup XPC connection
        let connectionToService = NSXPCConnection(serviceName: "nl.root3.support.xpc")
        connectionToService.remoteObjectInterface = NSXPCInterface(with: SupportXPCProtocol.self)
        connectionToService.resume()
        
        // Run XPC synchronously
        if let proxy = connectionToService.synchronousRemoteObjectProxyWithErrorHandler( { error in
            appCatalogController.logger.error("\(error.localizedDescription, privacy: .public)")
        }) as? SupportXPCProtocol {
            proxy.verifyAppCatalogCodeRequirement { verified in
                
                if verified {
                    appCatalogController.logger.debug("Successfully verified Catalog Agent code requirement")
                    // Only now the Catalog Agent is valid
                    catalogAgentValidated = true
                } else {
                    appCatalogController.logger.error("Failed to verify Catalog Agent code requirement")
                }
                
            }
        } else {
            appCatalogController.logger.error("Failed to connect to SupportXPC service")
        }
        
        // Invalidate connection
        connectionToService.invalidate()
        
        return catalogAgentValidated
        
    }
    
    // MARK: - Function to update app using App Catalog
    func updateApp(bundleID: String) async {
        
        appCatalogController.logger.debug("App \(bundleID, privacy: .public) added to update queue")
        
        // Command to update app
        let command = "'/usr/local/bin/catalog --install \(bundleID) --update-action --support-app'"
        
        // Remove Bundle ID from queued array
        await MainActor.run {
            appCatalogController.appsQueued.removeAll(where: { $0 == bundleID })
        }
        
        // Add bundle ID to apps currently updating
        appCatalogController.appsUpdating.append(bundleID)
        
        do {
            
            let exitCode: NSNumber = try await withCheckedThrowingContinuation { continuation in
                try? ExecutionService.executeScript(command: command) { exitCode in
                    continuation.resume(returning: exitCode)
                }
            }
            
            if exitCode == 0 {
                appCatalogController.logger.log("App \(bundleID, privacy: .public) successfully updated")
                
                // Temporarily drop app from updates array so it will not show once completed. Then we check updates again to verify the update was really successful
                await MainActor.run {
                    appCatalogController.updateDetails.removeAll(where: { $0.id == bundleID })
                }
                
            } else {
                appCatalogController.logger.error("Failed to update app \(bundleID, privacy: .public)")
            }
            
            // Stop update spinner
            await MainActor.run {
                appCatalogController.appsUpdating.removeAll(where: { $0 == bundleID })
                
//                // Check for updates again when apps currently updating is empty
//                if appCatalogController.appsUpdating.isEmpty {
//                    // Trigger check for app updates
//                    appCatalogController.ignoreUpdateChange = true
//                    appCatalogController.getAppUpdates()
//                }
            }
            
        } catch {
            appCatalogController.logger.log("Failed to update app \(bundleID, privacy: .public)")
            
            // Stop update spinner
            await MainActor.run {
                appCatalogController.appsUpdating.removeAll(where: { $0 == bundleID })
            }
            
//            // Trigger check for app updates
//            appCatalogController.ignoreUpdateChange = true
//            appCatalogController.getAppUpdates()
        }
        
    }
    
}
