//
//  FileUtilities.swift
//  Support
//
//  Created by Jordy Witteman on 06/04/2024.
//

import Foundation
import os

class FileUtilities {
    
    let logger = Logger(subsystem: "nl.root3.support", category: "FileUtilities")
    
    // MARK: - Get script
    func getScriptPermissions(pathname: String) -> (ownerID: Int, groupID: Int, permissions: NSNumber) {
        // Return the owner ID, group ID, and permissions of the specified script
        var fileAttributes: [FileAttributeKey: Any]
        var ownerID: Int = 0
        var groupID: Int = 0
        var mode: NSNumber = 0
        do {
            fileAttributes = try FileManager.default.attributesOfItem(atPath: pathname.removeEscapingCharacters())
            if let ownerProperty = fileAttributes[.ownerAccountID] as? Int {
                ownerID = ownerProperty
            }
            if let groupProperty = fileAttributes[.groupOwnerAccountID] as? Int {
                groupID = groupProperty
            }
            if let modeProperty = fileAttributes[.posixPermissions] as? NSNumber {
                mode = modeProperty
            }
        } catch {
            logger.error("Could not read file at path \(pathname, privacy: .public)")
        }
        return (ownerID, groupID, mode)
    }
    
    // MARK: - Verify script is owned by root and permissions 755
    func verifyPermissions(pathname: String) -> Bool {
        let (ownerID, groupID, mode) = getScriptPermissions(pathname: pathname)

        // root:wheel must be 755
        if ownerID == 0 && groupID == 0 {
            let required: NSNumber = 0o755
            if mode == required {
                logger.debug("Permissions for \(pathname, privacy: .public) are correct (owner:group 0:0, mode: 755)")
                return true
            } else {
                logger.error("Permissions for \(pathname, privacy: .public) are incorrect for root:wheel. Expected mode 755, found mode \(String(format: "%o", mode.intValue)).")
                return false
            }
        }

        // For scripts deployed using ServicesBackgroundTasks (Declarative Device Management) are secure and can also be allowed
        // https://developer.apple.com/documentation/devicemanagement/servicesbackgroundtasks
        // _rmd:_rmd is allowed regardless of permission mode
        if ownerID == 277 && groupID == 277 {
            logger.debug("Permissions for \(pathname, privacy: .public) are allowed (owner:group 277:277, any mode)")
            return true
        }

        logger.error("Permissions for \(pathname, privacy: .public) are incorrect. Allowed ownerships are root:wheel (0:0) with 755 or _rmd:_rmd (277:277) with 444. Found owner:group \(ownerID):\(groupID) and mode \(String(format: "%o", mode.intValue)).")
        return false
    }
    
    // MARK: - Function to check if file or folder exists
    func fileOrFolderExists(path: String) -> Bool {
        
        let fileManager = FileManager.default
        
        // Path to app bundle
        let file = URL(fileURLWithPath: path)
        
        if fileManager.fileExists(atPath: file.path) {
            return true
        } else {
            return false
        }
    }
    
}
