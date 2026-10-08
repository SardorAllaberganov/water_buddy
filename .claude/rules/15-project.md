---
description: Targets, schemes, membership and signing — the project file is a contract
globs: ["WaterBuddy.xcodeproj/**", "Entitlements/**", "Tools/**", "**/*.plist", "WaterBuddyWatch/**", "WaterBuddyWatchTests/**", "WaterBuddyWatchWidget/**"]
---

# Project

One Xcode project, **seven** targets, **four** of them signed. The project file carries invariants
the test suite structurally cannot see. These counts were re-derived from `xcodebuild -list
-project WaterBuddy.xcodeproj` and a `grep -c` over `project.pbxproj` on 2026-09-01, at the end of
the watchOS plan — do not increment the previous numbers by hand; re-derive them the same way.

## Targets and schemes
| Target | Bundle id | Role |
|---|---|---|
| `WaterBuddy` | `sardor.WaterBuddy` | the app |
| `WaterBuddyWidgetExtension` | `sardor.WaterBuddy.WaterBuddyWidget` | the phone WidgetKit extension |
| `WaterBuddyTests` | `sardor.WaterBuddyTests` | swift-testing, phone side |
| `WaterBuddyUITests` | `sardor.WaterBuddyUITests` | XCTest, phone side |
| `WaterBuddyWatch` | `sardor.WaterBuddy.watchkitapp` | the watch app |
| `WaterBuddyWatchTests` | `sardor.WaterBuddyWatchTests` | swift-testing, watch side |
| `WaterBuddyWatchWidget` | `sardor.WaterBuddy.watchkitapp.WaterBuddyWatchWidget` | the watch WidgetKit extension |

`WaterBuddyWatch`'s bundle id keeps the classic-era `.watchkitapp` suffix — a pre-existing spelling
from before this design was read, kept deliberately rather than renamed for its own sake.

- **`xcodebuild -list` reports four schemes, not seven**: `WaterBuddy`, `WaterBuddyWatch`,
  `WaterBuddyWatchWidget`, `WaterBuddyWidgetExtension`. The three `*Tests` targets have no scheme of
  their own; each is driven with `-only-testing:` against the scheme of the app that hosts it
  (`WaterBuddyTests`/`WaterBuddyUITests` under `-scheme WaterBuddy`, `WaterBuddyWatchTests` under
  `-scheme WaterBuddyWatch`)
- **The watch widget's scheme is `WaterBuddyWatchWidget`, with no "Extension" suffix** — unlike the
  phone widget's `WaterBuddyWidgetExtension`. The two targets are not named in parallel; do not
  assume one from the other when writing a gate command
- **No scheme compiles a sibling's sources.** `WaterBuddy` does not compile
  `WaterBuddyWidgetExtension`'s sources, and `WaterBuddyWatch` does not compile
  `WaterBuddyWatchWidget`'s — a widget-only or watch-widget-only break passes its container app's
  green test run untouched. Build every extension separately (rule `85-testing`)
- **All four schemes are now shared and checked in** under
  `WaterBuddy.xcodeproj/xcshareddata/xcschemes/`, as of 2026-09-01. They were auto-created from the
  target names until two of them (`WaterBuddyWatchWidget`, `WaterBuddyWidgetExtension`) were marked
  Shared in Xcode — which writes `SuppressBuildableAutocreation` for **every** target into
  `xcuserdata/…/xcschememanagement.plist` and stops Xcode auto-creating the rest. The `WaterBuddy`
  and `WaterBuddyWatch` schemes silently disappeared from the picker, and with them the ability to
  build the app to a device at all. The four `.xcscheme` files are the fix and must stay checked in:
  once autocreation is suppressed, a missing file is a missing scheme. `xcodebuild -list` is the
  check — it must report exactly four
