//
//  ExecutionService.swift
//  Support
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation

struct ExecutionService {

    static func executeScript(command: String, completion: @escaping (NSNumber) -> Void) throws {
        let remote = try HelperRemote().getRemote()
        
        remote.executeScript(command: command) { (exitCode) in
            completion(exitCode)
        }
    }
}
