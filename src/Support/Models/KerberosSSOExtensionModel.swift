//
//  KerberosSSOExtensionModel.swift
//  Support
//
//  Created by Jordy Witteman on 31/10/2021.
//

import Foundation

struct KerberosSSOExtension: Codable {
    
    let passwordExpiresDate: Date?
    let userName: String?
    
    enum CodingKeys: String, CodingKey {
        case passwordExpiresDate = "password_expires_date"
        case userName = "user_name"
    }
    
}
