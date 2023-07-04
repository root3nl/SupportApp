//
//  Extensions.swift
//  Support
//
//  Created by Jordy Witteman on 16/12/2020.
//

import Cocoa
import Foundation
import SwiftUI

// Extension to convert Hex colors to NSColor. https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
// Slightly modified to append the 1.0 Alpha channel to HEX color
extension NSColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])
            
            // MARK: - Slightly modified to append the 1.0 Alpha channel to HEX color
            hexColor += "ff"
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

// Extension to tint the notification badge easily using NSImage
// This will work with Swift 5
extension NSImage {
    func image(with tintColor: NSColor) -> NSImage {
        if self.isTemplate == false {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceIn)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
}

// Extension to resize NSImage. https://stackoverflow.com/questions/11949250/how-to-resize-nsimage
extension NSImage {
    func scaledCopy( sizeOfLargerSide: CGFloat) ->  NSImage {
        var newW: CGFloat
        var newH: CGFloat
        var scaleFactor: CGFloat
        
        if ( self.size.width > self.size.height) {
            scaleFactor = self.size.width / sizeOfLargerSide
            newW = sizeOfLargerSide
            newH = self.size.height / scaleFactor
        }
        else{
            scaleFactor = self.size.height / sizeOfLargerSide
            newH = sizeOfLargerSide
            newW = self.size.width / scaleFactor
        }
        
        return resizedCopy(w: newW, h: newH)
    }
    
    
    func resizedCopy( w: CGFloat, h: CGFloat) -> NSImage {
        let destSize = NSMakeSize(w, h)
        let newImage = NSImage(size: destSize)
        
        newImage.lockFocus()
        
        self.draw(in: NSRect(origin: .zero, size: destSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: CGFloat(1)
        )
        
        newImage.unlockFocus()
        
        guard let data = newImage.tiffRepresentation,
              let result = NSImage(data: data)
        else { return NSImage() }
        
        return result
    }
    
    public func writePNG(toURL url: URL) {
        guard let data = tiffRepresentation,
              let rep = NSBitmapImageRep(data: data),
              let imgData = rep.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)]) else {

            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(url)")
            return
        }

        do {
            try imgData.write(to: url)
        }catch let error {
            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
        }
    }
}

extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - String extension to replace local variables
extension String {
    
    func replaceLocalVariables(computerInfo: ComputerInfo, userInfo: UserInfo) -> String {
        var newString = self
        let localVariables = [
            ("%COMPUTERNAME%", computerInfo.hostname),
            ("%MODELNAME%", computerInfo.modelNameString),
            ("%MODELSHORTNAME%", computerInfo.modelShortName),
            ("%FULLNAME%", userInfo.fullName),
            ("%MACOSVERSION%", computerInfo.macOSVersion),
            ("%MACOSVERSIONNAME%", computerInfo.macOSVersionName),
            ("%IPADDRESS%", computerInfo.ipAddress),
            ("%SSID%", computerInfo.networkName),
            ("%UPDATESAVAILABLE%", "\(computerInfo.updatesAvailable)")
        ]
    
        // Loop through all possible local variables and replace when found
        for (original, replacement) in localVariables {
            newString = newString.replacingOccurrences(of: original, with: replacement)
        }
        return newString
    }

}
