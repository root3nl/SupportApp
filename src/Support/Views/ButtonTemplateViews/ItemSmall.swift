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
    var configurationItem: ConfiguredItem?
    
    // Access AppDelegate
    @EnvironmentObject private var appDelegate: AppDelegate
    
    // Get computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get user info from functions in class
    @EnvironmentObject var userinfo: UserInfo
    
    // Declare unified logging
    let logger = Logger(subsystem: "nl.root3.support", category: "Action")
    
    // Var to activate hover effect
    @State var hoverView = false
    
    // Var to show alert when no or invalid BundleID is given
    @State var showingAlert = false
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    
    // Get local preferences for Configurator Mode
    @EnvironmentObject var localPreferences: LocalPreferences
    
    var body: some View {
        
        if #available(macOS 26, *) {
            ZStack {
                
                VStack {
                    
                    if loading ?? false {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 22, height: 22)
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: image)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                        //                        .foregroundColor(hoverView && link != "" ? .primary : symbolColor)
                        //                        .symbolRenderingMode(.hierarchical)
                            .frame(width: 22, height: 22)
                            .accessibilityHidden(true)
                    }
                    
                    Spacer()
                    
                    // Optionally show a subtitle when user hovers over button
                    if subtitle != "" && hoverView {
                        Text(subtitle?.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo) ?? "")
                            .font(.system(.subheadline, design: .default))
                            .foregroundStyle(.white)
                            .frame(width: 80)
                            .lineLimit(1)
                    } else {
                        Text(title.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo))
                            .font(.system(.subheadline, design: .default))
                            .foregroundStyle(.white)
                            .frame(width: 80)
                            .lineLimit(1)
                    }
                }
                .padding(10)
                
                // Optionally show remove item button
                if preferences.editModeEnabled && !preferences.showItemConfiguration {
                    RemoveItemButtonView(configurationItem: configurationItem)
                }
            }
            .frame(width: 114, height: 64)
            .contentShape(Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title + ", " + (subtitle ?? ""))
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(NSLocalizedString("An error occurred", comment: "")), message: Text(preferences.errorMessage), dismissButton: .default(Text("OK")))
            }
            .onHover() {
                hover in self.hoverView = hover
            }
            .onTapGesture() {
                if preferences.editModeEnabled {
                    guard let configurationItem else {
                        return
                    }
                    localPreferences.currentConfiguredItem = configurationItem
                    preferences.showItemConfiguration.toggle()
                    
                } else {
                    tapGesture()
                }
            }
            .modifier(GlassEffectModifier(hoverView: hoverView, hoverEffectEnable: true))
            .animation(.bouncy, value: hoverView)
        } else {
            ZStack {
                VStack {
                    
                    if loading ?? false {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 24, height: 24)
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: image)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(hoverView && link != "" ? .primary : symbolColor)
                            .frame(width: 24, height: 24)
                            .accessibilityHidden(true)
                    }
                    
                    Spacer()
                    
                    // Optionally show a subtitle when user hovers over button
                    if subtitle != "" && hoverView {
                        Text(subtitle?.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo) ?? "")
                            .font(.system(.subheadline, design: .rounded))
                    } else {
                        Text(title.replaceLocalVariables(computerInfo: computerinfo, userInfo: userinfo))
                            .font(.system(.subheadline, design: .rounded))
                        
                    }
                }
                .padding(10)
                
                // Optionally show remove item button
                if preferences.editModeEnabled && !preferences.showItemConfiguration {
                    RemoveItemButtonView(configurationItem: configurationItem)
                }
            }
            .frame(width: 114, height: 60)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title + ", " + (subtitle ?? ""))
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
                if preferences.editModeEnabled {
                    guard let configurationItem else {
                        return
                    }
                    localPreferences.currentConfiguredItem = configurationItem
                    preferences.showItemConfiguration.toggle()
                    
                } else {
                    tapGesture()
                }
            }
        }
    }
    
    func tapGesture() {
        // Don't do anything when no link is specified
        guard link != "" else {
            logger.debug("No link specified for \(title, privacy: .public), button disabled...")
            return
        }
        
        if linkType == "App" {
            openApp()
        } else if linkType == "URL" {
            openLink()
        } else if linkType == "Command" {
            runCommand()
            // MARK: - DistributedNotification is deprecated, use PrivilegedScript instead
        } else if linkType == "DistributedNotification" || linkType == "PrivilegedScript" {
            Task {
                await runPrivilegedCommand()
            }
        } else {
                self.showingAlert.toggle()
                logger.error("Invalid Link Type: \(linkType!)")
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
        
        // Close popover
        appDelegate.togglePopover(nil)
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
    
    // MARK: - Function to run privileged script
    func runPrivilegedCommand() async {
        
        logger.log("Trying to run privileged script...")
        
        let defaults = UserDefaults.standard
        
        // Exit when no script was found
        guard let privilegedCommand = link else {
            logger.error("Privileged script was not found")
            return
        }
        
        // Check value comes from a Configuration Profile. If not, the script may be maliciously set and needs to be ignored
        guard defaults.objectIsForced(forKey: linkPrefKey!) == true else {
            logger.error("Action \(privilegedCommand, privacy: .public) is not set by an administrator and is not trusted. Action will not be executed")
            return
        }
        
        // Verify permissions
        guard FileUtilities().verifyPermissions(pathname: privilegedCommand) else {
            return
        }
        
        do {
            try ExecutionService.executeScript(command: privilegedCommand) { exitCode in
                
                if exitCode == 0 {
                    self.logger.debug("Privileged script ran successfully with exit code 0")
                } else {
                    self.logger.error("Error while running privileged script. Exit code: \(exitCode, privacy: .public)")
                }

            }
        } catch {
            logger.log("Failed to run privileged script. Error: \(error.localizedDescription, privacy: .public)")
        }
    }
}

