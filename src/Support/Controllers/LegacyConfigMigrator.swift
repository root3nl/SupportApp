//
//  LegacyConfigMigrator.swift
//  Support
//
//  Converts a Support App 2.x preference dictionary to the 3.x schema and
//  drives the user-facing migration flow (file pickers, parsing, writing).
//

import AppKit
import Foundation
import OSLog
import UniformTypeIdentifiers

/// Converts a Support App 2.x preference dictionary to the 3.x schema and
/// drives the end-to-end user flow.
///
/// `migrate(_:)` is the pure transform — it takes a raw `[String: Any]`
/// preference dict (either a `.plist` root or the inner payload of a
/// `.mobileconfig`) and returns the migrated dictionary. Hide-toggles are
/// honored, info-item defaults are filled in, and 3-up button rows are
/// emitted as `ButtonMedium` while 2-up rows are emitted as `Button`,
/// matching the legacy `LegacyContentView` layout exactly.
///
/// `runUserSelectedMigration()` is the side-effectful entry point: it
/// presents `NSOpenPanel`, parses the chosen file, dispatches to the
/// appropriate payload layout (flat or MCX), serializes the result, and
/// presents `NSSavePanel`. The view that calls it only has to display the
/// returned `Outcome` as an alert.
struct LegacyConfigMigrator {

    // MARK: - User-facing outcome

    /// Result of `runUserSelectedMigration()`. The view turns this into a
    /// SwiftUI alert (or a no-op when the user cancelled a panel).
    /// `Sendable` so it can cross isolation boundaries between detached
    /// off-main work and the main-actor caller.
    enum Outcome: Sendable {
        case cancelled
        case success(URL)
        /// `titleKey` and `messageFormatKey` are Localizable.strings keys.
        /// `arguments` fills `%@` placeholders in the format string. The
        /// array is constrained to `String` (Sendable) — all current
        /// callers pass strings; `String` conforms to `CVarArg` so the
        /// view can hand it to `String(format:arguments:)` directly.
        case failure(titleKey: String, messageFormatKey: String, arguments: [String])
    }

