# WIDGET — the contract

The widget's surface as it actually stands. The *reasoning* lives in the DocC on
`WaterBuddyWidget.swift` / `AddWaterIntent.swift` and in `.claude/rules/40-widget`.

**Last updated:** 2026-10-10 (eighteenth pass — `/doc_sync` after the redesign's stage 1 was finished
and staged. **No file under `WaterBuddyWidget/` changed, and no contract here did.** The shared
`LiquidGlassModifier.swift` gained two things since the last pass, both inside the branch that draws
Apple's glass: a black tint on the regular variant and an explicit hit region. The widget passes
`.archived`, takes the hand-made stack, and reaches neither. The extension built for the simulator
from the final source (`** BUILD SUCCEEDED **`, iOS 27.0); it was **not placed on a Home Screen**, so
"draws exactly what it drew" rests on the routing test and on the hand-made branch being unchanged,
not on a render.
Previously: 2026-10-09, seventeenth pass — `/doc_sync` during the redesign's stage 1, which was
staged and not finished. **No file under `WaterBuddyWidget/` changed, and the widget draws exactly
what it drew.** One shared file did, `LiquidGlassModifier.swift`: the app now draws Apple's glass on
iOS 26 and later, and *The two rendering modes* says why the widget cannot and does not. The
extension built for the simulator with the change; it was not placed on a Home Screen this pass.
Previously: sixteenth pass — `/doc_sync` after known issue #73: the reminder plan
`AddWaterIntent` files now follows the app's reminders toggle as it stands at the press, because
`refresh()` re-reads the flag. One bullet under *The intent also reschedules reminders*; no file under
`WaterBuddyWidget/` changed, and no other contract.
Previously: 2026-10-08, fifteenth pass — `/doc_sync` after known issue #68: the medium family's
two figure lines now follow the app's language like the rest of the widget. Its column is `MediumColumn`,
a view beneath `HydrationView`'s injection, and `HydrationView` reads no string itself. No contract
changed; known issue #76, found while moving the column, is pointed to from *Accessibility*.
Previously: fourteenth pass — `/doc_sync` after roadmap item 6: the extension also
holds **a control**, `LogWaterControl`, listed from iOS 18 inside `if #available(iOS 18.0, *)` — its own
section below. `AddWaterIntent` writes out its default `authenticationPolicy`, and
`DataManager.requestWidgetReload()` now reloads controls as well as timelines. Neither widget's contract
changed. Previously: thirteenth pass — `/doc_sync` after roadmap item 5: the extension now
holds **two widgets**, and the second, `LockScreenWidget`, has its own section below. The Home Screen
widget's contract is unchanged except that `PourButton` is no longer `private` — its `minimumTarget` is
the Lock Screen button's floor too. Previously: twelfth pass — `/doc_sync` after roadmap item 4, the Siri phrase: the snapshot's `serving` now reads `DataManager.usualServing(in:)` — the same value, given one name the Siri shortcut also calls; the "Shortcuts vocabulary" section corrected from "not translated", stale since known issue #1 was fixed on 2026-10-06; and a note that Shortcuts now lists the app's own *Log a Glass* beside *Log Water*. No widget contract changed. Previously: eleventh pass — `/doc_sync` after known issue #46: one sentence below still said `DataManager`'s reminder hook "spawns a detached `Task`"; it now queues each reconcile on one `ReconcileQueue`, in call order. No widget contract changed. Previously: tenth pass — /doc_sync after the App Store preparation work: the build command here was still pinned to `OS=18.6,name=iPhone 16` and is now `OS=26.5,name=iPhone 17`, and the extension's deployment target moved 26.5 → 17.0 to close a live defect where the widget did not exist on any device below 26.5 while its host app deployed to 18.6. The widget contract itself — families, timeline, rendering modes, intent parameters — is unchanged. Previously: ninth pass — one sentence: the reminder hook's early return is
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
| Bundle | `WaterBuddyWidgetBundle` (`@main`), two widgets and a control — this one, `LockScreenWidget` (*The Lock Screen widget*, below) and, inside `if #available(iOS 18.0, *)`, `LogWaterControl` (*The Control Center control*, below) |
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
| `serving` | `DataManager.usualServing(in:)` — `resolveServings(in:)[1]` with a name: the **middle** quick-add vessel, and the one definition the Siri shortcut (`LogServingIntent`, app-only) logs too | the vessels are user-editable, so the button's face and the amount it logs are no longer a constant both processes compile. They agree by reading one key instead |

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

**`.fullColor`** — the ordinary Home Screen. The hand-made glass, with
`LiquidGlass.Base.archived` standing in for the material because there is no live backdrop to
sample. **It is no longer "the app's glass exactly" on iOS 26 and later:** since the redesign's stage
1 (2026-10-09, staged) the app draws Apple's glass there, and the widget does not. `.archived` is a
`.flat` base, and `LiquidGlass.rendering(…)` answers `.handMade` for a `.flat` base on every OS —
`aFlatBaseIsAlwaysHandMade` pins it — so nothing in this extension reaches `glassEffect`. The widget's
own pass of the redesign is stage 6 and is not built.

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
`WidgetBorderedButtonStyle`'s capsule over the glass. (A control is not a widget: its button is a
`ControlWidgetButton` — *The Control Center control*, below.)

