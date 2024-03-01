//
//  OSStatus+Extensions.swift
//  nl.root3.support.helper
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation

extension OSStatus {

    var hasSecError: Bool { self != errSecSuccess }

    var secErrorDescription: String {
        let error = SecCopyErrorMessageString(self, nil) as String? ?? "Unknown error"
        return error
    }
}
