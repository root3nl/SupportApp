//
//  FoundationModelsQuestionView.swift
//  Support
//
//  Created by Jordy Witteman on 25/02/2026.
//

import SwiftUI
import FoundationModels

@available(macOS 26, *)
struct FoundationModelsQuestionView: View {
    
    var question: String
    
    // Get preferences or default values
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var localPreferences: LocalPreferences
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Local preferences for Configurator Mode or (managed) UserDefaults
    var activePreferences: PreferencesProtocol {
        preferences.configuratorModeEnabled ? localPreferences : preferences
    }
    
    // Set the custom color for all symbols depending on Light or Dark Mode.
    var color: Color {
        if colorScheme == .dark && !activePreferences.customColorDarkMode.isEmpty {
            return Color(NSColor(hex: "\(activePreferences.customColorDarkMode)") ?? NSColor.controlAccentColor)
        } else if !activePreferences.customColor.isEmpty {
            return Color(NSColor(hex: "\(activePreferences.customColor)") ?? NSColor.controlAccentColor)
        } else {
            return .accentColor
        }
    }
    
    // Update cancel hover state
    @State private var hoveredCancelButton: Bool = false
    @State private var hoveredItem: String?
    
    @State private var answer: String = ""
    @State private var session: LanguageModelSession?
            
    var body: some View {
        
        Group {
            HStack {
                
                Button(action: {
                    preferences.showQuestionView.toggle()
                }) {
                    BackButton()
                }
                .modify {
                    if #available(macOS 26, *) {
                        $0
                            .buttonStyle(.glass)
                            .buttonBorderShape(.circle)
                        //                                .controlSize(.small)
                    } else {
                        $0
                            .buttonStyle(.plain)
                    }
                }
                
                Text(NSLocalizedString("IT_ASSISTANT", comment: ""))
                    .font(.system(.headline, design: .rounded))
                
                Spacer()
            }
            
            Divider()
                .padding(2)
            
            if !answer.isEmpty {
                ScrollView {
                    Text(answer)
                        .font(.system(.body, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, minHeight: 300, alignment: .topLeading)
                        .animation(.default, value: answer)
                        .contentTransition(.opacity)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300, alignment: .center)
            }
            
        }
        .frame(minWidth: 300)
        .padding(.horizontal)
        .unredacted()
        .task {
            if session == nil {
                session = LanguageModelSession(model: .default, instructions: """
            You are a helpful IT assistant and your task is to provide the user with easy to understand actionable advise. 
            If you don't know the exact answer, respond with: "Sorry, I cannot help you with that"
"""
)
            }
            
            do {
                try await fetchAnswer()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    @Generable
    struct Response {
        @Guide(description: "The answer to the question")
        var answer: String

        @Guide(description: "Whether it was not possible to answer the question")
        var insufficientInformation: Bool
    }
    
    func fetchAnswer() async throws {
     
        guard let session else {
            return
        }
        
        let stream = session.streamResponse(generating: Response.self) {
            "Question: \(question)"
            "This is the text:"
        }
        
        for try await partialResponse in stream {
            if partialResponse.content.insufficientInformation == true {
                answer = "I couldn't find enough information to answer this."
            } else {
                answer = partialResponse.content.answer ?? ""
            }
        }
        
    }
}

//#Preview {
//    FoundationModelsQuestionView()
//}
