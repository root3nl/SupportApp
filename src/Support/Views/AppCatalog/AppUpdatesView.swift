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
    
    @State var updateDetails: [CatalogItem] = [
        CatalogItem(id: "com.google.Chrome", name: "Google Chrome", iconThumbnail: "https://imagedelivery.net/-IT6z0z0Ec5yEiYj3DvVjg/e8a3c353f3a3b6c17a4787401a70b1b2962c7eb0/public", lastKnownVersion: "118.0.5993"),
        CatalogItem(id: "org.mozilla.firefox", name: "Firefox", iconThumbnail: "https://imagedelivery.net/-IT6z0z0Ec5yEiYj3DvVjg/9e32756554c350bba99d7f64e239e1ba46479a2b/public", lastKnownVersion: "118.0.2"),
        CatalogItem(id: "com.nonstrict.Bezel-direct", name: "Bezel", iconThumbnail: "https://imagedelivery.net/-IT6z0z0Ec5yEiYj3DvVjg/3b5a937520532c6fd5cefc621ed220faf7cba396/public", lastKnownVersion: "1.0.2"),
        CatalogItem(id: "com.1password.1password", name: "1Password", iconThumbnail: "https://imagedelivery.net/-IT6z0z0Ec5yEiYj3DvVjg/8894cfb90d1ef5fabe711357b74d0dbde0da4361/public", lastKnownVersion: "8.10.18")
    ]
            
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
                }
                
                Divider()
                    .padding(2)
                
                ForEach(updateDetails, id: \.self) { update in
                    
                    HStack {
                        
                        if #available(macOS 12, *) {
                            if let icon = update.iconThumbnail {
                                
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
                        }
                        
                        VStack(alignment: .leading) {
                            
                            Text(update.name ?? "")
                                .font(.system(.headline, design: .rounded))
                            
                            Text(update.lastKnownVersion ?? "")
                                .foregroundColor(.secondary)
                                .font(.system(.subheadline, design: .rounded))
                            
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            Text(NSLocalizedString("UPDATE", comment: ""))
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal)
                                .background(color)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        
                    }
                    
                }
                
            } else {
                
                HStack {
                    
                    Spacer()
                    
                    VStack {
                        
                        Text(NSLocalizedString("YOUR_MAC_IS_UP_TO_DATE", comment: ""))
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.medium)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .modify {
                                if #available(macOS 12, *) {
                                    $0.symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, color)
                                } else {
                                    $0.foregroundColor(color)

                                }
                            }
                        
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
