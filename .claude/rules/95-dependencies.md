---
description: There are no dependencies, and that is the rule
globs: ["WaterBuddy.xcodeproj/project.pbxproj", "**/*.swift"]
---

# Dependencies

WaterBuddy has **zero** third-party dependencies. Every capability comes from an Apple SDK
framework, and the project file carries no package references at all.

- Do not add a Swift Package, a CocoaPod, a Carthage dependency, or a vendored `.xcframework`. Every
  target keeps `packageProductDependencies` empty
- Keep every `PBXFrameworksBuildPhase` at `files = ()`. Never add an explicit link in Xcode's
  *Frameworks, Libraries, and Embedded Content* — a framework enters only as an `import` line
- When a visual or arithmetic effect is roughly forty lines of arithmetic, hand-roll it as a pure,
  seedable value type instead of adding a package for it. The waves, the aurora, the confetti and
  the glass are all this
- No file under `WaterBuddyWidget/` may `import SwiftData`. The extension's own sources import only
  `AppIntents`, `WidgetKit` and `SwiftUI` (rule `40-widget`)
- A Swift file importing a framework unavailable to iOS (`AppKit`, or any macOS-only module) must
  live **outside** the four synchronized root-group folders — put it in `Tools/` at the repository
  root, where it belongs to no target
- Do not create `docs/dependencies.md`. It is created the moment the first third-party dependency is
  added, and not before (rule `99-docs-cascade`)
- Adding a dependency is a decision for the owner, argued in writing before the diff exists