    /// Sendable error thrown across detached-task boundaries. Carries
    /// everything needed to construct an `Outcome.failure`.
    private struct MigrationFailure: Error, Sendable {
        let titleKey: String
        let messageFormatKey: String
        let arguments: [String]
    }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "nl.root3.support",
        category: "LegacyMigration"
    )

    /// Drive the migration flow: prompt for an input file, parse it,
    /// migrate the embedded Support App settings (handling both flat and
    /// MCX `.mobileconfig` layouts), then prompt for an output location
    /// and write the result. Returns an `Outcome` describing success,
    /// user cancellation, or a specific validation/IO failure.
    ///
    /// The two `NSPanel` interactions stay on the main actor; everything
    /// else (file read, plist parse, migrate, serialize, indent rewrite,
    /// file write) runs off-main on a detached task at user-initiated
    /// priority so the UI stays responsive on large profiles.
    @MainActor
    static func runUserSelectedMigration() async -> Outcome {
        guard let inputURL = presentOpenPanel() else { return .cancelled }

        let inputExtension = inputURL.pathExtension.lowercased()
        let isMobileConfig = (inputExtension == "mobileconfig")

        // Read + parse + migrate + serialize + indent-rewrite off-main.
        let preparedData: Data
        do {
            preparedData = try await Task.detached(priority: .userInitiated) {
                try prepareMigratedData(from: inputURL, isMobileConfig: isMobileConfig)
            }.value
        } catch let failure as MigrationFailure {
            return outcome(for: failure)
        } catch {
            // PropertyListSerialization throws plain NSError; we only get
            // here if `prepareMigratedData` lets a non-`MigrationFailure`
            // escape — treat it as a generic parse failure.
            return failure(
                "MIGRATION_ERROR_INVALID_PLIST",
                "MIGRATION_ERROR_PARSE_FAILED",
                error.localizedDescription
            )
        }

        guard let outputURL = presentSavePanel(
            inputURL: inputURL, isMobileConfig: isMobileConfig
        ) else {
            return .cancelled
        }

        // Write off-main as well — large profiles can stall the UI.
        do {
            try await Task.detached(priority: .userInitiated) {
                try preparedData.write(to: outputURL)
            }.value
        } catch {
            return failure(
                "MIGRATION_ERROR_SAVE_FILE",
                "MIGRATION_ERROR_FILE_FORMAT",
                outputURL.lastPathComponent, error.localizedDescription
            )
        }

        return .success(outputURL)
    }

    // MARK: - Panel presentation (main actor)

    @MainActor
    private static func presentOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = .downloadsDirectory
        var allowedTypes: [UTType] = [.propertyList]
        if let mobileconfigType = UTType(filenameExtension: "mobileconfig") {
            allowedTypes.append(mobileconfigType)
        }
        openPanel.allowedContentTypes = allowedTypes
        openPanel.message = NSLocalizedString(
            "MIGRATE_LEGACY_CONFIG_SELECT_FILE",
            comment: "NSOpenPanel prompt for the legacy config migration flow"
        )
        guard openPanel.runModal() == .OK else { return nil }
        return openPanel.url
    }

    @MainActor
    private static func presentSavePanel(
        inputURL: URL, isMobileConfig: Bool
    ) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.directoryURL = .downloadsDirectory
        let stem = inputURL.deletingPathExtension().lastPathComponent
        let ext = inputURL.pathExtension.lowercased()
        savePanel.nameFieldStringValue = "\(stem)-3x.\(ext)"
        if isMobileConfig, let mobileconfigType = UTType(filenameExtension: "mobileconfig") {
            savePanel.allowedContentTypes = [mobileconfigType]
        } else {
            savePanel.allowedContentTypes = [.propertyList]
        }
        guard savePanel.runModal() == .OK else { return nil }
        return savePanel.url
    }

    // MARK: - Off-main preparation

    /// Pure, `nonisolated` pipeline: read input → parse → migrate →
    /// serialize → indent-rewrite → return ready-to-write `Data`. Runs on
    /// a detached task. Throws `MigrationFailure` (Sendable) with the
    /// localized keys + arguments needed for the user-facing alert.
    private static func prepareMigratedData(
        from inputURL: URL, isMobileConfig: Bool
    ) throws -> Data {
        let data: Data
        do {
            data = try Data(contentsOf: inputURL)
        } catch {
            throw MigrationFailure(
                titleKey: "MIGRATION_ERROR_READ_FILE",
                messageFormatKey: "MIGRATION_ERROR_FILE_FORMAT",
                arguments: [inputURL.lastPathComponent, error.localizedDescription]
            )
        }

        let plistObject: Any
        do {
            plistObject = try PropertyListSerialization.propertyList(
                from: data, options: [], format: nil
            )
        } catch {
            throw MigrationFailure(
                titleKey: "MIGRATION_ERROR_INVALID_PLIST",
                messageFormatKey: "MIGRATION_ERROR_PARSE_FAILED",
                arguments: [error.localizedDescription]
            )
        }

        let migratedDict: [String: Any]

        if isMobileConfig {
            guard var wrapper = plistObject as? [String: Any],
                  var payloads = wrapper["PayloadContent"] as? [[String: Any]]
            else {
                throw MigrationFailure(
                    titleKey: "MIGRATION_ERROR_INVALID_PROFILE",
                    messageFormatKey: "MIGRATION_ERROR_NO_PAYLOAD_CONTENT",
                    arguments: []
                )
            }

            // Try both supported layouts:
            //  1. Flat: PayloadType == "nl.root3.support" with settings keys
            //     directly on the payload dict (Support App's own export).
            //  2. MCX:  PayloadType == "com.apple.ManagedClient.preferences"
            //     with settings nested at PayloadContent.nl.root3.support
            //     .Forced[0].mcx_preference_settings (Jamf-style profiles).
            var migratedAnyPayload = false
            for index in payloads.indices {
                if migrateFlatPayload(at: index, in: &payloads)
                    || migrateMCXPayload(at: index, in: &payloads) {
                    migratedAnyPayload = true
                    break
                }
            }

            guard migratedAnyPayload else {
                throw MigrationFailure(
                    titleKey: "MIGRATION_ERROR_NO_PAYLOAD",
                    messageFormatKey: "MIGRATION_ERROR_MISSING_SUPPORT_PAYLOAD",
                    arguments: []
                )
            }

            wrapper["PayloadContent"] = payloads
            migratedDict = wrapper
        } else {
            guard let dict = plistObject as? [String: Any] else {
                throw MigrationFailure(
                    titleKey: "MIGRATION_ERROR_INVALID_PLIST",
                    messageFormatKey: "MIGRATION_ERROR_PLIST_NOT_DICT",
                    arguments: []
                )
            }
            migratedDict = migrate(dict)
        }

        let outputData: Data
        do {
            outputData = try PropertyListSerialization.data(
                fromPropertyList: migratedDict, format: .xml, options: 0
            )
        } catch {
            throw MigrationFailure(
                titleKey: "MIGRATION_ERROR_INVALID_PLIST",
                messageFormatKey: "MIGRATION_ERROR_PARSE_FAILED",
                arguments: [error.localizedDescription]
            )
        }

        return tabsToSpaces(outputData)
    }

    /// Log + lift a thrown `MigrationFailure` into an `Outcome.failure`.
    private static func outcome(for failure: MigrationFailure) -> Outcome {
        logger.error(
            "\(failure.titleKey, privacy: .public) / \(failure.messageFormatKey, privacy: .public)"
        )
        return .failure(
            titleKey: failure.titleKey,
            messageFormatKey: failure.messageFormatKey,
            arguments: failure.arguments
        )
    }

    // MARK: - Payload-layout dispatch

    /// Migrate a payload whose `PayloadType` is `nl.root3.support` (the
    /// flat layout Support App's own Export feature emits). Returns `true`
    /// when the payload at `index` matched and was migrated.
    private static func migrateFlatPayload(
        at index: Int, in payloads: inout [[String: Any]]
    ) -> Bool {
        guard (payloads[index]["PayloadType"] as? String) == "nl.root3.support" else {
            return false
        }
        payloads[index] = migrate(payloads[index])
        return true
    }

    /// Migrate a payload whose `PayloadType` is
    /// `com.apple.ManagedClient.preferences` carrying Support App settings
    /// at `PayloadContent.nl.root3.support.Forced[0].mcx_preference_settings`
    /// (the layout Jamf and other MDMs emit). Returns `true` when the
    /// payload at `index` matched and the nested settings were migrated in
    /// place.
    private static func migrateMCXPayload(
        at index: Int, in payloads: inout [[String: Any]]
    ) -> Bool {
        var payload = payloads[index]
        guard (payload["PayloadType"] as? String)
                == "com.apple.ManagedClient.preferences",
              var innerContent = payload["PayloadContent"] as? [String: Any],
              var supportDomain = innerContent["nl.root3.support"] as? [String: Any],
              var forcedArray = supportDomain["Forced"] as? [[String: Any]],
              !forcedArray.isEmpty,
              var firstForced = forcedArray.first,
              let settings = firstForced["mcx_preference_settings"] as? [String: Any]
        else {
            return false
        }

        firstForced["mcx_preference_settings"] = migrate(settings)
        forcedArray[0] = firstForced
        supportDomain["Forced"] = forcedArray
        innerContent["nl.root3.support"] = supportDomain
        payload["PayloadContent"] = innerContent
        payloads[index] = payload
        return true
    }

    // MARK: - Output formatting

    /// Replace leading tabs on each line with four spaces.
    /// `PropertyListSerialization` indents with tabs; tab characters inside
    /// string values are left alone so we never corrupt content.
    private static func tabsToSpaces(_ data: Data) -> Data {
        guard let text = String(data: data, encoding: .utf8) else { return data }
        let converted = text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line -> String in
                var tabs = 0
                var idx = line.startIndex
                while idx < line.endIndex, line[idx] == "\t" {
                    tabs += 1
                    idx = line.index(after: idx)
                }
                return String(repeating: "    ", count: tabs) + line[idx...]
            }
            .joined(separator: "\n")
        return converted.data(using: .utf8) ?? data
    }

    /// Log a migration failure and package it as an `Outcome.failure`.
    /// Variadic `arguments` fill `%@` placeholders in the localized format.
    private static func failure(
        _ titleKey: String, _ messageFormatKey: String, _ arguments: String...
    ) -> Outcome {
        logger.error(
            "\(titleKey, privacy: .public) / \(messageFormatKey, privacy: .public)"
        )
        return .failure(
            titleKey: titleKey,
            messageFormatKey: messageFormatKey,
            arguments: arguments
        )
    }

    // MARK: - Pure migration transform

    static func migrate(_ source: [String: Any]) -> [String: Any] {
        var result = source

        // If a 3.x Rows array is already present and non-empty, leave it.
        let existingRows = result["Rows"] as? [Any]
        let rowsAlreadyPresent = (existingRows?.isEmpty == false)

        if !rowsAlreadyPresent {
            var rows: [[String: Any]] = []

            // Info rows.
            let infoRows: [(String, String, String, String, String)] = [
                ("InfoItemOne",   "ComputerName",  "InfoItemTwo",   "MacOSVersion", "HideFirstRowInfoItems"),
                ("InfoItemThree", "Uptime",        "InfoItemFour",  "Storage",      "HideSecondRowInfoItems"),
                ("InfoItemFive",  "",              "InfoItemSix",   "",             "HideThirdRowInfoItems")
            ]
            for (key1, default1, key2, default2, hideKey) in infoRows {
                if boolValue(result[hideKey]) { continue }

                var items: [[String: Any]] = []
                for (key, defaultValue) in [(key1, default1), (key2, default2)] {
                    let value: String
                    if let raw = result[key] as? String {
                        value = raw
                    } else {
                        value = defaultValue
                    }
                    if !value.isEmpty {
                        items.append(["Type": value])
                    }
                }
                if !items.isEmpty {
                    rows.append(["Items": items])
                }
            }

            // Button rows.
            for (rowName, hideKey) in [("First", "HideFirstRowButtons"),
                                       ("Second", "HideSecondRowButtons")] {
                if boolValue(result[hideKey]) { continue }

                var populated: [(title: String, subtitle: String, symbol: String,
                                 link: String, type: String)] = []
                for slot in ["Left", "Middle", "Right"] {
                    let title = stringValue(result["\(rowName)RowTitle\(slot)"])
                    let link = stringValue(result["\(rowName)RowLink\(slot)"])
                    if title.isEmpty && link.isEmpty { continue }
                    populated.append((
                        title: title,
                        subtitle: stringValue(result["\(rowName)RowSubtitle\(slot)"]),
                        symbol: stringValue(result["\(rowName)RowSymbol\(slot)"]),
                        link: link,
                        type: stringValue(result["\(rowName)RowType\(slot)"])
                    ))
                }
                if populated.isEmpty { continue }

                let buttonType = (populated.count >= 3) ? "ButtonMedium" : "Button"
                var items: [[String: Any]] = []
                for slot in populated {
                    var item: [String: Any] = ["Type": buttonType]
                    if !slot.title.isEmpty    { item["Title"]      = slot.title }
                    if !slot.subtitle.isEmpty { item["Subtitle"]   = slot.subtitle }
                    if !slot.symbol.isEmpty   { item["Symbol"]     = slot.symbol }
                    if !slot.link.isEmpty     { item["Action"]     = slot.link }
                    if !slot.type.isEmpty     { item["ActionType"] = slot.type }
                    items.append(item)
                }
                rows.append(["Items": items])
            }

            // Extension rows.
            for letter in ["A", "B"] {
                let title = stringValue(result["ExtensionTitle\(letter)"])
                let link = stringValue(result["ExtensionLink\(letter)"])
                if title.isEmpty && link.isEmpty { continue }

                var item: [String: Any] = ["Type": "Extension"]
                if !title.isEmpty { item["Title"] = title }
                let subtitle = stringValue(result["ExtensionValue\(letter)"])
                let symbol = stringValue(result["ExtensionSymbol\(letter)"])
                let actionType = stringValue(result["ExtensionType\(letter)"])
                if !subtitle.isEmpty   { item["Subtitle"]   = subtitle }
                if !symbol.isEmpty     { item["Symbol"]     = symbol }
                if !link.isEmpty       { item["Action"]     = link }
                if !actionType.isEmpty { item["ActionType"] = actionType }

                // Reverse-DNS bundle id heuristic: contains '.', no '/' or ':'.
                if !link.isEmpty,
                   link.contains("."),
                   !link.contains("/"),
                   !link.contains(":") {
                    item["ExtensionID"] = link
                }

                rows.append(["Items": [item]])
            }

            if !rows.isEmpty {
                result["Rows"] = rows
            }
        }

        // Strip 2.x keys regardless of whether we rebuilt Rows.
        for key in legacyKeys {
            result.removeValue(forKey: key)
        }
        return result
    }

    private static let legacyKeys: [String] = {
        var keys: [String] = [
            "InfoItemOne", "InfoItemTwo", "InfoItemThree",
            "InfoItemFour", "InfoItemFive", "InfoItemSix",
            "HideFirstRowInfoItems", "HideSecondRowInfoItems",
            "HideThirdRowInfoItems",
            "HideFirstRowButtons", "HideSecondRowButtons"
        ]
        for row in ["First", "Second"] {
            for prop in ["Title", "Subtitle", "Type", "Link", "Symbol"] {
                for slot in ["Left", "Middle", "Right"] {
                    keys.append("\(row)Row\(prop)\(slot)")
                }
            }
        }
        for letter in ["A", "B"] {
            for prop in ["Title", "Value", "Symbol", "Type", "Link", "Alert"] {
                keys.append("Extension\(prop)\(letter)")
            }
        }
        return keys
    }()

    private static func stringValue(_ raw: Any?) -> String {
        (raw as? String) ?? ""
    }

    private static func boolValue(_ raw: Any?) -> Bool {
        if let bool = raw as? Bool { return bool }
        if let num = raw as? NSNumber { return num.boolValue }
        return false
    }
}
