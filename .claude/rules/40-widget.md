---
description: The widget — a read-only draw path over the cache, and glass that survives templating
globs: ["WaterBuddyWidget/**/*.swift", "WaterBuddy/WaterSurface.swift", "WaterBuddy/LiquidGlassModifier.swift", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift"]
---

# Widget

The widget is the second front door. Its provider **draws**; it does not manage state.

## Target membership

`WaterBuddyWidgetExtension`'s exception set (`project.pbxproj`, six files:
`DataManager.swift`, `LiquidGlassModifier.swift`, `NotificationManager.swift`, `ReminderPlan.swift`,
`WaterLog.swift`, `WaterSurface.swift`) is a **separate contract** from `WaterBuddyWatch`'s own
(`3B60BAE6703F44AE6C46153F`, Task 9 of the watchOS plan). The `target` field on a
`PBXFileSystemSynchronizedBuildFileExceptionSet` is scalar, so one set can never serve two targets —
each of the four native targets under `WaterBuddy.xcodeproj` that reaches into `WaterBuddy/` (the
widget, the watch app, and the watch widget; the phone app owns the folder outright) has to name its
own membership. The watch's exception set is currently **six** files, not five —
`DataManager.swift`, `LiquidGlassModifier.swift`, `ReminderPlan.swift`, `WaterLog.swift`,
`WaterSurface.swift`, **and `WristPlan.swift`**, added because `WristModel` buckets pours through it
— and it deliberately omits `NotificationManager.swift`: `role.mayFileReminders` is `false` on both
watch roles, so shipping the notification surface to a process that can never file one is pointless
(rule `80-notifications`). The watch's own files (`WristModel.swift`, `WristView.swift`,
`WristAurora.swift`, `WristVessel.swift`, `WaterBuddyWatchApp.swift`) are invisible to the widget
extension and vice versa — reaching one from the other is a target-membership error, not an import
one, and the app scheme's green test run cannot show it (rule `15-project`).

`WaterBuddyWatchWidget` has a third, independently-minimal exception set: **six** files —
`DataManager.swift`, `LiquidGlassModifier.swift`, `ReminderPlan.swift`, `WaterLog.swift`,
`WaterSurface.swift`, **and `WristPlan.swift`** — omitting only `NotificationManager.swift` (same
reason as the watch app). It was five until 2026-09-01, when the complication stopped reading the
mirror alone: spec §16 made `WristView` usable before its first sync, drawing pending outbox pours
against `DataManager.defaultDailyGoal`, and a complication that still read only `Key.wristMirror`
would have sat at 0% while the app beside it showed real water. Counting the outbox means bucketing
it by day, which is `WristPlan`'s job — so the widget now *does* bucket pours, and the sentence that
said it never would is retired rather than reworded. `LiquidGlassModifier.swift` is still required
only **transitively**: nothing in the watch widget calls `.liquidGlass(...)` directly, but
`WaterSurface.swift`'s own `#Preview` does, and a `#Preview` still has to compile into whatever
target the file joins.

## The read path
- Every member of `HydrationProvider` stays `nonisolated` and reads only through
  `DataManager.snapshot(...)` and `DataManager.nextDayBoundary(...)`. Never `DataManager.shared`,
  and never by constructing a `DataManager`
- A timeline provider carries no isolation and a `ModelContext` is not `Sendable`, so reading the
  cache is what keeps the read path synchronous (rule `43-concurrency`)
- Constructing a `DataManager` would materialise the goal, seed the cached total, stamp the day,
  recompute today and ring the widget doorbell — writes from a process whose job is to draw. Several
  of those are guarded by `DataManager.role` (`.ownsSharedStorage`, `.mayHaveLegacyStandardDefaults`);
  `recomputeToday()` is not, which is exactly why the provider must never build one
- `WaterSnapshot` stays a `Sendable`, `Equatable` plain value with no isolation and no reference to
  `DataManager.shared`. Every field it exposes is derivable from the `UserDefaults` cache alone
- `WaterBuddyWidget/` must never gain an `import SwiftData`. The cache is the widget's only read
  surface for a total
- `snapshot(...)` applies the rollover to its returned value only and writes no key. Use `if let` on
  the marker, never `guard let … else { water = 0 }`
- `WaterSnapshot.percentage` stays `Int((progressUnclamped * 100).rounded())` — never "tidied" to
  `water * 100 / goal`, which rounds differently from the app
- Do not add a seventh file to the shared set. Anything both processes need goes into one of the
  existing six; `WaterSnapshot` and `AppLanguage` live in `DataManager.swift` for exactly this reason
- Any change here keeps `readingLeavesTheStoreUntouched` and `readingAnEmptySuiteDoesNotCreateKeys`
  green — a snapshot read may not create or alter a single key

## The timeline
- `getTimeline` always emits the second, midnight-dated entry with a zeroed total alongside the
  current one, with `policy: .after(midnight)` — not `.atEnd`, not a periodic interval. That is how
  the widget rolls over unattended
- The midnight comes from `DataManager.nextDayBoundary(after:calendar:)`, the same calendar
  `snapshot`'s ordinal compares against (rule `30-rollover`)
- `getSnapshot` returns `WaterSnapshot.sample` when `context.isPreview`, and reads the real store
  only otherwise
- `configurationDisplayName` and `description` are plain static string literals — never
  interpolated, never built from `DataManager.defaultServing` and never naming an amount at all.
  The gallery renders them before any entry exists — and since the vessels are editable, any figure
  written there would be wrong for every user who changed theirs