- **`IPHONEOS_DEPLOYMENT_TARGET = 17.0`** on all ten sites that take it (project level, the app, the
  widget extension, and both test targets, Debug and Release each) and **`WATCHOS_DEPLOYMENT_TARGET
  = 26.0`** on all six watch-side sites, `SWIFT_VERSION = 5.0` project-wide, and
  **`TARGETED_DEVICE_FAMILY = 1` on the four phone-side targets, `4` on the three watch-side ones** —
  **iPhone and Apple Watch only. iPad was dropped on 2026-09-02** and there is no iPad layout to
  verify any more. Superseded on that date: the previous text read `26.5`/`26.5`/`"1,2"` and said
  "the app ships for iPad as well as iPhone."
  - The floors moved **down**, which is the unusual direction, so the reasoning is worth keeping.
    The app target had drifted to `18.6` while its own embedded widget extension was still `26.5` —
    meaning the widget did not exist on any device below 26.5, a live defect in a shipped
    configuration. Both are now 17.0 and the mismatch is closed.
  - **The drop cost zero source changes.** Verified by building at both floors and diffing the
    warning sets: identical, 38 warnings either way, zero errors. No `#available` branch was added
    anywhere. Do not assume a future floor change is equally free — re-run the same experiment.
  - **`17.0` and `26.0` are compile- and link-verified only.** No iOS 17.x runtime and no watchOS
    26.0 runtime is installed on this machine, so nothing has ever *run* at either floor.
    `vtool -show-build` on the built binaries (`minos 17.0`, `minos 26.0`) is the whole of the
    evidence (rule `85-testing`)
  - **Two iPad artifacts survive the device-family change and cannot be removed from the project
    file.** Xcode 26.6's `actool` emits `AppIcon76x76@2x~ipad.png` and a `CFBundleIcons~ipad`
    Info.plist key from a modern single-size universal icon **unconditionally**, even when passed
    `--target-device iphone` alone and with `TARGETED_DEVICE_FAMILY = 1`. Confirmed on a clean build
    into empty DerivedData, so it is not a stale-artifact effect. The compiled `Assets.car` *is*
    correct — 4 `phone` renditions, zero `pad` — and iOS never reads `CFBundleIcons~ipad` on a
    family-1 app, so this is dead weight rather than a defect. Do not "fix" it by hand; it is
    regenerated every build

## Membership
- All seven targets' sources come from their own `PBXFileSystemSynchronizedRootGroup` — a new file
  dropped in a folder joins that target automatically. That makes **seven** synchronized-folder-
  bearing targets, not four
- `WaterBuddy/` gives nothing to any of the other three native targets that reach into it by
  default. Three separate `PBXFileSystemSynchronizedBuildFileExceptionSet`s do that work, **not
  one** — the `target` field on each is scalar, so a single set can never serve two targets:
  - `WaterBuddyWidgetExtension`'s (pre-existing, six files): `DataManager.swift`,
    `LiquidGlassModifier.swift`, `NotificationManager.swift`, `ReminderPlan.swift`, `WaterLog.swift`,
    `WaterSurface.swift`
  - `WaterBuddyWatch`'s (Task 9 of the watchOS plan, six files): `DataManager.swift`,
    `LiquidGlassModifier.swift`, `ReminderPlan.swift`, `WaterLog.swift`, `WaterSurface.swift`, and
    `WristPlan.swift` — omitting `NotificationManager.swift`, since `role.mayFileReminders` is
    `false` on both watch roles and shipping the notification surface to a process that can never
    file one is pointless
  - `WaterBuddyWatchWidget`'s (Task 16, **six** files as of 2026-09-01): `DataManager.swift`,
    `LiquidGlassModifier.swift`, `ReminderPlan.swift`, `WaterLog.swift`, `WaterSurface.swift`,
    `WristPlan.swift` — omitting only `NotificationManager.swift`. It was five until spec §16 made
    the complication count pending outbox pours alongside the mirror, which requires `WristPlan`'s
    day bucketing; the earlier claim that this widget "never buckets pours itself" is retired.
    `LiquidGlassModifier.swift` is required only transitively, through `WaterSurface.swift`'s own
    `#Preview`
- **Each list is its own contract.** A new shared file, or a rename, missing from the relevant
  exception set fails to compile only in that one target — which no other target's green test run
  touches. Do not grow any of the three lists casually; put anything more than one target needs into
  a file already on the relevant list (rule `40-widget`, rule `25-shared-storage`)
- `AddWaterIntent` is compiled into the phone widget extension **only**; a second copy in the app
  binary registers the same Shortcuts action twice
- `LogServingIntent` and `WaterBuddyShortcuts` are app-only and stay out of every exception set: a
  provider and its intents share a target. `AddWaterIntent` stays the widget extension's own,
  differently named action
- A file importing a framework unavailable to iOS or watchOS must live outside all seven
  synchronized folders — `Tools/` at the repository root belongs to no target, which is why
  `GenerateAppIcon.swift` sits there and is run with `swift Tools/GenerateAppIcon.swift`

## Never ship workflow config
- **`CLAUDE.md` and `.claude/**` are never members of a build target.** They appear in the navigator
  for editing and nothing more. `docs/`, `tasks/` and `HISTORY.md` likewise
- They live at the repository root, outside every synchronized folder, so this holds by construction —
  keep it that way

