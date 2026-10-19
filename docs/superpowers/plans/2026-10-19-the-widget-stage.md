# The Widget's Stage Implementation Plan

> **For the session that runs it:** executed in the main loop, task by task, tests first — `CLAUDE.md`
> has no implementation subagent. Steps use checkboxes (`- [ ]`). **Nothing is committed**: each task
> ends with its files staged by name, and the owner runs `/commit` (rule `90-git`).

**Goal:** roadmap item 1.3.1 — the Home Screen widget's pour button becomes the white primary surface
(6a), the small widget gets a layout for StandBy, where iOS removes its background (6b), and a new
medium *Week* widget draws the last seven days against the goal and opens History when tapped (6c).

**Architecture:** 6a and 6b change only views in `WaterBuddyWidget/WaterBuddyWidget.swift`. 6c caches
the week in the App Group as `Key.weekTotals`, rewritten from the rows wherever today's total is
recomputed — `init` and `saveAndRecompute()`, in the app and in the widget extension alike — and
read through `WaterSnapshot.weekTotals` and `WaterSnapshot.week(endingOn:calendar:)`. The new
`WeekWidget` shares `HydrationProvider`; its `.widgetURL(WidgetLink.history)` is answered in
`RootTabView` by `AppTab(link:)`.

**Tech Stack:** Swift 5 mode, SwiftUI, WidgetKit, SwiftData, String Catalogs, swift-testing, Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-19-the-widget-stage-design.md` — approved by the owner on
2026-10-19 with D1–D4. §3 holds the design, §5 the rule wording (approved and staged), §7 the tests,
§8 the verification. Read it with this plan.

**What was checked in writing it** (2026-10-19, HEAD `41309e3`): every type, member, key, test and
helper named below was read from the tree — `DaySummary.series` (`DataManager.swift:2236`),
`republishHistory()` (`:1003`), `saveAndRecompute()` (`:1100`), `init` (`:583`–`:586`),
`snapshot(defaults:calendar:now:)` (`:2913`), `resolveServings(in:)` (`:1586`), `readAppliedLedger`
(`:772`), `PageTurn.turn(to:)` (`PageTurn.swift:43`), `UnreadableStore`, the four tests that count the
doorbell from construction (Preconditions, P1). The SDK's `WidgetKit` interface was read for
`showsWidgetContainerBackground` (get-only, iOS 17), `widgetRenderingMode` (settable) and
`widgetURL(_:)`. Both catalogues round-trip byte-identically through
`json.dumps(…, ensure_ascii=False, indent=2) + "\n"` with their keys in code-point order, and the
neighbours of every new key were found by a sorted search. **None of the code below was compiled.**

## Global Constraints

- Floors stay `IPHONEOS_DEPLOYMENT_TARGET = 17.0` and `WATCHOS_DEPLOYMENT_TARGET = 26.0`; no
  `#available` is added (`showsWidgetContainerBackground` is iOS 17). Zero dependencies;
  `project.pbxproj` does not change; no file joins an exception set (rule `15-project`).
- `WaterBuddyWidget/` imports only `AppIntents`, `WidgetKit` and `SwiftUI`; the widget's draw path
  reads only `DataManager.snapshot(...)` and `nextDayBoundary(...)` (rule `40-widget`).
- `DataManager` is the only writer of `Key.weekTotals`. It is written by `init` and
  `saveAndRecompute()` only — never by `refresh()`, `dayDidTurn()`, `resetIfNeeded()` or
  `applyDailyReset(on:)` — never from a failed read, and never when unchanged (spec §3.4 W1–W5).
