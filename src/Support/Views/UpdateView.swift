//
//  MoreInfoView.swift
//  Support
//
//  Created by Jordy Witteman on 13/06/2023.
//

import SwiftUI

struct UpdateView: View {
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    var color: Color
    
    @State private var showPopover: Bool = false
            
    var body: some View {
        
        VStack {
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                Text("More Info")
                    .foregroundColor(color)
                    .font(.system(.subheadline, design: .rounded))
                    .padding(.horizontal, 6)
                    .clipShape(Capsule())
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color, lineWidth: 1)
                    )
                    .padding(4)
            }
        }
        .padding(4)
        .popover(isPresented: $showPopover) {
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                                        
                    Text("Managed Updates Available")
                        .font(.system(.headline, design: .rounded))
                    
                    Spacer()
                    
                    Button(action: {
                        openSoftwareUpdate()
                    }) {
                        Text("Update Now")
                    }
                    
                }
                .fixedSize()
                
                Divider()
                    .padding(2)
                
                ForEach(computerinfo.recommendedUpdates, id: \.self) { update in
                    
                    Text("•\t\(update.displayName)")
                        // Set frame to 250 to allow multiline text
//                        .frame(width: 300)
                        .fixedSize()
                    
                }
                
                if preferences.updateText != "" {
                    
                    Divider()
                        .padding(2)
                    
                    // Supports for markdown through a variable:
                    // https://blog.eidinger.info/3-surprises-when-using-markdown-in-swiftui
                    Text(.init(preferences.updateText))
                        .font(.system(.body, design: .rounded))
                        // Set frame to 250 to allow multiline text
                        .frame(width: 300)
                        .fixedSize()
                }

            }
            .padding()
        }
        .onTapGesture {
            showPopover.toggle()
        }
    }
    
    // Open URL
    func openSoftwareUpdate() {
        
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate") else {
            return
        }

        NSWorkspace.shared.open(url)
        
        // Close the popover
        NSApp.deactivate()

    }
}
