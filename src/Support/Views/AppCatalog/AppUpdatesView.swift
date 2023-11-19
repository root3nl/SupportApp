//
//  AppUpdatesView.swift
//  Support
//
//  Created by Jordy Witteman on 21/10/2023.
//

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
      
    // State of UpdateView popover
    @State private var showPopover: Bool = false
    
    // Update counter
    var updateCounter: Int
//    var color: Color
    
    @State var updateDetails: [InstalledAppItem] = []
            
    var body: some View {
        
        ZStack {
            EffectsView(material: NSVisualEffectView.Material.fullScreenUI, blendingMode: NSVisualEffectView.BlendingMode.behindWindow)
            
            // We need to provide Quit option for Apple App Review approval
            if !preferences.hideQuit {
                QuitButton()
            }
            
            VStack(spacing: 10) {
                
                // MARK: - Horizontal stack with Title and Logo
                HeaderView()
                
                //        VStack(alignment: .leading, spacing: 8) {
                
                Group {
                    
                    HStack {
                        
                        Button(action: {
                            withAnimation {
                                appCatalogController.showAppUpdates.toggle()
                            }
                        }) {
                            Ellipse()
                                .foregroundColor(Color.gray.opacity(0.5))
                                .overlay(
                                    Image(systemName: "chevron.backward")
                                )
                                .frame(width: 26, height: 26)
                        }
                        .buttonStyle(.plain)
                                                
                        Text(updateCounter > 0 ? NSLocalizedString("UPDATES_AVAILABLE", comment: "") : NSLocalizedString("NO_UPDATES_AVAILABLE", comment: ""))
                            .font(.system(.headline, design: .rounded))
//                            .foregroundStyle(.secondary)
                        
                        Spacer()

                    }
                    
                    if updateCounter > 0 {
                        
//                        HStack {
//                            
//                            Text(updateCounter > 0 ? NSLocalizedString("UPDATES_AVAILABLE", comment: "") : NSLocalizedString("NO_UPDATES_AVAILABLE", comment: ""))
//                                .font(.system(.headline, design: .rounded))
//                            
//                            Spacer()
//                            
//                            Button(action: {
//                                showPopover = false
//                                openAppCatalog()
//                            }) {
//                                Text(NSLocalizedString("APP_CATALOG", comment: ""))
//                            }
//                            .buttonStyle(.borderedProminent)
//                        }
                        
                        Divider()
                            .padding(2)
                        
                        ForEach(updateDetails, id: \.self) { update in
                            
                            HStack {
                                
                                if let icon = update.icon {
                                    
                                    AsyncImage(url: URL(string: icon)) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(height: 36)
                                        
                                    } placeholder: {
                                        Image("DefaultLogo")
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(6)
                                            .redacted(reason: .placeholder)
                                            .overlay(
                                                ProgressView()
                                            )
                                            .frame(width: 36, height: 36)
                                    }
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
                                    //                            Text(NSLocalizedString("UPDATE", comment: ""))
                                    //                                .font(.system(.body, design: .rounded))
                                    ////                                .fontWeight(.regular)
                                    //                                .foregroundColor(.secondary)
                                    //                                .padding(.vertical, 4)
                                    //                                .padding(.horizontal)
                                    //                                .background(Color.gray.opacity(0.2))
                                    //                                .clipShape(Capsule())
                                    if appCatalogController.appsUpdating.contains(update.id) {
                                        Ellipse()
                                            .foregroundColor(Color.gray.opacity(0.5))
                                            .overlay(
                                                ProgressView()
                                                    .scaleEffect(0.5)
                                            )
                                            .frame(width: 26, height: 26)
                                            .padding(.leading, 10)
                                    } else {
                                        Ellipse()
                                            .foregroundColor(Color.gray.opacity(0.5))
                                            .overlay(
                                                Image(systemName: "arrow.down")
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
            }
        }
        // Set frame to 250 to allow multiline text
//        .frame(width: 300)
//        .fixedSize()
//        .padding()
        .unredacted()
        .task {
            getAppUpdates()
        }
    }
    
    func getAppUpdates() {
        let defaults = UserDefaults(suiteName: "nl.root3.catalog")
        
        if let encodedAppUpdates = defaults?.object(forKey: "UpdateDetails") as? Data {
            let decoder = JSONDecoder()
            if let decodedAppUpdates = try? decoder.decode([InstalledAppItem].self, from: encodedAppUpdates) {
                DispatchQueue.main.async {
                    updateDetails = decodedAppUpdates
                }
            }
        }
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
    
    // MARK: - Function to update app using App Catalog
    func updateApp(bundleID: String) {
        
        let command = "/usr/local/bin/catalog -i \(bundleID)"
        
        // Add bundle ID to apps currently updating
        appCatalogController.appsUpdating.append(bundleID)
        
        do {
            try ExecutionService.executeScript(command: command) { exitCode in
                
                if exitCode == 0 {
                    print("App \(bundleID) successfully updated")
                } else {
                    print("Failed to update app \(bundleID)")
                }
                
                // Stop update spinner
                if appCatalogController.appsUpdating.contains(bundleID) {
                    if let index = appCatalogController.appsUpdating.firstIndex(of: bundleID) {
                        DispatchQueue.main.async {
                            appCatalogController.appsUpdating.remove(at: index)
                        }
                    }
                }
                
            }
        } catch {
            print("Failed to update app \(bundleID). Error in PrivilegedHelperTool")
            
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
