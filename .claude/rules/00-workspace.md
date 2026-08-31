---
description: Entry point — read the DocC first, then the rules, and enforce the conventions everywhere
globs: ["**/*"]
---

# Before Task
- Read `CLAUDE.md` and the rule files for the surface you are editing
- Read the **DocC comments on the type you are changing**. They carry the rulings and they outrank
  these files — they document the cases where the natural implementation is wrong and the test suite
  cannot see the difference
- Check `tasks/lessons.md` for past mistakes on similar work
- Read `docs/AI_CONTEXT.md` for where the work stands, then the sheet that owns your subject
- Decide which target(s) you are touching, and whether the file is one of the six compiled into both

# After Task
- Run the gate — both test invocations **and** the widget extension build (rule `85-testing`)
- Run the app on the simulator, and put the widget on the Home Screen, if this touched storage,
  entitlements, target membership or the widget's view tree
- Checkpoint in `HISTORY.md` and run `/doc_sync` (rule `99-docs-cascade`)
- Stage the work and stop. **Never commit** until the owner runs `/commit` (rule `90-git`)

# Layout
```
WaterBuddy/              the app — SwiftUI, iOS 18.5, @Observable DataManager over SwiftData
WaterBuddyWidget/        the WidgetKit extension — StaticConfiguration + interactive AddWaterIntent
WaterBuddyTests/         swift-testing (@Test / #expect), own suite per test
WaterBuddyUITests/       XCTest — the setup gate, the accessibility tree, the tab swap
Entitlements/            one App Group entitlement file per signed target
Tools/                   standalone scripts, in no target
docs/                    AI_CONTEXT · STATE · WIDGET · DESIGN
tasks/                   lessons.md, append-only
```

# Swift Only
- One type per file, named for the type
- No `TODO`/`FIXME` left in a diff — either fix it or record it in `docs/AI_CONTEXT.md`'s known issues
- Comments explain **why**, never what. Match the density of the file you are editing
- DocC (`///`) on anything whose natural implementation would be wrong; a plain `//` for a local
  reason

# Naming
- Types, protocols: `PascalCase` — `DataManager`, `WaterSnapshot`, `ReminderPlan`
- Members, cases, parameters: `camelCase`
- A view is `<Name>View.swift`; a `ViewModifier` and its `View` extension share one file
- `UserDefaults` keys are `static let` on `DataManager.Key`, prefixed `sardor.WaterBuddy.`
- Notification identifiers are built from `ReminderPlan.identifierPrefix`
- Tests read as sentences: `theDayBoundaryHoldsAcrossADstTransition`, `refreshPicksUpAnExternalWrite`

# Time
- **No unpinned `Date()` in logic.** The clock is injected as `now: () -> Date`; a bare `Date()` is
  allowed only as a default argument at a composition root
- Day boundaries come from `Calendar.waterBuddyDay`, never `Calendar.current`
- The stored *day* is a `yyyyMMdd` ordinal; an *instant* is a `Date` (rule `30-rollover`)

# Values
- **No floating-point millilitres.** Volumes are `Int`; `Double` appears only as a drawing fraction
- Every value is clamped on the way in and validated on the way out of the shared suite
- No magic numbers in a view — sizes, radii and colours come from the design system
  (rule `60-design-system`)

# Hard limits
- **A denied tool call is a stop sign, never a detour.** If a tool refuses an action, that is the
  owner declining it. Report it and stop — no heredoc after a refused `Write`, no `sed -i` after a
  refused `Edit`
- **Never weaken an assertion to make a number pass** (rule `85-testing`)
- **Never run an ad-hoc script that writes into `group.sardor.WaterBuddy` or `UserDefaults.standard`**
  — both are live user data on this machine (rule `25-shared-storage`)
- Run `xcodebuild` in the foreground, one simulator, `-parallel-testing-enabled NO`