- One doorbell a pass: the `currentWater` setter rings when today's total moved; the week rings only
  when it has news and the total did not (spec §3.4 W6, as this plan's P1 makes exact).
- `Key.weekTotals`, `readWeekTotals(from:)` and `WaterSnapshot.week(endingOn:calendar:)` are
  `nonisolated` when written (#147, spec §3.4 R5).
- The pour button stays exactly `PourButton.minimumTarget` (44 pt), `ring: false`; outside
  `.fullColor`, white content in the lit rim (rule `60-design-system`).
- In the bare layout the vessel draws its rim and its water, never its glass (D4); its figures carry
  `.privacySensitive()` and it draws the quiet form under `.privacy` (D3).
- Every colour from `Aurora`, every corner from `LiquidGlass`; no literal radius in a view; volumes are
  `Int` (rule `60-design-system`, rule `00-workspace`).
- Every new key: `extractionState: manual`, an explicit `en`, `ru` and `uz`, in **both** catalogues,
  and in `sharedKeys` (rule `70-privacy`). Gallery strings are static literals naming no figure.
- Never weaken an assertion; a test that disagrees with the code is a stop (rule `85-testing`).
- No new warning against a clean baseline of HEAD, compared per file and message (`CLAUDE.md`: 29
  unique lines on Xcode 27.0).
- The tree is edited with Edit and Write only — no `sed -i`, no heredoc or script writing into it.
  Scripts may *read* the tree and write into the scratchpad.
- `xcodebuild` in the foreground, one simulator, `-parallel-testing-enabled NO`; never
  `xcrun simctl shutdown all` — shut down by UDID. `uptime` before a UI run;
  `-collect-test-diagnostics never` on every UI run. Every run whose figure goes into a doc writes its
  own log, named by time.
- Devices: unit tests on the stock iOS 27.0 *iPhone 17*; UI tests on *WaterBuddy Gate 27* and
  *WaterBuddy Gate 26.5*; watch tests on *WaterBuddy Watch 27*; every probe and placement on
  *WaterBuddy Probe 27* — never a Gate device.
- Xcode must not have the project open while a catalogue is edited (`tasks/lessons.md`, 2026-10-18).

## Review Focus

The five inputs the spec implies and its tests do not name, most likely first, each pinned in the
task that owns it:

1. **A serving moved from today to yesterday** — both today's total and a past day change in one
   edit. A reasonable person expects one widget reload, not two. Pinned by
   `aServingMovedToYesterdayRingsOnce` in Task 3 (and the existing
   `aMoveAcrossMidnightRingsTheWidgetDoorbellOnce` stays green unedited).
2. **The app not opened for three days, nothing tapped.** The cache stops at its last write; the week
   read three days later must show those days and zeros after them, never a shorter week. Pinned by
   `aDayNewerThanTheCacheIsEmpty` in Task 3.
3. **A week read in another time zone** than it was written in — a traveller. Seven days, no trap,
   the cached days it can name, the newest from today's total. Pinned by
   `aWeekReadInAnotherZoneStillHasSevenDays` in Task 3.
4. **A corrupt serving of `Int.max`.** The writer saturates the day at `maximumDailyIntake`, which its
   own reader must accept — a cache the reader rejects would show *Open WaterBuddy* forever. Pinned
   by `aCorruptServingSaturatesTheCachedDay` in Task 3.
5. **A tap before 1.3 was ever opened** — the extension's own `init` writes the first week, so the
   widget is never stuck on its empty state after a tap. Pinned by `theFirstWeekRingsTheWidgetOnce`
   in Task 3, which constructs a manager on an empty suite as the extension's first tap does.

## Preconditions — before any code

- [ ] **P1 — the four doorbell tests (owner's decision).** Writing the first week rings the widget
  (spec W6), so constructing a manager on an empty suite now rings once. Four tests count rings from
  construction and will read 2 where they read 1:
  `DataManagerTests.mutationsRingTheWidgetDoorbellAndNoOpRefreshesDoNot` (`:421`),
  `choosingALanguageRingsTheWidgetDoorbellExactlyOnce` (`:1009`),
  `savingAGoalRingsTheWidgetDoorbellExactlyOnce` (`:1323`) and
  `WaterLogTests.loggingRingsTheWidgetDoorbellExactlyOnce` (`:268`). This plan **rebases them** — each
  counts from after construction, asserting the same "exactly once" about its own mutation — and pins
  construction's ring in `theFirstWeekRingsTheWidgetOnce` and `aCachedWeekRingsNothingOnLaunch`
  (Task 3). The alternative is no ring on the first write, which leaves a week widget placed before
  1.3 was opened saying *Open WaterBuddy* after the app was opened, until the next pour or midnight.
  **The owner approves the rebase before Task 3.**
- [ ] **P2 — the link's tick (owner's decision).** `RootTabView` plays `Haptics.select` on every
  change of `turn.shown` (`.sensoryFeedback(Haptics.select, trigger: turn.shown)`), so a turn made by
  the widget's link ticks too, where spec §3.6 said no haptic. This plan **accepts the tick** — the
  user's own tap on the widget brought the turn. Silencing it needs a counter bumped by the two bars
  only, which changes both bars. **The owner chooses before Task 4.**

  *(2026-10-19: the owner approved the plan and ruled both in one reply — P1, rebase the four tests;
  P2, keep the tick.)*
- [ ] **The catalogues are clean and Xcode is closed.** This must print nothing, and `lsof -p` on any
  running Xcode must show no WaterBuddy project file:

```bash
git diff --stat -- WaterBuddy/Localizable.xcstrings WaterBuddyWidget/Localizable.xcstrings WaterBuddy/AppShortcuts.xcstrings WaterBuddyWatch/Localizable.xcstrings WaterBuddyWatchWidget/Localizable.xcstrings
```

- [ ] **Read the DocC** on `PourButton`, `MiniVessel`, `WidgetPane`, `WidgetCardBackdrop` and
  `HydrationView` (`WaterBuddyWidget.swift`), on `republishHistory()` (`DataManager.swift:983`–`1002`),
  `saveAndRecompute()`, `WaterSnapshot` (`:2331`–`2440`) and `PrimarySurfaceModifier`
  (`LiquidGlassModifier.swift:675`–`684`) — rule `00-workspace`, and `CLAUDE.md`'s required reading.

## Files

| File | Change | Task |
|---|---|---|
| `WaterBuddyWidget/WaterBuddyWidget.swift` | `PourSurface`; `SmallLayout`, the bare layout, the quiet form, `widgetPane(glass:)`; `widgetCard()`, `.sample(at:)`, internal `WidgetCardBackdrop` | 1, 2, 5 |
| `WaterBuddy/DataManager.swift` | `Key.weekTotals`, `readWeekTotals(from:)`, `recomputeTodayAndTheWeek()`, `cacheWeek`, `republishHistory(cachingTheWeek:)`, `DaySummary.window`, `WaterSnapshot.weekTotals` and `week(endingOn:calendar:)`, `WidgetLink`; DocC | 3, 4 |
| `WaterBuddyTests/WeekCacheTests.swift` | new: `WeekCacheTests` (`@MainActor`) | 3 |
| `WaterBuddyTests/WaterSnapshotTests.swift` | new suite `WeekSnapshotTests` (not `@MainActor`) | 3 |
| `WaterBuddyTests/DataManagerTests.swift`, `WaterBuddyTests/WaterLogTests.swift` | the four rebased tests (P1) | 3 |
| `WaterBuddy/RootTabView.swift` | `AppTab(link:)`, `.onOpenURL` | 4 |
| `WaterBuddyTests/RootTabViewTests.swift` | two tests in `AppTabTests` | 4 |
| `WaterBuddyWidget/WeekWidget.swift` | new: `WeekWidget`, `WeekView`, `WeekCard` | 5 |
| `WaterBuddyWidget/WaterBuddyWidgetBundle.swift` | lists `WeekWidget` | 5 |
| `WaterBuddyWidget/Localizable.xcstrings` | seven keys | 5 |
| `WaterBuddy/Localizable.xcstrings` | three keys | 5 |
| `WaterBuddyTests/LocalizationTests.swift` | `sharedKeys` + 7; one new test | 5 |
| `HISTORY.md`, `docs/AI_CONTEXT.md`, `docs/ROADMAP.md`, `docs/WIDGET.md`, `docs/STATE.md`, `docs/DESIGN.md`, `tasks/lessons.md` | records | 7 |

`S` is the session's scratchpad directory. A shell's variables do not carry from one call to the
next, so every block that uses it sets it first (`S=<that directory>`).

**A unit run** uses this form, changing only the `-only-testing:` list:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/<Suite> -parallel-testing-enabled NO 2>&1 | tee "$S/<name>-$(date +%H%M%S).log" | grep -E '✔|✘|error:|warning:|Test run with|TEST (SUCCEEDED|FAILED)'
```

**A widget build** — the only proof 6a and 6b have below the simulator (spec §7: the test target
reaches no widget-only source):

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | tee "$S/widget-$(date +%H%M%S).log" | grep -E 'error:|warning:.*WaterBuddyWidget/|BUILD (SUCCEEDED|FAILED)'
```

**The gate**, on the staged tree. Copy the index out and gate the copy, so what is gated is what the
owner will commit. `G` is a new directory named for the time (`G="$S/gate-$(date +%H%M)"`); each run
tees to its own timestamped log, with `uptime` written into it at its start and end:

```bash
git checkout-index -a --prefix="$G/"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -parallel-testing-enabled NO -collect-test-diagnostics never -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=26.5,name=WaterBuddy Gate 26.5' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -parallel-testing-enabled NO -collect-test-diagnostics never -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
xcodebuild build -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$G-dd"
xcodebuild build -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -derivedDataPath "$G-dd"
```

If a UI run would pass the ten-minute foreground limit, run its classes in chunks by name. Expected:
unit `✔ Test run with N tests passed`, N from the attribute grep; UI `GoalSetupUITests` with 1 skipped
by design and 0 failures on each system; watch `✔ Test run with 57 tests in 6 suites passed`; both
builds `** BUILD SUCCEEDED **`. Shut each simulator down by UDID after its run. Read each count off its
log.

**The warning comparison.** A clean `build-for-testing` of HEAD and of the index copy, each into an
empty folder, unique lines by file and message; then the widget scheme (and, after 6c, every scheme)
the same way. `H` is a new directory named for the time:

```bash
mkdir -p "$H" && git archive HEAD | tar -x -C "$H"
xcodebuild build-for-testing -project "$H/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$H-clean" 2>&1 | tee "$S/head-build-$(date +%H%M%S).log" | grep -E 'warning:' | sed -E "s|$H/||; s|/private$H/||; s/:[0-9]+:[0-9]+:/:/" | sort -u > "$S/head-warnings.txt"
xcodebuild build-for-testing -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$G-clean" 2>&1 | tee "$S/index-build-$(date +%H%M%S).log" | grep -E 'warning:' | sed -E "s|$G/||; s|/private$G/||; s/:[0-9]+:[0-9]+:/:/" | sort -u > "$S/index-warnings.txt"
wc -l < "$S/head-warnings.txt"
comm -13 "$S/head-warnings.txt" "$S/index-warnings.txt"
```

Check the counter first: HEAD's list must give the 29 unique lines `CLAUDE.md` names before it is
trusted. Expected: `comm -13` prints nothing. A new line is a failure, fixed before going on.

**A placement probe** — how every widget is looked at on the simulator. A **throwaway** XCUITest file in
a copy, never in the tree, run on *WaterBuddy Probe 27* with `-resultBundlePath`: it drives SpringBoard
(`XCUIApplication(bundleIdentifier: "com.apple.springboard")`) — long-press an empty spot, *Edit* →
*Add Widget*, search *WaterBuddy*, pick the widget and family, *Add Widget*, *Done* — attaching a
screenshot after every step, so the selectors are corrected from what the shots show. Export with
`xcrun xcresulttool export attachments`. Dark appearance by `xcrun simctl ui <udid> appearance dark`.
**Look at every shot before writing a word about it** (`tasks/lessons.md`, 2026-10-18).

---

### Task 1: Stage 6a — the white pour button

**Files:**
- Modify: `WaterBuddyWidget/WaterBuddyWidget.swift` — `PourButton.label` (`:441`–`:463`); a new
  `PourSurface` after `WidgetPane` (`:509`)

**Interfaces:**
- Consumes: `View.primarySurface(in:ring:)` (`LiquidGlassModifier.swift:821`).
- Produces: `View.pourSurface(in:)` — private to the file.

No unit test can reach this code (spec §7). Its proof is the widget build, the previews and the
placement on the simulator.

- [ ] **Step 1: The surface.** After `WidgetPane`'s closing brace, add:

```swift
// MARK: - The pour button's surface

private extension View {

    /// The pour button's surface — the one place in a widget the redesign's primary surface is
    /// drawn.
    func pourSurface<S: SwiftUI.Shape & InsettableShape>(in shape: S) -> some View {
        modifier(PourSurface(shape: shape))
    }
}

/// The widget's one action as the redesign's primary surface: solid white, `Aurora.top` content
/// (rule `60-design-system`).
///
/// **No ring.** ``PrimarySurfaceModifier``'s ring reaches six points outside the shape, and the
/// button is exactly ``PourButton/minimumTarget`` — the target `MiniVessel.radius(fitting:besides:gap:)`
/// derives the vessel's clearance from (rule `40-widget`). A ring would eat the 4-pt gap.
///
/// **Outside `.fullColor` it keeps the white content in the lit rim.** On a template only alpha
/// survives, and a white shape with dark content comes back as one blank disc. That is the fallback
/// every pane in a templated widget takes (``WidgetPane``).
private struct PourSurface<S: Shape & InsettableShape>: ViewModifier {

    let shape: S

    @Environment(\.widgetRenderingMode) private var renderingMode

    @ViewBuilder
    func body(content: Content) -> some View {
        if renderingMode == .fullColor {
            // The surface sets its content's colour; the label sets none of its own.
            content.primarySurface(in: shape, ring: false)
        } else {
            content
                .foregroundStyle(.white)
                .background {
                    shape.strokeBorder(.white.opacity(0.45), lineWidth: 1)
                }
        }
    }
}
```

- [ ] **Step 2: The label.** Replace `PourButton.label` with:

```swift
    @ViewBuilder
    private var label: some View {
        switch shape {
        case .circle:
            Image(systemName: "plus")
                .font(.system(size: 19, weight: .semibold))
                .frame(width: Self.minimumTarget, height: Self.minimumTarget)
                .pourSurface(in: Circle())
                .contentShape(Circle())

        case .capsule:
            Text(strings.localized("+%1$d ml", serving, locale: locale))
                .font(.callout.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: Self.minimumTarget)
                .pourSurface(in: Capsule())
                .contentShape(Capsule())
        }
    }
```

  Both `.foregroundStyle(.white)` lines are gone: the surface owns the colour (rule
  `60-design-system`: never give a primary label a `.foregroundStyle` of its own). Amend
  `PourButton`'s DocC with one sentence: "Drawn on the redesign's primary surface in full colour, and
  as white in the lit rim on a template (``PourSurface``)."

- [ ] **Step 3: Build.** Run **A widget build**. Expected: `** BUILD SUCCEEDED **`, no warning from
  `WaterBuddyWidget/`.

- [ ] **Step 4: Stage.** `git add WaterBuddyWidget/WaterBuddyWidget.swift`

- [ ] **Step 5: The gate and the warning comparison** (above). Expected as written there.

- [ ] **Step 6: Placement.** **A placement probe** on the index copy: the small and the medium
  Hydration widget, light and dark — the white disc and capsule with `Aurora.top` content, the vessel
  still clear of the disc; then a tap on the button raises the figure (`chronod`/`linkd` may refuse a
  widget's button on the simulator, as #63 records — say what the shot shows). A tinted Home Screen,
  if the probe can reach *Customize → Tinted*; if not, it joins the device list (spec §8.3).

---

### Task 2: Stage 6b — the small widget in StandBy, and its quiet form

**Files:**
- Modify: `WaterBuddyWidget/WaterBuddyWidget.swift` — `HydrationView` (`:112`–`:200`), `MiniVessel`
  (`:271`–`:397`), `widgetPane` and `WidgetPane` (`:468`–`:509`), the previews (`:605`)

**Interfaces:**
- Produces: `SmallLayout(snapshot: WaterSnapshot, bare: Bool)` and `MiniVessel(snapshot:bare:)` —
  private to the file; `widgetPane(in:density:elevation:glass:)`, `glass` defaulting to `true`.

- [ ] **Step 1: Glass that can stand down.** In the `widgetPane` extension and `WidgetPane`, add the
  flag:

```swift
private extension View {

    /// ``LiquidGlassModifier``, with the two things a widget has to do differently.
    ///
    /// `glass: false` draws the rim alone, for a pane that stands on the system's black (StandBy):
    /// glass never goes over a flat background (rule `60-design-system`).
    func widgetPane<S: SwiftUI.Shape & InsettableShape>(
        in shape: S,
        density: LiquidGlass.Density,
        elevation: LiquidGlass.Elevation,
        glass: Bool = true
    ) -> some View {
        modifier(WidgetPane(shape: shape, density: density, elevation: elevation, glass: glass))
    }
}
```

  and in `WidgetPane`, a stored `let glass: Bool` after `elevation`, and the body's condition
  `if glass && renderingMode == .fullColor {`. Add to its DocC: "With `glass` off it draws the rim in
  every mode — the bare layout in StandBy, where an empty sheer pane over black reads as a grey disc."

- [ ] **Step 2: The vessel, bare and quiet.** In `MiniVessel`, after `let snapshot: WaterSnapshot`:

```swift
    /// Stands on the system's black, in StandBy: the rim and the water, never the glass
    /// (rule `60-design-system`, spec 2026-10-19-the-widget-stage §3.3).
    var bare = false

    @Environment(\.redactionReasons) private var redactionReasons

    /// Whether iOS has asked for the figure to be hidden — a locked phone in StandBy, when its own
    /// lock settings say so (rule `70-privacy`).
    private var isQuiet: Bool { redactionReasons.contains(.privacy) }
```

  and replace its `body` with:

```swift
    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)

            ZStack {
                // The quiet form is the Lock Screen widget's: an empty vessel, no water and no
                // figure, still recognisably WaterBuddy to the person it belongs to.
                if !isQuiet {
                    ZStack {
                        water(diameter: diameter)
                        readout(diameter: diameter)
                    }
                    .privacySensitive()
                }
            }
            .frame(width: diameter, height: diameter)
            .widgetPane(in: Circle(), density: .sheer, elevation: .resting, glass: !bare)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        // A figure hidden from sight is hidden from speech (rule `65-accessibility`).
        .accessibilityValue(isQuiet ? "" : strings.localized("%1$d percent. %2$d of %3$d millilitres.", snapshot.percentage, snapshot.currentWater, snapshot.dailyGoal, locale: locale))
    }
```

  Add to its DocC: "**Quiet when iOS asks.** Its figures carry `.privacySensitive()`, and under
  `.privacy` it draws an empty vessel and speaks its label alone, as the Lock Screen widget does — so a
  locked phone in StandBy shows no figure whenever iOS's own settings say so. On an unlocked Home
  Screen nothing is redacted."

- [ ] **Step 3: The small layout, with its flag.** Remove `HydrationView.small` and add, before
  `// MARK: - Medium column`:

```swift
// MARK: - Small

/// The vessel and the pour button on a diagonal. They cannot stack — a 138pt card will not hold a
/// legible vessel *and* a 44pt target beneath it — and they must not overlap, because two glass discs
/// sharing an edge read as one dented shape rather than two controls.
///
/// **Bare in StandBy.** With `bare`, iOS has removed the background and there is no card: the two
/// stand on the system's black, the vessel sized by the same clearance formula over the larger square
/// and drawing its rim rather than its glass (rule `60-design-system`). The flag is a parameter
/// because `showsWidgetContainerBackground` is get-only: ``HydrationView`` reads it once, and a
/// `#Preview` builds this directly (rule `40-widget`).
private struct SmallLayout: View {

    let snapshot: WaterSnapshot
    let bare: Bool

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let vessel = 2 * MiniVessel.radius(fitting: side, besides: PourButton.minimumTarget)

            ZStack {
                MiniVessel(snapshot: snapshot, bare: bare)
                    .frame(width: vessel, height: vessel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                PourButton(shape: .circle, serving: snapshot.serving)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
    }
}
```

- [ ] **Step 4: Read the background once.** In `HydrationView`, add after `cardPadding`:

```swift
    /// How far the vessel and the button stand in from the edge when iOS has removed the background
    /// (StandBy). Less than the card's inset and padding together, because no card is drawn round
    /// them; on a 158-pt widget it leaves the vessel about 105 pt across, where the card leaves 84.
    private static let bareInset: CGFloat = 8
```

  and after `@Environment(\.widgetFamily) private var family`:

```swift
    /// `false` when iOS has removed the container background — on iPhone, StandBy. **Read here and
    /// only here**, and handed down as ``SmallLayout``'s flag: it is get-only, so no preview could set
    /// it (rule `40-widget`).
    @Environment(\.showsWidgetContainerBackground) private var showsBackground
```

  Replace the first line of `body`, `card`, with `layout`, and add:

```swift
    /// The card, or — for the small family once iOS has removed the background — the bare layout.
    /// Small only: iPhone's StandBy shows small widgets alone (inferred from Apple's documentation,
    /// spec §3.3), so the medium family never meets a removed background there.
    @ViewBuilder
    private var layout: some View {
        if family == .systemSmall && !showsBackground {
            SmallLayout(snapshot: entry.snapshot, bare: true)
                .padding(Self.bareInset)
        } else {
            card
                .padding(Self.cardInset)
        }
    }
```

  `body` keeps `.containerBackground(for: .widget) { WidgetAurora() }` and the three environment
  lines; its own `.padding(Self.cardInset)` moves into `layout` as shown. In `content`, the `default`
  case becomes `SmallLayout(snapshot: entry.snapshot, bare: false)`.

- [ ] **Step 5: The previews.** After the two widget previews:

```swift
// StandBy is not on the simulator, and `showsWidgetContainerBackground` cannot be set, so the bare
// layout is drawn directly, on the black iOS draws behind it (spec §3.3).
#Preview("Small · StandBy") {
    SmallLayout(snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000), bare: true)
        .padding(8)
        .frame(width: 158, height: 158)
        .background(Color.black)
        .environment(\.colorScheme, .dark)
}

#Preview("Small · StandBy at night") {
    SmallLayout(snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000), bare: true)
        .padding(8)
        .frame(width: 158, height: 158)
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .environment(\.widgetRenderingMode, .vibrant)
}

