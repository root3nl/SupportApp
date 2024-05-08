//
//  ExecutionService.swift
//  SupportXPC
//
//  Created by Jordy Witteman on 29/11/2023.
//

import Foundation

struct ExecutionService {
    
    static func verifyAppCatalogCodeRequirement(completion: @escaping (Bool) -> Void) throws -> Void {
        
        let bundleIdentifier = "nl.root3.catalog.agent"
        let teamID = "98LJ4XBGYK"
        
        // Define the code requirement string
        let codeRequirementString = "anchor apple generic and identifier \"" + bundleIdentifier + "\"" +
            " and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */" +
            " or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */" +
            " and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */" +
            " and certificate leaf[subject.OU] = \"" + teamID + "\"" +
            ")"
        
        // Create a SecRequirementRef from the code requirement string
        var requirement: SecRequirement?
        let status = SecRequirementCreateWithString(codeRequirementString as CFString, [], &requirement)
        
        guard status == errSecSuccess, let codeRequirement = requirement else {
            logger.error("Error creating code requirement: \(status)")
            completion(false)
            return
        }
        
        // Get the URL of the binary to verify
        let symlinkURL = URL(fileURLWithPath: "/usr/local/bin/catalog")
        
        // Resolve the symlink to its target
        guard let binaryURL = try? FileManager.default.destinationOfSymbolicLink(atPath: symlinkURL.path) else {
            print("Error resolving symlink.")
            return
        }
        
        // Create a SecStaticCodeRef from the binary URL
        var staticCode: SecStaticCode?
        let staticCodeStatus = SecStaticCodeCreateWithPath(URL(fileURLWithPath: binaryURL) as CFURL, [], &staticCode)
        
        guard staticCodeStatus == errSecSuccess, let code = staticCode else {
            logger.error("Error creating static code: \(staticCodeStatus)")
            completion(false)
            return
        }
        
        // Check if the binary meets the code requirements
        let satisfiesRequirements = SecStaticCodeCheckValidityWithErrors(code, [], codeRequirement, nil)
        
        if satisfiesRequirements == errSecSuccess {
            logger.debug("Catalog binary meets code requirements")
            completion(true)
        } else {
            logger.error("Catalog binary does not meet code requirements")
            completion(false)
        }
        
    }
    
    static func getUpdateDeclaration(completion: @escaping (Data) -> Void) throws -> Void {
        
        // Specify the path to the plist file
        let plistPath = "/private/var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist" // Replace this with the actual path to your plist file
        
        // Check if the file exists
        if FileManager.default.fileExists(atPath: plistPath) {
            logger.debug("macOS software update declaration plist was found")
            
            // Read the plist file
            do {
                // Read plist data from the file
                let plistData = try Data(contentsOf: URL(fileURLWithPath: plistPath))
                completion(plistData)
                
            } catch {
                logger.error("Error reading plist: \(error)")
            }
        } else {
            logger.debug("No macOS software update declaration plist found")
        }
    }

    static func executeScript(command: String, completion: @escaping ((NSNumber) -> Void)) throws -> Void {
        
        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", "'\(command)'"]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        try process.run()
        
        // Stream script output to Unified Logging
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.isEmpty {
                outputPipe.fileHandleForReading.readabilityHandler = nil
                return
            }
            if let outputString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines) {
                logger.log("\(outputString, privacy: .public)")
                print(outputString)
            }
        }
                
        process.waitUntilExit()
        
        process.terminationHandler = { process in
            completion(NSNumber(value: process.terminationStatus))
        }
    }
}
