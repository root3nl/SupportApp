//
//  InstalledAppItem.swift
//  Support
//
//  Created by Jordy Witteman on 21/10/2023.
//

import Foundation

struct InstalledAppItem: Codable, Identifiable, Hashable {
    
    let id: String
    let name: String?
    let icon: String?
    let version: String?
    
}
