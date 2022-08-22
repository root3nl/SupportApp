//
//  PopoverAlertView.swift
//  Support
//
//  Created by Jordy Witteman on 22/08/2022.
//

import SwiftUI

@available(macOS 12.0, *)
struct PopoverAlertView: View {
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    @Binding var uptimeAlert: Bool
    var title: String
    var message: String
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "NotificationIcon")!) ?? NSImage(named: "DefaultLogo"))!)
                .resizable()
                .scaledToFit()
                .frame(height: 64)
            
            Text(title)
                // Set frame to 250 to allow multiline text
//                .padding(.horizontal)
                .frame(width: 250)
                .fixedSize()
                .font(.system(.headline, design: .rounded))
            
            Text(message)
                // Set frame to 250 to allow multiline text
//                .padding(.horizontal)
                .frame(width: 250)
                .fixedSize()
                .font(.system(.body, design: .rounded))
                        
            Button("Close", action: {
                self.uptimeAlert.toggle()
            })
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
//        .frame(idealWidth: 250, maxWidth: 250, idealHeight: 200, maxHeight: 200)
    }
}
