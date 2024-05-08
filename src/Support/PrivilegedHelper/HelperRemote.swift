//
//  HelperRemote.swift
//  Support
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation
import os
import XPC
import ServiceManagement

struct HelperRemote {
    
    var logger = Logger(subsystem: "nl.root3.support", category: "SupportHelper")

    // MARK: - Properties
    var isHelperInstalled: Bool { FileManager.default.fileExists(atPath: HelperConstants.helperPath) }

    // MARK: - Functions
    /// Install the Helper in the privileged helper tools folder and load the daemon
    func installHelper() throws {

        // try to get a valid empty authorisation
        var authRef: AuthorizationRef?
        var authStatus = AuthorizationCreate(nil, nil, [.preAuthorize], &authRef)

        guard authStatus == errAuthorizationSuccess else {
            logger.error("Unable to get a valid empty authorization reference to load Helper daemon")
            throw PrivilegedHelperError.helperInstallation("Unable to get a valid empty authorization reference to load Helper daemon")
        }

        // create an AuthorizationItem to specify we want to bless a privileged Helper
        let authItem = kSMRightBlessPrivilegedHelper.withCString { authorizationString in
            AuthorizationItem(name: authorizationString, valueLength: 0, value: nil, flags: 0)
        }

        // it's required to pass a pointer to the call of the AuthorizationRights.init function
        let pointer = UnsafeMutablePointer<AuthorizationItem>.allocate(capacity: 1)
        pointer.initialize(to: authItem)

        defer {
            // as we instantiate a pointer, it's our responsibility to make sure it's deallocated
            pointer.deinitialize(count: 1)
            pointer.deallocate()
        }

        // store the authorization items inside an AuthorizationRights object
        var authRights = AuthorizationRights(count: 1, items: pointer)

        let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
        authStatus = AuthorizationCreate(&authRights, nil, flags, &authRef)

        guard authStatus == errAuthorizationSuccess else {
            logger.error("Unable to get a valid loading authorization reference to load Helper daemon")
            throw PrivilegedHelperError.helperInstallation("Unable to get a valid loading authorization reference to load Helper daemon")
        }

        // Try to install the helper and to load the daemon with authorization
        var error: Unmanaged<CFError>?
        if SMJobBless(kSMDomainSystemLaunchd, HelperConstants.domain as CFString, authRef, &error) == false {
            let blessError = error!.takeRetainedValue() as Error
            logger.error("Error while installing the Helper: \(blessError.localizedDescription, privacy: .public)")
            throw PrivilegedHelperError.helperInstallation("Error while installing the Helper: \(blessError.localizedDescription)")
        }

        // Helper successfully installed
        // Release the authorization, as mentioned in the doc
        AuthorizationFree(authRef!, [])
    }

    private func createConnection() -> NSXPCConnection {
        let connection = NSXPCConnection(machServiceName: HelperConstants.domain, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: SupportHelperProtocol.self)
        connection.exportedInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        connection.exportedObject = self

        connection.invalidationHandler = { [isHelperInstalled] in
            if isHelperInstalled {
                logger.error("Unable to connect to Helper although it is installed")
            } else {
                logger.error("Helper is not installed")
            }
        }
        logger.debug("Helper connected!")

        connection.resume()

        return connection
    }

    private func getConnection() throws -> NSXPCConnection {
        if !isHelperInstalled {
            // we'll try to install the Helper if not already installed, but we need to get the admin authorization
            try installHelper()
        }
        return createConnection()
    }

    func getRemote() throws -> SupportHelperProtocol {
        var proxyError: Error?

        // Try to get the helper
        let helper = try getConnection().remoteObjectProxyWithErrorHandler({ (error) in
            proxyError = error
        }) as? SupportHelperProtocol

        // Try to unwrap the Helper
        if let unwrappedHelper = helper {
            return unwrappedHelper
        } else {
            logger.error("\(proxyError?.localizedDescription ?? "Unknown error")")
            throw PrivilegedHelperError.helperConnection(proxyError?.localizedDescription ?? "Unknown error")
        }
    }
}
