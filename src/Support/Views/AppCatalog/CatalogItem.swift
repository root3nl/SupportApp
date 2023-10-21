//
//  CatalogItem.swift
//  Support
//
//  Created by Jordy Witteman on 21/10/2023.
//

import Foundation

struct CatalogItem: Codable, Identifiable, Hashable {
    
    let id: String
    let name: String?
    let iconThumbnail: String?
    let lastKnownVersion: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "bundle_id"
        case name
        case iconThumbnail = "icon_thumbnail"
        case lastKnownVersion = "version"
    }
    
}
