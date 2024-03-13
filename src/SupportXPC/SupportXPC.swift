//
//  SupportXPC.swift
//  SupportXPC
//
//  Created by Jordy Witteman on 27/11/2023.
//

import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class SupportXPC: NSObject, SupportXPCProtocol {
    
    // MARK: HelperProtocol
    func executeScript(command: String, completion: @escaping (NSNumber) -> Void) {
        
        do {
            try ExecutionService.executeScript(command: command) { (result) in
                completion(result)
            }
        } catch {
            logger.error("Error: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func getUpdateDeclaration(completion: @escaping (Data) -> Void) {
        
        do {
            try ExecutionService.getUpdateDeclaration() { (result) in
                completion(result)
            }
        } catch {
            logger.error("Error: \(error.localizedDescription, privacy: .public)")
        }
        
    }
    
}
