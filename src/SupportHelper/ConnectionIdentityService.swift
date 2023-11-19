//
//  ConnectionIdentityService.swift
//  nl.root3.support.helper
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation

enum ConnectionIdentityService {
    
    static private let requirementString =
        #"anchor apple generic and identifier "\#(HelperConstants.mainAppBundleID)" and certificate leaf[subject.OU] = "\#(HelperConstants.teamID)""# as CFString
    
    static func isConnectionValid(connection: NSXPCConnection) -> Bool {
        // 1
        guard let token = AuditTokenHack.getAuditTokenData(from: connection) else {
            logger.error("Unable to get the property 'auditToken' from the connection")
            return false
        }
        
        // 2
        guard let secCode = secCodeFrom(token: token), verifyWithRequirementString(secCode: secCode) else {
            return false
        }
        
        // 3
        return true
    }
    
    private static func secCodeFrom(token: Data) -> SecCode? {
        // 1
        let attributesDict = [kSecGuestAttributeAudit: token]
        var secCode: SecCode?

        // 2
        let status = SecCodeCopyGuestWithAttributes(
            nil,
            attributesDict as CFDictionary,
            SecCSFlags(rawValue: 0),
            &secCode
        )

        // 3
        if status.hasSecError {
            // unable to get the (running) code from the token
            logger.error("Could not get 'secCode' with the audit token. \(status.secErrorDescription, privacy: .public)")
            return nil
        }

        // 4
        return secCode
    }
    
    static private func verifyWithRequirementString(secCode: SecCode) -> Bool {
        var secRequirement: SecRequirement?

        // 1
        let reqStatus = SecRequirementCreateWithString(
            requirementString,
            SecCSFlags(rawValue: 0),
            &secRequirement
        )
        
        // 2
        if reqStatus.hasSecError {
            logger.error("Unable to create the requirement string. \(reqStatus.secErrorDescription, privacy: .public)")
            return false
        }

        // 3
        let validityStatus = SecCodeCheckValidity(
            secCode,
            SecCSFlags(rawValue: 0),
            secRequirement
        )
       
        // 4
        if validityStatus.hasSecError {
            logger.error("NSXPC client does not meet the requirements. \(reqStatus.secErrorDescription, privacy: .public)")
            return false
        }

        return true
    }
    
}
