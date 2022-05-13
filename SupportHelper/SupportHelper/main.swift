//
//  main.swift
//  SupportHelper
//
//  Created by Jordy Witteman on 02/11/2021.
//

import Foundation
import AppKit
import os

class SupportHelper {

    // Notification name when a button is clicked
    let notificationNameAction = "nl.root3.support.Action"
    
    // Notification name when the Support App popover appears
    let notificationNameSupportAppeared = "nl.root3.support.SupportAppeared"
    
    // Unified Logging
    let logger = Logger(subsystem: "nl.root3.support.helper", category: "Helper")
    
    // Support App UserDefaults
    let supportDefaults = UserDefaults(suiteName: "nl.root3.support")
    
    init() {
        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name(notificationNameAction),
            object: nil,
            queue: nil,
            using: self.gotNotification(notification:)
        )
        
        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name(notificationNameSupportAppeared),
            object: nil,
            queue: nil,
            using: self.gotNotificationSupportAppeared(notification:)
        )
    }
    
    // Function to run script or command when a button is clicked
    func gotNotification(notification: Notification) {
        logger.debug("Received Distributed Notification: \(notification, privacy: .public)")
        
        // Get action from Configuration Profile
        let action = supportDefaults?.string(forKey: notification.object as! String) ?? ""
        guard !action.isEmpty else {
            logger.error("No action defined for key \(notification.object as! String, privacy: .public). Please set this value in the Support App Configuration Profile")
            return
        }
        logger.debug("Action: \(action, privacy: .public)")
        
        // Check value comes from a Configuration Profile. If not, the command or script may be maliciously set and needs to be ignored
        if supportDefaults?.objectIsForced(forKey: notification.object as! String) == true {
            let task = Process()
            task.launchPath = "/bin/zsh"
            task.arguments = ["-c", action]
            task.launch()
        } else {
            logger.error("Action \"\(action, privacy: .public)\" is not set by an administrator and potentially dangerous. Action will not be executed")
        }
    }
    
    // Function to run script or command when the Support App popover appears
    func gotNotificationSupportAppeared(notification: Notification) {
        logger.debug("Received Distributed Notification: \(notification, privacy: .public)")
        
        // Get action from Configuration Profile
        let action = supportDefaults?.string(forKey: "OnAppearAction") ?? ""
        guard !action.isEmpty else {
            logger.error("No action defined for OnAppearAction. Please set this value in the Support App Configuration Profile")
            return
        }
        logger.debug("Action: \(action, privacy: .public)")
        
        // Check value comes from a Configuration Profile. If not, the command or script may be maliciously set and needs to be ignored
        if supportDefaults?.objectIsForced(forKey: "OnAppearAction") == true {
            let task = Process()
            task.launchPath = "/bin/zsh"
            task.arguments = ["-c", action]
            task.launch()
        } else {
            logger.error("Action \"\(action, privacy: .public)\" is not set by an administrator and potentially dangerous. Action will not be executed")
        }
    }
}

let helper = SupportHelper()

dispatchMain()



