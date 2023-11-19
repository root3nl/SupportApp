//
//  PrivilegedHelperError.swift
//  nl.root3.support.helper
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation

enum PrivilegedHelperError: LocalizedError {
    case invalidStringConversion
    case helperInstallation(String)
    case helperConnection(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidStringConversion: return "The output data is not convertible to a String (utf8)"
        case .helperInstallation(let description): return "Helper installation error. \(description)"
        case .helperConnection(let description): return "Helper connection error. \(description)"
        case .unknown: return "Unknown error"
        }
    }
}