#Preview("Small · locked") {
    SmallLayout(snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000), bare: true)
        .padding(8)
        .frame(width: 158, height: 158)
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .redacted(reason: .privacy)
}
```

- [ ] **Step 6: Build.** Run **A widget build**. Expected: `** BUILD SUCCEEDED **`, no warning from
  `WaterBuddyWidget/`.

- [ ] **Step 7: Stage.** `git add WaterBuddyWidget/WaterBuddyWidget.swift`

- [ ] **Step 8: The gate and the warning comparison.** Expected as written above.

- [ ] **Step 9: A throwaway render of the bare layout.** In a fresh index copy only: make
  `HydrationView.layout` take the bare branch unconditionally and its container background
  `Color.black`; place the small widget with **A placement probe**; shoot. Then the same copy with
  `.environment(\.widgetRenderingMode, .vibrant)` at `HydrationView`'s root, and again with
  `.redacted(reason: .privacy)`. Expected: the vessel's rim and water on black, about 105 pt across,
  the white disc on the diagonal clear of it; at "night" white silhouettes and a rimmed button; locked,
  an empty rim and the button. The copy is deleted after. Nothing about real StandBy is claimed from
  this — that is the owner's device (spec §8.3).

---

### Task 3: Stage 6c — the week in the cache

**Files:**
- Modify: `WaterBuddy/DataManager.swift` — `Key` (`:103`–`:170`), `init` (`:585`–`:586`),
  `republishHistory()` (`:983`–`:1027`), `republishStreak()`'s DocC (`:1031`–`:1033`),
  `saveAndRecompute()` (`:1112`–`:1113`), after `usualSlot` (`:1612`), `DaySummary.series`
  (`:2236`–`:2272`), `WaterSnapshot` (`:2331`–`:2440`), `snapshot(defaults:calendar:now:)` (`:2932`)
- Create: `WaterBuddyTests/WeekCacheTests.swift`
- Modify: `WaterBuddyTests/WaterSnapshotTests.swift` — a suite appended after `WidgetLanguageTests`
- Modify: `WaterBuddyTests/DataManagerTests.swift:421`–`:431`, `:1009`–`:1019`, `:1323`–`:1333`;
  `WaterBuddyTests/WaterLogTests.swift:268`–`:276` (P1)

**Interfaces:**
- Produces: `DataManager.Key.weekTotals: String` (`nonisolated static let`);
  `DataManager.readWeekTotals(from: UserDefaults) -> [Int: Int]?` (`nonisolated static`);
  `DaySummary.window(days: Int, endingOn: Date, in: Calendar) -> [(ordinal: Int, date: Date)]`
  (`nonisolated static`); `WaterSnapshot.weekTotals: [Int: Int]?` (defaulted `nil`);
  `WaterSnapshot.week(endingOn: Date, calendar: Calendar) -> [DaySummary]?` (`nonisolated`).

- [ ] **Step 1: The seams — present, and wrong on purpose.** Each wrongness is one a test below must
  catch.
  - In `Key`, after `reviewRequestedVersion`:

```swift
        /// The last ``DataManager/historyWindow`` days' totals, JSON-encoded `[Int: Int]` — day
        /// ordinal → millilitres, every day of the window present and zeros included — for the week
        /// widget, which may never open SwiftData (rule `40-widget`).
        ///
        /// **Absent means not yet known, never "nothing drunk"**, so nothing materialises it: the
        /// widget says to open the app rather than drawing a week of zeros (rule `25-shared-storage`).
        /// Derived, like ``currentWater``: rewritten from the rows wherever today's total is
        /// recomputed (``DataManager/recomputeTodayAndTheWeek()``), read through
        /// ``DataManager/readWeekTotals(from:)``.
        ///
        /// `nonisolated`, as ``wristApplied`` is: `readWeekTotals(from:)`, on the widget's read path,
        /// names it.
        nonisolated static let weekTotals = prefix + "weekTotals"
```

    and in `all`, `reviewRequestedVersion,` becomes `reviewRequestedVersion, weekTotals,`.
  - After `usualSlot`: `nonisolated static func readWeekTotals(from defaults: UserDefaults) -> [Int: Int]? { nil }`
  - In `WaterSnapshot`, after `serving`: `var weekTotals: [Int: Int]? = nil`, and after
    `hasReachedGoal`:
    `nonisolated func week(endingOn instant: Date, calendar: Calendar) -> [DaySummary]? { nil }`
  - In `extension DaySummary`, before `series`, the walk — real, a refactor the existing series tests
    cover:

```swift
    /// The `days` local days ending on the day containing `now`, oldest first, each as its ordinal
    /// and its start — the one walk ``series(from:days:endingOn:in:)`` and
    /// ``WaterSnapshot/week(endingOn:calendar:)`` both take, so History's card and the week widget
    /// cannot name different days. Non-positive `days` yields `[]`.
    nonisolated static func window(days: Int, endingOn now: Date, in calendar: Calendar) -> [(ordinal: Int, date: Date)] {
        guard days > 0 else { return [] }

        let today = calendar.startOfDay(for: now)

        // Walked with `date(byAdding: .day,)`, never by subtracting 86,400 seconds — a DST day is
        // 23 or 25 hours long and a seconds-based walk silently drops or repeats one
        // (rule `30-rollover`).
        return (0..<days).reversed().compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today).map {
                (DataManager.dayOrdinal(for: $0, in: calendar), $0)
            }
        }
    }
