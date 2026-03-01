//
//  RAGService.swift
//  Support
//
//  Created by Codex on 01/03/2026.
//

import Foundation
import os

@available(macOS 26, *)
actor RAGService {
    static let shared = RAGService()

    private let docsDirectoryURL = URL(fileURLWithPath: "/Library/Application Support/Support App/docs", isDirectory: true)
    private let logger = Logger(subsystem: "nl.root3.support", category: "RAGService")
    private var indexedChunks: [IndexedChunk] = []
    private var hasPreparedIndex = false

    func prepareIndexIfNeeded() async throws {
        guard !hasPreparedIndex else {
            logger.debug("Skipping index preparation because the index is already loaded")
            return
        }

        logger.debug("Preparing RAG index from docs directory: \(self.docsDirectoryURL.path, privacy: .public)")

        let chunks = try loadMarkdownChunks()
        indexedChunks = chunks
        hasPreparedIndex = true
        logger.debug("Loaded \(chunks.count) chunks from local markdown documentation")
        logger.debug("Using lexical retrieval only")
    }

    func context(for question: String, limit: Int = 4) async throws -> String {
        try await prepareIndexIfNeeded()

        logger.debug("Retrieving context for question: \(question, privacy: .public)")

        guard !indexedChunks.isEmpty else {
            logger.debug("No indexed chunks available, returning empty context")
            return ""
        }

        let fallbackMatches = lexicalMatches(for: question, limit: limit)
        logger.debug("Lexical retrieval returned \(fallbackMatches.count) matching chunks")
        return formattedContext(from: fallbackMatches)
    }

    private func loadMarkdownChunks() throws -> [IndexedChunk] {
        guard FileManager.default.fileExists(atPath: docsDirectoryURL.path) else {
            logger.error("Docs directory does not exist at path: \(self.docsDirectoryURL.path, privacy: .public)")
            return []
        }

        let enumerator = FileManager.default.enumerator(
            at: docsDirectoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        var chunks: [IndexedChunk] = []
        var importedFileCount = 0

        while let fileURL = enumerator?.nextObject() as? URL {
            guard isMarkdownFile(fileURL) else {
                continue
            }

            let document = try String(contentsOf: fileURL, encoding: .utf8)
            let fileChunks = chunkDocument(document, sourceURL: fileURL)
            importedFileCount += 1
            chunks.append(contentsOf: fileChunks)
            logger.debug("Imported markdown file \(fileURL.lastPathComponent, privacy: .public) with \(document.count) characters into \(fileChunks.count) chunks")
        }

        logger.debug("Finished importing \(importedFileCount) markdown files")

        return chunks
    }

    private func chunkDocument(_ document: String, sourceURL: URL) -> [IndexedChunk] {
        let sanitizedParagraphs = document
            .components(separatedBy: "\n\n")
            .map { $0.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !sanitizedParagraphs.isEmpty else {
            return []
        }

        let maxChunkLength = 1_200
        var result: [IndexedChunk] = []
        var buffer = ""

        for paragraph in sanitizedParagraphs {
            let candidate = buffer.isEmpty ? paragraph : "\(buffer)\n\n\(paragraph)"
            if candidate.count <= maxChunkLength {
                buffer = candidate
                continue
            }

            if !buffer.isEmpty {
                result.append(IndexedChunk(id: UUID(), sourceURL: sourceURL, text: buffer))
            }

            if paragraph.count <= maxChunkLength {
                buffer = paragraph
            } else {
                let slices = stride(from: 0, to: paragraph.count, by: maxChunkLength).map { index in
                    let start = paragraph.index(paragraph.startIndex, offsetBy: index)
                    let end = paragraph.index(
                        start,
                        offsetBy: min(maxChunkLength, paragraph.count - index),
                        limitedBy: paragraph.endIndex
                    ) ?? paragraph.endIndex
                    return String(paragraph[start..<end])
                }

                for slice in slices {
                    result.append(IndexedChunk(id: UUID(), sourceURL: sourceURL, text: slice))
                }

                buffer = ""
            }
        }

        if !buffer.isEmpty {
            result.append(IndexedChunk(id: UUID(), sourceURL: sourceURL, text: buffer))
        }

        return result
    }

    private func lexicalMatches(for question: String, limit: Int) -> [IndexedChunk] {
        let terms = Set(tokenize(question))

        guard !terms.isEmpty else {
            return []
        }

        let scoredChunks = indexedChunks.compactMap { chunk -> (IndexedChunk, Int)? in
            let score = tokenize(chunk.text).reduce(into: 0) { partialResult, token in
                if terms.contains(token) {
                    partialResult += 1
                }
            }

            return score > 0 ? (chunk, score) : nil
        }

        return scoredChunks
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.sourceURL.lastPathComponent < rhs.0.sourceURL.lastPathComponent
                }

                return lhs.1 > rhs.1
            }
            .prefix(limit)
            .map(\.0)
    }

    private func tokenize(_ text: String) -> [String] {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
    }

    private func formattedContext(from chunks: [IndexedChunk]) -> String {
        logger.debug("Formatting \(chunks.count) chunks into the prompt context")
        return chunks.map { chunk in
            """
            Source: \(chunk.sourceURL.lastPathComponent)
            \(chunk.text)
            """
        }
        .joined(separator: "\n\n---\n\n")
    }

    private func isMarkdownFile(_ fileURL: URL) -> Bool {
        let fileExtension = fileURL.pathExtension.lowercased()
        return ["md", "markdown"].contains(fileExtension)
    }
}

private struct IndexedChunk: Hashable, Identifiable {
    let id: UUID
    let sourceURL: URL
    let text: String
}
