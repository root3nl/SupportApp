//
//  HeaderView.swift
//  Support
//
//  Created by Jordy Witteman on 11/07/2022.
//

import SwiftUI

struct HeaderView: View {
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        // MARK: - Horizontal stack with Title and Logo
        HStack(spacing: 10) {
            
            // Supports for markdown through a variable:
            Text(.init(preferences.title))
                .font(.system(size: 20, design: .rounded))
                .fontWeight(.medium)

            Spacer()
            
            // Logo shown in the top right corner
            if colorScheme == .light && defaults.string(forKey: "Logo") != nil {
                Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "Logo")!) ?? NSImage(named: "DefaultLogo"))!)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
            // Show different logo in Dark Mode when LogoDarkMode is also set
            } else if colorScheme == .dark && defaults.string(forKey: "Logo") != nil {
                if defaults.string(forKey: "LogoDarkMode") != nil {
                    Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "LogoDarkMode")!) ?? NSImage(named: "DefaultLogo"))!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 48)
                } else if defaults.string(forKey: "Logo") != nil && defaults.string(forKey: "LogoDarkMode") == nil {
                    Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "Logo")!) ?? NSImage(named: "DefaultLogo"))!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 48)
                } else {
                    Image("DefaultLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 48)
                }
            // Show default logo in all other cases
            } else {
                Image("DefaultLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
            }
            
        }
        .foregroundColor(Color.primary)
        .padding(.leading, 16.0)
        .padding(.trailing, 10.0)
        .padding(.top, 10.0)
        .unredacted()
    }
}
