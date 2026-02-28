//
//  QuestionSearchFieldView.swift
//  Support
//
//  Created by Jordy Witteman on 28/02/2026.
//

import SwiftUI

@available(macOS 26, *)
struct QuestionSearchFieldView: View {
    
    @Environment(MessageStore.self) private var messageStore
    
    @Binding var disabled: Bool
    var onSend: () async throws -> Void
    
    @State private var questionText: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(.secondary)
            
            TextField("Tell me about any issues...", text: $questionText)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
                .textFieldStyle(.plain)
                .submitLabel(.send)
                .disabled(disabled)
                .onSubmit {
                    let trimmedQuestion = questionText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedQuestion.isEmpty else {
                        return
                    }

                    let newQuestion = FoundationModelMessage(id: UUID(), message: trimmedQuestion, role: .user, urls: nil, bundleIDs: nil)
                    messageStore.messages.append(newQuestion)
                    questionText = ""

                    Task {
                        try? await onSend()
                    }
                }
        }
        .padding(8)
        .modifier(GlassEffectModifier(hoverView: false, hoverEffectEnable: false))
//        .padding(.horizontal, 10)
    }
}

//#Preview {
//    QuestionSearchFieldView()
//}
