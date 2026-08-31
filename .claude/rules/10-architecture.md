---
description: Two front doors, one writer, one derived cache
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift"]
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
WaterBuddy.store         7 keys, derived cache
source of truth          read by the app AND the widget
app only
```

## The rulings
- **`DataManager` is the only writer** to either store. No view, intent or provider writes a key
  (rule `20-state`)
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
  the day and the one-shot migration are all guarded by `isAppExtension` (rule `25-shared-storage`)
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

## Forbidden
- A view or intent writing `UserDefaults` directly
- A timeline provider touching `DataManager.shared`, or constructing a `DataManager`
- `import SwiftData` anywhere under `WaterBuddyWidget/`
- A second day representation, a second spelling of the App Group, or a raw key string
- `removeAllPendingNotificationRequests()`
- A `Material` in widget glass
- A bare `withAnimation`, a bare `print` outside `#if DEBUG`, a bare `Date()` in logic
