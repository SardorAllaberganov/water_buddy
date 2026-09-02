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
- `IPHONEOS_DEPLOYMENT_TARGET = 26.5` and `WATCHOS_DEPLOYMENT_TARGET = 26.5` on every target that
  takes the respective setting, `SWIFT_VERSION = 5.0` project-wide, and **`TARGETED_DEVICE_FAMILY =
  "1,2"` on the four phone-side targets, `4` on the three watch-side ones** — the app ships for iPad
  as well as iPhone, and a layout change is verified on both; the watch side has no such split

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

## Localization
- `developmentRegion = en`, `knownRegions = (en, ru, uz, Base)`, and
  `LOCALIZATION_PREFERS_STRING_CATALOGS = YES` at project level
- Adding a language means the catalogue in **both** `WaterBuddy/` and `WaterBuddyWidget/`, plus
  `knownRegions`, plus `AppLanguage.selectable` (rule `70-privacy`)
