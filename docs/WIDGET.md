# WIDGET — the contract

The widget's surface as it actually stands. The *reasoning* lives in the DocC on
`WaterBuddyWidget.swift` / `AddWaterIntent.swift` and in `.claude/rules/40-widget`.

**Last updated:** 2026-09-01 (ninth pass — one sentence: the reminder hook's early return is
`role.mayFileReminders`, not `isAppExtension`. No widget contract changed. Previously: eighth pass — every `WaterSnapshot` field documented, and the timeline's code sample corrected: it still showed the memberwise midnight entry that was fixed. Previously: the button now logs `entry.snapshot.serving`, and `rolledOver()` fixes the midnight entry that dropped the chosen language)

---

## Configuration

| | |
|---|---|
| Type | `StaticConfiguration` — there is nothing to configure |
| `kind` | `"WaterBuddyHydration"` (`WaterBuddyWidget.kind`) |
| Families | `.systemSmall`, `.systemMedium` |
| Provider | `HydrationProvider` (`TimelineProvider`) |
| Entry view | `HydrationView` |
| `configurationDisplayName` | `"Hydration"` — **static literal** |
| `description` | `"Track today's hydration and log a glass without opening the app."` — **static literal** |
| Content margins | `.contentMarginsDisabled()` |
| Bundle | `WaterBuddyWidgetBundle` (`@main`), one widget |
| Gallery name | `INFOPLIST_KEY_CFBundleDisplayName = Hydration` |
| Info.plist | `WaterBuddyWidget-Info.plist` → `NSExtensionPointIdentifier = com.apple.widgetkit-extension` |

**Both gallery strings must stay static literals.** They are read by the system, not rendered by
us, so WidgetKit cannot carry format arguments across that boundary: interpolating either — by the
`LocalizedStringKey` or the `Text` overload, both were tried — traps the moment `body` is
evaluated, with *"Formatted text for `description` is not supported"*. That happens in the gallery
on device, not only in the Xcode preview.

So the serving is deliberately **not named** in the description — and since the vessels became
editable it could not be even if that were desirable, because the gallery renders before any entry
exists and any figure written there would be wrong for every user who changed theirs. The widget's
face draws `entry.snapshot.serving`.

`.contentMarginsDisabled()` because the system's ~16pt margin is a fifth of a 158pt canvas; the
card supplies its own inset (`cardInset = 10`, `cardPadding = 12`).

## The read path

`HydrationProvider` is `nonisolated` throughout — `TimelineProvider` carries no isolation — so
nothing in it may touch the `@MainActor` `DataManager.shared`. It reads through
`DataManager.snapshot(defaults:calendar:now:)`, which is also the **only way to read without
writing**: constructing a `DataManager` materialises the goal, stamps the day, can zero the total
and rings the widget doorbell — four writes from a process whose whole job is to draw.

**Everything the widget knows is on `WaterSnapshot`, and every field of it is derivable from the
`UserDefaults` cache alone** — that is the whole bar for living there, because the widget may never
open SwiftData (rule `40-widget`).

| Field | Resolved from | Why it has to cross |
|---|---|---|
| `currentWater` | `Key.currentWater`, with the day-ordinal rollover applied to the *returned value only* | the figure the vessel fills to |
| `dailyGoal` | `resolveDailyGoal(in:)` | the denominator; a missing key read as `0` would draw the first sip as 100% |
| `language` | `resolveLanguage(in:)` | the widget has its own strings table and its own process; without this it draws the *device* language while the app draws the chosen one |
| `serving` | `resolveServings(in:)[1]` — the **middle** quick-add vessel | the vessels are user-editable, so the button's face and the amount it logs are no longer a constant both processes compile. They agree by reading one key instead |

`serving` is the newest and the one to reason about carefully: it is why `PourButton` takes an
`Int` and builds `AddWaterIntent(amount:)` rather than `init()`. Taking it from the snapshot rather
than resolving it live in the extension is deliberate — the face is rendered into an archive ahead
of time, so a live read could disagree with the number already drawn beside it. From one snapshot
they can be stale together but never inconsistent with each other.

| Method | Returns |
|---|---|
| `placeholder(in:)` | `WaterSnapshot.sample` |
| `getSnapshot(in:)` | `WaterSnapshot.sample` when `context.isPreview`, else `DataManager.snapshot(now:)` |
| `getTimeline(in:)` | two entries + `.after(midnight)` |

`WaterSnapshot.sample` is **1,150 of 2,000** — past halfway, so the water has a visible surface and
the readout has two digits. A brand-new install would otherwise advertise itself with an empty
vessel.

### The timeline

```swift
let midnight = DataManager.nextDayBoundary(after: now)
let current  = DataManager.snapshot(now: now)
[
    HydrationEntry(date: now,      snapshot: current),
    HydrationEntry(date: midnight, snapshot: current.rolledOver()),
]
Timeline(entries: entries, policy: .after(midnight))
```

An entry's `date` is when WidgetKit *renders* it, so the second entry is a scheduled visual change
that costs no wake-up. Without it, a widget nobody touches still shows yesterday's water tomorrow
morning.

**`rolledOver()`, never a memberwise call — and this is a fixed bug, not a preference.** That line
read `WaterSnapshot(currentWater: 0, dailyGoal: current.dailyGoal)` until 2026-08-30. `language`
carries a default of `.system`, so **every field the author did not name was silently reset at local
midnight**: a user who chose Russian in the app watched the widget revert to the *device* language
overnight and stay there until something else reloaded the timeline. It shipped for two releases and
nothing could see it — the app scheme never compiles this target, and the widget's rendering has no
automated coverage at all.

`rolledOver()` copies `self` and zeroes one field, so a field added later is carried across for free
rather than needing to be remembered. `serving` was added an hour after the fix and inherited it
without a line of work. `rollingOverChangesNothingExceptTheTotal` asserts the **whole value** rather
than a list of fields, so the test cannot go stale the way the initialiser did.

`nextDayBoundary(after:calendar:)` uses the **same** `Calendar.waterBuddyDay` as the rollover, so
the app and the widget never disagree about when the day turns. It falls back to
`date + 24h` if `nextDate` ever returns `nil`.

## The two rendering modes

`@Environment(\.widgetRenderingMode)`, checked in `MiniVessel`, `WidgetPane`,
`WidgetCardBackdrop` and `WidgetAurora`.

**`.fullColor`** — the ordinary Home Screen. The app's glass exactly, with
`LiquidGlass.Base.archived` standing in for the material because there is no live backdrop to
sample.

**Anything else** — a tinted Home Screen, StandBy. The system treats the whole widget as a
template: **colour is discarded and only alpha survives**, so every layer `LiquidGlass` stacks
becomes additive — including the black scrim, which would *brighten* the pane, and the shadows,
which would ring it in haze.

| Element | `.fullColor` | templated |
|---|---|---|
| Pane | full `liquidGlass(base: .archived, …)` | `shape.strokeBorder(.white.opacity(0.45), lineWidth: 1)` only |
| Water | `WaterSurface` (two gradient waves) + `WaterReadabilityScrim` | one opaque `WaveShape` at `.white.opacity(0.55)` |
| Card backdrop | `WidgetAurora` scaled `1.22`, blurred `12`, saturated `1.1` | `Color.clear` |
| Container background | `WidgetAurora` (gradient + three lights) | `Color.black` |

Parts that change with the data carry `.invalidatableContent()`; tintable artwork carries
`.widgetAccentable()`.

## Layout

Small — vessel and button on a **diagonal**. They cannot stack (a 138pt card will not hold a
legible vessel *and* a 44pt target beneath it) and they must not overlap (two glass discs sharing
an edge read as one dented shape, not two controls).

Medium — vessel beside the numbers: hero volume, `of N ml` under it, full-width quick-add capsule.

### The vessel radius is derived from the button, not from the canvas

```swift
static func radius(fitting side: CGFloat, besides target: CGFloat, gap: CGFloat = 4) -> CGFloat {
    let root2  = 2.0.squareRoot()
    let button = target / 2
    let reach  = root2 * (side - button)
    let cap    = (reach - button - gap) / (1 + root2)
    return max(0, min(side * 0.37, cap))
}
```

With the vessel's centre at `(r, r)` and the button's at `(side - t/2, side - t/2)`, the centres
are `√2·(side - t/2 - r)` apart and that must beat `r + t/2` by the gap.

A flat proportion cannot do this job: **74% of the short side clears by 6pt on a 158pt widget and
overlaps by 3pt on the 141pt one an iPhone SE-class device gets.** The 0.37 proportion still
governs everywhere it fits. (It is spelled out in typed steps because the one-line form takes the
type checker past its time limit.)

`PourButton.minimumTarget = 44` and **WidgetKit does not pad a button out** — the hit region is
exactly the label's frame.

## The interactive half

`Button(intent:)` is the **only** kind of button a widget can have: the archive carries the intent
and the system runs it on tap. `.buttonStyle(.plain)`, or the system draws
`WidgetBorderedButtonStyle`'s capsule over the glass.

### `AddWaterIntent`, as Shortcuts sees it

| | |
|---|---|
| `title` | `"Log Water"` (a `let` — a `static var` on a `Sendable` type is an error in the Swift 6 mode) |
| `description` | `"Adds a serving of water to today's total in WaterBuddy."`, `categoryName: "Hydration"` |
| `openAppWhenRun` | `false` |
| `@Parameter amount` | title `"Amount"`, description `"Millilitres of water to log."`, `default: 250`, `inclusiveRange: (1, 100_000)` |
| `parameterSummary` | `"Log \(\.$amount) ml of water"` |
| `init()` | sets `amount = DataManager.defaultServing` — the `AppIntent` requirement and the Shortcuts default, **not** the path the widget button takes |
| `init(amount:)` | explicit amount — **this is what the button uses**, with `entry.snapshot.serving` |
| `perform()` | `@MainActor` → `DataManager.shared.addWater(amount:)`, then `WidgetCenter.shared.reloadAllTimelines()`, then **`await NotificationManager.reconcile(…)`** |

`@Parameter` is a macro and its arguments must be compile-time constants, so they **cannot** spell
`DataManager.defaultServing` or `maximumDailyIntake` — and especially cannot spell a value the user
edits at runtime. Those literals are only what Shortcuts pre-fills and validates against when a
person builds an automation by hand; the widget's button goes through `init(amount:)` with
`entry.snapshot.serving`, and `addWater` does the real clamping
regardless of what any caller asks for.

`@MainActor` on the implementation of a `nonisolated` protocol requirement is legal and
warning-free in **both** language modes — verified by compiling under `-swift-version 5` and
`-swift-version 6`. It is what lets the body touch `DataManager.shared` without hopping by hand.

**The explicit reload is not redundant.** WidgetKit reloads after an interactive intent on its own,
but only the timeline it owns and only if it decides something changed — which covers neither this
intent run from Shortcuts nor a total already pinned at `maximumDailyIntake`, where
`currentWater`'s setter returns early and never rings the doorbell.

`AddWaterIntent` is compiled into the **extension only**. The app's own button already holds the
`DataManager`, and a second copy in the app binary would register the same action twice in
Shortcuts.

### The intent also reschedules reminders, and it is the only place that can

`perform()` ends on an **awaited** `NotificationManager.reconcile(…)`. That is not the "call the
side effect again to make sure" rule `20-state` forbids — it is the only place the work can happen
at all:

- A widget extension is guaranteed to live exactly as long as the *awaited* work inside
  `perform()`. `DataManager`'s injected reminder hook spawns a detached `Task`, which in this
  process would be torn down before it reached the system — so that hook returns immediately
  unless `role.mayFileReminders`, which only `.phoneApp` answers `true`. (It read
  `!isAppExtension` until 2026-08-31; the predicate now also excludes a watch, for a second and
  independent reason — `ReminderPlan.Slot.identifier` is a pure function of day and hour, so a
  separate notification centre would file identifiers it cannot dedupe against the phone's.)
- The centre reached from here is the **containing app's**. An `.appex` has no notification identity
  of its own: `UNUserNotificationCenter.current()` sees a non-`APPL` bundle and resolves through
  `LSPlugInKitProxy.containingBundle`, so these requests join the same pending set the app manages.
  Which is why `reconcile` only ever removes identifiers under `ReminderPlan.identifierPrefix` —
  `removeAllPendingNotificationRequests()` from here would clear the app's entire set.

**Unverified:** whether WidgetKit's sandbox *permits* the call at runtime. The addressing is proven;
the permission is not, and sandbox profiles are kernel-compiled. `DataManager.refresh()` reconciles
on every foreground as the backstop, so a denial degrades to "reminders correct themselves next time
you open the app" rather than breaking. Full reasoning in rule `80-notifications`.

`ReminderPlan.swift` and `NotificationManager.swift` are on the extension's `membershipExceptions`
list for exactly this reason — six shared files now, not four.

## Accessibility

- The vessel is one element: `.accessibilityElement(children: .ignore)`, label
  `"Today's hydration"`, value `"\(percentage) percent. \(currentWater) of \(dailyGoal) millilitres."`
- In the medium family the visible hero figure and the `of N ml` line are hidden
  **individually** — both numbers are already in the vessel's value, and left visible they become
  two more stops, the second of which is a fragment. Never hide the enclosing stack: it also holds
  the button, and the widget's only control would become unreachable.
- The button carries `.accessibilityLabel("Add \(entry.snapshot.serving) millilitres")`; a
  bare `+` does not say what it adds.
- The medium column caps at `.dynamicTypeSize(...DynamicTypeSize.accessibility1)` — a widget
  cannot scroll or reflow, so past the first accessibility size the type holds still rather than
  eating the 44pt control.

## The extension carries its own localisation

The widget ships in English, Russian and Uzbek, and **it has its own `Localizable.xcstrings`** —
`WaterBuddyWidget/Localizable.xcstrings`, 19 keys — the 10 hand-written ones are a strict subset of
the app's 56; the other nine were extracted by the build (see below).

That duplication is not a preference. The catalogue was first placed in `WaterBuddy/` and added to
the widget's `membershipExceptions`, exactly the arrangement the six shared `.swift` files use. It
does not work: `xcodebuild` ran `xcstringstool` against the **app** target's build directory only,
the `.appex` came out with no `.lproj` at all, and the build then rewrote `project.pbxproj` to
delete the entry. A synchronized-folder membership exception carries source, not resources.

**Which language it draws in comes from the snapshot.** `WaterSnapshot.language` is read by
`DataManager.snapshot(defaults:calendar:now:)` out of the App Group cache — the provider is
`nonisolated` and never touches the model — and `HydrationView` injects it as
`EnvironmentValues.strings` and `\.locale`. Without it the widget would render in the *device*
language while the app rendered in the chosen one: two front doors disagreeing. `serving` travels
in the same snapshot for the same reason, and `rolledOver()` is what carries **both** across the
midnight entry — which it did not before, so the widget silently reverted to the device language at
local midnight until something else reloaded it.

Two limits worth stating plainly:

- **The gallery strings do not follow.** `.configurationDisplayName` and `.description` are read by
  the system for the widget picker, not rendered by us, so they stay in the device language.
- **The face follows on the next refresh, not instantly.** Changing the language rings the widget
  doorbell, but a timeline already built is an archive another process replays, and WidgetKit
  decides when to redraw. `SettingsView`'s language card says so rather than implying otherwise.

The catalogue now holds **19 keys**, and only 10 of them were written by hand. Xcode's build
extracts every `Text` / `Label` / `LocalizedStringResource` literal in the target and appends it, so
the file is part hand-authored contract and part build output. The 10 deliberate ones are everything
the extension *draws or files*:

| Key | Where |
|---|---|
| `Hydration` | `.configurationDisplayName` |
| `Track today's hydration and log a glass without opening the app.` | `.description` |
| `Today's hydration` | the vessel's accessibility label |
| `%1$d ml` · `of %1$d ml` · `+%1$d ml` | the readout and the button's face |
| `%1$d percent. %2$d of %3$d millilitres.` | the vessel's accessibility value |
| `Add %1$d millilitres` | the button's accessibility label |
| `Time for water` · `A glass now keeps you on track for the day.` | the reminder copy |

The last two are on the list because `NotificationManager` is one of the six shared files and
`AddWaterIntent` files reminders **from the extension** — so the copy is composed in the widget
process, where `Bundle.main` is the `.appex`.

The gallery strings stay **static literals**, as rule `40-widget` requires: a localisation key is
still a literal, and nothing is interpolated into either.

Formats are positional (`%1$d`) rather than bare `%d` so a translator may reorder — Uzbek turns
"X of Y" into "Y dan X". `LocalizationTests` asserts the extension actually ships both languages,
that its table agrees with the app's value for value, and that every translation carries the same
format arguments as its key.

### `AddWaterIntent`'s Shortcuts vocabulary is **not** translated

Found by this `/doc_sync` pass, and **not fixed here** — `/doc_sync` never touches source.

The build extracted nine further keys into the widget catalogue, all with no localisations at all.
Three are dead (`+%lld`, `1,450 ml`, `Today` — extracted before the interpolated `Text` sites became
`String(format:)`, and no longer produced by any source). One is deliberate (`%`). **The other five
are `AddWaterIntent`'s entire Shortcuts-facing vocabulary:**

| String | Where the user sees it |
|---|---|
| `Log Water` | `static let title` — the action's name in Shortcuts |
| `Adds a serving of water to today's total in WaterBuddy.` | `IntentDescription` |
| `Amount` | the `@Parameter` title |
| `Millilitres of water to log.` | the `@Parameter` description |
| `Log ${amount} ml of water` | `parameterSummary` |

So a Russian or Uzbek user who adds the WaterBuddy action in Shortcuts gets an English one, while
the widget beside it draws their language.

These are `LocalizedStringResource` and `@Parameter` macro arguments, which have to be **compile-time
constants** — the file already records that constraint for a different reason. They cannot take a
runtime bundle the way `Text(_:bundle:)` does, so honouring the in-app language picker here may not
be possible at all; following the *device* language almost certainly is, by translating the keys and
letting the system resolve them.

`everyDrawnStringIsTranslatedUnlessDeliberatelyNot` did not catch this because it checks the **app**
bundle only. The same check pointed at the extension would have.

## Building it

**The app scheme does not compile the extension's own sources.** A widget-only break passes a green
test run completely untouched:

```
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
                 -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16'
```

Last run 2026-08-28: `** BUILD SUCCEEDED **`, 0 warnings.

Neither this nor the unit suite can see a widget that renders blank. After any change to the
widget's view tree, entitlements or target membership, place it on a Home Screen.
