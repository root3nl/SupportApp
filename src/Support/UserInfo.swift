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
    
    // Static sign in string
    var signInString = NSLocalizedString("Sign In Here", comment: "")
    
    // Static password change string
    var changeString = NSLocalizedString("Change Now", comment: "")
    
    // Set preference suite to "com.jamf.connect.state"
    let defaultsJamfConnect = UserDefaults(suiteName: "com.jamf.connect.state")
    
    // Set prefence suite to "com.trusourcelabs.NoMAD"
    let defaultsNomad = UserDefaults(suiteName: "com.trusourcelabs.NoMAD")
    
    // Set the password change string when hovering over the password info item. Show the sign in string when not logged in instead of the password change string.
    var passwordChangeString: String {
        if userPasswordExpiryString == signInString {
            return signInString
        } else {
            return changeString
        }
    }
    
    // MARK: -  Set the password change link based on password type
    var passwordChangeLink: String {
        if preferences.passwordType == "Apple" {
            return "open /System/Library/PreferencePanes/Accounts.prefPane"
        } else if preferences.passwordType == "JamfConnect" {
            if defaultsJamfConnect?.bool(forKey: "PasswordCurrent") ?? false {
                // FIXME: - Need an option to change password using Jamf Connect
                // https://docs.jamf.com/jamf-connect/2.9.1/documentation/Jamf_Connect_URL_Scheme.html#ID-00005c31
                return ""
            } else {
                return "open jamfconnect://signin"
            }
        } else if preferences.passwordType == "KerberosSSO" {
            if passwordChangeString == signInString {
                return "app-sso -a \(preferences.kerberosRealm)"
            } else {
                return "app-sso -c \(preferences.kerberosRealm)"
            }
        } else if preferences.passwordType == "Nomad" {
            if defaultsNomad?.bool(forKey: "SignedIn") ?? false {
                return "open nomad://passwordchange"
            } else {
                return "open nomad://signin"
            }
        } else {
            return "open /System/Library/PreferencePanes/Accounts.prefPane"
        }
    }
    
    // MARK: - Function to check which password source to check
    func getCurrentUserRecord() {
        if preferences.passwordType == "Apple" {
            applePasswordExpiryDate()
        } else if preferences.passwordType == "JamfConnect" {
            jcExpiryDate()
        } else if preferences.passwordType == "KerberosSSO" {
            kerbSSOExpiryDate()
        } else if preferences.passwordType == "Nomad" {
            nomadExpiryDate()
        } else if !preferences.passwordType.isEmpty {
            logger.error("Invalid password type: \(self.preferences.passwordType)")
        }
    }
    
    // MARK: - Function to get the user record and password expiry for local and mobile accounts
    // https://gitlab.com/Mactroll/NoMAD/blob/8786704ccf1ae4c1ec0f5efec60fa27a0f4a871f/NoMAD/NoMADUser.swift
    func applePasswordExpiryDate() {
        
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
                        
                        // Publish values back on the main thread
                        DispatchQueue.main.async {
                            
                            // Show Today when password expires in less than 24 hours
                            if userPasswordExpires < 86400 && userPasswordExpires > 0 {
                                self.userPasswordExpiryString = NSLocalizedString("Expires Today", comment: "")
                                
                                // Show Password never expires when password policy is disabled
                            } else if userPasswordExpires == -1 {
                                self.userPasswordExpiryString = NSLocalizedString("Never Expires", comment: "")
                                
                                // Show Password is expired
                            } else if userPasswordExpires == 0 {
                                self.userPasswordExpiryString = NSLocalizedString("Expired", comment: "")
                                // Show x days until expiry
                            } else {
                                self.userPasswordExpiresInDays = Int(userPasswordExpires / 60 / 60 / 24)
                                if self.userPasswordExpiresInDays > 1 {
                                    self.userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(self.userPasswordExpiresInDays)" + NSLocalizedString(" days", comment: ""))
                                } else {
                                    self.userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(self.userPasswordExpiresInDays)" + NSLocalizedString(" day", comment: ""))
                                }
                            }
                            
                            // Determine if notification badge with exclamation mark should be shown in tile
                            if self.preferences.passwordExpiryLimit > 0 && self.userPasswordExpiresInDays <= self.preferences.passwordExpiryLimit {
                                // Only apply when password policy is enabled
                                if userPasswordExpires != -1 {
                                    // Set boolean to true to show alert and menu bar icon notification badge
                                    self.passwordExpiryLimitReached = true
                                }
                            } else {
                                // Set boolean to false to hide alert and menu bar icon notification badge
                                self.passwordExpiryLimitReached = false
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
    func jcExpiryDate() {
        guard defaultsJamfConnect?.bool(forKey: "PasswordCurrent") ?? false else {
            userPasswordExpiryString = signInString
            
            // Set boolean to false to hide alert and menu bar icon notification badge
            passwordExpiryLimitReached = false
            return
        }
        
        guard let expiryDate = defaultsJamfConnect?.object(forKey: "ComputedPasswordExpireDate") as? Date else {
            // Don't show 'Never Expires' because we are not sure Jamf Connect is able to detect it.
            userPasswordExpiryString = NSLocalizedString("Change Now", comment: "")
            
            // Set boolean to false to hide alert and menu bar icon notification badge
            passwordExpiryLimitReached = false
            return
        }
        
        let expiresInDays = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day!
        
        if expiresInDays == 0 {
            userPasswordExpiryString = NSLocalizedString("Expires Today", comment: "")
        } else if expiresInDays < 0 {
            userPasswordExpiryString = NSLocalizedString("Expired", comment: "")
        } else {
            if expiresInDays > 1 {
                userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(expiresInDays)" + NSLocalizedString(" days", comment: ""))
            } else {
                userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(expiresInDays)" + NSLocalizedString(" day", comment: ""))
            }
        }
        
        setNotificationBadge(expiresInDays: expiresInDays)
    }
    
    // MARK: - Function to get Kerberos SSO Extension password expiry
    func kerbSSOExpiryDate() {
        
        if preferences.kerberosRealm == "" {
            userPasswordExpiryString = "Kerberos Realm Not Set"
            logger.error("Kerberos Realm is not set, pleases set the key 'KerberosRealm' to the Kerberos Realm used in capitals")
        } else {

            // Perform on background thread
            DispatchQueue.global().async { [self] in
                
                let query = "app-sso -j -i \(preferences.kerberosRealm)"
                
                let task = Process()
                let pipe = Pipe()
                
                task.standardOutput = pipe
                task.standardError = pipe
                task.launchPath = "/bin/zsh"
                task.arguments = ["-c", "\(query)"]
                task.launch()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)!
                
                if !task.isRunning {
                    let status = task.terminationStatus
                    if status == 0 {
                        logger.debug("\(output)")
                    } else {
                        logger.error("\(output)")
                    }
                }
                
                // Set JSONDecoder to handle ISO-8601 dates
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                // Publish values back on the main thread
                DispatchQueue.main.async {
                    
                    // Try to decode JSON output to get password expiry date
                    do {
                        let decoded = try decoder.decode(KerberosSSOExtension.self, from: data)
                        
                        if decoded.passwordExpiresDate != nil && decoded.userName != nil {
                            let expiresInDays = Calendar.current.dateComponents([.day], from: Date(), to: decoded.passwordExpiresDate!).day!
                            self.setNotificationBadge(expiresInDays: expiresInDays)
                            
                            if expiresInDays == 0 {
                                self.userPasswordExpiryString = NSLocalizedString("Expires Today", comment: "")
                            } else if expiresInDays < 0 {
                                self.userPasswordExpiryString = NSLocalizedString("Expired", comment: "")
                            } else {
                                if expiresInDays > 1 {
                                    self.userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(expiresInDays)" + NSLocalizedString(" days", comment: ""))
                                } else {
                                    self.userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(expiresInDays)" + NSLocalizedString(" day", comment: ""))
                                }
                            }
                        } else if decoded.passwordExpiresDate == nil && decoded.userName != nil {
                            self.userPasswordExpiryString = NSLocalizedString("Never Expires", comment: "")
                            // Set boolean to false to hide alert and menu bar icon notification badge
                            self.passwordExpiryLimitReached = false
                        } else {
                            self.userPasswordExpiryString = self.signInString
                            // Set boolean to false to hide alert and menu bar icon notification badge
                            self.passwordExpiryLimitReached = false
                        }
                        
                    } catch {
                        self.logger.error("\(error.localizedDescription)")
                        self.userPasswordExpiryString = error.localizedDescription
                    }
                }
            }
        }
    }
    
    // MARK: - Function to get NoMAD password expiry
    func nomadExpiryDate() {
        guard defaultsNomad?.bool(forKey: "SignedIn") ?? false else {
            userPasswordExpiryString = signInString
            // Set boolean to false to hide alert and menu bar icon notification badge
            passwordExpiryLimitReached = false
            return
        }
        
        guard let expiryDate = defaultsNomad?.object(forKey: "LastPasswordExpireDate") as? Date else {
            userPasswordExpiryString = NSLocalizedString("Never Expires", comment: "")
            // Set boolean to false to hide alert and menu bar icon notification badge
            passwordExpiryLimitReached = false
            return
        }
        
        let expiresInDays = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day!
        
        if expiresInDays == 0 {
            userPasswordExpiryString = NSLocalizedString("Expires Today", comment: "")
        } else if expiresInDays < 0 {
            userPasswordExpiryString = NSLocalizedString("Expired", comment: "")
        } else {
            if expiresInDays > 1 {
                userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(expiresInDays)" + NSLocalizedString(" days", comment: ""))
            } else {
                userPasswordExpiryString = (NSLocalizedString("Expires in ", comment: "") + "\(expiresInDays)" + NSLocalizedString(" day", comment: ""))
            }
        }
        
        setNotificationBadge(expiresInDays: expiresInDays)
        
    }
    
    // MARK: - Determine if notification badge with exclamation mark should be shown in tile
    func setNotificationBadge(expiresInDays: Int) {
        if preferences.passwordExpiryLimit > 0 && expiresInDays <= preferences.passwordExpiryLimit {
            // Set boolean to true to show alert and menu bar icon notification badge
            passwordExpiryLimitReached = true
        } else {
            // Set boolean to false to hide alert and menu bar icon notification badge
            passwordExpiryLimitReached = false
        }
        
        // Post changes to notification center
        NotificationCenter.default.post(name: Notification.Name.passwordExpiryLimit, object: nil)
    }

    // MARK: - Expirimental function to change the local Mac password
    func changePassword() {
        do {
            let node = try ODNode.init(session: session, type: UInt32(kODNodeTypeAuthentication))
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
