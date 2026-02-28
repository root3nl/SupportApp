//
//  MessageView.swift
//  Support
//
//  Created by Jordy Witteman on 27/02/2026.
//

import SwiftUI

@available(macOS 26.0, *)
struct MessageView: View {
    
    let message: FoundationModelMessage
    let color: Color
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: .leading) {
                if let message = message.message {
                    Text(message)
                        .foregroundStyle(.white)
                        .font(.headline)
                        .contentTransition(.interpolate)
                        .textSelection(.enabled)
                } else {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 40))
                        .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.continuous))
                }
                if let urls = message.urls {
                    ForEach(urls, id: \.self) { url in
                        HStack(alignment: .top) {
                            Image(systemName: "link")
                                .foregroundStyle(.white)
                            if let destination = URL(string: url) {
                                Link(destination: destination) {
                                    Text(url)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                                .foregroundStyle(.white)
                                .font(.headline)
                            } else {
                                Text(url)
                                    .foregroundStyle(.white)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .textSelection(.enabled)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top)
                }
                if let bundleIDs = message.bundleIDs {
                    ForEach(bundleIDs, id: \.self) { bundleID in
                        HStack {
                            Image(systemName: "arrow.up.right.square.fill")
                                .foregroundStyle(.white)
                            Text(bundleID)
                                .foregroundStyle(.white)
                                .font(.headline)
                                .textSelection(.enabled)
                        }
                    }
                }
            }
            .padding(10)
            .modify {
                if colorScheme == .dark {
                    $0
                        .glassEffect(.clear.tint(message.role == .user ? .blue : .clear), in: .rect(cornerRadius: 16))
                } else {
                    $0
                        .glassEffect(.clear.tint(message.role == .user ? .blue : .primary.opacity(0.4)), in: .rect(cornerRadius: 16))
                }
            }
            .frame(maxWidth: 300, alignment: message.role == .assistant ? .leading : .trailing)
            .animation(.bouncy, value: message.message)
            
            if message.role == .assistant {
                Spacer()
            }
        }
        
    }
}

//#Preview {
//    if #available(macOS 26.0, *) {
//        VStack {
//            MessageView(message: FoundationModelMessage(id: UUID(), message: "This is a test message", role: .assistant, urls: nil, bundleIDs: nil), color: .accentColor)
//            MessageView(message: FoundationModelMessage(id: UUID(), message: "This is a test message", role: .user, urls: nil, bundleIDs: nil), color: .accentColor)
//            MessageView(message: FoundationModelMessage(id: UUID(), message: "...", role: .assistant, urls: nil, bundleIDs: nil), color: .accentColor)
//        }
//    } else {
//        // Fallback on earlier versions
//    }
//}
