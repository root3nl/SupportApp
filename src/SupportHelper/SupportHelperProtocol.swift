//
//  SupportHelperProtocol.swift
//  nl.root3.support.helper
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation

/// The protocol that this service will vend as its API. This protocol will also need to be visible to the process hosting the service.
@objc(SupportHelperProtocol)
protocol SupportHelperProtocol {
    
    @objc func executeScript(command: String, completion: @escaping ((NSNumber) -> Void)) -> Void
}
