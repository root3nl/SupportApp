//
//  SoftwareUpdateDeclarationModel.swift
//  Support
//
//  Created by Jordy Witteman on 06/03/2024.
//

import Foundation

struct Declaration: Codable {
    let detailsURL: String?
    let targetBuildVersion: String?
    let targetLocalDateTime: String
    let targetOSVersion: String
    
    enum CodingKeys: String, CodingKey {
        case detailsURL = "DetailsURL"
        case targetBuildVersion = "TargetBuildVersion"
        case targetLocalDateTime = "TargetLocalDateTime"
        case targetOSVersion = "TargetOSVersion"
    }
}

struct PolicyFields: Codable {
    let declarations: [String: Declaration]?
    
    enum CodingKeys: String, CodingKey {
        case declarations = "Declarations"
    }
    
}

struct SoftwareUpdateDeclarationModel: Codable {
    let policyFields: PolicyFields
    
    enum CodingKeys: String, CodingKey {
        case policyFields = "SUCorePersistedStatePolicyFields"
    }
}

