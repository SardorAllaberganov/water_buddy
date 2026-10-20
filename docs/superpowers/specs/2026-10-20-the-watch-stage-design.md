# The watch's stage — Apple's glass, the pour row and three faces — design

**Status:** approved by the owner in conversation on 2026-10-20, in four sections — the glass, the
screen, the faces, and the rules with the gate — after five rulings: decision D6 kept as approved on
2026-10-09 (a watchOS 26 runtime is installed before the stage is measured), the faces offered in
three families (circular, rectangular, corner), every face display-only, every face's figures
redacted when watchOS asks, and approach A in three sub-stages (§3.1). The rectangle's layout —
header, line, bar — was chosen from two drawn in the conversation. Written on 2026-10-20 for the
owner's review; **no plan, no rule text and no code yet.** Roadmap item **1.3.2**
(`docs/ROADMAP.md` §4), which is the premium redesign's stage 7
(`docs/superpowers/specs/2026-10-09-premium-redesign-design.md` §9, decisions D5 and D6) plus
rectangular and corner complications. The rule wording in §5 is a proposal — rules change only when
the owner decides (rule `99-docs-cascade`) — typed for approval **before** 7a's code, as for 1.3.1.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `06229be` on 2026-10-20. The
canvas is the redesign's own, <https://claude.ai/artifact/UYGcabBfVjduqkzvqtZ5bt>, board *Watch*
(`project/Watch.dc.html`), read the same day. Claims about Apple's platform carry their source:
**SDK** is `WatchOS27.0.sdk/…/SwiftUICore.swiftmodule/arm64_32-apple-watchos.swiftinterface` and
`…/WidgetKit.swiftmodule/arm64_32-apple-watchos.swiftinterface` in Xcode 27.0 on this machine;
anything else is marked **inferred**, and the plan or the device proves it before anything rests on
it.

---

## 1. What is being built

The watch catches up with the phone, in three sub-stages, each with its own gate and its own
`/commit`:

- **7a — Apple's glass on the watch.** The glass routing, which answers "available" on iOS only,
  answers for watchOS 26 too. The watch's panes draw Apple's glass; its tint and contrast are
  measured on the watch's own renders.
- **7b — the screen, as the canvas draws it.** The vessel becomes a display showing the percentage;
  the millilitre line moves under it; a row of three pour buttons — Cup, Glass, Bottle — replaces
  the tap-to-pour vessel and the *More* sheet.
- **7c — three faces.** The complication offers `.accessoryRectangular` and `.accessoryCorner` beside
  today's `.accessoryCircular`, all display-only, all reading one shared calculation with the app,
  all redacting their figures when watchOS asks.

**Before 7a's measurements:** the owner installs a watchOS 26.x simulator runtime (D6, §3.2).

## 2. What happens today

