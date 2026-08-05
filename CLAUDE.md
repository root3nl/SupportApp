# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Support App is a macOS menu bar app (SwiftUI, `LSUIElement = true`) for organizations — diagnostic info, shortcuts to support resources, App Catalog integration, macOS update prompts. Distributed via MDM and configured almost entirely through managed `UserDefaults` (Configuration Profile). Vendor: Root3 (Team ID `98LJ4XBGYK`).

- Deployment target: macOS 14.0
- Swift 5.0, app-sandboxed
- App bundle ID: `nl.root3.support`
- Version / build are tracked in `src/Support/Info.plist` (`CFBundleShortVersionString`, `CFBundleVersion`) and bumped by CI via `xcrun agvtool next-version -all` (run from `src/`).

## Builds and CI

There is no test target, no package manager, and no lint config. Everything is Xcode.

Local build of the app:

```sh
xcodebuild clean build \
  -project src/Support.xcodeproj \
  -scheme Support \
  -configuration Release \
  -archivePath ./build/Support.xcarchive \
  archive

xcodebuild -archivePath ./build/Support.xcarchive \
  -exportArchive -exportPath ./build \
  -exportOptionsPlist ./pkgbuild/exportOptions.plist
```

Packaged release (signed `.pkg`, notarized, stapled) is produced by `build_pkg_automated.zsh <version> <apple_id> <app_specific_password> <xcode_path>`. It requires the Developer ID Installer cert "Developer ID Installer: Root3 B.V. (98LJ4XBGYK)" in the keychain and a notarytool keychain profile named `Root3`. Don't try to run this locally without those secrets — it's intended for GitHub Actions.

GitHub Actions workflows in `.github/workflows/`:
- `build_pkg_beta.yml` — triggered on push to `development`. Bumps build number, **flips `betaRelease` to `true` in `src/Support/Preferences.swift` via `sed`** (this edit is intentional and not committed back), builds, notarizes, uploads artifact.
- `build_pkg_release_manual.yml` — manual dispatch, builds the release `.pkg` (no build bump, no beta watermark).
- `build_pkg_alpha_xcode_beta.yml` — self-hosted runner, uses Xcode beta from `vars.XCODE_VERSION_BETA`.

Branch convention: develop on `development`, release on `main`. Pushing to `development` triggers an artifact build.

## Three Xcode targets in `src/Support.xcodeproj`

1. **Support** — the main sandboxed app (`nl.root3.support`).
2. **nl.root3.support.helper** — Privileged Helper Tool, source in `src/SupportHelper/`. Installed at `/Library/PrivilegedHelperTools/nl.root3.support.helper` via `SMJobBless` (see `src/Support/PrivilegedHelper/HelperRemote.swift`). Runs as root. Used for actions that require elevation.
3. **SupportXPC** — bundled XPC service (`nl.root3.support.xpc`), source in `src/SupportXPC/`. **Not sandboxed** (`app-sandbox = false` in its entitlements). Used to escape the main app's sandbox for actions that don't need root.

Both helpers expose a `executeScript(command:)` interface plus a few specialized calls (e.g. `getUpdateDeclaration`, `verifyAppCatalogCodeRequirement` on `SupportXPC`). XPC connections in both directions enforce a code-signing requirement that pins the Team ID — see `ConnectionIdentityService` in `src/SupportHelper/` and `codeRequirement` in `src/SupportHelper/SupportHelper.swift`. Don't loosen those.

### Don't confuse the two "SupportHelper"s

There is a **separate, legacy** Xcode project at `SupportHelper/SupportHelper.xcodeproj` (top-level, not under `src/`). That's a LaunchAgent that listens for `DistributedNotificationCenter` notifications (`nl.root3.support.Action`, `nl.root3.support.SupportAppeared`) and runs MDM-defined shell actions. It is unrelated to the SMJobBless helper at `src/SupportHelper/`. CI ignores `SupportHelper/**` (see `paths-ignore` in workflows). When the request touches "the helper", clarify which one.

For security, both helpers only execute commands whose `UserDefaults` key is forced by MDM (`supportDefaults.objectIsForced(forKey:)`). Preserve this check — unmanaged values must be ignored.

## Configuration model