### `AddWaterIntent`, as Shortcuts sees it

| | |
|---|---|
| `title` | `"Log Water"` (a `let` — a `static var` on a `Sendable` type is an error in the Swift 6 mode) |
| `description` | `"Adds a serving of water to today's total in WaterBuddy."`, `categoryName: "Hydration"` |
| `openAppWhenRun` | `false` |
| `authenticationPolicy` | `.alwaysAllowed` — the protocol's default, written out on 2026-10-08 because the control's locked-phone ruling rests on it (rule `70-privacy`) |
| `@Parameter amount` | title `"Amount"`, description `"Millilitres of water to log."`, `default: 250`, `inclusiveRange: (1, 100_000)` |
| `parameterSummary` | `"Log \(\.$amount) ml of water"` |
| `init()` | sets `amount = DataManager.defaultServing` — the `AppIntent` requirement and the Shortcuts default, **not** the path the widget button takes |
| `init(amount:)` | explicit amount — **this is what every button uses**: both widgets' with `entry.snapshot.serving`, the control's with its provider's `snapshot.serving` |
| `perform()` | `@MainActor` → `DataManager.shared.addWater(amount:)`, then `WidgetCenter.shared.reloadAllTimelines()`, then **`await NotificationManager.reconcile(…)`** |

`@Parameter` is a macro and its arguments must be compile-time constants, so they **cannot** spell
`DataManager.defaultServing` or `maximumDailyIntake` — and especially cannot spell a value the user
edits at runtime. Those literals are only what Shortcuts pre-fills and validates against when a
person builds an automation by hand; every button goes through `init(amount:)` — both widgets' with
`entry.snapshot.serving`, the control's with its provider's `snapshot.serving` — and `addWater` does
the real clamping regardless of what any caller asks for.

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
  `perform()`. `DataManager`'s injected reminder hook queues its reconcile for a background
  worker (one `ReconcileQueue` per process, so reconciles run in call order), which in this
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
- The plan it files is `DataManager.shared.currentReminderSlots()`, and since 2026-10-08 that plan
  follows the app's reminders toggle as it stands at the press. `addWater(amount:)` starts with
  `refresh()`, which now re-reads `remindersEnabled` with the goal, the vessels and the language. Until
  then an extension that had outlived the toggle planned from the flag it launched with: a press after
  reminders were switched on filed an empty plan, which cleared them, and a press after they were
  switched off filed them again (known issue #73, retired — pinned by tests, never reproduced on a
  device).

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
  eating the 44pt control. *(By reading, the cap does not reach the hero's own `@ScaledMetric`, which
  sits above it — known issue #76, not rendered.)*

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
`EnvironmentValues.strings` and `\.locale`, reading neither itself: a view's own `@Environment` comes
from above it, so every string is resolved in a view below — `MiniVessel`, `PourButton`, and the medium
family's `MediumColumn`. Without it the widget would render in the *device*
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

### `AddWaterIntent`'s Shortcuts vocabulary is translated

*(This section said "**not** translated" until 2026-10-07. Known issue #1 was fixed on 2026-10-06 and
the section was not updated with it; the code won.)*

Five strings in the widget's catalogue are `AddWaterIntent`'s entire Shortcuts-facing vocabulary, and
all five ship in English, Russian and Uzbek:

| String | Where the user sees it |
|---|---|
| `Log Water` | `static let title` — the action's name in Shortcuts |
| `Adds a serving of water to today's total in WaterBuddy.` | `IntentDescription` |
| `Amount` | the `@Parameter` title |
| `Millilitres of water to log.` | the `@Parameter` description |
| `Log ${amount} ml of water` | `parameterSummary` |

They are `LocalizedStringResource` and `@Parameter` macro arguments — **compile-time constants** — so
they cannot take a runtime bundle the way `Text(_:bundle:)` does: they follow the **device** language,
resolved by the system, not the in-app language picker. `everyWidgetStringIsTranslatedUnlessDeliberatelyNot`
checks the extension's own catalogue, the half `everyDrawnStringIsTranslatedUnlessDeliberatelyNot`
(app bundle only) could never see.

**Shortcuts lists a second WaterBuddy action** since 2026-10-07: *Log a Glass*, the app-only
`LogServingIntent` behind the Siri phrase. Its strings live in the **app's** catalogue, not this
one — it is not part of the extension (`docs/superpowers/specs/2026-10-07-siri-phrase-design.md`).

## The Lock Screen widget

Added 2026-10-08 (roadmap item 5; spec `docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md`,
the authority for everything below; rules `40-widget`, `60-design-system`, `65-accessibility`,
`70-privacy`).

| | |
|---|---|
| Type | `StaticConfiguration` — `LockScreenWidget`, in `WaterBuddyWidget/LockScreenWidget.swift` |
| `kind` | `"WaterBuddyLockScreen"` (`LockScreenWidget.kind`) |
| Families | `.accessoryCircular`, `.accessoryRectangular`, `.accessoryInline` — iOS 16.0, under the 17.0 floor |
| Provider | **the same `HydrationProvider`** — the same snapshot read, gallery sample, midnight `rolledOver()` entry and `.after(midnight)` policy |
| Gallery strings | the Home Screen widget's two literals, `"Hydration"` and its description |
| Content margins | iOS's own — **no** `.contentMarginsDisabled()` (configuration-wide; the Home Screen's) |
| Container background | an empty `containerBackground(for: .widget)`: the Lock Screen draws none, but iOS overlays a warning on a widget without one |

