//
//  UserInfo.swift
//  Support
//
//  Created by Jordy Witteman on 16/05/2021.
//

import Foundation
import OpenDirectory
import os
import SwiftUI

// Class to get user based info
class UserInfo: ObservableObject {
    
    // Get preferences or default values
    @ObservedObject var preferences = Preferences()
    
    let session = ODSession.default()
    var records = [ODRecord]()
    
    // Get current logged in user and the user's uid
    let currentConsoleUserName: String = NSUserName()
    let uid: String = String(getuid())
    
    // Declare unified logging
    let logger = Logger(subsystem: "nl.root3.support", category: "UserInfo")
    
    // Variable for the password expiry in days used in the complete password expiry string
    var userPasswordExpiresInDays = Int()
     
    // Complete string to show in info item
    @Published var userPasswordExpiryString: String = ""
    
    // Boolean to show alert and menu bar icon notification badge
    @Published var passwordExpiryLimitReached: Bool = false
    
    // Set preference suite to "com.jamf.connect.state"
    let defaultsJamfConnect = UserDefaults(suiteName: "com.jamf.connect.state")
    
    var passwordString: String {
        if preferences.passwordType == "Apple" {
            return userPasswordExpiryString
        } else if preferences.passwordType == "JamfConnect" {
            return jcExpiryDate()
        } else {
            return "Unknown password source"
        }
    }
    
    // MARK: - Function to get the user record
    // https://gitlab.com/Mactroll/NoMAD/blob/8786704ccf1ae4c1ec0f5efec60fa27a0f4a871f/NoMAD/NoMADUser.swift
    func getCurrentUserRecord() {
        
        DispatchQueue.global().async { [self] in
            do {
                let node = try ODNode.init(session: session, type: UInt32(kODNodeTypeAuthentication))
                //            let node = try ODNode.init(session: session, type: UInt32(kODNodeTypeLocalNodes))
                let query = try ODQuery.init(node: node, forRecordTypes: kODRecordTypeUsers, attribute: kODAttributeTypeRecordName, matchType: UInt32(kODMatchEqualTo), queryValues: currentConsoleUserName, returnAttributes: kODAttributeTypeNativeOnly, maximumResults: 0)
                records = try query.resultsAllowingPartial(false) as! [ODRecord]
            } catch {
                logger.error("Unable to get local user account ODRecords")
                userPasswordExpiryString = String(error.localizedDescription)
            }
        }
        
        // We may have gotten multiple ODRecords that match username,
        // So make sure it also matches the UID.
        
        // Perform on background thread
        DispatchQueue.global().async { [self] in

        for case let record in records {
            let attribute = "dsAttrTypeStandard:UniqueID"
            if let odUid = try? String(describing: record.values(forAttribute: attribute)[0]) {
                if ( odUid == uid) {
                    // Get seconds until password expires
                    let userPasswordExpires = record.secondsUntilPasswordExpires
                    
                    // Get the account type
                    let accountType = record.recordType
                    logger.debug("Account Type: \(accountType ?? "")")
                    
                    // Publish values back on the main thread
                    DispatchQueue.main.async {
                        
                        // Show Today when password expires in less than 24 hours
                        if userPasswordExpires < 86400 && userPasswordExpires > 0 {
                            userPasswordExpiryString = NSLocalizedString("Expires Today", comment: "")
                            
                            // Show Password never expires when password policy is disabled
                        } else if userPasswordExpires == -1 {
                            userPasswordExpiryString = NSLocalizedString("Never Expires", comment: "")
                            
                            // Show Password is expired
                        } else if userPasswordExpires == 0 {
                            userPasswordExpiryString = NSLocalizedString("Expired", comment: "")
                            // Show x days until expiry
                        } else {
                            userPasswordExpiresInDays = Int(userPasswordExpires / 60 / 60 / 24)
                            if userPasswordExpiresInDays > 1 {
                                userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(userPasswordExpiresInDays)" + NSLocalizedString(" days", comment: ""))
                            } else {
                                userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(userPasswordExpiresInDays)" + NSLocalizedString(" day", comment: ""))
                            }
                        }
                        
                        // Determine if notification badge with exclamation mark should be shown in tile
                        if preferences.passwordExpiryLimit > 0 && userPasswordExpiresInDays <= preferences.passwordExpiryLimit {
                            // Only apply when password policy is enabled
                            if userPasswordExpires != -1 {
                                // Set boolean to true to show alert and menu bar icon notification badge
                                passwordExpiryLimitReached = true
                            }
                        } else {
                            // Set boolean to false to hide alert and menu bar icon notification badge
                            passwordExpiryLimitReached = false
                        }
                        
                        // Post changes to notification center
                        NotificationCenter.default.post(name: Notification.Name.passwordExpiryLimit, object: nil)
                        
                    }
                    
                    logger.debug("Password expiry in seconds: \(userPasswordExpires)")
                    logger.debug("Password expiry in days: \(self.userPasswordExpiresInDays)")
                }
            }
        }
        }
    }
    
    // MARK: - Function to get Jamf Connect password expiry
    func jcExpiryDate() -> String {
        guard let expiryDate = defaultsJamfConnect?.object(forKey: "ComputedPasswordExpireDate") as? Date else {
            return NSLocalizedString("Never Expires", comment: "")
        }
        let expiresInDays = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day!
        return (NSLocalizedString("Expires in ", comment: "") + "\(expiresInDays)" + NSLocalizedString(" days", comment: ""))
    }
    
    // MARK: - Expirimental function to change the local Mac password
    
    func changePassword() {
        do {
            let node = try ODNode.init(session: session, type: UInt32(kODNodeTypeAuthentication))
//            let node = try ODNode.init(session: session, type: UInt32(kODNodeTypeLocalNodes))
            let query = try ODQuery.init(node: node, forRecordTypes: kODRecordTypeUsers, attribute: kODAttributeTypeRecordName, matchType: UInt32(kODMatchEqualTo), queryValues: currentConsoleUserName, returnAttributes: kODAttributeTypeNativeOnly, maximumResults: 0)
            records = try query.resultsAllowingPartial(false) as! [ODRecord]
        } catch {
            logger.error("Unable to get local user account ODRecords")
            userPasswordExpiryString = String(error.localizedDescription)
        }
        
        // We may have gotten multiple ODRecords that match username,
        // So make sure it also matches the UID.
        
        for case let record in records {
            let attribute = "dsAttrTypeStandard:UniqueID"
            if let odUid = try? String(describing: record.values(forAttribute: attribute)[0]) {
                if ( odUid == uid) {
                    // Get seconds until password expires
                    
                    if newPassword != verifyNewPassword {
                        logger.error("Passwords do not match...")
                    } else {
                        do {
                            // Change the password
                            try record.changePassword(currentPassword, toPassword: newPassword)
                            passwordChangedAlert = true
                        } catch {
                            logger.error("Error changing password...")
                        }
                        
                        // Empty the textfields
                        currentPassword = ""
                        newPassword = ""
                        verifyNewPassword = ""
                    }
                                        
                } else {
                    logger.debug("Error")
                }
            }
        }
    }
    
    @Published var passwordChangedAlert = false
    
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var verifyNewPassword = ""

}
