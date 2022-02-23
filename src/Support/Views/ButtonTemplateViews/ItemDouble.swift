//
//  ItemDouble.swift
//  Support
//
//  Created by Jordy Witteman on 29/04/2021.
//

import os
import SwiftUI

struct ItemDouble: View {
    
    var title: String
    var secondTitle: String
    var subtitle: String
    var secondSubtitle: String
    var linkType: String?
    var link: String?
    var image: String
    var symbolColor: Color
    var notificationBadge: Int?
    var notificationBadgeBool: Bool?
    
    // Declare unified logging
    let logger = Logger(subsystem: "nl.root3.support", category: "Action")
    
    // Vars to activate hover effect
    @State var hoverEffectEnable: Bool
    @State var hoverView = false
    
    @State var showSubtitle = false
    
    // Var to show alert when no or invalid BundleID is given
    @State var showingAlert = false
    
    // Get preferences or default values
    @ObservedObject var preferences = Preferences()
    
    // Enable animation
    //    var animate: Bool
    
    var body: some View {
        
        ZStack {
            
            HStack {
                Ellipse()
                    .foregroundColor(hoverView ? .primary : symbolColor)
                    .overlay(
                        Image(systemName: image)
                            .foregroundColor(hoverView ? Color("hoverColor") : Color.white)
                    )
                    .frame(width: 26, height: 26)
                    .padding(.leading, 10)
                
                VStack(alignment: .leading) {
                    
                    Text(hoverView && hoverEffectEnable ? secondTitle : title)
                        .font(.system(.body, design: .rounded)).fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text(hoverView && hoverEffectEnable ? secondSubtitle : subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            if notificationBadge != nil && notificationBadge! > 0 {
                NotificationBadgeView(badgeCounter: notificationBadge!)
            }
            
            if notificationBadgeBool ?? false {
                NotificationBadgeTextView(badgeCounter: "!")
            }
        }
        .frame(width: 176, height: 60)
        .background(hoverView && hoverEffectEnable ? EffectsView(material: NSVisualEffectView.Material.windowBackground, blendingMode: NSVisualEffectView.BlendingMode.withinWindow) : EffectsView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
        .cornerRadius(10)
        // Apply gray and black border in Dark Mode to better view the buttons like Control Center
        .modifier(DarkModeBorder())
        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
        .alert(isPresented: $showingAlert) {
            // FIXME: - Adjust when Jamf Connect Password Change can be triggered
            // https://docs.jamf.com/jamf-connect/2.9.1/documentation/Jamf_Connect_URL_Scheme.html#ID-00005c31
            Alert(title: Text(linkType == "JamfConnectPasswordChangeException" ? NSLocalizedString("OPEN_JAMF_CONNECT_MANUALLY", comment: "") : NSLocalizedString("An error occurred", comment: "")), message: Text(linkType == "JamfConnectPasswordChangeException" ? NSLocalizedString("OPEN_JAMF_CONNECT_MANUALLY_TEXT", comment: "") : preferences.errorMessage), dismissButton: .default(Text("OK")))
        }
        .onHover() {
            hover in self.hoverView = hover
        }
        .onTapGesture() {
            if linkType == "App" {
                openApp()
            } else if linkType == "URL" {
                openLink()
            } else if linkType == "Command" {
                runCommand()
            } else if linkType == "DistributedNotification" {
                postDistributedNotification()
            } else {
                // FIXME: - Asjust when Jamf Connect Password Change can be triggered
                // https://docs.jamf.com/jamf-connect/2.9.1/documentation/Jamf_Connect_URL_Scheme.html#ID-00005c31
                if linkType == "JamfConnectPasswordChangeException" {
                    self.showingAlert.toggle()
                } else {
                    self.showingAlert.toggle()
                    logger.error("Invalid Link Type: \(linkType!)")
                }
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
        
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: .utf8)!
        
        if !task.isRunning {
            let status = task.terminationStatus
            if status == 0 {
//                logger.debug("\(output)")
            } else {
//                logger.error("\(output)")
                self.showingAlert.toggle()
            }
        }
        
        // Close the popover
        NSApp.deactivate()
    }
    
    // Post Distributed Notification
    func postDistributedNotification() {
        logger.debug("Posting Distributed Notification: \(link ?? "NoLinkSpecified")")
        
        // Initialize distributed notifications
        let nc = DistributedNotificationCenter.default()
        
        // Define the NSNotification name
        let name = NSNotification.Name(link ?? "NoLinkSpecified")
        
        // Post the notification including all sessions to support LaunchDaemons
        nc.postNotificationName(name, object: nil, userInfo: nil, options: [.deliverImmediately, .postToAllSessions])
        
        // Close the popover
        NSApp.deactivate()
    }
    
}

