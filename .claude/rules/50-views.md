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
- No `@Query` and no `ModelContext` in a view — read `manager.todaysLogs`, or `manager.historyLogs`
  for a past day
- A view never writes `UserDefaults`. Every mutation goes through a `DataManager` method, or a
  `Binding` whose setter calls one
- Premium's state comes from `@Environment(PremiumStore.self)`. A view never imports `StoreKit` and
  never holds a `Product`; it is handed `PremiumAccess.Plan`s

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
- A sentence built from a key with an argument goes through one of two helpers, with the injected
  `\.locale`: `strings.figure(_:_:locale:)` for a `%n$@` key fed volumes it formats itself, and
  `strings.localized(_:_:locale:)` for everything else. Never `String(format:)` over a resolved
  key: without a locale Foundation does not take a counted noun's form from the app's language,
  and groups nothing. A figure is grouped wherever it appears — drawn or spoken

## Composition
- Decompose a `body` into a `private var` per section and a `private func` per repeated item.
  Factor a fragment into its own property the moment it is built twice
- Mark a computed subview `@ViewBuilder` only when it actually branches; a straight-line subview is
  a plain `private var … : some View`
- A helper view stays a `private struct` in the file that uses it, and earns its own file only when
  a second screen wants it
- The **menu** a screen offers is a `static let` on that view — `HistoryView.servingRange`/
  `servingStep`, `WelcomeView.goalRange`/`goalStep` — never on `DataManager`. A second screen
  asking the same question reads the first screen's declaration
- A menu is what a screen *offers*; a **preference is what the user chose**, and rule `20-state`
  makes `DataManager` the only thing allowed to persist one. `dailyGoal` is the precedent: its range
  still lives on `WelcomeView` while its value lives on the model. The quick-add vessels are the
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
- Home scrolls, and its column is a `Layout` — `HomeColumn` — not a stack: every part at its own
  height, the vessel given what is left between `HomeView.vesselRange(scaled:)`'s floor and ceiling.
  A stack inside a scroll view is never offered less than its ideal height, so it cannot shrink a
  child; and where it is short of room it squeezes a line of text that carries a
  `minimumScaleFactor` before a view with layout priority
- On Home the Glass is ranked above Cup and Bottle: it is the screen's primary surface, because
  slot `DataManager.usualSlot` is what every one-tap door logs
- History is one `List`, and everything on the screen is a row of it: the header, the week card,
  the strip and the servings — in Month mode the header, the switch, the month card, an opened day
  and the figures — each with the list's own surfaces cleared. Nothing is fixed above
  it, so the `+` scrolls away with the header. The list stops one point short of the top safe
  area (`.padding(.top, 1)`), so its rows are clipped under the status bar and never drawn across it
- What History decides is a `static` on `HistoryView` that takes its state as parameters —
  `stripBars(for:vessels:)` and `vessel(forAmount:amounts:)`, both `nonisolated`, and
  `sliderBounds(forAmount:vessels:)`. Where an instant falls in a day is the model's answer:
  `dayFraction(of:)` and `hours(_:onDayOf:)`
- A view holds a serving's **id** when it must name one outside a sheet — `UndoOffer` — never the
  `WaterLog`
- A `ViewThatFits` is offered its row's whole width (`.frame(maxWidth: .infinity)`) and chooses
  among whole controls, never among labels inside one `Button`; a one-line candidate carries
  `.fixedSize()`. Without them Home's *Undo* was sized as one form and drew another, and drew
  *Undo* as *U…*

## Navigation
- Navigation is a `ZStack` switching on `@State private var tab: AppTab`, with the custom
  `GlassTabBar` mounted through `.safeAreaInset(edge: .bottom, spacing: 0)`. Do not introduce
  `TabView`, `NavigationStack` or `NavigationLink` — there are none in the project
- Every destination has exactly one route to it. No header button, gear or shortcut that duplicates
  a tab
- A widget's link from outside the app is an entrance, not a second route: `RootTabView` answers
  `WidgetLink.history` in `.onOpenURL`, through `AppTab(link:)`, by turning to History as its tab
  would. Before setup the link is ignored
- History's *Week · Month* switch is a control inside the screen, not a route. It is drawn where
  `HistoryView.offersMonth(status:offered:)` says, and Month mode's servings are read-only —
  adding and correcting stay Week mode's, for every user
- Present a sheet with `.sheet(item:)` bound to an optional `@State`, handing the thing being edited
  to the sheet as an `init` parameter — not a `Bool` plus a separately-stored selection
- The paywall is presented with `.sheet(item:)` bound to an optional `PaywallView.Entry` — where it
  was opened from, `.settings` or `.history` — never a `Bool`
- `.safeAreaInset` reserves the bar's height for **scrolling**, not for the resting layout. A screen
  whose last card sits under the bar needs its own bottom padding
- Declare `.preferredColorScheme(.dark)` once per hosting controller — on `RootTabView` for the
  three tabs, and separately on a sheet or the pre-setup root. Never substitute
  `.environment(\.colorScheme, .dark)` in the app (that spelling is the widget's, rule `40-widget`)
- A tab that draws model data calls `.onAppear { manager.refresh() }`. `HomeView`, `HistoryView`
  and `SettingsView` all do

## Bindings and controls
- When a view mirrors a model value into `@State` for a slider or field, seed it through `init`
  (`_goal = State(initialValue: currentGoal)`) — never in `.task` or `.onAppear` — and take a
  re-read value from `.onChange(of:)` on the model's property while no drag is in flight. A
  `@State` ignores every later `init` value, so without it a refresh leaves the old figure drawn
- A continuous control that writes to the model commits on both `onEditingChanged` and
  `onChange(of:)` guarded by an `isDragging` flag: one gesture, one write
- A tap target is at least 44pt via `minHeight` (never a fixed `height`), and the whole slot is the
  target via `.frame(maxWidth: .infinity)` + `.contentShape(Rectangle())`
- A haptic is driven by a monotonically-bumped `@State` counter, so a background write or a rollover
  cannot fire one

## Animation
- Animate with `.animation(_:value:)` scoped to the value that changed. A bare `withAnimation` is
  banned — there is not one call site in the project. One scroll runs inside
  `withTransaction(\.animation, …)`: the welcome bringing its opened calculator into view
  (`WelcomeView`, the stage 5 plan's decision P5), because a scroll position is not view state an
  `.animation(_:value:)` can scope. It wraps `scrollTo` alone, never a state change
- Animate a list on row identity (`manager.todaysLogs.map(\.id)`), never on an amount
- A state-carrying modifier stays present in both branches with a `.clear` value rather than being
  inserted and removed, so SwiftUI animates a colour instead of a layer
- A celebration is anchored to the thing that filled, not to the screen

## Text and strings
- Resolve every user-visible string through `@Environment(\.strings) private var strings`, injected
  once at the root from `manager.language` — on the watch, `WristModel.language` — together with
  `\.locale`. Never `Bundle.main`, and never resolve a string into a `static let`
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
  `rescheduleReminders: { _ in }`, or it reconciles against a real notification centre (rule
  `80-notifications`). All five places that build one for a preview pass it — `HomeView`,
  `HistoryView` (one factory for its two previews), `SettingsView`, `RootTabView` and `WelcomeView`
- Pin preview data to `Calendar.waterBuddyDay.startOfDay(for: .now)`, never an offset from `now`, so
  the sample does not fall out of "today"