Everything user-facing is driven by `UserDefaults` keys in the `nl.root3.support` domain, normally delivered via Configuration Profile (`Configuration Profile Samples/Support App Configuration Sample.mobileconfig`, schema in `Jamf Pro Custom Schema/Jamf Pro Custom Schema.json`).

Two parallel preferences containers, both conforming to `PreferencesProtocol` (`src/Support/LocalPreferences.swift`):

- `Preferences` — wraps `@AppStorage` over the real `nl.root3.support` defaults. This is what's read in production.
- `LocalPreferences` — `@Published` in-memory copy used by **Configurator Mode**, the in-app GUI editor.

Views select between them with the same pattern everywhere:

```swift
var activePreferences: PreferencesProtocol {
    preferences.configuratorModeEnabled ? localPreferences : preferences
}
```

Keep that pattern when adding new view code that reads preferences. When adding a new managed preference:
1. Add an `@AppStorage` in `Preferences.swift`.
2. Add a matching `@Published` in `LocalPreferences.swift` (and its `clear()`).
3. Add it to `PreferencesProtocol` if views need to read it via `activePreferences`.
4. Add it to `AppModel` in `src/Support/Models/AppModel.swift` with the same `CodingKeys` raw value as the `@AppStorage` key — `AppModel` is what Configurator Mode exports as a `.plist` / `.mobileconfig` (see `AppView.exportPropertyList` / `exportMobileConfig`).
5. Add the key to the Jamf custom schema JSON if it should be admin-visible.

`Preferences.saveUserDefaults(appConfiguration:)` encodes an `AppModel` to a plist and writes it to the persistent domain — this is how Configurator Mode commits changes from the in-app editor.

## App structure

- `SupportApp.swift` — `@main`, hosts `ConfiguratorSettingsView` in the `Settings` scene; the menu bar UI is set up by `AppDelegate.applicationDidFinishLaunching`.
- `AppDelegate.swift` — owns the `NSStatusItem`, `NSPopover`, timers, `LaunchAgent` registration via `SMAppService`, and instantiates the shared `ObservableObject`s (`ComputerInfo`, `UserInfo`, `Preferences`, `LocalPreferences`, `AppCatalogController`, `PopoverLifecycle`).
- `AppView.swift` — root SwiftUI view in the popover. Chooses between: welcome screen, App Catalog updates, macOS updates, uptime alert, item configuration, new `ContentView` (row-based), or `LegacyContentView` (fixed grid, used when no `rows` configured).
- `ComputerInfo.swift`, `UserInfo.swift` — large `ObservableObject`s that publish system/user state for the info items (these are the big files; ~38k and ~22k respectively).
- `Views/ButtonTemplateViews/` — the reusable item templates (`Item`, `ItemSmall`, `ItemDouble`, `ItemCircle`, `ItemExtension`, `ProgressBarItem`, `InfoItem`). Subviews in `Views/ButtonViews/` provide the per-item content (Storage, Uptime, Password, Network, etc.).
- `Constants.swift` — popover and item dimensions. Don't hardcode widths; reuse these.
- `Views/ViewModifiers/GlassEffectModifier.swift` / `GlassContainerIfAvailable.swift` — macOS 26+ "glass" styling is feature-gated with `if #available(macOS 26, *)`; preserve the fallback branch when editing styled views.

## Localization

`.lproj` directories under `src/Support/`: `de`, `en`, `es`, `fr`, `nl`, `nl-NL`, `sv`. Add new user-facing strings to **all** locales' `Localizable.strings` (use `NSLocalizedString(...)` or SwiftUI's `Text("…")` with a literal — SwiftUI extracts both).

## Things to leave alone unless explicitly asked

- The `betaRelease` Bool in `Preferences.swift` — CI rewrites it.
- The `codeRequirement` strings and `setCodeSigningRequirement` calls in the helpers and `Info.plist` `SMPrivilegedExecutables` — they pin the Root3 Team ID and certificate fields; changing them breaks SMJobBless.
- The `objectIsForced` guard in both helpers' notification/script handlers — it's the only thing preventing arbitrary script execution from any process that can write the user's defaults.
- `pkgbuild/`, `build_pkg_automated.zsh`, `exportOptions.plist`, `distribution.xml` — signing and notarization are tightly coupled; small edits here break the release pipeline.
