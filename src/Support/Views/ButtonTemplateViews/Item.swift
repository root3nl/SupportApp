//
//  Item.swift
//  Support
//
//  Created by Jordy Witteman on 30/12/2020.
//

import os
import SwiftUI

struct Item: View {
    var title: String
    var subtitle: String?
    var linkType: String?
    var link: String?
    var image: String
    var symbolColor: Color
    var notificationBadge: Int?
    var notificationBadgeBool: Bool?
    var deferralsRemaining: Int?
    var loading: Bool?
    var linkPrefKey: String?
    
    // Vars to activate hover effect
    @State var hoverEffectEnable: Bool
    @State var hoverView = false
    
    // Var to show subtitle when on hover
    @State var showSubtitle = false
    
    // Var to show alert when no or invalid BundleID is given
    @State var showingAlert = false
    
    // Get preferences or default values
    @ObservedObject var preferences = Preferences()
    
    // Declare unified logging
    let logger = Logger(subsystem: "nl.root3.support", category: "Action")
    
    // Enable animation
    var animate: Bool
    
    var body: some View {
        
        ZStack {
            
            HStack {
                if loading ?? false {
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
                        .foregroundColor(hoverView && link != "" ? .primary : symbolColor)
                        .overlay(
                            Image(systemName: image)
                                .foregroundColor(hoverView && link != "" ? Color("hoverColor") : Color.white)
                        )
                        .frame(width: 26, height: 26)
                        .padding(.leading, 10)
                }
                
                VStack(alignment: .leading) {
                    
                    Text(title)
                        .font(.system(.body, design: .rounded)).fontWeight(.medium)
                        .lineLimit(2)
                    
                    if subtitle != "" && hoverView && showSubtitle {
                        // Show the subtitle when hover animation is enabled
                        Text(subtitle ?? "")
                            .font(.system(.subheadline, design: .rounded))
                            .lineLimit(2)
                        
                    } else if !animate {
                        // Always show the subtitle when hover animation is disabled
                        Text(subtitle ?? "")
                            .font(.system(.subheadline, design: .rounded))
                            .lineLimit(2)
                            // Show placeholder when no initial value is set for Custom Info Items
                            .redacted(reason: (subtitle == "KeyPlaceholder") ? .placeholder: .init())
                        
                    }
                }
                
                Spacer()
            }
            
            if notificationBadge != nil && notificationBadge! > 0 {
                NotificationBadgeView(badgeCounter: notificationBadge!, deferralsRemaining: deferralsRemaining)
            }
            
            if notificationBadgeBool ?? false {
                NotificationBadgeTextView(badgeCounter: "!")
            }
        }
        .frame(width: 176, height: 60)
        .background(hoverView && hoverEffectEnable && link != "" ? EffectsView(material: NSVisualEffectView.Material.windowBackground, blendingMode: NSVisualEffectView.BlendingMode.withinWindow) : EffectsView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
        .cornerRadius(10)
        // Apply gray and black border in Dark Mode to better view the buttons like Control Center
        .modifier(DarkModeBorder())
        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(NSLocalizedString("An error occurred", comment: "")), message: Text(preferences.errorMessage), dismissButton: .default(Text("OK")))
        }
        .onHover() {
            hover in self.hoverView = hover
            
            // Animation when hovering
            if animate {
                withAnimation(.easeInOut) {
                    self.showSubtitle.toggle()
                }
            }
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
        
        // Close the popover
        NSApp.deactivate()

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
