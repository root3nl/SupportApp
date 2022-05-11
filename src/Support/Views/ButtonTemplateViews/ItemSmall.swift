//
//  ItemSmall.swift
//  Support
//
//  Created by Jordy Witteman on 30/12/2020.
//

import os
import SwiftUI

struct ItemSmall: View {
    var title: String
    var subtitle: String?
    var linkType: String?
    var link: String?
    var image: String
    var symbolColor: Color
    var loading: Bool?
    var linkPrefKey: String?
    
    // Declare unified logging
    let logger = Logger(subsystem: "nl.root3.support", category: "Action")
    
    // Var to activate hover effect
    @State var hoverView = false
    
    // Var to show alert when no or invalid BundleID is given
    @State var showingAlert = false
    
    // Get preferences or default values
    @ObservedObject var preferences = Preferences()
    
    var body: some View {
        
        VStack {
        
            if loading ?? false {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: image)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(hoverView && link != "" ? .primary : symbolColor)
                    .frame(width: 24, height: 24)
            }

        Spacer()

            // Optionally show a subtitle when user hovers over button
            if subtitle != "" && hoverView {
                Text(subtitle ?? "")
                    .font(.system(.subheadline, design: .rounded))
            } else {
                Text(title)
                    .font(.system(.subheadline, design: .rounded))

            }
        }
        .padding(.vertical, 10)
        .frame(width: 114, height: 60)
        .background(hoverView && link != "" ? EffectsView(material: NSVisualEffectView.Material.windowBackground, blendingMode: NSVisualEffectView.BlendingMode.withinWindow) : EffectsView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
        .cornerRadius(10)
        // Apply gray and black border in Dark Mode to better view the buttons like Control Center
        .modifier(DarkModeBorder())
        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(NSLocalizedString("An error occurred", comment: "")), message: Text(preferences.errorMessage), dismissButton: .default(Text("OK")))
        }
        .onHover() {
            hover in self.hoverView = hover
        }
        .onTapGesture() {
            // Don't do anything when no link is specified
            guard link != "" else {
                logger.debug("No link specified for \(title), button disabled...")
                return
            }
            
            if linkType == "App" {
                openApp()
            } else if linkType == "URL" {
                openLink()
            } else if linkType == "Command" {
                runCommand()
            } else if linkType == "DistributedNotification" {
                postDistributedNotification()
            } else {
                self.showingAlert.toggle()
                logger.error("Invalid Link Type: \(linkType!)")
            }
        }
    }
    
    // Open application with given Bundle Identifier
    func openApp() {
        
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: link ?? "")
        // Show alert when there is an error
        else {
            self.showingAlert.toggle()
            return }
        let configuration = NSWorkspace.OpenConfiguration()
        
        NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
    }
    
    // Open URL
    func openLink() {
        guard let url = URL(string: link ?? "")
        // Show alert when there is an error
        else {
            self.showingAlert.toggle()
            return }
        NSWorkspace.shared.open(url)
    }
    
    // Run a command as the user
    func runCommand() {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", "\(link ?? "")"]
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
                
        if !task.isRunning {
            let status = task.terminationStatus
            if status == 0 {
                logger.debug("\(output)")
            } else {
                logger.error("\(output)")
                self.showingAlert.toggle()
            }
        }
        
        // Close the popover
        NSApp.deactivate()
    }
    
    // Post Distributed Notification
    func postDistributedNotification() {
        logger.debug("Posting Distributed Notification: nl.root3.support.Action")
        
        // Initialize distributed notifications
        let nc = DistributedNotificationCenter.default()
        
        // Define the NSNotification name
        let name = NSNotification.Name("nl.root3.support.Action")
        
        // Post the notification including all sessions to support LaunchDaemons
        nc.postNotificationName(name, object: linkPrefKey, userInfo: nil, options: [.postToAllSessions, .deliverImmediately])
        
    }
}
