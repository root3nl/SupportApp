//
//  ButtonIconView.swift
//  Support
//

import os
import SwiftUI

// View to show the icon of a configurable button. Shows the custom image when the Image preference
// key is set and the image can be loaded, with a fallback to the SF Symbol from the Symbol key
struct ButtonIconView: View {

    // SF Symbol shown when no custom image is configured or the custom image cannot be loaded
    var symbol: String

    // Optional local file path, remote URL or Base64 encoded data URI of a custom image
    var image: String?

    // Color for the SF Symbol
    var symbolColor: Color

    // Font for the SF Symbol
    var symbolFont: Font

    // Optional background shape behind the SF Symbol. No background is shown when nil
    var backgroundColor: Color? = nil

    // Size of the custom image. The SF Symbol is sized by the view using this view
    var imageSize: CGFloat

    // Declare unified logging
    let logger = Logger(subsystem: "nl.root3.support", category: "ButtonIcon")

    @EnvironmentObject private var popoverLifecycle: PopoverLifecycle
    @State private var loadedImage: NSImage?
    @State private var loadedSource: String?

    private struct LoadID: Equatable {
        let source: String?
        let presentation: UUID
    }

    // Path to the local custom image, nil when no, a remote or a Base64 encoded image is configured
    private var localImagePath: String? {
        guard let image, !image.isEmpty, !image.hasPrefix("http"), !image.hasPrefix("data:") else {
            return nil
        }

        // Support both file URLs and paths starting with a tilde
        if image.hasPrefix("file://") {
            return URL(string: image)?.path
        } else {
            return (image as NSString).expandingTildeInPath
        }
    }

    var body: some View {
        Group {
            if let image, image.hasPrefix("http") {
                AsyncImage(url: URL(string: image)) { phase in
                    if let remoteImage = phase.image {
                        remoteImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                    } else {
                        symbolView
                    }
                }
            } else if loadedSource == image, let loadedImage {
                Image(nsImage: loadedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
            } else {
                symbolView
            }
        }
        .task(id: LoadID(source: image, presentation: popoverLifecycle.presentationToken)) {
            loadedImage = nil
            loadedSource = nil
            guard let image, !image.isEmpty, !image.hasPrefix("http") else { return }

            let result: NSImage?
            if image.hasPrefix("data:") {
                result = await ButtonImageLoader.shared.base64Image(dataURI: image)
            } else if let localImagePath {
                result = await ButtonImageLoader.shared.localImage(path: localImagePath)
            } else {
                result = nil
            }

            // A previous request must not replace an image after the source changes.
            guard !Task.isCancelled else { return }
            loadedSource = image
            loadedImage = result
            if result == nil {
                // Do not expose embedded image contents in the log.
                logger.error("Custom button image could not be loaded. Falling back to SF Symbol...")
            }
        }
    }

    // SF Symbol with optional background shape
    @ViewBuilder private var symbolView: some View {

        if let backgroundColor {
            Ellipse()
                .foregroundColor(backgroundColor)
                .overlay(
                    Image(systemName: symbol)
                        .foregroundColor(symbolColor)
                        .font(symbolFont)
                )
        } else {
            Image(systemName: symbol)
                .font(symbolFont)
                .foregroundColor(symbolColor)
        }
    }
}

// Serializes loading away from the main actor. Local files are read once per
// presentation/source change, never on hover. Reading them afresh also handles
// replacement, deletion and repaired files without a stale path-based cache.
actor ButtonImageLoader {
    static let shared = ButtonImageLoader()
    private let embeddedImages: NSCache<NSString, NSImage> = {
        let cache = NSCache<NSString, NSImage>()
        cache.countLimit = 32
        return cache
    }()

    func localImage(path: String) -> NSImage? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        return NSImage(data: data)
    }

    func base64Image(dataURI: String) -> NSImage? {
        if let cached = embeddedImages.object(forKey: dataURI as NSString) {
            return cached
        }
        // Profile editors may wrap Base64 strings over multiple lines.
        guard let separator = dataURI.firstIndex(of: ","),
              let data = Data(base64Encoded: String(dataURI[dataURI.index(after: separator)...]),
                              options: .ignoreUnknownCharacters),
              let image = NSImage(data: data) else { return nil }
        embeddedImages.setObject(image, forKey: dataURI as NSString)
        return image
    }
}