- **The screen** (`WristView.swift`). The vessel *is* the pour button: a tap logs the Glass, and the
  amount it pours is shown nowhere. It is sized at 0.78125 of the screen's height, an owner ruling
  ("25% bigger, twice"). Cup and Bottle sit behind a *More* button, below the fold at rest on every
  size, which opens `WristServingMenu`, a sheet. The sync caption sits between the vessel and the
  button. The Glass's index is spelled `primaryIndex = 1` (`WristView.swift:137`), a third spelling of
  `DataManager.usualSlot` (known issue #104).
- **The vessel** (`WristVessel.swift`). A `.sheer`, `.floating` glass circle with the water, a
  readability scrim, the percentage and — inside it — the millilitre line `%1$@ / %2$@ ml`. That line
  measures 3.34:1 at worst over water against its 4.5:1 floor (#44). The scrim ramp
  (`scrimFullStrengthLevel`, 0.2) is calibrated to where that line's ink sits.
  `diameter(fitting:reserving:)` has had no production caller since the screen moved to
  `diameter(fitting:within:)` (#84(d)).
- **The glass.** Hand-made on the watch: `LiquidGlass.systemGlassAvailable` is `false` there by
  `#if os(iOS)`, and so are `sampling(_:)`'s Apple branch and `GlassGroupModifier`
  (`LiquidGlassModifier.swift`). The watch's dark scrim is black at the widget's values. The *More*
  capsule and the sheet's rows are `.sheer` and not `interactive`, which on Apple's glass would map
  to the clear, untinted variant under a label (#91(b)).
- **The face** (`WaterBuddyWatchWidget.swift`). One family, `.accessoryCircular`: an open gauge, the
  drop, the percentage, tinted `Aurora.blue`. The entry carries a percentage only, computed in the
  provider by its own copy of the rounding formula (#20). No figure is `.privacySensitive()`. It draws
  no word and injects no language. Kind `"WaterBuddyWatchWidget"`; name *WaterBuddy*; description
  *Today's hydration*; timeline `[now]` plus `WristPlan.dayBoundaries(…)`, policy `.atEnd`.
- **Runtimes.** watchOS 27.0 and 11.5 are installed; no 26.x (#77). The watch's floor, 26.0, has
  never been executed. The watch suite holds 57 tests; no UI-test target exists for the watch (#42),
  and no test target compiles `WaterBuddyWatchWidget`.

## 3. The design

### 3.1 Approaches

- **A — chosen.** One spec, three sub-stages (7a glass → 7b screen → 7c faces). One pure value,
  `WristPlan.Face`, computes total, goal, percentage and progress for both the screen and the faces.
  The existing widget kind gains two families. The glass goes first because it is the cheapest change
  and the riskiest unknown: the screen is then built on glass already measured.
- **B — rejected.** The same, but the provider computes total and goal itself. Fewer shared lines,
  but the screen and the face would keep separate arithmetic — the drift `WristPlan` exists to
  prevent — and #20 would stay at four copies.
- **C — rejected.** A widget kind per family, as the phone split out its Lock Screen widget. The phone
  split because its Home Screen configuration disables margins and draws glass; every watch family is
  an accessory drawn alike, so a second kind would only add gallery entries and a kind name that is
  permanent once placed.

### 3.2 Prerequisite — a watchOS 26 runtime (D6)

D6 was approved on 2026-10-09 as *"install a watchOS 26 runtime when stage 7 is next"*; the roadmap's
later "26 or later" reading is retired by the owner's ruling of 2026-10-20. The owner installs the
newest watchOS 26.x simulator runtime Xcode 27.0 offers, and creates one watch on it. Every
measurement in this stage is taken on that runtime **and** on 27.0, because the phone's glass
rendered and hit-tested differently on iOS 26.5 and 27.0 (rule `85-testing`). The installed version
is pinned by number in the gate once it is known (§8.1).

### 3.3 Stage 7a — Apple's glass on the watch

**The routing.** In `LiquidGlassModifier.swift`, three places widen from iOS to iOS and watchOS,
through one availability check, `#available(iOS 26.0, watchOS 26.0, *)` — the SDK declares `Glass`,
`glassEffect(_:in:)` and `GlassEffectContainer` `watchOS 26.0` (**SDK**):

1. `LiquidGlass.systemGlassAvailable` — `true` on watchOS 26.0 and later, which on the watch is
   always, its floor being 26.0.
2. `sampling(_:)`'s Apple branch and the `systemGlass` property behind it.
3. `GlassGroupModifier` — `GlassEffectContainer` on watchOS 26 too.

No call site changes, and `LiquidGlass.rendering(base:reduceTransparency:systemGlassAvailable:)` is
untouched: every watch pane takes the default `.material(.ultraThinMaterial)` base, so each routes
itself. On iOS nothing changes. The watch widget compiles the file and draws no glass — an accessory
face takes none — so for it this is compile-only.

**The watch's panes.**
- **The vessel** — `.sheer`, not a control — takes Apple's **clear** glass, untinted: its readout has
  `WaterReadabilityScrim`, and a tint would dull the water (`systemVariant(density:interactive:)`).
- **A pane that is a control** takes **regular** glass, tinted with `LiquidGlass.systemTintColor`. In
  7a those are the *More* capsule and the sheet's rows, which gain `interactive: true`: the glass is
  the pressable surface (rule `60-design-system`). That closes #91(b). 7b deletes both, but they are
  the watch's labelled panes today, and measuring them settles the tint 7b's discs then use.
- The sheen and the lit rim are drawn over Apple's glass, as on the phone. Reduce Transparency still
  draws the opaque fill, `Base.archived.opaqueFill` on the watch (`docs/DESIGN.md`).
- `Glass.interactive()` gives a control the system's own press response (**inferred** from the phone;
  rendered in 7a). `PressStyle` and `Haptics` stay out of the watch (rule `60-design-system`'s
  *Interaction*), so `glassIsPressed` is never set there.

**The tint is measured, never carried over.** `systemTintOpacity(for: .regular)` is 0.64, climbed on
iOS 27.0. 7a renders the *More* capsule and a sheet row on the watch, on 26.x and 27.0, through a
minute of `WristAurora`, and measures their labels against 4.5:1. If 0.64 passes on both, it stays
one value. If not, `systemTintOpacity` gains an `onPhone:` parameter — as
`scrim(density:scheme:base:onPhone:)` already has, fed by `LiquidGlass.runsOnPhone` — and the watch
takes the lightest rung that passed on both runtimes, held by a test of the same shape as
`theTintIsNoLighterThanTheLightestRungThatPassed`. The figures go into `docs/DESIGN.md`.

### 3.4 Stage 7b — the screen

From the top, as the canvas's board *Watch* draws it (208×248, the 46mm screen):

1. **The vessel — a display.** `WristVessel` draws the percentage only. It stops being a `Button`
   and is one VoiceOver element again: `.accessibilityElement(children: .ignore)`, the label
   *Today's hydration*, and the value it speaks today, `%1$d percent. %2$d of %3$d millilitres.`,
   through `Face.spokenFigures(in:locale:)` (§3.5). The modifiers move from `WristView`'s button
   back onto the vessel, whose DocC changes with them.
2. **The line** — *1,300 of 2,000 ml* — under the vessel: the phone's `%1$@ of %2$@ ml`, grouped
   through `strings.figure(_:_:locale:)`, in a text style (never a fixed size), hidden from
   VoiceOver because the vessel speaks the same figures (rule `65-accessibility`). `WristVessel`'s
   `readout(volume:goal:strings:locale:)` and the watch's own `%1$@ / %2$@ ml` key are removed.
3. **The row** — Cup, Glass, Bottle, in `vesselSlots` order, built by a `nonisolated static`
   `pourRow(from:)` from `primary(from:)` and `secondary(from:)`, never from the raw servings, so a
   short or missing mirror still leaves a Glass that pours the default (§9.2 of the redesign).
   - **Cup and Bottle** are discs showing their slot's glyph:
     `.liquidGlass(in: Circle(), density: .sheer, interactive: true)` — regular, tinted glass — at
     least `wristMinimumTarget` (44pt) square, the canvas's 46pt where the screen allows. Each one's
     amount sits beneath it, `%1$d ml`, hidden from VoiceOver.
   - **The Glass** is the screen's one primary surface: `.primarySurface(in: Capsule(), ring: false)`,
     its glyph and its amount inside. **No ring:** the redesign's §3.3 gives the ring to the phone,
     and on the watch it would nearly touch the discs across the row's gaps. The canvas draws a faint
     one; the canvas is an approximation (the redesign's §12).
   - **Two whole rows, one chosen.** A `ViewThatFits(in: .horizontal)`, offered the row's full width,
     takes the first that fits: the capsule with its amount inside, or three equal discs — the Glass a
     white one, still the primary surface — with the Glass's amount beneath it as well (rule
     `50-views`: it chooses among whole controls). By
     arithmetic the capsule fits from the 46mm screen up, and three 46pt discs fit the 40mm screen
     with 4pt gaps; the renders settle it. The gap between two panes is never under 4pt.
   - The row is wrapped in `.glassGroup()`.
   - **VoiceOver:** each button's label is the phone's `%1$@, add %2$d millilitres` with the slot's
     name and amount — `HomeView`'s own call — and its plural forms come with it. The drawn amounts
     are hidden, individually (rule `65-accessibility`).
   - `.buttonStyle(.plain)`; no haptic, no `PressStyle`. The white Glass has no pressed wash on the
     watch, because nothing there sets `glassIsPressed`.
4. **The sync caption**, `attribution(mirror:now:strings:locale:)`, below the row, unchanged.

**The column.** The vessel takes the height left after the line, the row, its amounts and the gaps,
between `WristVessel`'s 60pt floor and a ceiling the plan fixes from the 46mm render, starting from
the canvas's 100pt. A stack inside a scroll view is never offered less than its ideal height, so this
is a `Layout`, `WristColumn`, in its own file in `WaterBuddyWatch/` — rule `50-views`' reason for
`HomeColumn`, one device over. It stays inside today's `GeometryReader` + `ScrollView` +
`.frame(minHeight:)` + `.scrollBounceBehavior(.basedOnSize)`, so the screen is static wherever it
fits. On 40mm and 42mm the vessel reaches its floor and the amounts and the caption take a turn of
the crown; the row is kept on screen at rest. `vesselHeightFraction` is removed — D5 reversed the
ruling it carried.

**The scrim, re-derived.** With the line gone, the vessel's lowest readout is the percentage, large
and bold, held to 3:1. `scrimFullStrengthLevel` is re-derived the way it was first derived — the
level at which water first reaches the percentage's ink, on renders at the 60pt floor and on real
sizes, rounded so the ink is assumed lower than it is — and its test is rewritten from the line to
the percentage. #44 closes: no small text is left over water.

**Removed:** the vessel's `Button`, `isMenuPresented`, `menuButton(offering:)`, `WristServingMenu`;
the keys *More*, *Shows the other serving sizes* and *Logs %1$d millilitres*;
`vesselHeightFraction`; `WristVessel.readout(…)`; `diameter(fitting:reserving:)` and its test,
`reservingMoreSpaceShrinksTheVessel` (#84(d)). `primaryIndex` becomes `DataManager.usualSlot`, the
one name for the Glass's slot (#104).

### 3.5 The shared face — `WristPlan.Face`

Arrives in 7b, where the screen is its first reader; 7c makes the provider its second.

```swift
extension WristPlan {
    nonisolated struct Face: Equatable, Sendable {
        let total: Int        // WristPlan.todaysTotal(mirror:outbox:now:calendar:)
        let goal: Int         // mirror?.dailyGoal ?? DataManager.defaultDailyGoal
        var progress: Double  // total / goal, clamped 0...1; 0 when goal <= 0
        var percentage: Int   // Int((Double(total) / Double(goal) * 100).rounded()), clamped 0...999; 0 when goal <= 0
        func spokenFigures(in strings: Bundle, locale: Locale) -> String
    }
    nonisolated static func face(mirror: WristMirror?, outbox: [WristPour], now: Date, calendar: Calendar) -> Face
}
```

- **Nested in `WristPlan.swift`, not a file of its own,** because a new file would grow two exception
  sets (rule `15-project`); `ReminderPlan.Slot` is the precedent. It stays pure: `Foundation` and
  the `Bundle` helpers `DataManager.swift` already gives every watch target.
- **The formula is the provider's today, unchanged,** including its `0...999` clamp — so the face's
  figures do not move. The screen's one difference: above 999% it now draws 999, as the face always
  has.
- `WristModel.todaysTotal` and `displayGoal` read through it, so #20's two watch copies of the
  rounding become one (the phone's two remain, out of scope).
- `spokenFigures(in:locale:)` is `WaterSnapshot.spokenFigures(in:locale:)`'s twin: the same key, so
  the vessel and every face speak alike.

### 3.6 Stage 7c — the faces

**The entry.** `WristWidgetEntry(date:, face: WristPlan.Face, language: AppLanguage)`. The provider
keeps `readStore()`, its boundary entries and `.atEnd`; where it computed a percentage it now calls
`WristPlan.face(…)`. `language` is `AppLanguage(code: mirror?.languageCode)` — the phone's choice,
as `WristModel.language` resolves it — injected at the view's root as `\.strings` and `\.locale`
together (rule `70-privacy`). The placeholder and the gallery preview draw `Face`'s sample, 62% as
today. The kind stays `"WaterBuddyWatchWidget"`, so every circular face already placed keeps working;
`.configurationDisplayName("WaterBuddy")` and `.description("Today's hydration")` stay the two static
literals, the description still resolved by WidgetKit in the watch's own language.

**The three shapes,** chosen by `@Environment(\.widgetFamily)` in one view, each a `private struct`
in a new file, `WaterBuddyWatchWidget/WristFaceView.swift` — a synchronized folder, so no
`project.pbxproj` edit:

- **Circular** — today's open `.accessoryCircular` gauge, the drop, the percentage, tinted
  `Aurora.blue`. Unchanged to the eye.
- **Corner** — `.accessoryCorner` (**SDK**, watchOS 9.0): the percentage, formatted `.percent` under
  the injected locale, with a curved gauge along the bezel as its `.widgetLabel` (**SDK**), tinted
  `Aurora.blue`. Scaled to fit, with every language checked at three digits — Russian writes
  *100 %* (`tasks/lessons.md`, 2026-10-08).
- **Rectangular** — three lines:
  ```
  💧 Hydration                65%
  1,300 of 2,000 ml
  ████████████████░░░░░░░░░░░
  ```
  A header of the drop, *Hydration* and the percentage, accented; the app screen's own line,
  `%1$@ of %2$@ ml`; an `.accessoryLinearCapacity` bar tinted `Aurora.blue`.

**On every shape:**
- **Privacy.** Every figure — the percentage, the line, every gauge's value — carries
  `.privacySensitive()`. Whenever `redactionReasons` contains `.privacy`, the shape draws its quiet
  form: the drop and an empty gauge, and on the rectangle *Hydration* over an empty bar — no figure
  and no fill, the phone's Lock Screen widget one device over. When watchOS asks — a locked watch;
  Always On with the app's complication data turned off — is **inferred**, and proved on a device.
- **VoiceOver.** One element per shape, `.accessibilityElement(children: .ignore)` — a face is not a
  control: the label *Today's hydration* and the value `face.spokenFigures(in:locale:)`. The quiet
  form speaks its label alone.
- **Colour.** No glass and no aurora on a face. The gauges are tinted `Aurora.blue`, as the circular
  face is today; on a tinted face the header and the gauges are `.widgetAccentable()`.
- **No button.** A tap opens the watch app, as today. Nothing new is written: `WristModel` stays the
  only writer to the watch's suite (rule `20-state`).
- **Nothing special in Always On.** The system dims the face; no `isLuminanceReduced` branch.

### 3.7 Strings

No new string is authored: every key comes from the app's catalogue, value for value, in en, ru and
uz, with its plural variations.

| Catalogue | Gains | Loses |
|---|---|---|
| `WaterBuddyWatch` (7b) | `%1$@ of %2$@ ml`, `%1$@, add %2$d millilitres` | `%1$@ / %2$@ ml`, `Logs %1$d millilitres`, `More`, `Shows the other serving sizes` |
| `WaterBuddyWatchWidget` (7c) | `Hydration`, `%1$@ of %2$@ ml`, `%1$d percent. %2$d of %3$d millilitres.` | — |

`LocalizationTests`: `watchSharedKeys` gains the watch's two and `watchOwnKeys` loses its four in 7b;
in 7c a `watchWidgetSharedKeys` list — the three above plus *Today's hydration* — replaces the single
description check in `theWatchAgreesWithThePhoneOnEverySharedString`, compared against the app bundle
in every language. Xcode is closed while a catalogue is edited by hand (`tasks/lessons.md`,
2026-10-18; #50).

## 4. What it touches beyond the watch

- **`LiquidGlassModifier.swift`**, one of the shared six: the availability check only. On iOS every
  branch answers as today; the phone widget passes `.archived` and never meets `glassEffect`.
- **`WristPlan.swift`** compiles into the phone app too, which never calls it; `Face` is tested there,
  in `WristPlanTests` (`WaterBuddyTests/WristSyncTests.swift`).
- **`WaterBuddyTests/LocalizationTests.swift`** (§3.7).
- **Nothing else:** no key, no wire field, no `schemaVersion` change, no entitlement, no exception set,
  no change to the phone app, its widgets, `DataManager`'s logic or `WristLink`.

## 5. What this amends — proposed, for the owner's word

Typed into the rule files unstaged, for the owner's approval, **before 7a's code**. The wording below
is the substance; the typed text follows each file's voice.

- **`15-project`** — *The second version check is the glass's*: `LiquidGlassModifier` draws Apple's
  glass inside `#available(iOS 26.0, watchOS 26.0, *)`; the watch, whose floor is 26.0, always takes
  it. Retire "`#if os(iOS)` keeps the watch on the hand-made stack until the redesign's watch stage".
  The watch side is run-verified on watchOS 26.x and 27.0.
- **`60-design-system`**
  - *Glass*: "the hand-made stack everywhere else — a `.flat` base, iOS 17 to 25, and the watch until
    its own stage" loses its watch clause; `.glassGroup()` is `GlassEffectContainer` on iOS 26 and
    watchOS 26.
  - *Glass*, the tint: measured on the watch too; where the watch needs its own rung it is read
    through `systemTintOpacity`'s `onPhone:`, never written at a call site (only if 7a needs it).
  - *The primary surface*: on the watch the Glass pour button is the primary surface,
    `.primarySurface(in: Capsule(), ring: false)`.
  - *Interaction*: the watch still has no `PressStyle` and no haptic; its glass controls take
    `Glass.interactive()`'s own press response.
  - *Water*: the watch vessel's ramp is calibrated to the percentage, its lowest readout.
  - A new *On the watch face* subsection: no glass and no aurora; gauges tinted `Aurora.blue`;
    `.widgetAccentable()` on a tinted face; every figure `.privacySensitive()` with a quiet form.
- **`65-accessibility`** — *VoiceOver*: the vessel is one element in all three processes that draw
  it, the watch's again; each pour button on the watch carries `%1$@, add %2$d millilitres`; each
  watch face is one element, and its quiet form speaks no figure.
- **`70-privacy`** — *WatchConnectivity*'s carve-out names the watch's three faces, not "an
  `.accessoryCircular` complication", and holds them to the Lock Screen widget's marking:
  `.privacySensitive()` on every figure and a quiet form whenever `redactionReasons` contains
  `.privacy`. *Localization*: the faces' drawn words follow `WristMirror.languageCode`; their
  `.description` follows the watch's system language.
- **`85-testing`** — *The gate*: while watchOS 26 is supported, the watch unit tests also run on the
  26.x runtime, a sixth invocation. *A green suite is not proof*: the watch's three faces, placed by
  hand on a watch face, a tinted one included, on both runtimes.
- **`00-workspace`** — *Layout*: `WaterBuddyWatchWidget/` draws circular, rectangular and corner
  faces.

`20-state`, `25-shared-storage`, `30-rollover`, `40-widget`, `43-concurrency` and `80-notifications`
are untouched: no key, writer, day rule, isolation or exception set moves.

## 6. Privacy

Nothing new leaves either device and nothing new crosses the wire. The faces draw the user's own
figures on the user's own watch face — rule `70-privacy`'s carve-out — and from 7c hide them whenever
watchOS redacts, which today's circular face does not. No notification, no Live Activity, no new
entitlement, no usage-description key.

## 7. Testing

Written first and run red, per sub-stage (rule `85-testing`).

- **7a.** A watch-side `theWatchDrawsAppleGlass`: `LiquidGlass.systemGlassAvailable` is `true` on
  watchOS 26.0 and later — red today, by `#if os(iOS)`. If the tint gains a watch rung, a test holding
  it to the lightest rung that passed. Which variant a pane takes is already pinned by
  `systemVariant(density:interactive:)`'s tests; the arguments each watch call site passes are proved
  by its render, not by a test.
- **7b.** `WristPlan.Face` in `WristPlanTests`: no mirror → the default goal; the phone's total until
  its day ends plus the outbox; the rounding identical to the provider's formula; the `0...999` clamp;
  progress clamped and 0 for a goal ≤ 0; `spokenFigures` in a translated bundle. `pourRow(from:)` in
  `WristViewLogicTests`: Cup, Glass, Bottle for a full mirror and for none; a one-element mirror keeps
  a Glass pouring the default. The line grouped in the chosen language, through the new key. The
  scrim ramp re-derived to the percentage. **Removed with its code:**
  `reservingMoreSpaceShrinksTheVessel`. **Rewritten because what they test moved:**
  `theVesselReadoutGroupsThousandsInTheChosenLanguage`, for the line under the vessel, and
  `theWatchScrimIsAtFullStrengthBeforeWaterCanReachTheMillilitreLine`, for the percentage. None is
  narrowed to pass.
- **7c.** `LocalizationTests`' watch widget keys (§3.7). The provider's arithmetic is `Face`'s,
  already tested; the views have no automated coverage, as no widget's rendering has (rule
  `85-testing`).

## 8. Verification

### 8.1 The gate

Per sub-stage, the five invocations of rule `85-testing`, plus — from 7a — the watch unit tests on
the 26.x runtime, pinned by number once installed. The watch runs on the made-for-purpose
*WaterBuddy Watch 27* where the pinned *Apple Watch Series 12 (46mm)* has no data (#77), and a watch
run boots its paired phone (#51). One simulator at a time otherwise, `-parallel-testing-enabled NO`.

### 8.2 Warnings

No new warning against a baseline measured by a clean build of a `HEAD` export on Xcode 27.0, per
file and message, primary lines only — the watch app's 2 and the watch widget scheme's 29 re-measured
before 7a.

### 8.3 On the simulator, then the owner's device

- **7a:** the current screen and the sheet on Apple's glass, on 26.x and 27.0, measured as §3.3 says;
  Reduce Transparency.
- **7b:** the screen on all five watchOS 27.0 sizes (40, 42, 44, 46, 49mm) and on 26.x; a pour from
  each button reaching the phone; an accessibility text size; Russian and Uzbek in the row; Reduce
  Transparency; the percentage's scrim through a pour from empty.
- **7c:** all three faces placed on a watch face, on both runtimes, a tinted face included; Russian
  and Uzbek at three digits; the faces turning over at midnight with the app closed.
- **The owner's device, in 1.2.7's sweep as a new known issue:** the faces' quiet form on a locked
  watch and in Always On with complication data off; VoiceOver on the wrist, row and faces; the
  discs' press; the screen on a watch running 26.x if one is to hand.

## 9. Known limitations, and what is not in scope

- **Not in scope:** an inline family; any interactive face; haptics or `PressStyle` on the watch; a
  watch UI-test target (#42); the watch's App Store image (1.2.8's follow-up, #32, #88); the watch
  widget's display name (#24); `isMirrorStale` (#38); watchOS controls and the Smart Stack.
- On 40mm and 42mm the row's amounts and the caption need a turn of the crown (§3.4).
- What a face does when watchOS redacts, and the press response of Apple's glass on the watch, are
  inferred until rendered or worn.
- The push that keeps the face current stays unproven on 26.x hardware (#52) — unchanged by this
  stage.

## 10. Open before the plan

- **D1 — the runtime.** The owner installs the watchOS 26.x runtime (§3.2) before 7a's measurements;
  7a's code and its failing tests can begin on 27.0 while it downloads.
- **D2 — the tree.** `.claude/settings.json` is modified and `Screenshots/census/` is untracked in the
  working tree; this stage touches neither, and leaves them to the owner.

*(2026-10-20: the owner approved this spec as written ("ok, go ahead"), after five points were laid
beside it in chat: §7's 7a tests prove call sites by render rather than by test; `WristColumn` and
`WristFaceView.swift` are new files in synchronized folders; the screen's percentage takes the face's
`0...999` clamp; and rule `00-workspace` joins §5.)*

## 11. Sequence

1. The owner installs the watchOS 26.x runtime (D1). The rule wording of §5 is typed unstaged and
   approved.
2. **7a** — failing tests → the routing → the *More* capsule and the rows made interactive → renders
   and measurement on both runtimes → the tint ruled → the gate → `/commit` → `/doc_sync`.
3. **7b** — `Face` and the row's tests → `WristPlan.Face` → `WristColumn`, the row, the line, the
   vessel as a display → the removals and the catalogue → the scrim re-derived → renders → the gate →
   `/commit` → `/doc_sync`.
4. **7c** — `LocalizationTests` → the entry and the language → `WristFaceView` with three shapes → the
   catalogue → faces placed on both runtimes → the gate → `/commit` → `/doc_sync`.