**What each shape draws.** The circle: an `.accessoryCircularCapacity` ring filled to `progress`, with
`Text(snapshot.percentage, format: .percent.locale(locale))` inside at a `0.4` scale floor — `MiniVessel`'s
floor; at 0.6 Russian's `38 %` truncated to `38…`. The rectangle: `%1$d ml` and `of %1$d ml` (the medium
family's keys), an `.accessoryLinearCapacity` bar, and the **+** —
`Button(intent: AddWaterIntent(amount: entry.snapshot.serving))`, `.buttonStyle(.plain)`, a `plus` over
`AccessoryWidgetBackground`, framed to `PourButton.minimumTarget`. The line: a `drop.fill` and the
percentage. The gallery draws `WaterSnapshot.sample`: **57%** (1,150 of 2,000 — `57.49999999999999`
rounds down).

**Rendering.** The iPhone Lock Screen is always the vibrant mode, so there is no branch on
`widgetRenderingMode`, no glass, no `Aurora` colour and no `colorScheme` override — capacity gauges,
`.primary`/`.secondary` and `AccessoryWidgetBackground` only.

**Privacy.** Every figure-bearing view, fills included, is `.privacySensitive()`; each shape reads
`redactionReasons` and, under `.privacy`, draws its quiet form — the drop, an empty ring or bar,
*Hydration* — and speaks its label alone, the button *Log Water*. Both answer the one trigger iOS applies
when the user turns off *Allow Access When Locked → Lock Screen Widgets*.

**Language.** `LockScreenView` injects `\.strings` and `\.locale` from `entry.snapshot.language` and reads
neither itself — each shape is a child view, because a view's own `@Environment` comes from above it
(known issue #68 was the Home Screen medium family's version of that trap, fixed on 2026-10-08 the same
way: its column, `MediumColumn`, is a view of its own).

**Accessibility.** One combined element per shape (label `Today's hydration`, the vessel's
percent-and-millilitres value), the button its own; the drawn figures, gauges and glyphs also carry
`.accessibilityHidden(true)`. The card's figures carry `.invalidatableContent()`, so a tap shows at once.

