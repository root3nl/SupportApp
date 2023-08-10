//
//  SoftwareUpdateModel.swift
//  Support
//
//  Created by Jordy Witteman on 18/12/2022.
//

import Foundation

struct SoftwareUpdateModel: Identifiable, Codable, Hashable {
    
    var id: String
    var displayName: String
    var displayVersion: String?
    var mobileSoftwareUpdate: Bool?
    var productKey: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Identifier"
        case displayName = "Display Name"
        case displayVersion = "Display Version"
        case mobileSoftwareUpdate = "MobileSoftwareUpdate"
        case productKey = "Product Key"
    }
    
}
