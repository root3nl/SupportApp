//
//  NotificationNames.swift
//  NotificationNames
//
//  Created by Jordy Witteman on 11/10/2021.
//

import Foundation

// Static notification names
extension Notification.Name {
    
    static let uptimeDaysLimit = Notification.Name("UptimeDaysLimit")
    static let storageLimit = Notification.Name("StorageLimit")
    static let networkState = Notification.Name("NetworkState")
    static let passwordExpiryLimit = Notification.Name("PasswordExpiryLimit")
    
}
