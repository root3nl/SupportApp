//
//  RemoveEscapingCharacters.swift
//  Support
//
//  Created by Jordy Witteman on 13/05/2024.
//

import Foundation

// MARK: - String extension to remove any escaping characters
extension String {
    
    // Helper function to handle file paths and remove any escaping characters
    func removeEscapingCharacters() -> String {
        var newString = self
        newString = newString.replacingOccurrences(of: "\\ ", with: " ")
        return newString
    }

}
