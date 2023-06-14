//
//  MoreInfoView.swift
//  Support
//
//  Created by Jordy Witteman on 13/06/2023.
//

import os
import SwiftUI

struct UpdateView: View {
    
    let logger = Logger(subsystem: "nl.root3.support", category: "SoftwareUpdate")
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
      
    // State of UpdateView popover
    @State private var showPopover: Bool = false
    
    // Update counter
    var updateCounter: Int
            
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                
                Text(updateCounter > 0 ? "Updates Available" : "No updates available")
                    .font(.system(.headline, design: .rounded))
                
                Spacer()
                
                Button(action: {
                    showPopover = false
                    openSoftwareUpdate()
                }) {
                    if updateCounter > 0 {
                        Text("Update Now")
                    } else {
                        Text("Settings")
                    }
                }
                .modify {
                    if #available(macOS 12, *) {
                        if updateCounter > 0 {
                            $0.buttonStyle(.borderedProminent)
                        } else {
                            $0.buttonStyle(.bordered)
                        }
                    }
                }
            }
            
            Divider()
                .padding(2)
            
            if updateCounter > 0 {
                
                ForEach(computerinfo.recommendedUpdates, id: \.self) { update in
                    
                    Text("•\t\(update.displayName)")
                        .font(.system(.body, design: .rounded))
                    
                }
                
                if preferences.updateText != "" {
                    
                    Divider()
                        .padding(2)
                    
                    HStack {
                        
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                        
                        // Supports for markdown through a variable:
                        // https://blog.eidinger.info/3-surprises-when-using-markdown-in-swiftui
                        Text(.init(preferences.updateText))
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    
                }
            } else {
                
                HStack {
                    
                    Spacer()
                    
                    VStack {
                        
                        Text("You're all set")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.medium)
                        
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                        
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
    
    // Open URL
    func openSoftwareUpdate() {
        
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate") else {
            return
        }

        NSWorkspace.shared.open(url)

        DispatchQueue.global().async {
            let process = Process()
            let outputPipe = Pipe()
            
            process.standardOutput = outputPipe
            process.standardError = outputPipe
            process.launchPath = "/usr/sbin/softwareupdate"
            process.arguments = ["-d", "-a"]
            
            do {
                try process.run()
            } catch {
                logger.error("\(error.localizedDescription)")
                return
            }
            
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)!
            
            // Stream script output to Unified Logging
            outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if data.isEmpty {
                    outputPipe.fileHandleForReading.readabilityHandler = nil
                    return
                }
                if let outputString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines) {
                    logger.log("\(outputString, privacy: .public)")
                }
            }
            
            process.waitUntilExit()

        }
        
        // Close the popover
        NSApp.deactivate()

    }
}
