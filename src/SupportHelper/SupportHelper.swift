//
//  SupportHelper.swift
//  nl.root3.support.helper
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation

class SupportHelper: NSObject, NSXPCListenerDelegate, SupportHelperProtocol {

    // MARK: - Properties

    let listener: NSXPCListener
    private var connections = [NSXPCConnection]()
    private var shouldQuit = false
    private var shouldQuitCheckInterval = 1.0
    
    // Support main app Code Requirement
    let codeRequirement = "anchor apple generic and identifier \"" + HelperConstants.mainAppBundleID + "\"" +
        " and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */" +
        " or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */" +
        " and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */" +
        " and certificate leaf[subject.OU] = \"" + HelperConstants.teamID + "\"" +
        ")"

    // MARK: - Initialisation

    override init() {
        self.listener = NSXPCListener(machServiceName: HelperConstants.domain)
        super.init()
        self.listener.delegate = self
    }

    // MARK: - Functions

    // MARK: HelperProtocol

    func executeScript(command: String, completion: @escaping (NSNumber) -> Void) {
        
        do {
            try HelperExecutionService.executeScript(command: command) { (result) in
                completion(result)
            }
        } catch {
            logger.error("Error: \(error.localizedDescription, privacy: .public)")
        }
    }

    func run() {
        // start listening on new connections
        self.listener.resume()
    
//        // prevent the terminal application to exit
//        RunLoop.current.run()
        
        // Keep the helper running until shouldQuit variable is set to true.
        // This variable is changed to true in the connection invalidation handler in the listener(_ listener:shoudlAcceptNewConnection:) function.
        while !shouldQuit {
            RunLoop.current.run(until: Date.init(timeIntervalSinceNow: shouldQuitCheckInterval))
        }
    }

    // Listen and monitor connections. When there are no more connections, the Runloop will stop running and the PrivilegedHelperTool will quit
    // https://github.com/choco/FlixDNS/blob/master/FlixDNS%20Privileged%20Helper/PrivilegedHelperService.swift
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        
        // Make sure only the main app can connect and validate Team ID and Code Requirement
        guard ConnectionIdentityService.isConnectionValid(connection: newConnection) else {
            self.shouldQuit = true
            return false
        }
        
        newConnection.exportedInterface = NSXPCInterface(with: SupportHelperProtocol.self)
        newConnection.remoteObjectInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        
        // Check Code Requirement
        newConnection.setCodeSigningRequirement(codeRequirement)
        
        newConnection.exportedObject = self
        newConnection.invalidationHandler = (() -> Void)? {
            if let indexValue = self.connections.firstIndex(of: newConnection) {
                self.connections.remove(at: indexValue)
            }
            
            if self.connections.count == 0 {
                logger.debug("No more XPC connections, exiting...")
                self.shouldQuit = true
            }
        }
        self.connections.append(newConnection)
        newConnection.resume()
        return true
    }
}