```

    and in `series`, the `guard days > 0`, `let today` and `let window` lines become
    `let window = Self.window(days: days, endingOn: now, in: calendar)`; the rest is unchanged.
  - At the top of `republishHistory()`, before its guard — **the wrong writer**: on every call
    (refresh and the day turning included), from a failed read as zeros, ringing every time:

```swift
        // SEAM (Task 3, Step 1) — wrong on purpose; removed in Step 4.
        let seamInstant = now()
        if let start = Self.historyWindowStart(endingOn: seamInstant, calendar: calendar) {
            let rows = readLogs(from: start, to: Self.nextDayBoundary(after: seamInstant, calendar: calendar)) ?? []
            let series = DaySummary.series(from: rows, days: Self.historyWindow, endingOn: seamInstant, in: calendar)
            if let data = try? JSONEncoder().encode(Dictionary(series.map { ($0.dayOrdinal, $0.total) }, uniquingKeysWith: { first, _ in first })) {
                defaults.set(data, forKey: Key.weekTotals)
                reloadWidgets()
            }
        }
```

- [ ] **Step 2: Write the failing tests.** Create `WaterBuddyTests/WeekCacheTests.swift`:

```swift
//
//  WeekCacheTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 19/10/26.
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private func gregorian(in timeZone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}

private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// A clock a test can move between mutations.
private final class MovableClock: @unchecked Sendable {
    var now: Date
    init(_ now: Date) { self.now = now }
}

/// The widget doorbell, counted. A reference, because the closure that rings it outlives the call.
private final class Rings: @unchecked Sendable {
    var count = 0
}

/// One throwaway suite and one in-memory store, and as many managers on them as a test needs: the
/// morning after is a **second process** on the same group (spec 2026-10-19-the-widget-stage §2).
@MainActor
private struct WeekStore {

    let defaults: UserDefaults
    let container: ModelContainer
    let rings = Rings()

    func manager(_ clock: MovableClock, calendar: Calendar = utcDay) -> DataManager {
        DataManager(
            defaults: defaults,
            modelContainer: container,
            calendar: calendar,
            now: { clock.now },
            reloadWidgets: { [rings] in rings.count += 1 },
            rescheduleReminders: { _ in },
            publishWrist: { _ in }
        )
    }

    /// The cached week, as the widget reads it.
    func cached() -> [Int: Int]? {
        DataManager.readWeekTotals(from: defaults)
    }
}

@MainActor
private func withWeekStore<T>(_ body: (WeekStore) throws -> T) throws -> T {
    let name = "test.waterbuddy.week.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return try body(WeekStore(defaults: defaults, container: container))
}

// MARK: - Tests

/// The week the week widget draws, cached where today's total is: `init` and every mutation, in
/// whichever phone process made it — never `refresh()`, never the day turning, never a failed read
/// (rule `20-state`, spec §3.4).
@MainActor
struct WeekCacheTests {

    @Test func aPourCachesTheWeek() throws {
        try withWeekStore { store in
            let clock = MovableClock(utc(2026, 10, 19, 14))
            let manager = store.manager(clock)
            manager.addLog(amount: 400, at: utc(2026, 10, 15, 9))
            manager.addLog(amount: 600, at: utc(2026, 10, 18, 20))
            manager.addLog(amount: 250)

            #expect(store.cached() == [
                20261013: 0, 20261014: 0, 20261015: 400, 20261016: 0,
                20261017: 0, 20261018: 600, 20261019: 250,
            ])
        }
    }

    /// The case approach A exists for: the extension's own process, the next morning, rolls the day
    /// over in `init` before it logs the tap — and the cached total for yesterday goes with it.
    @Test func theMorningAfterATapKeepsYesterday() throws {
        try withWeekStore { store in
            let evening = MovableClock(utc(2026, 10, 18, 21))
            let app = store.manager(evening)
            app.addLog(amount: 1_000, at: utc(2026, 10, 18, 8))
            app.addLog(amount: 250)

            let morning = MovableClock(utc(2026, 10, 19, 7))
            let tap = store.manager(morning)
            tap.addWater(amount: 250)

            let snapshot = DataManager.snapshot(defaults: store.defaults, calendar: utcDay, now: morning.now)
            let week = try #require(snapshot.week(endingOn: morning.now, calendar: utcDay))
            #expect(week.map(\.total) == [0, 0, 0, 0, 0, 1_250, 250])
        }
    }

    @Test func aPourTodayRingsTheWidgetOnce() throws {
        try withWeekStore { store in
            let manager = store.manager(MovableClock(utc(2026, 10, 19, 14)))
            let before = store.rings.count

            manager.addLog(amount: 250)

            #expect(store.rings.count - before == 1, "today's total rings; the week's today must not ring again")
        }
    }

    @Test func anEditToAnEarlierDayRingsTheWidgetOnce() throws {
        try withWeekStore { store in
            let manager = store.manager(MovableClock(utc(2026, 10, 19, 14)))
            manager.addLog(amount: 400, at: utc(2026, 10, 17, 9))
            let serving = try #require(manager.allLogs().first)
            let before = store.rings.count

            manager.updateLog(serving, newAmount: 650)

            #expect(store.cached()?[20261017] == 650)
            #expect(store.rings.count - before == 1, "today's total did not move, so only the week can tell the widget")
        }
    }

    /// Review Focus 1: both today and a past day move in one edit; one reload, not two.
    @Test func aServingMovedToYesterdayRingsOnce() throws {
        try withWeekStore { store in
            let manager = store.manager(MovableClock(utc(2026, 10, 19, 14)))
            manager.addLog(amount: 300, at: utc(2026, 10, 19, 9))
            let serving = try #require(manager.allLogs().first)
            let before = store.rings.count

            manager.updateLog(serving, newAmount: 300, timestamp: utc(2026, 10, 18, 21))

            #expect(store.cached()?[20261018] == 300)
            #expect(store.cached()?[20261019] == 0)
            #expect(store.rings.count - before == 1)
        }
    }

    /// Review Focus 5: an empty suite — a fresh install, or the extension's first tap before 1.3 was
    /// opened — gets its first week from `init`, and the widget is told.
    @Test func theFirstWeekRingsTheWidgetOnce() throws {
        try withWeekStore { store in
            #expect(store.cached() == nil)

            _ = store.manager(MovableClock(utc(2026, 10, 19, 14)))

            #expect(store.cached() != nil)
            #expect(store.rings.count == 1, "the week widget was saying to open the app")
        }
    }

    @Test func aCachedWeekRingsNothingOnLaunch() throws {
        try withWeekStore { store in
            let clock = MovableClock(utc(2026, 10, 19, 14))
            let first = store.manager(clock)
            first.addLog(amount: 250)
            let before = store.rings.count

            _ = store.manager(clock)

            #expect(store.rings.count == before)
        }
    }

    /// Compared as bytes, not through the reader, so the seam's reader cannot hide a write.
    @Test func refreshNeverWritesTheWeek() throws {
        try withWeekStore { store in
            let manager = store.manager(MovableClock(utc(2026, 10, 19, 14)))
            let sentinel = try JSONEncoder().encode(Dictionary(uniqueKeysWithValues: (13...19).map { (20261000 + $0, 111) }))
            store.defaults.set(sentinel, forKey: DataManager.Key.weekTotals)

            manager.refresh()

            #expect(store.defaults.data(forKey: DataManager.Key.weekTotals) == sentinel)
        }
    }

    @Test func theDayTurningNeverWritesTheWeek() throws {
        try withWeekStore { store in
            let clock = MovableClock(utc(2026, 10, 19, 23, 50))
            let manager = store.manager(clock)
            let sentinel = try JSONEncoder().encode(Dictionary(uniqueKeysWithValues: (13...19).map { (20261000 + $0, 111) }))
            store.defaults.set(sentinel, forKey: DataManager.Key.weekTotals)

            clock.now = utc(2026, 10, 20, 0, 10)
            manager.dayDidTurn()

            #expect(store.defaults.data(forKey: DataManager.Key.weekTotals) == sentinel)
        }
    }

    /// A failed read is not a week of zeros (rule `20-state`).
    @Test func aFailedReadLeavesTheWeekAsItStands() throws {
        let unreadable = try UnreadableStore()
        defer { unreadable.remove() }

        let name = "test.waterbuddy.week.unreadable.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let manager = DataManager(
            defaults: defaults, modelContainer: unreadable.container, calendar: utcDay,
            now: { utc(2026, 10, 19, 14) },
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
        manager.addLog(amount: 2_000)
        let written = try #require(defaults.data(forKey: DataManager.Key.weekTotals), "the store must be healthy before it is broken")

        try unreadable.breakReads()
        #expect(!unreadable.stillReads, "the store must be unreadable before anything is asserted about a failed read")

        manager.addLog(amount: 500)

        #expect(defaults.data(forKey: DataManager.Key.weekTotals) == written)
    }

    /// Review Focus 4: a row of `Int.max` saturates its day, and the reader takes what the writer wrote.
    @Test func aCorruptServingSaturatesTheCachedDay() throws {
        try withWeekStore { store in
            let manager = store.manager(MovableClock(utc(2026, 10, 19, 14)))
            let other = ModelContext(store.container)
            other.insert(WaterLog(amount: .max, timestamp: utc(2026, 10, 18, 9)))
            try other.save()

            manager.addLog(amount: 250)

            #expect(store.cached()?[20261018] == DataManager.maximumDailyIntake)
        }
    }

    /// The widget and History's card are one reading of the same days — across the 25-hour day too.
    @Test func theWeekWidgetAgreesWithTheWeekCardAcrossADaylightSavingDay() throws {
        let newYork = gregorian(in: "America/New_York")
        let at = { (day: Int, hour: Int, minute: Int) in
            newYork.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
        }
        try withWeekStore { store in
            let clock = MovableClock(at(3, 12, 0))
            let manager = store.manager(clock, calendar: newYork)
            manager.addLog(amount: 300, at: at(1, 0, 30))     // the 25-hour day, before the change
            manager.addLog(amount: 400, at: at(1, 23, 59))    // and after it
            manager.addLog(amount: 500, at: at(2, 9, 0))
            manager.addLog(amount: 250)

            let snapshot = DataManager.snapshot(defaults: store.defaults, calendar: newYork, now: clock.now)
            let week = try #require(snapshot.week(endingOn: clock.now, calendar: newYork))
            #expect(week == manager.history)
            #expect(week.map(\.total) == [0, 0, 0, 0, 700, 500, 250])
        }
    }
}
```

  Append to `WaterBuddyTests/WaterSnapshotTests.swift`, after `WidgetLanguageTests`:

```swift
// MARK: - The cached week

/// The ways a stored week can be one this build did not write.
private enum WeekCorruption: CaseIterable, Sendable {
    case absent, notJSON, notData, sixDays, eightDays, aNegativeDay, aDayOverTheCap
}

/// ``WaterSnapshot/weekTotals`` and ``WaterSnapshot/week(endingOn:calendar:)`` — what the week widget
/// draws (spec 2026-10-19-the-widget-stage §3.4). **Not `@MainActor`**, as the widget's read is not.
struct WeekSnapshotTests {

