---
description: Two front doors, one writer, one derived cache
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift"]
---

# Architecture

## The shape
```
        the app                              the widget extension
  HomeView · HistoryView                HydrationProvider ── reads ──┐
  SettingsView · GoalSetupView                 │                     │
          │                              AddWaterIntent ─── writes ──┤
          ▼                                    │ (@MainActor)        │
    DataManager  ◄─────────────────────────────┘                     │
    @MainActor · @Observable · the only writer                       │
          │                                                          │
    ┌─────┴─────────────────┐                                        │
    ▼                       ▼                                        │
SwiftData                UserDefaults suite  ◄───────────────────────┘
WaterBuddy.store         9 keys, derived cache
source of truth          read by the app AND the widget
app only
```

A third, physically separate process pair — `WaterBuddyWatch` and `WaterBuddyWatchWidget` — holds
its own local App Group suite of 2 more keys (same App Group *identifier* as above, different
device, never the same container) and is written only by `WristModel`, never by `DataManager`. It
exchanges data with the diagram above solely through `WristLink`'s `WatchConnectivity` session — see
rule `70-privacy`'s *WatchConnectivity is a ruling, not an omission* and rule `25-shared-storage`'s
*The watch's own, separate suite*. `Key.wristApplied`, the phone-side half of that exchange's apply
ledger, lives in the 9 keys above, bringing the phone suite from 8 to 9.

## The rulings
- **One writer per store — the one honest weakening.** `DataManager` remains the only writer to
  either of the phone's two stores; no view, intent or provider writes a key (rule `20-state`). Since
  the watch, this is no longer "the only writer" full stop: `WristModel` is the only writer to the
  watch's own local suite, a disjoint key set on a disjoint physical container. This weakening is
  stated in **both** this file and rule `20-state` deliberately — an earlier draft of this rule
  conceded it in `20-state` while this file's own list below still asserted the stronger sentence
- **Two front doors, one serving.** The app's quick-add row and the widget's `AddWaterIntent` both go
  through `DataManager`, and the standard serving has exactly one spelling
- **Today's total is derived, never authored.** It is the sum of today's logs, recomputed after every
  mutation and written through the `currentWater` setter
- **The widget's draw path never opens SwiftData.** A `TimelineProvider` is `nonisolated` and a
  `ModelContext` is not `Sendable`, so the cache is what keeps that read synchronous
  (rule `43-concurrency`)
- **The provider reads `WaterSnapshot`, never `DataManager.shared`** — and never constructs a
  `DataManager`, which would write from a process whose job is to draw (rule `40-widget`)
- **Only the app writes on behalf of the group.** Materialising the goal, seeding the total, stamping
  the day, the one-shot migration, drawing history and rescheduling reminders are all guarded by
  `DataManager.role`, a four-state `nonisolated static let` that replaced the two-state
  `isAppExtension` at every guard site (rule `25-shared-storage`)
- **Layer boundaries are sacred:** view → `DataManager` → SwiftData + `UserDefaults`. Views own
  presentation state and nothing else; arithmetic both front doors show belongs on `DataManager` or
  `WaterSnapshot` (rule `50-views`)
- **Reminders are scheduled from a pure plan.** `ReminderPlan` decides when, `NotificationManager`
  only files and unfiles (rule `80-notifications`)

## Import direction
- The widget may import from the six shared files. **Nothing shared may import from the widget or
  from a view**
- `WaterBuddyWidget/` imports only `AppIntents`, `WidgetKit` and `SwiftUI` — never `SwiftData`
- `ReminderPlan` imports `Foundation` alone

## The shared six
`DataManager.swift` · `LiquidGlassModifier.swift` · `NotificationManager.swift` ·
`ReminderPlan.swift` · `WaterLog.swift` · `WaterSurface.swift`

They live in `WaterBuddy/` and reach the extension through the `membershipExceptions` set in
`project.pbxproj`. **That set is a contract, not a convenience** — it is what keeps the two front
doors logging the same serving and drawing the same water. Do not add a seventh: put what both
processes need into one of the six (rule `15-project`).

`WaterBuddyWatch` and `WaterBuddyWatchWidget` each carry their **own** exception set — the `target`
field on a `PBXFileSystemSynchronizedBuildFileExceptionSet` is scalar, so the widget's six-file set
above cannot also serve either watch target. Full membership in rule `40-widget`'s *Target
membership* section.

## Forbidden
- A view or intent writing `UserDefaults` directly
- A timeline provider touching `DataManager.shared`, or constructing a `DataManager`
- `import SwiftData` anywhere under `WaterBuddyWidget/`
- A second day representation, a second spelling of the App Group, or a raw key string
- `removeAllPendingNotificationRequests()`
- A `Material` in widget glass
- A bare `withAnimation`, a bare `print` outside `#if DEBUG`, a bare `Date()` in logic
- `WristModel` writing to the phone's SwiftData store or `DataManager` writing to the watch's local
  suite — the one-writer-per-store split is exact, not a shared free-for-all
