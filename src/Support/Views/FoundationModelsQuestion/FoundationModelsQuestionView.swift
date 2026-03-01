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
    
    @Environment(MessageStore.self) private var messageStore
    
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
    
    @State private var session: LanguageModelSession?
    @State private var question: String = ""
    @State private var isGenerating: Bool = false
    @State var scrollPosition: ScrollPosition = .init()
    private let composerInset: CGFloat = 30
    
    var body: some View {
        
        VStack {
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
            .padding(.horizontal)
            
            Divider()
                .padding(2)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    if !messageStore.messages.isEmpty {
                        ForEach(messageStore.messages) { message in
                            MessageView(message: FoundationModelMessage(id: message.id, message: message.message, role: message.role, urls: message.urls, bundleIDs: message.bundleIDs), color: color)
                                .id(message.id)
                            if let urls = message.urls {
                                if !urls.isEmpty {
                                    ForEach(urls, id: \.self) { url in
                                        MessageAttachmentView(url: url, color: color)
                                    }
                                }
                            }
                        }
                    } else {
                        ContentUnavailableView("Ask me aything!", systemImage: "sparkles", description: Text("I can help you find relevant resources from our organization."))
                    }

                    Color.clear
                        .frame(height: composerInset)
                }
                .scrollTargetLayout()
                .frame(maxWidth: .infinity)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition($scrollPosition, anchor: .bottom)
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 500, alignment: .topLeading)
            .padding(.horizontal)
            .overlay(alignment: .bottom) {
                
                HStack {
                    QuestionSearchFieldView(disabled: $isGenerating, onSend: {
                        do {
                            try await fetchAnswer()
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                    
                    Spacer()
                    
                    Button {
                        messageStore.messages.removeAll()
                        session = nil
                    } label: {
                        Label("Clear chat", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                    .disabled(isGenerating)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.plain)
                    .padding(8)
                    .modifier(GlassEffectModifier(hoverView: false, hoverEffectEnable: false))
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            }
        }
        .frame(minWidth: 300)
//        .padding(.horizontal)
        .unredacted()
        .task {
            do {
                try await fetchAnswer()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    @Generable
    struct Response {
        @Guide(description: "A brief answer to the question")
        var answer: String
        
        //        @Guide(description: "Whether it was not possible to answer the question")
        //        var insufficientInformation: Bool
        
        @Guide(description: "The related resources")
        var resources: [Resource]?
    }
    
    @Generable
    struct Resource {
        @Guide(description: "The URL to a related resource, including the protocol 'http://' or 'https://'", .maximumCount(2))
        var urls: [String]?
        
        @Guide(description: "The bundle identifier to a related app", .maximumCount(2))
        var appBundleIds: [String]?
    }

    func fetchAnswer() async throws {
        isGenerating = true
        defer { isGenerating = false }
        
        if session == nil {
            session = LanguageModelSession(model: .default, instructions: """
        You are a helpful IT assistant and your task is to take a question as input and provide the user with relevant resources from the provided IT documentation. Additional instructions:
        - Try to match the user's question with the key words in the documentation. 
        - If you don't know the answer respond with something like "Sorry, I cannot help you with that"
        - You MUST respond in the locale or language of the question in the prompt"
"""
            )
        }

        guard let session else {
            return
        }
        
        let stream = session.streamResponse(generating: Response.self) {
            "Question: \(question)"
            if !messageStore.messages.contains(where: {$0.role == .assistant }) {
                "Here is the IT documentation:"
                itDocs
            }

        }

        let answer = FoundationModelMessage(id: UUID(), message: nil, role: .assistant, urls: nil, bundleIDs: nil)
        messageStore.messages.append(answer)
        
        withAnimation {
          scrollPosition.scrollTo(edge: .bottom)
        }
        
        guard let index = messageStore.messages.firstIndex(of: answer) else {
            return
        }

        do {
            for try await partialResponse in stream {
                messageStore.messages[index].message = partialResponse.content.answer ?? ""
                messageStore.messages[index].urls = partialResponse.content.resources?.flatMap { $0.urls ?? [] }
//                messageStore.messages[index].bundleIDs = partialResponse.content.resources?.flatMap { $0.appBundleIds ?? [] }
            }
            
            withAnimation {
              scrollPosition.scrollTo(edge: .bottom)
            }
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
            print("exceededContextWindowSize")
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    let itDocs = """
"""
}