    /// Seven days, the 13th to the 19th of October 2026, oldest first.
    private static let aWeek: [Int: Int] = [
        20261013: 0, 20261014: 300, 20261015: 2_000, 20261016: 0,
        20261017: 1_200, 20261018: 2_400, 20261019: 900,
    ]

    private static func store(_ corruption: WeekCorruption, in defaults: UserDefaults) throws {
        let key = DataManager.Key.weekTotals
        let days = Array(aWeek.keys.sorted())
        switch corruption {
        case .absent: break
        case .notJSON: defaults.set(Data("not a week".utf8), forKey: key)
        case .notData: defaults.set("a week", forKey: key)
        case .sixDays: defaults.set(try JSONEncoder().encode(aWeek.filter { $0.key != days[0] }), forKey: key)
        case .eightDays: defaults.set(try JSONEncoder().encode(aWeek.merging([20261012: 0]) { first, _ in first }), forKey: key)
        case .aNegativeDay: defaults.set(try JSONEncoder().encode(aWeek.merging([days[1]: -1]) { _, new in new }), forKey: key)
        case .aDayOverTheCap: defaults.set(try JSONEncoder().encode(aWeek.merging([days[1]: DataManager.maximumDailyIntake + 1]) { _, new in new }), forKey: key)
        }
    }

    @Test func theSnapshotCarriesTheCachedWeek() throws {
        try withTempDefaults { defaults in
            defaults.set(try JSONEncoder().encode(Self.aWeek), forKey: DataManager.Key.weekTotals)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 19))