**Proved and not.** On the simulator: registered in the gallery, placed, rendered and captured in all
three languages and at three digits. **Not proved:** the **+** (`linkd` refuses the ad-hoc-signed
extension, #63), the quiet form, and what VoiceOver says — SpringBoard's XCUITest tree lists the drawn
texts beneath each combined element whatever the flags (#70). The owner's device check (spec §7.5) is
the proof.

## The Control Center control

Added 2026-10-08 (roadmap item 6; spec `docs/superpowers/specs/2026-10-08-control-center-design.md`,
the authority for everything below; rules `40-widget`, `70-privacy`, `15-project`,
`60-design-system`, `85-testing`).

| | |
|---|---|
| Type | `ControlWidget` — `LogWaterControl`, in `WaterBuddyWidget/LogWaterControl.swift`, `@available(iOS 18.0, *)`; the bundle lists it inside `if #available(iOS 18.0, *)`, the codebase's first version check |
| `kind` | `"WaterBuddyLogWater"` (`LogWaterControl.kind`) — permanent: iOS identifies every placed control by it |
| Configuration | `StaticControlConfiguration(kind:provider:)` |
| Provider | `LogWaterControlProvider` (`ControlValueProvider`, private, file scope): `currentValue()` returns `DataManager.snapshot(now: Date())`; `previewValue` is the default Glass in `.system` |
| Button | `ControlWidgetButton(action: AddWaterIntent(amount: snapshot.serving))` — the Glass, from the snapshot |
| Title | *Log Water*, resolved from `snapshot.language.bundle` and handed over as a `String` — the app's chosen language |
| Glyph | `vesselSlots[DataManager.usualSlot].symbol` — `mug.fill`, the slot `usualServing(in:)` reads |
| Gallery strings | `.displayName("Log Water")`, `.description("Adds a serving of water to today's total in WaterBuddy.")` — `AddWaterIntent`'s own, static; iOS draws them, and the Action Button's hint, in the phone's language |
| Figures | **none** — no total, goal, percentage or serving size (rule `70-privacy`) |

**Where it appears.** Control Center (a small tile draws the glyph alone), the Lock Screen's two control
slots, and the Action Button on iPhone 15 Pro and later — one control for all three.

**What keeps it current.** iOS builds the control from a value it reads when it chooses; a reload is
Apple's documented way to have it read again. `DataManager.requestWidgetReload()` — rung by every setter
that can change the Glass or the language — calls `ControlCenter.shared.reloadAllControls()` beside
`reloadAllTimelines()`, inside `#if os(iOS)` and `if #available(iOS 18.0, *)`. Measured on the
simulator: without it, a press made after an edit logged the previous Glass.

**A press** runs `AddWaterIntent.perform()` in the extension, as the widgets' **+** does — through
`chronod`, which on the simulator runs it where `linkd` refuses the widgets' buttons (#63). With
`.alwaysAllowed` it is meant to log without unlocking; whether iOS honours that on a locked iPhone, and
what happens before the first unlock after a restart (#72), is the device check's.

**Proved and not.** On the simulator: offered in the controls gallery, placed, its title following the
app's picker in all three languages, a press logging the stored Glass — an edited one included — and
a mutation run showing the reload is what delivers the edit. **Not proved:** a locked phone, a press
before the first unlock, a Lock Screen slot, the Action Button and VoiceOver (spec §7.4, #75).

## Building it

**The app scheme does not compile the extension's own sources.** A widget-only break passes a green
test run completely untouched:

```
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
                 -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Last run 2026-09-02: `** BUILD SUCCEEDED **`, 38 warnings — the pre-existing concurrency baseline in
`DataManager.swift`/`NotificationManager.swift`, **not** widget code (`docs/AI_CONTEXT.md` known
issue #29). Zero warnings originate in `WaterBuddyWidget/`.

*(Corrected 2026-09-02: this command read `OS=18.6,name=iPhone 16` until then, which had been stale
since the runtime pin moved. Rule `85-testing` is the authority for every gate destination; when the
two disagree, the rule wins and this file changes.)*

**The extension's deployment target is `IPHONEOS_DEPLOYMENT_TARGET = 17.0`** as of 2026-09-02, down
from 26.5 — and it moved because it *had* to. The app target had drifted to 18.6 while the extension
stayed at 26.5, which meant the widget did not exist on any device between those versions: a live
defect in a shipped configuration, invisible to every build and test. Both are now 17.0. The drop
cost no source changes at all, proven by building at both floors and diffing the warning sets.

Neither this nor the unit suite can see a widget that renders blank. After any change to the
widget's view tree, entitlements or target membership, place it on a Home Screen — the Lock Screen
widget on a Lock Screen, and the control in Control Center.

*(2026-10-08: "The app scheme does not compile the extension's own sources", above, is not what the
build does — `build-for-testing -scheme WaterBuddy` compiled `LockScreenWidget.swift` in target
`WaterBuddyWidgetExtension`, because the app embeds the `.appex`. Known issue #69; the sentence mirrors
rule `40-widget`, whose text is the owner's, so it is flagged here rather than rewritten. Seen again on
2026-10-08: `build -scheme WaterBuddy` also compiled both watch targets, which the app embeds too.)*
