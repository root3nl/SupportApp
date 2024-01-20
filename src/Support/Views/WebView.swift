//
//  WebView.swift
//  Support
//
//  Created by Jordy Witteman on 20/01/2024.
//

import SwiftUI
import WebKit

struct Webview: View {
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Set the custom color for all symbols depending on Light or Dark Mode.
    var customColor: String {
        if colorScheme == .light && defaults.string(forKey: "CustomColor") != nil {
            return preferences.customColor
        } else if colorScheme == .dark && defaults.string(forKey: "CustomColorDarkMode") != nil {
            return preferences.customColorDarkMode
        } else {
            return preferences.customColor
        }
    }
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    var body: some View {
        
        Group {
        
            HStack {
                
                Button(action: {
                    
                }) {
                    Ellipse()
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1))
                        .overlay(
                            Image(systemName: "chevron.backward")
                        )
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                
                Text(NSLocalizedString("WEBVIEW", comment: ""))
                    .font(.system(.headline, design: .rounded))
                
                Spacer()

            }
            
            WebViewController(url: URL(string: "https://support.root3.nl")!)
                .frame(width: 350, height: 600)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
        }
        .padding(.horizontal)
        .unredacted()
    }
}

struct WebViewController: NSViewRepresentable {
    
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        let wkwebView = WKWebView()
        let request = URLRequest(url: url)
        wkwebView.load(request)
        return wkwebView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}

