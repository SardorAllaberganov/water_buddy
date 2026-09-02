---
description: Views own presentation state and nothing else
globs: ["WaterBuddy/*View.swift", "WaterBuddy/WaterBuddyApp.swift", "WaterBuddy/Celebration.swift", "WaterBuddyWatch/*View.swift", "WaterBuddyWatch/WaterBuddyWatchApp.swift"]
---

# Views

A view reads the model and calls it. It does not compute what the model publishes, and it does not
persist anything.

## Getting the model
- `@Environment(DataManager.self) private var manager`. Never construct one, and never read
  `DataManager.shared` from a body — the app resolves the singleton once in `WaterBuddyApp.init()`
  and injects it with `.environment(manager)`
- The only state a view owns in `@State` is presentation state: which tab is showing, which row is
  being edited, a haptic counter, the value under a finger
- A `WaterLog` may sit in `@State` only as a **sheet's selection** (`@State private var editing:
  WaterLog?`), never as the source of a list
- No `@Query` and no `ModelContext` in a view — read `manager.todaysLogs`
- A view never writes `UserDefaults`. Every mutation goes through a `DataManager` method, or a
  `Binding` whose setter calls one

## Arithmetic belongs to the model
- A `body` must not recompute a figure the model already publishes. Take the total and the goal off
  `manager`; do not sum the rows on screen
- Draw fill levels from `manager.progress` (clamped `0...1`) and celebrate overachievement from
  `manager.progressUnclamped`. Never divide `currentWater` by `dailyGoal` in a view
- A button that mutates makes exactly **one** call into `DataManager` and repeats none of its work —
  no clamping, no recompute, no `WidgetCenter` reload from the view
- A figure both front doors show belongs on `DataManager` or `WaterSnapshot`. The whole-percent
  readout is currently computed in both `HomeView.percentage` and `WaterSnapshot.percentage`; a
  third copy is a bug waiting to round differently
- A `Slider`'s `Binding<Double>` bridge must `rounded()`, never truncate — the `step` snaps the
  value, and `rounded()` is what stops floating-point dust from reaching the store
- Volumes stay `Int`. `Double` appears only as a drawing fraction

## Composition
- Decompose a `body` into a `private var` per section and a `private func` per repeated item.
  Factor a fragment into its own property the moment it is built twice
- Mark a computed subview `@ViewBuilder` only when it actually branches; a straight-line subview is
  a plain `private var … : some View`
- A helper view stays a `private struct` in the file that uses it, and earns its own file only when
  a second screen wants it
- The **menu** a screen offers is a `static let` on that view — `HistoryView.servingRange`/
  `servingStep`, `GoalSetupView.goalRange`/`goalStep` — never on `DataManager`. A second screen
  asking the same question reads the first screen's declaration
- A menu is what a screen *offers*; a **preference is what the user chose**, and rule `20-state`
  makes `DataManager` the only thing allowed to persist one. `dailyGoal` is the precedent: its range
  still lives on `GoalSetupView` while its value lives on the model. The quick-add vessels are the
  same split — `vesselSlots` owns the names, glyphs and order, `DataManager.servings` owns the three
  amounts, and `HomeView.servings(amounts:)` is the pure function that joins them.
  **`vesselSlots` no longer lives on `HomeView`.** It moved to file scope in `WaterSurface.swift` as
  a `nonisolated let` — the "menu belongs to the screen that offers it" default from the previous
  paragraph holds only while exactly one screen asks the question, and the watch's `WristView`
  became a second, **non-view** consumer that needs the identical three names, glyphs and order
  without depending on `HomeView`'s own type. Reaching into another view's file-private state to
  share a menu is worse than promoting the menu once it has two askers; `WaterSurface.swift` is the
  file both `HomeView` and `WristView` already need for the vessel geometry itself, so the menu
  followed it rather than becoming a new shared file of its own (rule `15-project`'s seventh-file
  cost)
- A `static` that projects model state takes the state **as a parameter**. Reaching a `@MainActor`
  property from a `nonisolated` static needs `MainActor.assumeIsolated`, which traps when the
  assumption is wrong — a `precondition` in all but name, and rule `75-diagnostics` records that this
  codebase has none
- Any such static a non-`@MainActor` test reads must be `nonisolated` (rule `43-concurrency`)

## Navigation
- Navigation is a `ZStack` switching on `@State private var tab: AppTab`, with the custom
  `GlassTabBar` mounted through `.safeAreaInset(edge: .bottom, spacing: 0)`. Do not introduce
  `TabView`, `NavigationStack` or `NavigationLink` — there are none in the project
- Every destination has exactly one route to it. No header button, gear or shortcut that duplicates
  a tab
- Present a sheet with `.sheet(item:)` bound to an optional `@State`, handing the thing being edited
  to the sheet as an `init` parameter — not a `Bool` plus a separately-stored selection
- `.safeAreaInset` reserves the bar's height for **scrolling**, not for the resting layout. A screen
  whose last card sits under the bar needs its own bottom padding
- Declare `.preferredColorScheme(.dark)` once per hosting controller — on `RootTabView` for the
  three tabs, and separately on a sheet or the pre-setup root. Never substitute
  `.environment(\.colorScheme, .dark)` in the app (that spelling is the widget's, rule `40-widget`)
- A tab that draws model data calls `.onAppear { manager.refresh() }`. `HomeView` and `HistoryView`
  do; `SettingsView` does not, and reads a stale goal after an external write

## Bindings and controls
- When a view mirrors a model value into `@State` for a slider or field, seed it through `init`
  (`_goal = State(initialValue: currentGoal)`) — never in `.task` or `.onAppear`
- A continuous control that writes to the model commits on both `onEditingChanged` and
  `onChange(of:)` guarded by an `isDragging` flag: one gesture, one write
- A tap target is at least 44pt via `minHeight` (never a fixed `height`), and the whole slot is the
  target via `.frame(maxWidth: .infinity)` + `.contentShape(Rectangle())`
- A haptic is driven by a monotonically-bumped `@State` counter, so a background write or a rollover
  cannot fire one

## Animation
- Animate with `.animation(_:value:)` scoped to the value that changed. A bare `withAnimation` is
  banned — there is not one call site in the project
- Animate a list on row identity (`manager.todaysLogs.map(\.id)`), never on an amount
- A state-carrying modifier stays present in both branches with a `.clear` value rather than being
  inserted and removed, so SwiftUI animates a colour instead of a layer
- A celebration is anchored to the thing that filled, not to the screen

## Text and strings
- Resolve every user-visible string through `@Environment(\.strings) private var strings`, injected
  once at the root from `manager.language` together with `\.locale`. Never `Bundle.main`, and never
  resolve a string into a `static let`
- Where a SwiftUI convenience initializer cannot carry a bundle, use the closure form
  (`Label { Text("Delete", bundle: strings) } icon: { … }`)
- Timestamps render through the phone's own 12/24-hour setting
  (`Text(log.timestamp, format: .dateTime.hour().minute())`), never a fixed pattern
- One string serves both the visible label and the accessibility label — never two strings for one
  idea

## Previews
- Every `#Preview` that builds a `DataManager` passes **both** a throwaway `UserDefaults(suiteName:)`
  cleared with `removePersistentDomain` **and** `modelContainer:` holding an in-memory
  `ModelConfiguration`, plus `reloadWidgets: {}`. Letting `modelContainer:` default writes real rows
  into the owner's own data on every canvas rebuild
- A preview whose screen can write water or change the goal must also inject
  `rescheduleReminders: { _ in }`. `HomeView`, `GoalSetupView` and `HistoryView` currently omit it
  and reconcile against a real notification centre (rule `80-notifications`)
- Pin preview data to `Calendar.waterBuddyDay.startOfDay(for: .now)`, never an offset from `now`, so
  the sample does not fall out of "today"