            #expect(snapshot.weekTotals == Self.aWeek)
        }
    }

    /// Discarded whole, never repaired — as `resolveServings(in:)` treats its triple.
    @Test(arguments: WeekCorruption.allCases)
    func aWeekThisBuildDidNotWriteIsUnknown(_ corruption: WeekCorruption) throws {
        try withTempDefaults { defaults in
            try Self.store(corruption, in: defaults)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 19))

            #expect(snapshot.weekTotals == nil)
            #expect(snapshot.week(endingOn: utc(2026, 10, 19), calendar: utcDay) == nil)
        }
    }

    /// `async`, with each read into a local before `#expect`: the one shape seen to warn when a
    /// member read off the main actor is main-actor (#147). Step 6 takes `nonisolated` off
    /// `week(endingOn:calendar:)` to see it warn.
    @Test func theWeekEndsOnItsDayAndTakesThatDayFromTheTotal() async throws {
        let snapshot = WaterSnapshot(currentWater: 1_100, dailyGoal: 2_000, weekTotals: Self.aWeek)

        let cached = snapshot.weekTotals
        let week = snapshot.week(endingOn: utc(2026, 10, 19, 14), calendar: utcDay)

        #expect(cached == Self.aWeek)
        let days = try #require(week)
        #expect(days.map(\.dayOrdinal) == [20261013, 20261014, 20261015, 20261016, 20261017, 20261018, 20261019])
        #expect(days.map(\.total) == [0, 300, 2_000, 0, 1_200, 2_400, 1_100], "today is the vessel's figure, not the cache's")
    }

    @Test func theMidnightEntryShiftsTheWeekByADay() throws {
        let evening = WaterSnapshot(currentWater: 900, dailyGoal: 2_000, weekTotals: Self.aWeek)

        let days = try #require(evening.rolledOver().week(endingOn: utc(2026, 10, 20, 0), calendar: utcDay))

        #expect(days.map(\.dayOrdinal) == [20261014, 20261015, 20261016, 20261017, 20261018, 20261019, 20261020])
        #expect(days.map(\.total) == [300, 2_000, 0, 1_200, 2_400, 900, 0])
    }

    /// Review Focus 2: nothing opened or tapped for three days.
    @Test func aDayNewerThanTheCacheIsEmpty() throws {
        let stale = WaterSnapshot(currentWater: 0, dailyGoal: 2_000, weekTotals: Self.aWeek)

        let days = try #require(stale.week(endingOn: utc(2026, 10, 22, 9), calendar: utcDay))

        #expect(days.map(\.total) == [0, 1_200, 2_400, 900, 0, 0, 0])
    }

    /// Review Focus 3: read in Los Angeles, written in UTC.
    @Test func aWeekReadInAnotherZoneStillHasSevenDays() throws {
        let losAngeles = gregorian(in: "America/Los_Angeles")
        let snapshot = WaterSnapshot(currentWater: 500, dailyGoal: 2_000, weekTotals: Self.aWeek)

        // 02:00 UTC on the 19th is 19:00 on the 18th in Los Angeles.
        let days = try #require(snapshot.week(endingOn: utc(2026, 10, 19, 2), calendar: losAngeles))

        #expect(days.map(\.dayOrdinal) == [20261012, 20261013, 20261014, 20261015, 20261016, 20261017, 20261018])
        #expect(days.map(\.total) == [0, 0, 300, 2_000, 0, 1_200, 500])
    }

    @Test func readingACachedWeekLeavesTheStoreUntouched() throws {
        try withTempDefaults { defaults in
            seed(defaults, water: 750, goal: 2_500, day: 20_261_018)   // deliberately yesterday
            defaults.set(try JSONEncoder().encode(Self.aWeek), forKey: DataManager.Key.weekTotals)
            let before = waterBuddyKeys(in: defaults)

            _ = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 19))

            #expect(waterBuddyKeys(in: defaults) == before)
        }
    }
}
```

- [ ] **Step 3: Run RED.** `-only-testing:WaterBuddyTests/WeekCacheTests -only-testing:WaterBuddyTests/WeekSnapshotTests`.
  Expected — each failing **on its own expectation**, not on a build error:
  `aPourCachesTheWeek`, `anEditToAnEarlierDay…` and `aServingMovedToYesterday…` (the reader's `nil`),
  `theMorningAfterATapKeepsYesterday`, `theWeekWidgetAgrees…` and `aCorruptServingSaturates…`
  (`#require`/the reader's `nil`), `aPourTodayRingsTheWidgetOnce` and `aCachedWeekRingsNothingOnLaunch`
  (the seam rings every time), `theFirstWeekRingsTheWidgetOnce` (the reader's `nil`),
  `refreshNeverWritesTheWeek` and `theDayTurningNeverWritesTheWeek` (the seam writes),
  `aFailedReadLeavesTheWeekAsItStands` (the seam writes zeros); `theSnapshotCarriesTheCachedWeek`,
  `theWeekEndsOnItsDay…`, `theMidnightEntryShifts…`, `aDayNewerThanTheCache…` and
  `aWeekReadInAnotherZone…` (`nil`). **Seen green at RED, and why:** `aWeekThisBuildDidNotWriteIsUnknown`
  (the seam reads `nil` for everything — Step 6 breaks the validation to see each case fail) and
  `readingACachedWeekLeavesTheStoreUntouched` (the seam's snapshot reads nothing — Step 6 again). Any
  other test green here, or any build error: stop.

- [ ] **Step 4: Implement.** Remove the seam block from `republishHistory()`. Then:
  - Replace the `readWeekTotals` seam with:

```swift
    /// The cached week (``Key/weekTotals``), or `nil` when there is none this build wrote.
    ///
    /// **Validated on the way out, and discarded whole rather than repaired** — undecodable data, a
    /// count other than ``historyWindow``, or any day outside `0...maximumDailyIntake` — as
    /// ``resolveServings(in:)`` discards its triple: a partly-repaired week is a set of bars nobody's
    /// rows produced. `nil` is *unknown*, which the week widget says in words; it is never read as
    /// a week of zeros.
    ///
    /// `nonisolated static` for ``snapshot(defaults:calendar:now:)``, on the widget's read path.
    nonisolated static func readWeekTotals(from defaults: UserDefaults) -> [Int: Int]? {
        guard let data = defaults.data(forKey: Key.weekTotals),
              let week = try? JSONDecoder().decode([Int: Int].self, from: data),
              week.count == historyWindow,
              week.values.allSatisfy({ (0...maximumDailyIntake).contains($0) })
        else { return nil }
        return week
    }
```

  - Before `republishHistory()`, add:

```swift
    /// Recomputes today's total, then the week, from the rows — what `init` and
    /// ``saveAndRecompute()`` run, and nothing else does.
    ///
    /// **The week is cached exactly where today's total is recomputed** (rule `20-state`), in every
    /// process that builds a `DataManager` — the widget extension too. A tap the morning after rolls
    /// the day over in that process before it logs, and the cached total for yesterday goes with
    /// it; the week, rewritten here from the rows, keeps it (spec 2026-10-19-the-widget-stage §2,
    /// §3.4). ``refresh()`` and ``dayDidTurn()`` republish the week card and write nothing, for the
    /// reason ``refresh()`` never recomputes the total: a read across processes can miss the other
    /// process's newest row.
    ///
    /// **One doorbell a pass.** The ``currentWater`` setter rings when today's total moved. The week
    /// rings only when it has news and the total did not, so a serving moved from today to yesterday
    /// — both moved — still rings once.
    private func recomputeTodayAndTheWeek() {
        let totalBefore = storedCurrentWater
        recomputeToday()
        let weekHasNews = republishHistory(cachingTheWeek: true)
        if weekHasNews, storedCurrentWater == totalBefore {
            reloadWidgets()
        }
    }
```

  - Replace `republishHistory()` with the version below, keeping its DocC except the sentences from
    "and without this early return" to "(rule `40-widget`)." (`:989`–`:993`), which become: "The
    guard covers what the app draws — the rows, the series, the streak. **The week's cache is not
    behind it**: with `cachingTheWeek` the window is read in any process, the extension included,
    because the week widget reads the cache and the extension's own taps change the rows
    (``recomputeTodayAndTheWeek()``)." And it gains a last paragraph: "Returns whether the cached
    week has news for the widget (``cacheWeek(_:today:)``)."

```swift
    @discardableResult
    private func republishHistory(cachingTheWeek: Bool = false) -> Bool {
        let draws = Self.role.drawsHistory
        guard draws || cachingTheWeek else { return false }

        // Before the window below, and not inside it: the bars can return early — a failed read,
        // or a series that did not move — while a run further back still did.
        if draws {
            republishStreak()
        }

        let instant = now()
        guard let start = Self.historyWindowStart(endingOn: instant, calendar: calendar),
              let logs = readLogs(from: start, to: Self.nextDayBoundary(after: instant, calendar: calendar))
        else { return false }

        // One roll-up for the card and the cache, so the widget's week and the card are one reading.
        let series = DaySummary.series(
            from: logs,
            days: Self.historyWindow,
            endingOn: instant,
            in: calendar
        )
        let weekHasNews = cachingTheWeek && cacheWeek(series, today: dayOrdinal(for: instant))

        guard draws else { return weekHasNews }

        // `Dictionary(grouping:by:)` keeps each day's rows in the fetch's newest-first order.
        withMutation(keyPath: \.historyLogs) {
            storedHistoryLogs = Dictionary(grouping: logs) { dayOrdinal(for: $0.timestamp) }
        }

        guard series != storedHistory else { return weekHasNews }
        withMutation(keyPath: \.history) { storedHistory = series }
        return weekHasNews
    }

    /// Writes `series` to ``Key/weekTotals`` if it differs from the cache, and answers whether the
    /// widget has news: the cache was missing or unreadable, or a day before `today` moved. Today's
    /// own change is not news here — the ``currentWater`` setter announces it.
    private func cacheWeek(_ series: [DaySummary], today: Int) -> Bool {
        let week = Dictionary(series.map { ($0.dayOrdinal, $0.total) }, uniquingKeysWith: { first, _ in first })
        let cached = Self.readWeekTotals(from: defaults)
        guard week != cached, let data = try? JSONEncoder().encode(week) else { return false }
        defaults.set(data, forKey: Key.weekTotals)

        guard let cached else { return true }
        return week.contains { day, total in day != today && cached[day] != total }
    }
```

  - In `init`, `recomputeToday()` and `republishHistory()` (`:585`–`:586`) become
    `recomputeTodayAndTheWeek()`; in `saveAndRecompute()`, the same two lines (`:1112`–`:1113`)
    become `recomputeTodayAndTheWeek()`. `refresh()` and `dayDidTurn()` keep `republishHistory()`.
  - `republishStreak()`'s DocC: "a widget tap must not run a month's fetch in a process that draws
    one number" becomes "… in a process that draws no streak".
  - Replace the `week(endingOn:calendar:)` seam with:

```swift
    /// The week the widget draws: ``DataManager/historyWindow`` days ending on the day of `instant`,
    /// oldest first — or `nil` when no week is cached.
    ///
    /// **The day of `instant` takes ``currentWater``**, so the bar for today and the vessel beside
    /// it are one figure, and the midnight entry — this snapshot ``rolledOver()``, asked at midnight
    /// — shifts the week by itself: yesterday from the cache, today the zero (rule `30-rollover`). A
    /// day the cache does not hold had nothing logged since its last write, and is zero.
    ///
    /// Walked by ``DaySummary/window(days:endingOn:in:)``, the walk History's card is summed over,
    /// so the two can never name different days. `nonisolated`, because the widget's view and a
    /// non-`@MainActor` suite read it and the app target would otherwise infer it main-actor
    /// (rule `43-concurrency`, #147).
    nonisolated func week(endingOn instant: Date, calendar: Calendar) -> [DaySummary]? {
        guard let weekTotals else { return nil }
        let today = DataManager.dayOrdinal(for: instant, in: calendar)
        return DaySummary.window(days: DataManager.historyWindow, endingOn: instant, in: calendar).map { day in
            DaySummary(
                dayOrdinal: day.ordinal,
                total: day.ordinal == today ? currentWater : weekTotals[day.ordinal] ?? 0,
                date: day.date
            )
        }
    }
```

  - Give `weekTotals` its DocC:

```swift
    /// The last ``DataManager/historyWindow`` days' totals by day ordinal, as `DataManager` last
    /// cached them (``DataManager/Key/weekTotals``), or `nil` when none is cached — which the week
    /// widget says in words. Read through ``week(endingOn:calendar:)``, never by a view directly.
    ///
    /// **Defaulted**, like ``serving``, so the memberwise calls elsewhere — most of them in the
    /// widget target, which the app scheme's tests never compile — build unchanged.
    var weekTotals: [Int: Int]? = nil
```

  - In `snapshot(defaults:calendar:now:)`, after `serving: usualServing(in: defaults)`, add
    `,` and `weekTotals: readWeekTotals(from: defaults)` with a comment: "// The week widget's
    bars; the day of `now` is laid over them from `water` (``WaterSnapshot/week(endingOn:calendar:)``)."
  - `WaterSnapshot`'s first DocC line becomes: "Today's hydration, and the week the week widget
    draws, as a plain value, for a process that must read the store but must never write to it."

- [ ] **Step 5: Run GREEN.** The same two suites, then the whole unit target. Expected: the two suites
  pass. **In the whole target, exactly the four P1 tests fail**, each reading `2` where it expects `1`
  — and nothing else. Any other failure: stop and report.

- [ ] **Step 6: Prove the green-first tests, and the isolation.** Each change below is made, the named
  test run and **seen to fail**, and the change reverted — logs kept:
  - In `readWeekTotals`, drop `week.count == historyWindow,` → `aWeekThisBuildDidNotWriteIsUnknown`
    fails for `sixDays` and `eightDays`. Restore.
  - Drop the `allSatisfy` line → it fails for `aNegativeDay` and `aDayOverTheCap`. Restore.
  - In `snapshot(...)`, add `defaults.removeObject(forKey: Key.weekTotals)` before the return →
    `readingACachedWeekLeavesTheStoreUntouched` fails. Restore.
  - Take `nonisolated` off `week(endingOn:calendar:)` and run a clean build of the test target: the
    build prints "main actor-isolated instance method 'week(endingOn:calendar:)' cannot be called from
    outside of the actor" (or its kin) at `theWeekEndsOnItsDay…`. **If no warning appears**, the
    suite is not a canary for it — record that, and no DocC or rule may call it one (#147). Restore.
    Then the same for `readWeekTotals(from:)`, read from `snapshot`.

- [ ] **Step 7: Rebase the four doorbell tests (P1, as the owner approved).** In each, record the
  count straight after construction and assert the difference — the meaning unchanged:

```swift
    @Test func mutationsRingTheWidgetDoorbellAndNoOpRefreshesDoNot() {
        withTempDefaults { defaults in
            var reloads = 0
            let manager = makeManager(defaults, onReload: { reloads += 1 }) { utc(2026, 8, 28) }
            // Construction on an empty suite rings once, for the first week the week widget can draw
            // (spec 2026-10-19-the-widget-stage §3.4 W6, `WeekCacheTests`); this test is about what
            // comes after it.
            let constructed = reloads

            manager.addWater(amount: 250)
            #expect(reloads - constructed == 1)

            manager.refresh()
            #expect(reloads - constructed == 1)
        }
    }
```

  and the same shape — `let constructed = reloads` after `makeManager`, every `reloads == 1` becoming
  `reloads - constructed == 1`, messages kept — in `choosingALanguageRingsTheWidgetDoorbellExactlyOnce`
  and `savingAGoalRingsTheWidgetDoorbellExactlyOnce`; and in `WaterLogTests.loggingRingsTheWidgetDoorbellExactlyOnce`,
  `let constructed = reloads` as the first line inside `withTempStore`'s closure. Run the whole unit
  target. Expected: `✔ Test run with N tests passed`, N = 654 + the new ones by the attribute grep.

- [ ] **Step 8: Stage.**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/WeekCacheTests.swift WaterBuddyTests/WaterSnapshotTests.swift WaterBuddyTests/DataManagerTests.swift WaterBuddyTests/WaterLogTests.swift
```

---

### Task 4: Stage 6c — the link to History

**Files:**
- Modify: `WaterBuddy/DataManager.swift` — `WidgetLink` after `WaterSnapshot`'s closing brace
- Modify: `WaterBuddy/RootTabView.swift` — `AppTab` (`:25`–`:75`), `RootTabView.body` (`:130`–`:197`)
- Modify: `WaterBuddyTests/RootTabViewTests.swift` — `AppTabTests`

**Interfaces:**
- Produces: `WidgetLink.history: URL?` (`nonisolated enum`, file scope); `AppTab.init?(link: URL)`.

- [ ] **Step 1: Prove the delivery first (spec §3.6).** In a fresh index copy only: add
  `.widgetURL(URL(string: "waterbuddy://history"))` to `HydrationView.body`, and to `RootTabView.body`
  `.onOpenURL { url in if url.absoluteString == "waterbuddy://history" { turn.turn(to: .history) } }`.
  No URL scheme is registered. Install on *WaterBuddy Probe 27*, finish the welcome with *Not now*,
  place the small Hydration widget with **A placement probe**, and tap the vessel, not the button —
  warm (the app in the background on Home), then cold (`terminate()` first). Expected: the app opens
  on History both times (`app.tabBars.buttons["History"].isSelected`, and a shot). **If it opens on
  Home or not at all, stop here and report to the owner** — a URL scheme is not added unasked
  (spec §3.6). Delete the copy.

- [ ] **Step 2: The seams — wrong on purpose.** After `WaterSnapshot`'s closing brace in
  `DataManager.swift`:

```swift
// MARK: - Links from a widget

nonisolated enum WidgetLink {
    static let history: URL? = nil
}
```

  and in `AppTab`, after `opening`:

```swift
    init?(link: URL) {
        self = .history
    }
```

- [ ] **Step 3: Write the failing tests.** In `AppTabTests`, after `theTabsAreDistinguishable`:

```swift
    /// The week widget's link opens History (spec 2026-10-19-the-widget-stage §3.6, rule `50-views`).
    @Test func theWeekWidgetsLinkOpensHistory() throws {
        let link = try #require(WidgetLink.history, "the week widget has no link to set")
        #expect(AppTab(link: link) == .history)
    }

    /// Only the link a widget sets turns a page — a whole-URL match.
    @Test(arguments: ["waterbuddy://home", "waterbuddy://", "waterbuddy://history/today", "https://history", "history"])
    func anyOtherLinkOpensNothing(_ link: String) throws {
        let url = try #require(URL(string: link))
        #expect(AppTab(link: url) == nil)
    }
```

- [ ] **Step 4: Run RED.** `-only-testing:WaterBuddyTests/AppTabTests`. Expected: both fail on their
  expectations — `#require` on the `nil` link, and every argument opening History.

- [ ] **Step 5: Implement.** Replace the `WidgetLink` seam with:

```swift
// MARK: - Links from a widget

/// The links a widget opens the app with — one spelling, read by the widget that sets it and by
/// the app that answers it (rule `50-views`). In this file because both processes compile it and
/// the shared set does not grow (rule `15-project`).
///
/// **No URL scheme is registered with iOS for it.** A widget's link reaches its own app without one
/// — proved on the simulator before this shipped (spec 2026-10-19-the-widget-stage §3.6) — and a
/// registered scheme would be an entrance any app or web page could open.
///
/// `URL?`, built without a force-unwrap: this codebase never traps (rule `75-diagnostics`).
nonisolated enum WidgetLink {

    /// The week widget's: History, which shows the same week in full.
    static let history = URL(string: "waterbuddy://history")
}
```

  and the `AppTab` seam with:

```swift
    /// The tab a widget's link names, or `nil` for any other URL — the app's one answer to
    /// ``WidgetLink`` (rule `50-views`). A whole-URL match, so nothing but the link a widget sets
    /// turns a page.
    init?(link: URL) {
        guard link == WidgetLink.history else { return nil }
        self = .history
    }
```

- [ ] **Step 6: Answer it.** In `RootTabView.body`, after `.preferredColorScheme(.dark)` and its
  comment:

```swift
        // A widget's link turns to its tab as the bar would — an entrance from outside, not a second
        // route (rule `50-views`). Only once setup is done: before it this view does not exist, and
        // the welcome stays. The bar's tick plays for it, as for a tap (plan P2).
        .onOpenURL { url in
            if let tab = AppTab(link: url) {
                turn.turn(to: tab)
            }
        }
```

  Add one paragraph to `RootTabView`'s DocC: "**A widget opens a page.** The week widget's tap
  arrives as ``WidgetLink/history``, and ``AppTab/init(link:)`` names the tab it turns to, as the
  bar would."

- [ ] **Step 7: Run GREEN.** `-only-testing:WaterBuddyTests/AppTabTests`, then a build of the app.
  Expected: every test passes, no new warning.

- [ ] **Step 8: Stage.** `git add WaterBuddy/DataManager.swift WaterBuddy/RootTabView.swift WaterBuddyTests/RootTabViewTests.swift`

---

### Task 5: Stage 6c — the week widget and its strings

**Files:**
- Create: `WaterBuddyWidget/WeekWidget.swift`
- Modify: `WaterBuddyWidget/WaterBuddyWidget.swift` — `HydrationView.cardInset`/`cardPadding`
  (`:117`, `:120`), `card` (`:144`–`:156`), `.sample` (`:97`–`:102`) and its two readers (`:69`, `:76`),
  `widgetPane`'s extension and `WidgetCardBackdrop` lose `private`
- Modify: `WaterBuddyWidget/WaterBuddyWidgetBundle.swift`
- Modify: `WaterBuddyWidget/Localizable.xcstrings`, `WaterBuddy/Localizable.xcstrings`
- Modify: `WaterBuddyTests/LocalizationTests.swift:78`–`:89` and a new test after
  `theWidgetAgreesWithTheAppOnEverySharedString`

**Interfaces:**
- Consumes: `WaterSnapshot.week(endingOn:calendar:)`, `WidgetLink.history`, `DaySummary.window`,
  `DaySummary.average/best/daysMet/reached`, `Bundle.localized(_:_:locale:)`,
  `Bundle.figure(_:_:locale:)`, `LiquidGlass.innerCornerRadius`.
- Produces: `View.widgetCard()`; `WaterSnapshot.sample(at: Date)`; `WeekWidget.kind == "WaterBuddyWeek"`.

- [ ] **Step 1: The strings' failing test.** In `LocalizationTests.swift`, `sharedKeys` gains, at its
  end:

```swift
    "Week",
    "Your last seven days against your goal.",
    "Open WaterBuddy to see your week.",
    "Last %1$d days",
    "Goal met",
    "%1$@ of %2$@",
    "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.",
```

  and after `theWidgetAgreesWithTheAppOnEverySharedString`:

```swift
    /// The week widget's three new strings, exactly, in both bundles and every shipped language
    /// (spec 2026-10-19-the-widget-stage §3.7).
    @Test(arguments: [
        ("en", "Week", "Week"),
        ("ru", "Week", "Неделя"),
        ("uz", "Week", "Hafta"),
        ("en", "Your last seven days against your goal.", "Your last seven days against your goal."),
        ("ru", "Your last seven days against your goal.", "Последние семь дней в сравнении с вашей целью."),
        ("uz", "Your last seven days against your goal.", "Oxirgi yetti kun — maqsadingizga nisbatan."),
        ("en", "Open WaterBuddy to see your week.", "Open WaterBuddy to see your week."),
        ("ru", "Open WaterBuddy to see your week.", "Откройте WaterBuddy, чтобы увидеть свою неделю."),
        ("uz", "Open WaterBuddy to see your week.", "Haftangizni ko‘rish uchun WaterBuddy’ni oching."),
    ])
    func theWeekWidgetSaysWhatTheSpecSays(language: String, key: String, expected: String) {
        for (name, bundle) in [("app", appBundle), ("widget", widgetBundle)] as [(String, Bundle?)] {
            #expect(value(bundle, language, key) == expected,
                    "\(name): \"\(key)\" in \(language) is not the spec's wording")
        }
    }
```

  Run RED: `-only-testing:WaterBuddyTests/LocalizationTests` (the `@Suite struct` at `:246`). Expected:
  the shared-key tests fail for the seven keys in the widget bundle and the three new ones in the app
  bundle; the new test fails for all nine rows.

- [ ] **Step 2: The catalogues — Xcode closed.** Re-run the Preconditions' `git diff --stat` first.
  Print the four entries to copy with a read-only script into the scratchpad:

```bash
S=<scratchpad>; cat > "$S/entry.py" <<'EOF'
import json, sys
path, *keys = sys.argv[1:]
d = json.load(open(path))["strings"]
for k in keys:
    print(json.dumps({k: d[k]}, ensure_ascii=False, indent=2)[2:-2] + ",")
EOF
python3 -I "$S/entry.py" WaterBuddy/Localizable.xcstrings '%1$@ of %2$@' 'Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.' 'Goal met' 'Last %1$d days'
```

  With **Edit**, insert into `WaterBuddyWidget/Localizable.xcstrings`, each entry at two-space
  indentation inside `"strings"`, at its code-point position: `%1$@ of %2$@` before `"%1$d ml"`;
  `Average…` and then `Goal met` before `"Hydration"`; `Last %1$d days` before
  `"Log ${amount} ml of water"`; `Open WaterBuddy to see your week.` before `"Time for water"`; `Week`
  and then `Your last seven days against your goal.` before `"of %1$d ml"`. The three new entries, in
  both catalogues, are:

```json
    "Open WaterBuddy to see your week.": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Open WaterBuddy to see your week." } },
        "ru": { "stringUnit": { "state": "translated", "value": "Откройте WaterBuddy, чтобы увидеть свою неделю." } },
        "uz": { "stringUnit": { "state": "translated", "value": "Haftangizni ko‘rish uchun WaterBuddy’ni oching." } }
      }
    },
    "Week": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Week" } },
        "ru": { "stringUnit": { "state": "translated", "value": "Неделя" } },
        "uz": { "stringUnit": { "state": "translated", "value": "Hafta" } }
      }
    },
    "Your last seven days against your goal.": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Your last seven days against your goal." } },
        "ru": { "stringUnit": { "state": "translated", "value": "Последние семь дней в сравнении с вашей целью." } },
        "uz": { "stringUnit": { "state": "translated", "value": "Oxirgi yetti kun — maqsadingizga nisbatan." } }
      }
    },
```

  — written out in the catalogue's own expanded form (one key per line, as its neighbours are), not
  the compact form shown. In `WaterBuddy/Localizable.xcstrings`: `Open WaterBuddy…` before
  `"Open iOS Settings"`, `Week` before `"Welcome to"`, `Your last seven days…` before `"Your weight"`.
  Then check both files mechanically — this must print `True True` twice:

```bash
python3 -I -c '
import json
for p in ("WaterBuddyWidget/Localizable.xcstrings", "WaterBuddy/Localizable.xcstrings"):
    raw = open(p, encoding="utf-8").read(); d = json.loads(raw); keys = list(d["strings"])
    print(json.dumps(d, ensure_ascii=False, indent=2) + "\n" == raw, keys == sorted(keys))
'
```

- [ ] **Step 3: The card, shared.** In `WaterBuddyWidget.swift`: `cardInset` and `cardPadding` lose
  `private` (the week widget reads them); `private extension View` holding `widgetPane` becomes
  `extension View`; `private struct WidgetCardBackdrop` becomes `struct WidgetCardBackdrop`. After
  `WidgetPane`, add:

```swift
// MARK: - The card

extension View {

    /// The Home Screen widgets' card: padded, on `.frosted`/`.raised` glass over its own blurred
    /// aurora (``WidgetCardBackdrop``) — one definition, so the Hydration widget and the week widget
    /// sit side by side as one family. The inset from the widget's edge is the caller's
    /// (``HydrationView/cardInset``).
    func widgetCard() -> some View {
        padding(HydrationView.cardPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .widgetPane(in: ContainerRelativeShape(), density: .frosted, elevation: .raised)
            // Under the pane, not over it: `.background` applied *after* `.widgetPane` lands
            // beneath the glass, which is where a backdrop belongs.
            .background {
                WidgetCardBackdrop().clipShape(ContainerRelativeShape())
            }
    }
}
```

  and `HydrationView.card` becomes:

```swift
    private var card: some View {
        content
            .widgetCard()
            .accessibilityElement(children: .contain)
    }
```

- [ ] **Step 4: A sample with a week.** Replace the `private extension WaterSnapshot` holding
  `.sample` with:

```swift
extension WaterSnapshot {

    /// What the widget gallery and the redacted placeholder show: past halfway today, so the water
    /// has a visible surface and the readout has two digits — and a week of five days met, so the
    /// week widget advertises itself with bars rather than with its empty state. Built for the days
    /// ending on `date`, because a cached week is keyed by day.
    static func sample(at date: Date) -> WaterSnapshot {
        let days = DaySummary.window(days: DataManager.historyWindow, endingOn: date, in: .waterBuddyDay)
        let totals = [2_100, 1_600, 2_000, 2_300, 1_200, 2_050, 1_150]   // oldest first; today last
        return WaterSnapshot(
            currentWater: 1_150,
            dailyGoal: DataManager.defaultDailyGoal,
            weekTotals: Dictionary(zip(days.map { $0.ordinal }, totals), uniquingKeysWith: { first, _ in first })
        )
    }
}
```

  `placeholder(in:)` becomes `let now = Date()` / `HydrationEntry(date: now, snapshot: .sample(at: now))`,
  and `getSnapshot`'s `.sample` becomes `.sample(at: now)`.

- [ ] **Step 5: The week widget.** Create `WaterBuddyWidget/WeekWidget.swift`:

```swift
//
//  WeekWidget.swift
//  WaterBuddyWidget
//
//  Created by Sardor Allaberganov on 19/10/26.
//

import SwiftUI
import WidgetKit

// MARK: - Widget

/// The last seven days against the goal, on the Home Screen — History's week card at widget size
/// (spec 2026-10-19-the-widget-stage §3.5).
///
/// **The Hydration widget's provider**, never a second one: the two draw one snapshot, turn over at
/// one midnight and reload together (rule `40-widget`). The week reaches this process as
/// ``WaterSnapshot/weekTotals`` — the cache `DataManager` rewrites wherever it recomputes today's
/// total — because the widget may never open SwiftData.
///
/// **No button.** A tap opens History, which shows the same week in full (``WidgetLink/history``).
struct WeekWidget: Widget {

    /// Permanent once shipped: iOS identifies every placed widget by its kind.
    static let kind = "WaterBuddyWeek"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HydrationProvider()) { entry in
            WeekView(entry: entry)
        }
        // Static literals naming no figure, as the Hydration widget's are: the gallery renders them
        // before any entry exists, and WidgetKit traps on a formatted one (rule `40-widget`).
        .configurationDisplayName("Week")
        .description("Your last seven days against your goal.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Entry view

/// Injects the snapshot's language, draws the card and sets the link.
///
/// It reads no string itself, for ``HydrationView``'s reason: the bundle this injects reaches only
/// the views below it.
struct WeekView: View {

    let entry: HydrationEntry

    var body: some View {
        WeekCard(
            week: entry.snapshot.week(endingOn: entry.date, calendar: .waterBuddyDay),
            goal: entry.snapshot.dailyGoal
        )
        .widgetCard()
        .padding(HydrationView.cardInset)
        .widgetURL(WidgetLink.history)
        .containerBackground(for: .widget) { WidgetAurora() }
        .environment(\.colorScheme, .dark)
        .environment(\.strings, entry.snapshot.language.bundle)
        .environment(\.locale, entry.snapshot.language.locale)
    }
}

// MARK: - The card

/// History's week card at widget size: the title, the days met, seven bars on their tracks against a
/// dashed goal line, and the narrow weekday letters.
///
/// **History's values, measured again here.** Cyan for a met day and white for the rest, white 0.10
/// tracks, the goal line 1.5 pt at white 0.62 — each pair measured on this widget's own rendered
/// pane (`docs/DESIGN.md`), because History's figures were read on History's panes (rule
/// `60-design-system`). A met day also stands at or above the line, so colour is never its only sign
/// (rule `65-accessibility`). The scale is the goal or the best day, whichever is larger, so a day
/// over the goal stands above the line rather than being clipped to it.
///
/// **One element for VoiceOver**: *Last 7 days*, valued with the sentence History's card speaks. The
/// bars, the letters and the figure draw nothing into the tree.
private struct WeekCard: View {

    /// Oldest first, today last — or `nil` when no week is cached yet.
    let week: [DaySummary]?
    let goal: Int

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// The title's size at default Dynamic Type — a real magnitude, never a unitless `1`
    /// (rule `40-widget`). The figure and the letters are ratios of it.
    @ScaledMetric(relativeTo: .callout) private var titleSize: CGFloat = 15

    /// Room between two days' tracks.
    private let barInset: CGFloat = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            header

            if let week {
                days(week)
            } else {
                Text("Open WaterBuddy to see your week.", bundle: strings)
                    .font(.system(size: titleSize * 0.9, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.88))
                    // Two lines before a word is cut: it says what the widget needs.
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .foregroundStyle(.white)
        // A widget cannot scroll or reflow, so past the first accessibility size the type holds still
        // rather than eating the bars — the medium column's cap (rule `65-accessibility`).
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(spoken)
    }

    private var title: String {
        strings.localized("Last %1$d days", DataManager.historyWindow, locale: locale)
    }

    /// History's card's sentence, or the empty state's line.
    private var spoken: String {
        guard let week else {
            return strings.localizedString(forKey: "Open WaterBuddy to see your week.", value: nil, table: nil)
        }
        return strings.localized(
            "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.",
            DaySummary.average(of: week),
            DaySummary.best(of: week),
            DaySummary.daysMet(in: week, goal: goal),
            week.count,
            locale: locale
        )
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: titleSize, weight: .semibold, design: .rounded))

            Spacer(minLength: 8)

            if let week {
                // The figure over its label, as History draws its three.
                VStack(alignment: .trailing, spacing: 0) {
                    Text(strings.figure("%1$@ of %2$@", DaySummary.daysMet(in: week, goal: goal), week.count, locale: locale))
                        .font(.system(size: titleSize, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text("Goal met", bundle: strings)
                        .font(.system(size: titleSize * 0.7, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }

    private func days(_ week: [DaySummary]) -> some View {
        let scale = max(goal, DaySummary.best(of: week), 1)
        let goalFraction = min(Double(goal) / Double(scale), 1)

        return VStack(spacing: 4) {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(week, id: \.dayOrdinal) { day in
                            bar(for: day, scale: scale, height: proxy.size.height)
                                .padding(.horizontal, barInset)
                        }
                    }

                    // One line across all seven at the goal's height, from the first track's edge to
                    // the last's.
                    GoalRule()
                        .stroke(.white.opacity(0.62), style: StrokeStyle(lineWidth: 1.5, dash: [4.5, 3]))
                        .frame(height: 1.5)
                        .padding(.horizontal, barInset)
                        .offset(y: -proxy.size.height * goalFraction + 0.75)
                }
            }

            HStack(spacing: 0) {
                ForEach(week, id: \.dayOrdinal) { day in
                    // From the environment's locale, which the root injects from the snapshot —
                    // never the device's (rule `70-privacy`). Today's is heavier, the mark History
                    // gives its shown day, without the ring: nothing here is selected.
                    Text(day.date, format: .dateTime.weekday(.narrow))
                        .font(.system(size: titleSize * 0.75, weight: day.dayOrdinal == week.last?.dayOrdinal ? .heavy : .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func bar(for day: DaySummary, scale: Int, height: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous)
        let met = day.reached(goal)
        let fraction = min(Double(day.total) / Double(scale), 1)

        return ZStack(alignment: .bottom) {
            shape
                .fill(.white.opacity(0.10))

            shape
                .fill(met ? Aurora.cyan : Color.white)
                // A day with nothing logged still draws a sliver, so it reads as an empty day rather
                // than a missing one — History's rule.
                .frame(height: max(height * fraction, day.total > 0 ? 4 : 2))
                // On a tinted Home Screen a met day takes iOS's accent; it still stands at the line.
                .widgetAccentable(met)
        }
        .frame(maxWidth: .infinity)
    }
}

/// A horizontal rule through the middle of its frame — the week's dashed goal line.
private struct GoalRule: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

// MARK: - Preview

#Preview("Week", as: .systemMedium) {
    WeekWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: .sample(at: .now))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
}
```

- [ ] **Step 6: List it.** In `WaterBuddyWidgetBundle.body`, after `WaterBuddyWidget()`:
  `WeekWidget()`.

- [ ] **Step 7: GREEN.** **A widget build**, then `-only-testing:WaterBuddyTests/LocalizationTests`. Expected: `** BUILD SUCCEEDED **` with no warning from `WaterBuddyWidget/`; every
  localisation test passes, the nine new rows included.

- [ ] **Step 8: Stage.**

```bash
git add WaterBuddyWidget/WeekWidget.swift WaterBuddyWidget/WaterBuddyWidget.swift WaterBuddyWidget/WaterBuddyWidgetBundle.swift WaterBuddyWidget/Localizable.xcstrings WaterBuddy/Localizable.xcstrings WaterBuddyTests/LocalizationTests.swift
```

---

### Task 6: Stage 6c — verification

- [ ] **Step 1: The gate** (above), on the staged tree. Expected as written there.
- [ ] **Step 2: The warning comparison** (above), for every scheme — `DataManager.swift` changed.
- [ ] **Step 3: The extension's fetch, measured.** A **throwaway** unit test in an index copy, never
  the tree, on the stock *iPhone 17*: an on-disk store in a temporary directory with 90 days of ten
  servings, then 200 reads each of today's rows and of the window's rows with their roll-up, each
  through a fresh `ModelContext`, timed with `ContinuousClock`, the medians printed. Its log is named
  by time and carries `uptime`. The figure — the added cost of one widget tap — goes into `HISTORY.md`,
  and the owner sees it before 6c is committed (spec §7).
- [ ] **Step 4: The simulator pass** (spec §8.3), on *WaterBuddy Probe 27*, with the index copy
  installed and the welcome finished with *Not now*. With **A placement probe**:
  - Before any pour: the week widget's empty state is not shown — the app's launch wrote the first
    week. Then, in a fresh copy whose app is never launched, place the week widget first: *Open
    WaterBuddy to see your week.*; launch the app; the widget turns to bars.
  - Pours on Home and a past-day serving added in History; the widget's bars agree with History's card,
    day by day; the gallery shows the sample week.
  - A tap on the week widget opens History, warm and cold.
  - Light, dark; Russian and Uzbek (`-AppleLanguages`, and the in-app picker, which the widget
    follows).
  - The colour pairs — met bar, unmet bar, track, goal line, letters, figure — measured off a shot of
    the widget's pane at its worst frame, the figures into `docs/DESIGN.md`. A pair under its floor
    stops the stage and goes to the owner.

---

### Task 7: Records, and staging for the owner

- [ ] **Step 1:** `HISTORY.md` checkpoint `## [2026-10-19] — Roadmap item 1.3.1: the white button,
  StandBy and the week` (or the date it is run): the three stages, the rulings (D1–D4, P1, P2), the
  gates and warning comparisons as their logs show them, the RED runs, the measurement, every shot
  looked at.
- [ ] **Step 2:** `docs/AI_CONTEXT.md`: a *Current state* block; rows for `WeekWidget.swift`,
  `WeekCacheTests.swift` and every changed Swift file, re-counted with `wc -l`; the `@Test` counts by
  the attribute grep; known issues — what only a device shows (spec §8.3: StandBy by day and at night,
  locked with *Lock Screen Widgets* off, the week at midnight and the morning after, VoiceOver, a narrow
  iPhone, a tinted Home Screen if the probe could not reach it), and the time-zone lag and clock-back
  edge (spec §3.4).
- [ ] **Step 3:** `docs/ROADMAP.md`: 1.3.1's entry, dated; the device checks join 1.2.7's sweep.
  `docs/STATE.md`: `Key.weekTotals` in the key table — writer, reader, absence, validation.
  `docs/WIDGET.md`: the fourth widget, the snapshot's field and function, the bare layout, the quiet
  form, the link. `docs/DESIGN.md`: the measured pairs. `CLAUDE.md` is `/doc_sync`'s: the target table
  (three `StaticConfiguration`s), "ten keys" → eleven, the warning baseline's trail.
- [ ] **Step 4:** Stage every file by name:

```bash
git add HISTORY.md docs/AI_CONTEXT.md docs/ROADMAP.md docs/STATE.md docs/WIDGET.md docs/DESIGN.md docs/superpowers/plans/2026-10-19-the-widget-stage.md
git diff --cached --name-status
git diff --name-status
```

- [ ] **Step 5:** A fresh read-only reviewer on the whole staged change before the closing report; its
  findings checked at their source. `/doc_sync` is the owner's. Stop — the owner runs `/commit`.
