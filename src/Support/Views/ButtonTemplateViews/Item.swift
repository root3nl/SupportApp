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
    var loading: Bool?
    var linkPrefKey: String?
//    var updateView: Bool?
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
    
    // Get computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
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
                    
                    Text(title.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo))
                        .font(.system(.body, design: .rounded)).fontWeight(.medium)
                        .lineLimit(2)
                    
                    if subtitle != "" && hoverView && showSubtitle {
                        // Show the subtitle when hover animation is enabled
                        Text(subtitle?.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo) ?? "")
                            .font(.system(.subheadline, design: .rounded))
                            .lineLimit(2)
                        
                    } else if !animate {
                        // Always show the subtitle when hover animation is disabled
                        Text(subtitle?.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo) ?? "")
                            .font(.system(.subheadline, design: .rounded))
                            .lineLimit(2)
                            // Show placeholder when no initial value is set for Custom Info Items
                            .redacted(reason: (subtitle == "KeyPlaceholder") ? .placeholder: .init())
                        
                    }
                }
                
                Spacer()
            }
            
            // Optionally show notification badge with counter
            if notificationBadge != nil && notificationBadge! > 0 {
                NotificationBadgeView(badgeCounter: notificationBadge!)
            }
            
            // Optionally show notification badge with warning
            if notificationBadgeBool ?? false {
                NotificationBadgeTextView(badgeCounter: "!")
            }
            
//            if updateView != nil && notificationBadge! > 0 {
//                UpdateView(color: symbolColor)
//            }
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
                Task {
                    await runPrivilegedCommand()
                }
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
//        NSApp.deactivate()
        
        // Close popover
        appDelegate.togglePopover(nil)

    }
    
    // Run a command as the user
    func runCommand() {
        let task = Process()
        let pipe = Pipe()
        
        let command = link?.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo)
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", "\(command ?? "")"]
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
//        NSApp.deactivate()
        
        // Close popover
        appDelegate.togglePopover(nil)
    }
    
    // MARK: - Function to run privileged command or script
    func runPrivilegedCommand() async {
        
        logger.log("Trying to run privileged command or script...")
        
        let defaults = UserDefaults.standard
        
        // Exit when no command or script was found
        guard let privilegedCommand = link else {
            logger.error("Privileged command or script was not found")
            return
        }
        
        // Check value comes from a Configuration Profile. If not, the command or script may be maliciously set and needs to be ignored
        guard defaults.objectIsForced(forKey: linkPrefKey!) == true else {
            logger.error("Command or script \(privilegedCommand, privacy: .public) is not set by an administrator and is not trusted. Action will not be executed")
            return
        }
        
        // Verify permissions
        guard FileUtilities().verifyPermissions(pathname: privilegedCommand) else {
            return
        }
        
        do {
            try ExecutionService.executeScript(command: privilegedCommand) { exitCode in
                
                guard exitCode == 0 else {
                    self.logger.error("Error while running privileged script or command. Exit code: \(exitCode, privacy: .public)")
                    return
                }

            }
        } catch {
            logger.log("Failed to run privileged script or command. Error: \(error.localizedDescription)")
        }
    }
}
