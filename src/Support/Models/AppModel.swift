//
//  AppModel.swift
//  Support
//
//  Created by Jordy Witteman on 25/08/2025.
//

import Foundation

struct AppModel: Codable, Hashable {
    
    var title: String?
    var logo: String?
    var logoDarkMode: String?
    var rows: [Row]?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case logo = "Logo"
        case logoDarkMode = "LogoDarkMode"
    }
}
