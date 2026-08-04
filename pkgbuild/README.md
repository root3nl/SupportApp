# Package build

Builds the signed and notarized `Support <version>.pkg` installer.
CI uses `build_pkg_automated.zsh` in the repo root; `build_pkg.zsh` here is the
manual local equivalent.

| Path | Purpose |
| --- | --- |
| `scripts/postinstall` | Runs as root at install time. Installs and loads the Support App LaunchAgent, removes the legacy SupportHelper, and hands off to the privileged helper tool installer inside the app bundle. |
| `scripts/nl.root3.support.plist` | LaunchAgent → `/Library/LaunchAgents/` |
| `Support-component.plist` | Component options for `Support.app` (not relocatable, version checked). |
| `distribution.xml` | Distribution wrapper, needed for the `InstallApplication` MDM command. |

## The launchd property lists are static files

The launchd property lists are committed files, shipped with the package and
only copied into place at install time. Nothing generates or mutates a property
list on the target Mac.

There are two of them, in two different places, because the two scripts that
install them live in two different places:

| Property list | Source | Installed by |
| --- | --- | --- |
| `nl.root3.support.plist` | `pkgbuild/scripts/` (package scripts archive) | `pkgbuild/scripts/postinstall` |
| `nl.root3.support.helper.plist` | `src/Support/Scripts/` → `Support.app/Contents/Resources/` | `src/Support/Scripts/install_privileged_helper_tool.zsh` |

The helper's property list ships inside the app bundle because
`install_privileged_helper_tool.zsh` is a bundle resource, invoked by
`postinstall` as
`/Applications/Support.app/Contents/Resources/install_privileged_helper_tool.zsh`.
Keeping the two together means the script resolves its property list from its
own directory and stays self-contained. It is also sealed into the app's code
signature as a side effect.

Both used to be generated at install time — first with `defaults write`, then
with `PlistBuddy`. Both approaches are gone on purpose:

- `defaults write` hands the write to `cfprefsd`, which stamps
  `com.apple.quarantine` on every file it creates. launchd refuses to load
  quarantined property lists on macOS 27 and higher.
- Replacing it with `PlistBuddy` plus `xattr -d com.apple.quarantine` fixed that,
  but writing launchd property lists into `/Library/LaunchDaemons` and then
  stripping quarantine attributes is a persistence-and-evasion signature, and
  XDR/MDR products alerted on it.

The `rm -f` before each copy is load-bearing. Overwriting a file in place reuses
its inode and keeps its extended attributes, so upgrades from a
`defaults write`-era install would otherwise inherit the old quarantine
attribute. `cp -X` then guarantees no extended attributes are copied in, without
invoking `xattr`.

## Do not confuse the two `nl.root3.support.plist` files

There are two files with that name and they are **not** interchangeable:

- `pkgbuild/scripts/nl.root3.support.plist` — the **legacy LaunchAgent**, uses an
  absolute `ProgramArguments` path, installed to `/Library/LaunchAgents/`.
- `src/Support/nl.root3.support.plist` — the **SMAppService agent**, uses
  `BundleProgram`, copied by an Xcode build phase into
  `Support.app/Contents/Library/LaunchAgents/` and registered from
  `AppDelegate.swift` via `SMAppService.agent(plistName:)`.

`AppDelegate` deliberately skips SMAppService registration when the legacy
LaunchAgent is active (`SMAppService.statusForLegacyPlist`), so both mechanisms
coexist. Editing one is not a substitute for editing the other.

## When editing these property lists

- `ProgramArguments` paths are absolute and assume the app is at
  `/Applications/Support.app` — safe because `Support-component.plist` sets
  `BundleIsRelocatable = false`. Keep them in sync when a binary is renamed.
- `SpawnConstraint` restricts launchd to spawning binaries signed by Root3 with
  the expected signing identifier, so an orphaned property list cannot launch a
  substituted binary. It is a macOS 14+ key and is set unconditionally, which is
  safe here because every shipping target is built against macOS 14.
- `AssociatedBundleIdentifiers` makes Login Items show the app name rather than
  the developer name.
- Both build scripts run `plutil -lint` on `pkgbuild/scripts/*.plist` before
  packaging.

The legacy top-level `SupportHelper/` project still generates its LaunchDaemon
with `PlistBuddy` in its own `pkgbuild/scripts/postinstall`. It was left as-is:
its binary (`/usr/local/bin/SupportHelper`) is actively removed by the current
`postinstall`, and `SupportHelper/**` is in `paths-ignore` for CI.

## Verifying a build

```bash
pkgutil --expand-full "build/Support <version>.pkg" /tmp/support-expand && ls -l /tmp/support-expand/Support_component.pkg/Scripts/
```

The helper's property list should be in the app bundle:

```bash
ls -l build/Support.app/Contents/Resources/nl.root3.support.helper.plist
```

After installing, both destinations must be `root:wheel`, mode `644`, and carry
no extended attributes:

```bash
ls -la@ /Library/LaunchAgents/nl.root3.support.plist /Library/LaunchDaemons/nl.root3.support.helper.plist
```
