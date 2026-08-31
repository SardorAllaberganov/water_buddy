---
description: Targets, schemes, membership and signing — the project file is a contract
globs: ["WaterBuddy.xcodeproj/**", "Entitlements/**", "Tools/**", "**/*.plist"]
---

# Project

One Xcode project, four targets, two of them signed. The project file carries invariants the test
suite structurally cannot see.

## Targets and schemes
| Target | Bundle id | Role |
|---|---|---|
| `WaterBuddy` | `sardor.WaterBuddy` | the app |
| `WaterBuddyWidgetExtension` | `sardor.WaterBuddy.WaterBuddyWidget` | the WidgetKit extension |
| `WaterBuddyTests` | `sardor.WaterBuddyTests` | swift-testing |
| `WaterBuddyUITests` | `sardor.WaterBuddyUITests` | XCTest |

- The two schemes are `WaterBuddy` and `WaterBuddyWidgetExtension`. **The app scheme does not compile
  the widget's own sources**, so a widget-only break passes a green test run untouched — build the
  extension separately (rule `85-testing`)
- No shared schemes are checked in; both are auto-created from the target names. The moment either
  gains a test plan or an environment variable, mark it Shared
- `IPHONEOS_DEPLOYMENT_TARGET = 18.5`, `SWIFT_VERSION = 5.0`, and **`TARGETED_DEVICE_FAMILY = "1,2"`
  — the app ships for iPad as well as iPhone.** A layout change is verified on both

## Membership
- `WaterBuddy/`, `WaterBuddyWidget/`, `WaterBuddyTests/` and `WaterBuddyUITests/` are
  `PBXFileSystemSynchronizedRootGroup`s: a new file joins its folder's target automatically
- The extension gets nothing from `WaterBuddy/` by default. Exactly six files reach it through the
  `membershipExceptions` exception set:
  `DataManager.swift`, `LiquidGlassModifier.swift`, `NotificationManager.swift`, `ReminderPlan.swift`,
  `WaterLog.swift`, `WaterSurface.swift`
- **That list is the contract.** A new shared file, or a rename, that is not added to it fails to
  compile only in the widget target. Do not grow the list casually — put anything both processes need
  into one of the six instead (rule `40-widget`)
- `AddWaterIntent` is compiled into the widget extension **only**; a second copy in the app binary
  registers the same Shortcuts action twice
- A file importing a framework unavailable to iOS must live outside all four synchronized folders —
  `Tools/` at the repository root belongs to no target, which is why `GenerateAppIcon.swift` sits
  there and is run with `swift Tools/GenerateAppIcon.swift`

## Never ship workflow config
- **`CLAUDE.md` and `.claude/**` are never members of a build target.** They appear in the navigator
  for editing and nothing more. `docs/`, `tasks/` and `HISTORY.md` likewise
- They live at the repository root, outside every synchronized folder, so this holds by construction —
  keep it that way

## Signing
- Both signed targets carry their own file under `Entitlements/`, wired via `CODE_SIGN_ENTITLEMENTS`
  in **both** Debug and Release, each listing `group.sardor.WaterBuddy`
- The two files are currently byte-identical and nothing enforces that. If one changes, check the
  other by hand — and verify the built product with
  `codesign -d --entitlements - <path>`, because a missing entitlement degrades silently
  (rule `25-shared-storage`)
- The App Group is the only entitlement on either target (rule `70-privacy`)

## Localization
- `developmentRegion = en`, `knownRegions = (en, ru, uz, Base)`, and
  `LOCALIZATION_PREFERS_STRING_CATALOGS = YES` at project level
- Adding a language means the catalogue in **both** `WaterBuddy/` and `WaterBuddyWidget/`, plus
  `knownRegions`, plus `AppLanguage.selectable` (rule `70-privacy`)
