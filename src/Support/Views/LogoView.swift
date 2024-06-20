//
//  LogoView.swift
//  Support
//
//  Created by Jordy Witteman on 16/11/2022.
//  Inspired by Bart Reardon to support SF Symbol color options 
//

import SwiftUI

struct LogoView: View {
    
    var logo: String
    
    // Get string between "SF=" and optionally ","
    var symbol: String {
        if logo.components(separatedBy: ",").indices.contains(0) {
            let symbolString = logo.components(separatedBy: ",")[0]
            return symbolString.replacingOccurrences(of: "SF=", with: "")
        } else {
            return logo.replacingOccurrences(of: "SF=", with: "")
        }
    }
    
    // Get string for SF Symbol color option
    var symbolColor: String {
        if logo.components(separatedBy: ",color=").indices.contains(1) {
            return logo.components(separatedBy: ",color=")[1]
        } else {
            return ""
        }
    }
    
    var body: some View {
        
        // When "http" prefix is detected, try to fetch image from URL
        if logo.hasPrefix("http") {
            
            AsyncImage(url: URL(string: logo)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(height: 48)
                
            } placeholder: {
                Image("DefaultLogo")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(6)
                    .redacted(reason: .placeholder)
                    .overlay(
                        ProgressView()
                    )
                    .frame(width: 48, height: 48)
            }
        // When "SF=" prefix is detected, try to show SF Symbol with optional color options
        } else if logo.hasPrefix("SF=") {
            
            switch symbolColor {
            case "auto":
                Image(systemName: symbol)
                    .resizable()
                    .foregroundColor(.accentColor)
                    .scaledToFit()
                    .frame(height: 48)
            case "multicolor":
                Image(systemName: symbol)
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
            case "hierarchical":
                Image(systemName: symbol)
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
            case _ where symbolColor.hasPrefix("#"):
                Image(systemName: symbol)
                    .resizable()
                    .foregroundColor(Color(NSColor(hex: "\(symbolColor)") ?? NSColor.controlAccentColor))
                    .scaledToFit()
                    .frame(height: 48)
            default:
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
            }
        // Show default logo
        } else if logo == "default" {
            Image("DefaultLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 48)
        // In all other cases the file is expected to be local but fallback to default logo when not present
        } else {
            Image(nsImage: (NSImage(contentsOfFile: logo) ?? NSImage(named: "DefaultLogo"))!)
                .resizable()
                .scaledToFit()
                .frame(height: 48)
        }
    }
}
