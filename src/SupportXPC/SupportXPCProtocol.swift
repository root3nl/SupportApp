//
//  SupportXPCProtocol.swift
//  SupportXPC
//
//  Created by Jordy Witteman on 27/11/2023.
//

import Foundation

/// The protocol that this service will vend as its API. This protocol will also need to be visible to the process hosting the service.
@objc protocol SupportXPCProtocol {
    
    /// Replace the API of this protocol with an API appropriate to the service you are vending.
    @objc func executeScript(command: String, completion: @escaping ((NSNumber) -> Void)) -> Void
    
    @objc func getUpdateDeclaration(completion: @escaping (Data) -> Void) -> Void
}

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     connectionToService = NSXPCConnection(serviceName: "nl.root3.support.xpc")
     connectionToService.remoteObjectInterface = NSXPCInterface(with: SupportXPCProtocol.self)
     connectionToService.resume()

 Once you have a connection to the service, you can use it like this:

     if let proxy = connectionToService.remoteObjectProxy as? SupportXPCProtocol {
         proxy.performCalculation(firstNumber: 23, secondNumber: 19) { result in
             NSLog("Result of calculation is: \(result)")
         }
     }

 And, when you are finished with the service, clean up the connection like this:

     connectionToService.invalidate()
*/