- Keep `.contentMarginsDisabled()` on the configuration and let `HydrationView.cardInset` supply the
  inset, so the aurora runs edge to edge

## The write door
- `AddWaterIntent` is the one place the extension writes, and it is legal because `perform()` is
  `@MainActor`: it goes through `DataManager.shared.addWater(amount:)`, which re-reads first
- The button logs **`entry.snapshot.serving`** — the user's middle quick-add vessel — through
  `AddWaterIntent(amount:)`. It does **not** go through `init()`, and it does not compile a constant
  in: the vessels are editable, so the two front doors agree by reading one key rather than by
  spelling one literal. Take the amount from the snapshot rather than resolving it live here, so the
  figure drawn on the face and the amount the tap logs come from the same archive and cannot
  disagree within one render
- `init()` survives as the `AppIntent` requirement — the path Shortcuts constructs the action
  through before decoding a parameter over the top — and seeds `DataManager.defaultServing`, which
  is the right default for a caller that has expressed no preference
- Never treat the `@Parameter` literals (`default: 250`, `inclusiveRange: (1, 100_000)`) as the
  serving or the clamp — they exist because macro arguments must be compile-time constants, and
  Shortcuts can pass any amount in that range
- `perform()` must **not** re-resolve the amount from the suite. It logs the decoded `@Parameter`,
  because overriding it would silently discard what a Shortcuts automation, a Back Tap or Siri
  passed in — which is the entire reason `inclusiveRange` exists
- `perform()` calls `WidgetCenter.shared.reloadAllTimelines()` explicitly and keeps
  `openAppWhenRun = false`
- It `await`s `NotificationManager.reconcile(...)` inline rather than relying on `DataManager`'s
  injected hook, and passes `DataManager.shared.language.bundle` for the strings — a reminder filed
  from here would otherwise be in the wrong language
- It removes only identifiers under `ReminderPlan.identifierPrefix`. An `.appex` has no notification
  identity of its own (rule `80-notifications`)
- `AddWaterIntent`'s statics are `let`, never `var` — a `static var` on a `Sendable` type is
  nonisolated global mutable state
- It is compiled into the **widget extension only**. A second copy in the app binary registers the
  same action twice in Shortcuts
- `DataManager.requestReminderReschedule` keeps its `guard role.mayFileReminders else { return }` —
  corrected from the `guard !isAppExtension else { return }` this line named until 2026-09-01
  (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §9.2). `.watchApp` and
  `.watchExtension` both answer `mayFileReminders == false`, for the same reason the widget
  extension does: `ReminderPlan.Slot.identifier` is a pure function of day and hour, so a second
  notification centre filing the identical plan cannot dedupe against the first — a watch buzzing
  twice per slot, or 28 silent `add` failures into a discarded `ReconcileOutcome`

## Glass and rendering
- **Never pass a `Material` as the `base` of a glass pane drawn in the widget** — use
  `LiquidGlass.Base.archived` (or another `.flat`). A widget snapshot is rendered out of process
  against a backdrop the extension cannot sample, so a `Material` resolves against nothing and the
  pane comes back muddy or invisible
- Treat `Base.archived`'s two fills as derived constants. Do not retune them by eye; re-derive from
  the material recipe and the aurora's luminance if the backdrop changes
- Anything tinted, scrimmed or gradient-filled branches on
  `@Environment(\.widgetRenderingMode) == .fullColor` and falls back to a shape that survives
  templating — a stroked rim, an opaque silhouette, a flat colour
- Keep `WaterReadabilityScrim` between the water and the percentage readout in every vessel, app and
  widget alike. It is a contrast floor, not a plate over the design
- In the widget, scale the scrim with the level (`intensity: min(1, level * 1.6)`) rather than laying
  it down at full strength as the app does
- The waves are driven by the fixed `MiniVessel.frozenPhase`. Never introduce `TimelineView(.animation)`
  or any clock-driven phase into the extension's view tree — a widget gets snapshots, not frames
- Set the dark appearance with `.environment(\.colorScheme, .dark)`, never
  `.preferredColorScheme(.dark)`, and inject `entry.snapshot.language.bundle` and `.locale` at the
  same root
- `WidgetCardBackdrop` is applied with `.background` **after** `.widgetPane` so it lands beneath the
  glass, drawn scaled and blurred so it is out of register with the pane
- `@ScaledMetric` in the widget scales a real magnitude, never a unitless `1` — `UIFontMetrics`
  rounds to the nearest third of a point, which would quantise twelve Dynamic Type categories into
  three
- `MiniVessel.radius(fitting:besides:gap:)` stays the derived clearance formula, not a flat
  proportion
- Keep `.invalidatableContent()` on the figures an intent changes

## The control
- The only control is `Button(intent:)` with `.buttonStyle(.plain)` and a label frame of at least
  `PourButton.minimumTarget` (44pt). Never rely on the system to pad the hit region
- Hide the medium family's `Text`s with `.accessibilityHidden(true)` **individually** — never on the
  enclosing `VStack`, which also holds the button (rule `65-accessibility`)

## Proving it
- The app scheme does not compile the widget's sources. Build the extension separately after any
  change here, and after any change to one of the six shared files (rule `15-project`)
- The widget's rendering has no automated coverage: put it on the Home Screen, in both light and
  dark, and in a tinted (templated) configuration
