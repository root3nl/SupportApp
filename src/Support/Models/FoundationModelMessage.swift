//
//  FoundationModelMessage.swift
//  Support
//
//  Created by Jordy Witteman on 27/02/2026.
//

import Foundation

struct FoundationModelMessage: Hashable, Identifiable {
    let id: UUID
    var message: String?
    let role: Role
    var urls: [String]?
    var bundleIDs: [String]?
//    let timestamp: Date
}

enum Role {
    case user
    case assistant
}
