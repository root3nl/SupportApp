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
    func getScriptPermissions(pathname: String) -> (ownerID: Int, permissions: NSNumber) {
        // Return the ID and permissions of the specified script
        var fileAttributes: [FileAttributeKey: Any]
        var ownerID: Int = 0
        var mode: NSNumber = 0
        do {
            fileAttributes = try FileManager.default.attributesOfItem(atPath: pathname)
            if let ownerProperty = fileAttributes[.ownerAccountID] as? Int {
                ownerID = ownerProperty
            }
            if let modeProperty = fileAttributes[.posixPermissions] as? NSNumber {
                mode = modeProperty
            }
        } catch {
            logger.error("Could not read file at path \(pathname, privacy: .public)")
        }
        return (ownerID, mode)
    }
    
    // MARK: - Verify script is owned by root and permissions 755
    func verifyPermissions(pathname: String) -> Bool {
        
        let requiredPermissions: NSNumber = 0o755
        
        let (ownerID, mode) = getScriptPermissions(pathname: pathname)
        
        if ownerID == 0 && mode == requiredPermissions {
            logger.debug("Permissions for \(pathname, privacy: .public) are correct")
            return true
        } else {
            logger.error("Permissions for \(pathname, privacy: .public) are incorrect. Should be owned by root and with mode 755")
        }
        return false
    }
    
}