## Signing
- **Four** signed targets, not two: `WaterBuddy`, `WaterBuddyWidgetExtension`, `WaterBuddyWatch`,
  `WaterBuddyWatchWidget`. Each carries its own file under `Entitlements/` —
  `WaterBuddy.entitlements`, `WaterBuddyWidgetExtension.entitlements`,
  `WaterBuddyWatch.entitlements`, `WaterBuddyWatchWidgetExtension.entitlements` — wired via
  `CODE_SIGN_ENTITLEMENTS` in **both** Debug and Release, each listing `group.sardor.WaterBuddy`
- All four files are currently byte-identical (same content, re-verified by `shasum`) and nothing
  enforces that. If one changes, check the other three by hand — and verify the built product with
  `codesign -d --entitlements - <path>`, because a missing entitlement degrades silently
  (rule `25-shared-storage`)
- The App Group is the only entitlement on any of the four targets (rule `70-privacy`).
  `WatchConnectivity` itself needs **no** entitlement — the watch targets carry the identical single
  App Group entitlement as the phone side, nothing more

## Submission

Added 2026-09-02, when the project was first prepared for App Store Connect. None of this is visible
to the five-invocation gate — every item here fails at *upload*, after a successful archive.

- **Four `PrivacyInfo.xcprivacy` files, one per shipping bundle** — `WaterBuddy/`,
  `WaterBuddyWidget/`, `WaterBuddyWatch/`, `WaterBuddyWatchWidget/`. They are byte-identical, and
  each target's `PBXFileSystemSynchronizedRootGroup` gives membership with **no `project.pbxproj`
  edit at all** (verified: all four land in the built bundles). This is not optional paperwork —
  `UserDefaults` is a required-reason API, and Apple's wording is that since 1 May 2024 apps that do
  not declare their required-reason API use "aren't accepted by App Store Connect". A rejection, not
  a warning. All four bundles compile `DataManager.swift`, so all four need one; declaring only the
  two iOS bundles would still be rejected
- The declared reasons are **`1C8F.1`** (App Group-scoped access — `DataManager.sharedDefaults`
  resolving `group.sardor.WaterBuddy`) and **`CA92.1`** (app-scoped — the `.standard` fallback and
  the one-shot migration). `NSPrivacyTracking` is `false` with both arrays empty, which is true by
  construction: no account, no server, no analytics, no networking import anywhere (rule
  `70-privacy`, rule `95-dependencies`). If a future change adds a required-reason API — the file
  timestamp, disk space and active-keyboard categories are the other likely ones — all four files
  change together
- **`INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO`** on the app target's two configurations only.
  Extensions and the watch app inherit the containing app's declaration; do not duplicate it.
  Verified as `false` in the built `Info.plist`. Without it every upload stalls on a manual
  export-compliance questionnaire
- **The app icon is delivered inside the bundle, never uploaded separately.** App Store Connect has
  no icon upload field any more. The 1024² marketing icon comes out of the asset catalog, which is
  why `WaterBuddyWatch/Assets.xcassets/AppIcon.appiconset/Contents.json` must use the modern
  `universal` + **`"platform" : "watchos"`** single-size form. It carried `"idiom" :
  "watch-marketing"` until 2026-09-02, which compiles — silently, zero `actool` diagnostics — to a
  rendition whose idiom is `marketing` and **no watch launcher icon at all**. `"platform"` is
  load-bearing: omit it and `actool` emits no `Assets.car` whatsoever, again as a warning with exit
  code 0. Check with
  `xcrun assetutil --info <built>/WaterBuddyWatch.app/Assets.car | grep '"Idiom"'` → `watch`
- **Do not strip the alpha channel from the icon PNGs.** It looks like an ITMS-90717 risk and is
  not: every alpha byte in both marketing icons is already 255, and `actool` compiles a
  **byte-identical** `Assets.car` from RGB and RGBA sources (proven by sha256, both platforms). The
  compiled rendition is marked `Opaque: true` either way, because `Opaque` is derived from content
  rather than from the encoding. Stripping cannot change one byte of what is submitted

## Localization
- `developmentRegion = en`, `knownRegions = (en, ru, uz, Base)`, and
  `LOCALIZATION_PREFERS_STRING_CATALOGS = YES` at project level
- Adding a language means the catalogue in **all four** of `WaterBuddy/`, `WaterBuddyWidget/`,
  `WaterBuddyWatch/` and `WaterBuddyWatchWidget/`, plus `knownRegions`, plus `AppLanguage.selectable`
  (rule `70-privacy`)
- `WaterBuddy/AppShortcuts.xcstrings` is a fifth catalogue — Siri's phrases only, in `en` and `ru`,
  because Siri has no Uzbek (rule `70-privacy`)
