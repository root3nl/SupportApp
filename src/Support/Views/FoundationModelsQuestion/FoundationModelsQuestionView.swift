//
//  FoundationModelsQuestionView.swift
//  Support
//
//  Created by Jordy Witteman on 25/02/2026.
//

import SwiftUI
import FoundationModels
import OSLog

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
    @State private var isGenerating: Bool = false
    @State var scrollPosition: ScrollPosition = .init()
    private let composerInset: CGFloat = 30
    private let ragService = RAGService.shared
    private let logger = Logger(subsystem: "nl.root3.support", category: "FoundationModelsQuestion")

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
                            MessageView(
                                message: message,
                                color: color
                            )
                            .id(message.id)

                            if let urls = message.urls, !urls.isEmpty {
                                ForEach(urls, id: \.self) { url in
                                    MessageAttachmentView(url: url, color: color)
                                }
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "Ask me aything!",
                            systemImage: "sparkles",
                            description: Text("I can help you find relevant resources from our organization.")
                        )
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
        .unredacted()
        .task {
            do {
                try await ragService.prepareIndexIfNeeded()
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
        let currentQuestion = messageStore.messages
            .last(where: { $0.role == .user })?
            .message?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !currentQuestion.isEmpty else {
            logger.debug("Skipping generation because the latest user question is empty")
            return
        }

        logger.debug("Starting answer generation for question: \(currentQuestion, privacy: .public)")

        isGenerating = true
        defer { isGenerating = false }

        let relevantDocumentation = try await ragService.context(for: currentQuestion)
        logger.debug("Retrieved documentation context with \(relevantDocumentation.count) characters")

        if session == nil {
            logger.debug("Creating new LanguageModelSession")
            session = LanguageModelSession(model: .default, instructions: """
        You are a helpful IT assistant and your task is to answer the user's question using only the provided IT documentation excerpts.
        Additional instructions:
        - You MUST respond in the locale or language of the question in the prompt
        - If the supplied documentation does not answer the question, clearly say that the local IT documentation does not cover it
        - Prefer concise, actionable instructions
        """
            )
        }

        guard let session else {
            logger.error("LanguageModelSession is unexpectedly nil after initialization")
            return
        }

        let promptDocumentation = relevantDocumentation.isEmpty ? "No local IT documentation was found." : relevantDocumentation
        let promptPreview = String(promptDocumentation.prefix(500))
        logger.debug("Prompt question: \(currentQuestion, privacy: .public)")
        logger.debug("Prompt context preview (first 500 chars): \(promptPreview, privacy: .public)")

        let stream = session.streamResponse(generating: Response.self) {
            "Question: \(currentQuestion)"
            "Relevant IT documentation:"
            promptDocumentation
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
                logger.debug("Received partial response chunk with \(messageStore.messages[index].message?.count ?? 0) characters")
            }

            logger.debug("Completed answer generation. Final answer length: \(messageStore.messages[index].message?.count ?? 0)")
            logger.debug("Suggested resource URL count: \(messageStore.messages[index].urls?.count ?? 0)")

            withAnimation {
                scrollPosition.scrollTo(edge: .bottom)
            }
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            logger.error("Generation failed because the context window was exceeded")
            print("exceededContextWindowSize")
        } catch {
            logger.error("Generation failed with error: \(error.localizedDescription, privacy: .public)")
            print(error.localizedDescription)
        }
    }
}

