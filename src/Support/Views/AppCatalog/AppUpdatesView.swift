//
//  AppUpdatesView.swift
//  Support
//
//  Created by Jordy Witteman on 21/10/2023.
//

import SwiftUI

struct AppUpdatesView: View {
        
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
      
    // State of UpdateView popover
    @State private var showPopover: Bool = false
    
    // Update counter
    var updateCounter: Int
    var color: Color
    
    @State var updateDetails: [InstalledAppItem] = []
            
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            if updateCounter > 0 {
                
                HStack {
                    
                    Text(updateCounter > 0 ? NSLocalizedString("UPDATES_AVAILABLE", comment: "") : NSLocalizedString("NO_UPDATES_AVAILABLE", comment: ""))
                        .font(.system(.headline, design: .rounded))
                    
                    Spacer()
                    
                    Button(action: {
                        showPopover = false
                        openAppCatalog()
                    }) {
                        Text(NSLocalizedString("APP_CATALOG", comment: ""))
                    }
                    .buttonStyle(.borderedProminent)
                }
                
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
                            openAppCatalog()
                        }) {
//                            Text(NSLocalizedString("UPDATE", comment: ""))
//                                .font(.system(.body, design: .rounded))
////                                .fontWeight(.regular)
//                                .foregroundColor(.secondary)
//                                .padding(.vertical, 4)
//                                .padding(.horizontal)
//                                .background(Color.gray.opacity(0.2))
//                                .clipShape(Capsule())
                            Image(systemName: "arrow.down")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(7)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
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
                            .foregroundStyle(.white, color)
                        
                    }
                    
                    Spacer()
                    
                }
                
            }
        }
        // Set frame to 250 to allow multiline text
        .frame(width: 300)
        .fixedSize()
        .padding()
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
    }
    
}
