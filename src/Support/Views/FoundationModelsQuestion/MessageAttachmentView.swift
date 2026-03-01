//
//  MessageAttachmentView.swift
//  Support
//
//  Created by Jordy Witteman on 01/03/2026.
//

import SwiftUI

@available(macOS 26.0, *)
struct MessageAttachmentView: View {
    
    let url: String
    let color: Color
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        HStack {
            
            VStack(alignment: .leading) {
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
//                if let bundleIDs = message.bundleIDs {
//                    ForEach(bundleIDs, id: \.self) { bundleID in
//                        HStack {
//                            Image(systemName: "arrow.up.right.square.fill")
//                                .foregroundStyle(.white)
//                            Text(bundleID)
//                                .foregroundStyle(.white)
//                                .font(.headline)
//                                .textSelection(.enabled)
//                        }
//                    }
//                }
            }
            .padding(10)
            .modify {
                if colorScheme == .dark {
                    $0
                        .glassEffect(.clear.tint(.clear), in: .rect(cornerRadius: 20))
                } else {
                    $0
                        .glassEffect(.clear.tint(.primary.opacity(0.4)), in: .rect(cornerRadius: 20))
                }
            }
            .frame(maxWidth: 300, alignment: .leading)
            .animation(.bouncy, value: url)
            
            Spacer()
        }
        
    }
}

//#Preview {
//    MessageAttachmentView()
//}
