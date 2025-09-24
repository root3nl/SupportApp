//
//  SupportItemModel.swift
//  Support
//
//  Created by Jordy Witteman on 22/11/2024.
//

import Foundation

struct Row: Codable, Hashable {
    var items: [SupportItem]?
    
    enum CodingKeys: String, CodingKey {
        case items = "Items"
    }
}

struct SupportItem: Codable, Hashable {
    let type: String
    let title: String?
    let subtitle: String?
    let linkType: String?
    let link: String?
    let symbol: String?
    let extensionIdentifier: String?
    let onAppearAction: String?

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case title = "Title"
        case subtitle = "Subtitle"
        case linkType = "ActionType"
        case link = "Action"
        case symbol = "Symbol"
        case extensionIdentifier = "ExtensionID"
        case onAppearAction = "OnAppearAction"
    }
}

struct ConfiguredItem {
    
    let rowIndex: Int
    let itemIndex: Int
    
}
