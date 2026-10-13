# The Premium Redesign, Stage 3b (Navigation and Motion) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent ("Planning, test authorship, implementation and review
> all happen in the main loop"). Steps use checkbox (`- [ ]`) syntax for tracking. **No step commits
> and no step stages:** stage 3 is still in the index, uncommitted, and everything this plan writes
> stays unstaged beside it until the owner has run `/commit` for stage 3.

> **Executed on 2026-10-11 and 12, and built over the same day** (added by the fifty-fourth pass of
> `docs/AI_CONTEXT.md`; the plan below is kept as written). The *Architecture* and *Tech Stack*
> lines describe the first build. The second pass replaced the `TabView` container and kept
> screens with one pager, and `Arrival` now settles only the page the app opens on, its flag set
> from a task when the page is built and no longer from a tab being shown and left:
> `docs/superpowers/plans/2026-10-12-premium-redesign-stage-3b-motion.md`.

**Goal:** Every tab opens with its title in one place, the bar is Apple's own on iOS 26 and later,
a screen's content settles in when its tab is shown, and a touch is answered with a small motion
and, where it fits, a haptic.

**Architecture:** `RootTabView` chooses between two containers on the system alone: a `TabView` of
three `Tab`s on iOS 26 and later, and today's `ZStack` with the app's own bar below. One
`ScreenHeader` view and one `ScreenMetrics` value give the three screens a shared header. `Arrival`
is a pure value plus one modifier that each screen drives from its own appear and disappear. Two
rungs join `Haptics`. Nothing is stored and no model code changes.

**Tech Stack:** Swift (language mode 5; the app target defaults to main-actor isolation), SwiftUI
(iOS 17 floor; `TabView`'s `Tab` inside `#available(iOS 26.0, *)`), swift-testing, XCTest (the UI
suite and one throwaway probe), Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-11-navigation-and-motion-design.md`, with
`docs/superpowers/specs/2026-10-09-premium-redesign-design.md` behind it. Measurements:
`.superpowers/sdd/2026-10-11-navigation-and-motion/progress.md`.

**Authority for running it:** the owner's "go" of 2026-10-11 and the 2026-10-09 ruling "build the
remaining stages straight through … stopping only at each stage's `/commit` or a real design
decision". The decisions this stage takes for the owner are the spec's §10; the plan is executed
without a second approval and stops at its own `/commit`.

## Global Constraints

- **Floors stay iOS 17.0 and watchOS 26.0.** One new `#available(iOS 26.0, *)`, in `RootTabView`.
  `Tab` and `tabBarMinimizeBehavior` are named nowhere else.
- **Nothing is stored and no model code changes.** `DataManager.swift` is not edited. No new
  `DataManager.Key`. No file joins a shared set and `project.pbxproj` is not edited: the two new
  files sit in `WaterBuddy/`, whose synchronized root group makes them the app's alone.
- **One writer.** A view owns presentation state only (rule `50-views`).
- **Every label the UI tests query today is kept**: the three tab buttons by `AppTab.title(in:)`,
  *Today's hydration*, *Add a serving*, *Undo*, the day buttons, the sliders.
- **A screen keeps what it says to VoiceOver**: one heading, its value, the header trait.
- **A haptic is fired through `Haptics`**, from `.sensoryFeedback`, off a counter bumped by the
  user's own action or the value under the finger — never off a model value.
- **No colour literal, no `glassEffect` at a call site**, no bare `withAnimation`, no bare `print`,
  no unpinned `Date()` in logic. Volumes are `Int`.
- **New statics a test off the main actor reads are `nonisolated`**; a new file-scope value type is
  `nonisolated` (rule `43-concurrency`).
- **Tests first.** Write the test, run it, see it fail for the predicted reason, then implement.
  Never narrow an assertion to make it pass. Test names are not reused across suites.
- **Edits with `Edit`/`Write` only.** A script reads; it never writes into the repository.
  `Bash(sed -i:*)` and `Bash(xcrun simctl erase:*)` are denied; a refused call is a stop.
- Every `xcodebuild` in the foreground, one call at a time, `-parallel-testing-enabled NO`.
  **Never `xcrun simctl shutdown all`**; shut a simulator down by its own id. **Reuse the nine
  *WaterBuddy …* simulators**; make none.
- **Probes run on Probe devices; the gate's UI suite runs on Gate devices.**
- A run expected to fail carries `-collect-test-diagnostics never` (known issue #101). The gate's
  commands do not.
- **Never touch or stage** what was unstaged before this stage: `.claude/settings.json`, the two
  watch schemes, `WaterBuddy/AppShortcuts.xcstrings`, the two watch catalogues, `Screenshots/census/`,
  and stage 3's unstaged wording in `.claude/rules/50-views.md` and `65-accessibility.md`.

## Review Focus

Conditions the spec implies that the unit tests cannot drive, most likely to bite first, each with
the check that owns it:

1. **A screen left hidden.** A tab's content is drawn at zero opacity until it arrives; if the
   appear that sets the flag does not fire after a disappear, the screen comes back empty. →
   Task 3's `testAScreenComesBackWholeAfterItsTabIsLeft`, on both bars.
2. **State that used to die with the view.** Apple's bar keeps a screen alive: an *Undo* offer, or
   a past day picked in History, would still be there on return. → the kept
   `testAnUndoOfferDoesNotOutliveItsScreen` and Task 4's `testHistoryReturnsToTodayWhenItsTabIsLeft`.
3. **A caption over something bright.** Content scrolls under Apple's bar: a white week bar, a
   serving's amount, a slider's thumb. → Task 6 measures each caption over each of them, on iOS
   27.0 and 26.5.
4. **The largest text size in Russian on a 375 pt phone.** The title's line now has a floor of
   44 pt and the date sits under it at `.headline`. → Task 6 renders it; the kept
   `testTheTitleKeepsItsSizeBesideTheStreak` and `testAPastDaysHeadingKeepsItsSizeAtTheLargestTextSize`
   run in the gate.
5. **A tap straight after a tab change.** Content rises 10 pt for 0.4 s; a test, or a thumb, that
   taps at once must still land. → the 43 existing UI tests, every one of which taps after a
   change of tab, on both bars.

---

## File structure

| File | Change | Responsibility |
|---|---|---|
| `WaterBuddy/ScreenHeader.swift` | create | `ScreenMetrics` (margin, top inset, the title line's height) and `ScreenHeader`, the header every tab opens with |
| `WaterBuddy/Arrival.swift` | create | `Arrival` (the numbers and `delay(order:)`) and `View.arrives(_:order:)` |
| `WaterBuddy/Haptics.swift` | modify | `select`, `remove`, `removeIntensity` |
| `WaterBuddy/RootTabView.swift` | modify | the two containers; the app's own bar's captions on one line; the tab tick |
| `WaterBuddy/HomeView.swift` | modify | `ScreenHeader`; the shared metrics; arrival; the offer ends on disappear; the three touches |
| `WaterBuddy/HistoryView.swift` | modify | `ScreenHeader`; the shared margin; arrival and growing bars; today on disappear; the ticks |
| `WaterBuddy/SettingsView.swift` | modify | `ScreenHeader`; the shared metrics; arrival. Nothing else — the screen is stage 4's |
| `WaterBuddyTests/ScreenHeaderTests.swift` | create | `ScreenMetricsTests` |
| `WaterBuddyTests/ArrivalTests.swift` | create | `ArrivalTests` |
| `WaterBuddyTests/CelebrationTests.swift` | modify | one test and one extended test in `HapticLadderTests` |
| `WaterBuddyUITests/GoalSetupUITests.swift` | modify | five new tests |
| `WaterBuddyUITests/ZZMotionProbe.swift` | create, then **delete** | Task 6's throwaway captures |
| `.claude/rules/15-project.md`, `50-views.md`, `60-design-system.md`, `65-accessibility.md`, `85-testing.md` | modify, **left unstaged** | Task 7's wording, for the owner's yes |
| `HISTORY.md`, `tasks/lessons.md`, `docs/` | modify | Task 9 |

Shell variables used below — **each `Bash` call is a fresh shell**, so set them in every command:

```bash
SP=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/4ac349e8-123a-4e1d-8814-ef9b60971fea/scratchpad
DD="$SP/dd-stage3b"
```

One unit suite (replace `SUITE`):

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:WaterBuddyTests/SUITE -parallel-testing-enabled NO \
  -collect-test-diagnostics never -derivedDataPath "$DD" > "$SP/out/SUITE.log" 2>&1
grep -E '✔|✘|error:|Test run with|TEST (SUCCEEDED|FAILED)' "$SP/out/SUITE.log" | tail -12
```

One UI test while developing (replace `NAME`, and the destination for the other bar):

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Probe 27' \
  -only-testing:WaterBuddyUITests/GoalSetupUITests/NAME -parallel-testing-enabled NO \
  -collect-test-diagnostics never -derivedDataPath "$DD" > "$SP/out/NAME.log" 2>&1
grep -E 'error:|passed|failed|Executed|TEST (SUCCEEDED|FAILED)' "$SP/out/NAME.log" | tail -8
```

The other two destinations: `OS=26.5,name=WaterBuddy Probe 26.5` (Apple's bar) and
`OS=18.6,name=WaterBuddy Fallback 18.6` (the app's own).

---

### Task 0: The ledger and the baseline

**Files:** `.superpowers/sdd/2026-10-11-navigation-and-motion/progress.md` (git-ignored).

- [ ] **Step 1: Add the stage's section to the ledger**

Append a section *Stage 3b — execution* holding: the plan's path; the two shell variables; "runs
expected to fail carry `-collect-test-diagnostics never`"; "the UI target runs as two complementary
invocations per system"; "unstaged throughout — stage 3 is in the index"; and one line per task as
it finishes.

- [ ] **Step 2: Record the tree the stage starts from**

```bash
git status --short > "$SP/out/status-before.txt"; git diff --stat | tail -1; git diff --cached --stat | tail -1
```

- [ ] **Step 3: The warning baseline, from a clean build of the index**

The scratch export `"$SP/look"` is the index with three scratch edits; export it again, clean:

```bash
git checkout-index -a --prefix="$SP/base/"
```

Then, one call each, into one build folder that only the first starts empty:

```bash
cd "$SP/base" && xcodebuild build-for-testing -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$SP/dd-base" > "$SP/out/base-app.log" 2>&1
cd "$SP/base" && xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$SP/dd-base" > "$SP/out/base-widget.log" 2>&1
```

The watch schemes compile none of the files this stage touches except through the app target,
which `base-app.log` covers; they are built in the gate and compared there with HEAD's two known
warnings. Keep the two logs: Task 8 compares against them.

---

### Task 1: One header

**Files:**
- Create: `WaterBuddy/ScreenHeader.swift`, `WaterBuddyTests/ScreenHeaderTests.swift`
- Modify: `WaterBuddy/HomeView.swift` (`columnPadding`, `header`), `WaterBuddy/HistoryView.swift`
  (`margin`, `body`'s header row, `header`), `WaterBuddy/SettingsView.swift` (`body`'s padding,
  `header`), `WaterBuddyUITests/GoalSetupUITests.swift`

**Interfaces:**
- Produces: `ScreenMetrics.margin: CGFloat` (24), `ScreenMetrics.topInset: CGFloat` (16),
  `ScreenMetrics.titleLine: CGFloat` (44), `ScreenMetrics.slot(of:across:) -> CGFloat`, all
  `nonisolated static`; `ScreenHeader(title:detail:accessory:)`, three `@ViewBuilder` closures.

- [ ] **Step 1: Write the failing unit tests**

`WaterBuddyTests/ScreenHeaderTests.swift`:

```swift
//
//  ScreenHeaderTests.swift
//  WaterBuddyTests
//

import SwiftUI
import Testing
@testable import WaterBuddy

/// The numbers the three tabs share. Not `@MainActor`: everything read here is `nonisolated` on
/// purpose (rule `43-concurrency`), and the suite is the canary that keeps it so.
struct ScreenMetricsTests {

    /// History's week card gives each of its seven days one slot across the screen, inside the
    /// margin. On the narrowest supported iPhone that slot must still be a tap target.
    @Test func sevenDaysClearTheTapFloorOnTheNarrowestPhone() {
        #expect(ScreenMetrics.slot(of: DataManager.historyWindow, across: 375) >= 44)
    }

    /// One margin and one top inset, read by every screen — which is what puts a title in one
    /// place on all of them.
    @Test func everyScreenReadsTheSameNumbers() {
        #expect(HomeView.columnPadding.leading == ScreenMetrics.margin)
        #expect(HomeView.columnPadding.trailing == ScreenMetrics.margin)
        #expect(HomeView.columnPadding.top == ScreenMetrics.topInset)
        #expect(HistoryView.margin == ScreenMetrics.margin)
    }

    /// The title's line is as tall as the tallest thing that may share it, so a 36 pt chip and a
    /// 44 pt button do not centre the title at two heights.
    @Test func theTitlesLineIsAsTallAsATapTarget() {
        #expect(ScreenMetrics.titleLine >= 44)
    }

    @Test func aSlotOfNothingIsNotADivisionByZero() {
        #expect(ScreenMetrics.slot(of: 0, across: 375).isFinite)
    }
}
```

- [ ] **Step 2: Run it and see it fail**

Run the unit command with `SUITE` = `ScreenMetricsTests`.
Expected: the build fails — `cannot find 'ScreenMetrics' in scope`.

- [ ] **Step 3: Write the failing UI test**

In `GoalSetupUITests`, after `testHomeIsHeadedTodayOnce`:

```swift
    /// The title stands in one place on every tab.
    ///
    /// Each screen laid its own header out, in its own stage, and nothing compared them: *Today*
    /// sat 4 pt further left and 1.3 pt lower on Home than on History, and during the change of
    /// tab both were on screen at once. A frame read off the tree, never arithmetic over paddings
    /// (`tasks/lessons.md`, 2026-10-11).
    @MainActor
    func testTheTitleHoldsItsPlaceOnEveryTab() throws {
        let app = launchedOnHome()

        let home = app.staticTexts["Today"].firstMatch.frame

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        let history = app.staticTexts["Today"].firstMatch.frame

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        // The app's own bar draws a caption that also reads *Settings*; the heading is the higher.
        let settings = app.staticTexts.matching(identifier: "Settings").allElementsBoundByIndex
            .map(\.frame)
            .min { $0.minY < $1.minY } ?? .zero

        XCTAssertEqual(home.minX, history.minX, accuracy: 0.5, "Today moves sideways between Home and History")
        XCTAssertEqual(home.minY, history.minY, accuracy: 0.5, "Today moves up or down between Home and History")
        XCTAssertEqual(home.minX, settings.minX, accuracy: 0.5, "Settings' title starts somewhere else")
        XCTAssertEqual(home.minY, settings.minY, accuracy: 0.5, "Settings' title stands at another height")
    }
```

- [ ] **Step 4: Run it and see it fail**

Run the UI command with `NAME` = `testTheTitleHoldsItsPlaceOnEveryTab` on *WaterBuddy Probe 27* —
after Step 5 makes the target build; until then it fails with the unit suite.
Expected once it builds without Step 6: `Today moves sideways … (24.0) is not equal to (28.0)`.

- [ ] **Step 5: Write `ScreenHeader.swift`**

```swift
//
//  ScreenHeader.swift
//  WaterBuddy
//

import SwiftUI

/// The numbers every tab's screen shares.
///
/// At file scope and `nonisolated`, so `ScreenMetricsTests` reads them off the main actor (rule
/// `43-concurrency`). They are here, beside the header they place, because the header is the
/// thing that has to land in one spot on three screens: each screen used to carry its own, and
/// *Today* stood 4 pt further left and 1.3 pt lower on Home than on History.
nonisolated enum ScreenMetrics {

    /// The side margin. History's week card budgets its day buttons against it:
    /// `(375 − 2 × 24) / 7 = 46.7` pt on the narrowest supported iPhone, over the 44 pt floor
    /// (`sevenDaysClearTheTapFloorOnTheNarrowestPhone`).
    static let margin: CGFloat = 24

    /// From the top of the safe area to the top of the title's line.
    static let topInset: CGFloat = 16

    /// The least the title's line may be. Its accessory is a 36 pt chip on one screen, a 44 pt
    /// button on another and absent on a third; with no floor the title is centred against each
    /// and stands at three heights.
    static let titleLine: CGFloat = 44

    /// The width of one of `count` equal slots across a screen `width` wide, inside the margin.
    static func slot(of count: Int, across width: CGFloat) -> CGFloat {
        (width - 2 * margin) / CGFloat(max(count, 1))
    }
}

/// The header every tab opens with: the title, a line under it, and whatever shares the title's
/// line.
///
/// **The title comes first.** Home drew its date above the title and History its total below, so
/// one word had two places. A line under the title is the one arrangement both can share without
/// either carrying an empty line.
///
/// The screen supplies the three parts and what they say to VoiceOver — each is one heading with
/// a value of its own (rule `65-accessibility`). The header owns only what must be the same
/// everywhere: the sizes, the line's height, the halo for text on the aurora.
struct ScreenHeader<Title: View, Detail: View, Accessory: View>: View {

    @ViewBuilder var title: Title
    @ViewBuilder var detail: Detail
    @ViewBuilder var accessory: Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 12) {
                title
                    .font(.largeTitle.weight(.bold))
                    // First call on the line's width, and rigid in height: it may shrink for a
                    // long word at a large text size, and for nothing else
                    // (`testTheTitleKeepsItsSizeBesideTheStreak`).
                    .layoutPriority(1)
                    .fixedSize(horizontal: false, vertical: true)
                    // On the texts and not on the stack: an accessory is a pane, and a shadow on
                    // the stack would be cast by it as well.
                    .legibleOnBackdrop()

                Spacer(minLength: 0)

                accessory
            }
            .frame(minHeight: ScreenMetrics.titleLine)

            detail
                .font(.headline)
                .legibleOnBackdrop()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(.white)
    }
}
```

- [ ] **Step 6: Put the three screens on it**

`HomeView.swift` — the padding:

```swift
    nonisolated static let columnPadding = EdgeInsets(
        top: ScreenMetrics.topInset,
        leading: ScreenMetrics.margin,
        bottom: 20,
        trailing: ScreenMetrics.margin
    )
```

`HomeView.swift` — `header` becomes:

```swift
    private var header: some View {
        ScreenHeader {
            Text("Today", bundle: strings)
                .accessibilityValue(spokenDate)
                .accessibilityAddTraits(.isHeader)
        } detail: {
            if let today = manager.history.last?.date {
                Text(today, format: .dateTime.weekday(.wide).day().month(.wide))
                    // Further than its neighbours may shrink: at 0.6 the date was still cut
                    // short — *Воскресенье, 11 октя…* — on a 375 pt phone at the largest text
                    // size, and half of that size is still larger than the ordinary one.
                    .minimumScaleFactor(0.5)
                    .accessibilityHidden(true)
            }
        } accessory: {
            streakChip
        }
    }
```

Its DocC keeps its first two paragraphs and loses the third (the date no longer shares a column
with the chip); add: "The date stands under the title, as History's total does, so *Today* is in
one place on both (`ScreenHeader`)."

`HistoryView.swift` — the margin, with its DocC's arithmetic brought up to date:

```swift
    /// The screen's side margin — the one every tab shares. The week card's seven day buttons
    /// are budgeted against it: `(375 − 2 × 24) / 7 = 46.7` pt on the narrowest supported iPhone,
    /// over the 44-pt floor.
    nonisolated static let margin = ScreenMetrics.margin
```

`HistoryView.swift` — in `body`, the header row's inset; the list keeps its one point:

```swift
                header
                    // The shared inset, less the point the list itself stands off the safe area.
                    .historyRow(top: ScreenMetrics.topInset - 1, bottom: 10)
```

`HistoryView.swift` — `header` becomes:

```swift
    private var header: some View {
        ScreenHeader {
            dayTitle
        } detail: {
            // Both figures come off the model. The list adds up to this number, and a `body`
            // that computed it for itself is how the two start disagreeing
            // (rule `10-architecture`). Grouped by the app's locale, like Home's.
            Text(strings.figure("%1$@ of %2$@ ml", shownTotal, manager.dailyGoal, locale: locale))
                .fontDesign(.rounded)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(shownTotal)))
                .accessibilityHidden(true)
        } accessory: {
            // The *only* route to the serving sheet. The gear that once sat here became the
            // bar's third tab (`testSettingsIsReachableFromHomeAsATab`).
            addButton
        }
        .padding(.horizontal, Self.margin)
        .animation(.smooth(duration: 0.5), value: shownTotal)
    }
```

`dayTitle` loses nothing: the font it inherited from the old header it now inherits from
`ScreenHeader`. Every other `28` in the file that is a card's or a row's side margin already reads
`Self.margin` or `HistoryView.margin`; the sheet's own `.padding(.horizontal, 28)` is the sheet's
and stays.

`SettingsView.swift` — `body`'s column:

```swift
                    .padding(.horizontal, ScreenMetrics.margin)
                    .padding(.top, ScreenMetrics.topInset)
```

`SettingsView.swift` — `header` becomes:

```swift
    private var header: some View {
        ScreenHeader {
            Text("Settings", bundle: strings)
                .accessibilityAddTraits(.isHeader)
        } detail: {
            EmptyView()
        } accessory: {
            EmptyView()
        }
    }
```

- [ ] **Step 7: Run the unit suite and the UI test, green**

`ScreenMetricsTests`: `✔ Test run with 4 tests passed`. Then `testTheTitleHoldsItsPlaceOnEveryTab`
on *WaterBuddy Probe 27* and *WaterBuddy Fallback 18.6*: passed on both. Then the three header
tests that already exist, on *WaterBuddy Probe 27*: `testHomeIsHeadedTodayOnce`,
`testTheTitleKeepsItsSizeBesideTheStreak`, `testAPastDaysHeadingKeepsItsSizeAtTheLargestTextSize`.

- [ ] **Step 8: See the UI test fail for the defect, once**

With the build green, set `ScreenMetrics.margin` to `28` in the tree for one run of
`testTheTitleHoldsItsPlaceOnEveryTab`: it still passes — every screen follows. Restore it. Then
change `HomeView.columnPadding`'s `leading` to the literal `28` for one run.
Expected: `Today moves sideways between Home and History`. Restore it and confirm with
`git diff --stat -- WaterBuddy/HomeView.swift` that only this task's changes remain.

---

### Task 2: Two haptics

**Files:** Modify `WaterBuddy/Haptics.swift`, `WaterBuddyTests/CelebrationTests.swift`.

**Interfaces:**
- Produces: `Haptics.removeIntensity: Double`, `Haptics.select: SensoryFeedback`,
  `Haptics.remove: SensoryFeedback`.

- [ ] **Step 1: Write the failing tests**

In `HapticLadderTests`, replace the loop's array in `everyRungIsWithinTheLegalRange` with one that
names the new rung, and add a test:

```swift
    @Test func everyRungIsWithinTheLegalRange() {
        for intensity in [Haptics.confirmIntensity, Haptics.pourIntensity, Haptics.goalIntensity, Haptics.removeIntensity] {
            #expect(intensity > 0 && intensity <= 1, "an impact intensity outside 0...1 is ignored")
        }
    }

    /// Something taken away is felt, and never more firmly than something confirmed: a delete
    /// that thumped like a pour would read as the app applauding it.
    @Test func takingAwayIsNoFirmerThanAConfirmation() {
        #expect(Haptics.removeIntensity <= Haptics.confirmIntensity)
    }
```

- [ ] **Step 2: Run and see it fail** — `SUITE` = `HapticLadderTests`.
Expected: the build fails — `type 'Haptics' has no member 'removeIntensity'`.

- [ ] **Step 3: Implement**

In `Haptics`, after `goalIntensity` and after `goalReached`:

```swift
    /// Something taken away — a serving swiped off the list. `confirm`'s intensity on a lighter
    /// weight: felt, and never as firm as a thing confirmed.
    static let removeIntensity: Double = confirmIntensity
```

```swift
    /// A choice among peers: a tab, a day, a vessel, a step of a slider. The system's own
    /// selection tick, which is what its pickers play.
    static var select: SensoryFeedback { .selection }

    static var remove: SensoryFeedback { .impact(weight: .light, intensity: removeIntensity) }
```

The type's DocC says "The app's feedback ladder"; its first test's DocC says "Three rungs". Change
both to name five: three impacts of rising weight, a lighter one for a removal, and the selection
tick.

- [ ] **Step 4: Run, green** — `✔ Test run with 4 tests passed` for `HapticLadderTests`.

---

### Task 3: A screen arriving

**Files:**
- Create: `WaterBuddy/Arrival.swift`, `WaterBuddyTests/ArrivalTests.swift`
- Modify: `WaterBuddy/HomeView.swift`, `WaterBuddy/HistoryView.swift`,
  `WaterBuddy/SettingsView.swift`, `WaterBuddyUITests/GoalSetupUITests.swift`

**Interfaces:**
- Produces: `Arrival.rise`, `.duration`, `.stagger`, `.longestDelay`, `Arrival.delay(order:)`;
  `View.arrives(_ arrived: Bool, order: Int)`.

- [ ] **Step 1: Write the failing unit tests**

`WaterBuddyTests/ArrivalTests.swift`:

```swift
//
//  ArrivalTests.swift
//  WaterBuddyTests
//

import Foundation
import Testing
@testable import WaterBuddy

/// How a screen's content settles when its tab is shown, as numbers. Not `@MainActor`: `Arrival`
/// is `nonisolated` on purpose (rule `43-concurrency`).
struct ArrivalTests {

    @Test func theFirstSectionDoesNotWait() {
        #expect(Arrival.delay(order: 0) == 0)
    }

    @Test func eachSectionFollowsTheOneAboveIt() {
        #expect(Arrival.delay(order: 1) > Arrival.delay(order: 0))
        #expect(Arrival.delay(order: 2) > Arrival.delay(order: 1))
    }

    /// A day of twenty servings must not keep its last row waiting a second: past a few sections
    /// the delay stops growing, and the whole arrival is over in well under a second.
    @Test func aLongScreenIsNotKeptWaiting() {
        #expect(Arrival.delay(order: 500) == Arrival.longestDelay)
        #expect(Arrival.longestDelay + Arrival.duration <= 0.7)
    }

    @Test func anOrderBelowZeroIsTheFirst() {
        #expect(Arrival.delay(order: -3) == 0)
    }

    /// Enough to be seen as settling, never enough to be a slide across the screen.
    @Test func theRiseIsAFewPoints() {
        #expect(Arrival.rise > 0 && Arrival.rise <= 16)
    }
}
```

- [ ] **Step 2: Run and see it fail** — `SUITE` = `ArrivalTests`.
Expected: the build fails — `cannot find 'Arrival' in scope`.

- [ ] **Step 3: Write the failing UI test**

In `GoalSetupUITests`, after `testTheTabBarSwitchesBetweenHomeAndHistory`:

```swift
    /// A screen whose tab was left comes back whole.
    ///
    /// A screen's content is drawn at no opacity until it has arrived, and it arrives when the
    /// screen appears. If an appear ever failed to follow a disappear, the screen would come back
    /// with a title and nothing under it — present in the tree, and impossible to touch.
    @MainActor
    func testAScreenComesBackWholeAfterItsTabIsLeft() throws {
        let app = launchedOnHome()
        let glass = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()
        let goal = app.sliders["Daily water goal"]
        XCTAssertTrue(goal.waitForExistence(timeout: 5))
        XCTAssertTrue(goal.isHittable, "Settings came back without its first card")

        app.buttons["Home"].tap()
        XCTAssertTrue(glass.waitForExistence(timeout: 5))
        XCTAssertTrue(glass.isHittable, "Home came back without its quick-add row")
        XCTAssertTrue(app.otherElements["Today's hydration"].isHittable, "Home came back without its vessel")

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add a serving"].isHittable, "History came back without its header's button")
        app.buttons["Home"].tap()
        glass.tap()
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 5), "a pour made after two changes of tab did not land")
    }
```

It passes before the code exists: nothing is hidden yet. It is the pin for Review Focus 1, and
Step 7 is where it is seen failing.

- [ ] **Step 4: Write `Arrival.swift`**

```swift
//
//  Arrival.swift
//  WaterBuddy
//

import SwiftUI

/// How a screen's content settles into place when its tab is shown.
///
/// On iOS 26 the bar is Apple's and the page changes in one frame, so the motion is the page's
/// own: everything under the title rises a few points and fades in, each section a moment after
/// the one above. **The title does not move** — it stands in one place on every tab
/// (``ScreenHeader``), and reads as holding still while the screen changes under it.
///
/// A value at file scope and `nonisolated`, so `ArrivalTests` reads it off the main actor.
nonisolated enum Arrival {

    /// How far a section rises, in points.
    static let rise: CGFloat = 10

    /// How long one section takes.
    static let duration: Double = 0.4

    /// How long each section waits for the one above it.
    static let stagger: Double = 0.04

    /// The longest any section waits, however far down the screen it is.
    static let longestDelay: Double = 0.2

    /// How long the section at `order` waits before it starts; `0` is the first under the title.
    static func delay(order: Int) -> Double {
        min(Double(max(order, 0)) * stagger, longestDelay)
    }
}

private struct ArrivalModifier: ViewModifier {

    let arrived: Bool
    let order: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(arrived ? 1 : 0)
            // **Under Reduce Motion it is the fade alone.** It runs once per tap, which the rule
            // exempts — but it is travel across the screen, not feedback under a finger
            // (rule `65-accessibility`).
            .offset(y: arrived || reduceMotion ? 0 : Arrival.rise)
            // Scoped to the flag, never a bare `withAnimation` (rule `50-views`). No animation on
            // the way out: a screen that is leaving is not seen leaving.
            .animation(
                arrived ? .smooth(duration: Arrival.duration).delay(Arrival.delay(order: order)) : nil,
                value: arrived
            )
    }
}

extension View {

    /// Draws this view as arriving with its screen: hidden until `arrived`, then risen and faded
    /// in, `order` sections after the first.
    ///
    /// The screen owns the flag — set when it appears, cleared when it disappears — so the
    /// arrival plays when a tab is shown and when the app opens, and not on a return from the
    /// background or from a sheet.
    func arrives(_ arrived: Bool, order: Int) -> some View {
        modifier(ArrivalModifier(arrived: arrived, order: order))
    }
}
```

- [ ] **Step 5: Drive it from each screen**

Each of the three views gains:

```swift
    /// Whether this screen has arrived — set when it appears, cleared when it goes
    /// (``Arrival``). Presentation state.
    @State private var arrived = false
```

`HomeView.body` — the column's children, and the two hooks (the existing `.onAppear` gains a line):

```swift
                        header
                        vessel.arrives(arrived, order: 0)
                        status.arrives(arrived, order: 1)
                        quickAddRow.arrives(arrived, order: 2)
```

```swift
        .onAppear {
            manager.refresh()
            arrived = true
        }
        .onDisappear { arrived = false }
```

`HistoryView.body` — each row's content, before its `historyRow`:

```swift
                    HistoryCard(shown: shownPastDay?.dayOrdinal ?? manager.history.last?.dayOrdinal, arrived: arrived) { ordinal in
                        selectedDay = Self.selection(forDay: ordinal, in: manager.history)
                    }
                    .arrives(arrived, order: 0)
                    .historyRow()
```

```swift
                if shownLogs.isEmpty {
                    emptyState
                        .arrives(arrived, order: 1)
                        .historyRow(top: 22)
                } else {
                    DayStrip(logs: shownLogs, marksReminder: shownPastDay == nil, arrived: arrived)
                        .arrives(arrived, order: 1)
                        .historyRow()

                    servings
                }
```

In `servings`, `ServingRow(…) { … }` gains `.arrives(arrived, order: 2)` before
`.historyRow(top: 5, bottom: 5, sides: Self.margin)`. And the hooks:

```swift
        .onAppear {
            manager.refresh()
            arrived = true
        }
        .onDisappear { arrived = false }
```

`HistoryCard` and `DayStrip` each gain `let arrived: Bool` and
`@Environment(\.accessibilityReduceMotion) private var reduceMotion`, and:

```swift
    /// The bars stand at nothing until the screen has arrived, and grow from the baseline as it
    /// does. Under Reduce Motion they are simply there.
    private var grown: Bool { arrived || reduceMotion }
```

`HistoryCard.bar(for:)` — the filled capsule's height:

```swift
                .frame(height: grown ? max(barHeight * fraction, day.total > 0 ? 6 : 2) : 0)
```

and on `days`, beside its two animations:

```swift
        .animation(.smooth(duration: 0.5).delay(Arrival.delay(order: 1)), value: grown)
```

`DayStrip.plot` — a bar's frame, and the plot's animation:

```swift
                        .frame(width: barWidth, height: grown ? max(proxy.size.height * bar.height, barWidth) : 0)
```

```swift
        .animation(.smooth(duration: 0.5).delay(Arrival.delay(order: 2)), value: grown)
```

`SettingsView.body` — the cards, and the hooks beside `.task`:

```swift
                        header
                        GoalCard(currentGoal: manager.dailyGoal).arrives(arrived, order: 0)
                        ServingsCard(current: manager.servings).arrives(arrived, order: 1)
                        remindersCard.arrives(arrived, order: 2)
                        LanguageCard().arrives(arrived, order: 3)
```

```swift
        .onAppear { arrived = true }
        .onDisappear { arrived = false }
```

- [ ] **Step 6: Run, green**

`ArrivalTests`: `✔ Test run with 5 tests passed`. `testAScreenComesBackWholeAfterItsTabIsLeft` and
`testTheTabBarSwitchesBetweenHomeAndHistory` on *WaterBuddy Probe 27* and *WaterBuddy Fallback
18.6*: passed.

- [ ] **Step 7: See the UI test fail for the defect, once**

In `HomeView`, remove `arrived = true` from `.onAppear` for one run of
`testAScreenComesBackWholeAfterItsTabIsLeft`.
Expected: `Home came back without its quick-add row`. Restore the line; `git diff` shows it back.

---

### Task 4: The tabs

**Files:** Modify `WaterBuddy/RootTabView.swift`, `WaterBuddy/HomeView.swift`,
`WaterBuddy/HistoryView.swift`, `WaterBuddyUITests/GoalSetupUITests.swift`.

**Interfaces:**
- Consumes: `Haptics.select` (Task 2).
- Produces: nothing a later task names.

- [ ] **Step 1: Write the three UI tests**

In `GoalSetupUITests`, after `testAScreenComesBackWholeAfterItsTabIsLeft`:

```swift
    /// On iOS 26 and later the bar is Apple's, and a press dragged along it carries the selection.
    /// The app's own bar, below iOS 26, answers a tap only.
    @MainActor
    func testAPressDraggedAlongTheBarChangesTheTab() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("the app's own bar answers a tap only") }
        let app = launchedOnHome()

        app.buttons["Home"].press(
            forDuration: 0.6,
            thenDragTo: app.buttons["Settings"],
            withVelocity: .slow,
            thenHoldForDuration: 0.4
        )
        XCTAssertTrue(
            app.sliders["Daily water goal"].waitForExistence(timeout: 5),
            "the drag did not carry the selection to Settings"
        )
    }

    /// The app's own bar: three captions on one line. Each hung under a glyph of its own height,
    /// and *History* stood two and a half points above its neighbours.
    @MainActor
    func testTheBarsCaptionsShareALine() throws {
        if #available(iOS 26.0, *) { throw XCTSkip("Apple's bar draws its own captions") }
        let app = launchedOnHome()

        // The lowest text of each name is its caption: no heading stands below the bar.
        let tops = ["Home", "History", "Settings"].map { name in
            app.staticTexts.matching(identifier: name).allElementsBoundByIndex.map(\.frame.minY).max() ?? 0
        }
        XCTAssertGreaterThan(tops[0], 0, "the bar's captions are not in the tree")
        XCTAssertEqual(tops[0], tops[1], accuracy: 0.5, "History's caption is not on Home's line")
        XCTAssertEqual(tops[1], tops[2], accuracy: 0.5, "Settings' caption is not on History's line")
    }

    /// History opens on today each time its tab is shown. It did so by being rebuilt on every
    /// change of tab; under Apple's bar a screen is kept, and has to do it on purpose.
    @MainActor
    func testHistoryReturnsToTodayWhenItsTabIsLeft() throws {
        let app = launchedOnHome()

        // A serving today is what draws the week card, and with it yesterday's button.
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        app.buttons["History"].tap()

        let yesterday = app.buttons[Self.dayNames()[1]]
        XCTAssertTrue(yesterday.waitForExistence(timeout: 5), "the week card has no button for yesterday")
        yesterday.tap()
        XCTAssertTrue(yesterday.isSelected, "tapping a day did not select it")

        app.buttons["Home"].tap()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))
        app.buttons["History"].tap()

        XCTAssertTrue(app.buttons["Today"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Today"].isSelected, "History came back on the day it was left on")
    }
```

- [ ] **Step 2: Run them and record what each does before the code**

On *WaterBuddy Probe 27*: `testAPressDraggedAlongTheBarChangesTheTab` **fails** — `the drag did
not carry the selection to Settings`; `testHistoryReturnsToTodayWhenItsTabIsLeft` passes (the
rebuild); `testTheBarsCaptionsShareALine` is skipped. On *WaterBuddy Fallback 18.6*:
`testTheBarsCaptionsShareALine` **fails** — `History's caption is not on Home's line`; the drag
test is skipped.

- [ ] **Step 3: The two containers**

`RootTabView` becomes — its DocC keeps its two paragraphs on the shared aurora and on
`preferredColorScheme`, and gains the third:

```swift
/// **Two containers, chosen by the system and by nothing else.** On iOS 26 and later the three
/// screens are the tabs of a `TabView` and the bar is Apple's: the glass, the lens that follows a
/// finger dragged along it, and whatever iOS makes of it next. Below iOS 26 Apple's bar is the
/// flat one, so the app keeps its own. The branch cannot change while the app runs, and `Tab` —
/// an iOS 18 API — is named only inside it; the floor stays iOS 17
/// (`docs/superpowers/specs/2026-10-11-navigation-and-motion-design.md` §4).
struct RootTabView: View {

    /// Which destination is showing. Presentation state, which is the only kind a view owns
    /// (rule `50-views`) — nothing about the tab is persisted, so a relaunch opens on Home.
    @State private var tab: AppTab = .opening

    var body: some View {
        container
            // A tick as the selection moves, on either bar. Off the view's own state, which only
            // the user's tap or drag changes (rule `60-design-system`).
            .sensoryFeedback(Haptics.select, trigger: tab)
            // (the existing comment on `preferredColorScheme`, unchanged)
            .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var container: some View {
        if #available(iOS 26.0, *) {
            SystemTabs(selection: $tab)
        } else {
            HandMadeTabs(selection: $tab)
        }
    }
}

// MARK: - Apple's bar

/// The three screens as the tabs of a `TabView`.
///
/// **A screen is kept while its tab is away**, where the app's own container rebuilds it. What
/// the rebuild did by accident each screen now does when it disappears: Home ends its *Undo*
/// offer, History returns to today.
@available(iOS 26.0, *)
private struct SystemTabs: View {

    @Binding var selection: AppTab

    @Environment(\.strings) private var strings

    var body: some View {
        TabView(selection: $selection) {
            Tab(AppTab.home.title(in: strings), systemImage: AppTab.home.symbol, value: AppTab.home) {
                HomeView()
            }
            Tab(AppTab.history.title(in: strings), systemImage: AppTab.history.symbol, value: AppTab.history) {
                HistoryView()
            }
            Tab(AppTab.settings.title(in: strings), systemImage: AppTab.settings.symbol, value: AppTab.settings) {
                SettingsView()
            }
        }
        // The selected tab's glyph and caption. White, and the figure is Task 6's.
        .tint(.white)
        // Three destinations the user returns to all day are not something to hide on scroll.
        .tabBarMinimizeBehavior(.never)
    }
}

// MARK: - The app's own bar

/// Below iOS 26: the screens swapped in a `ZStack`, under the app's own glass bar.
private struct HandMadeTabs: View {

    @Binding var selection: AppTab

    var body: some View {
        ZStack {
            switch selection {
            case .home:     HomeView().transition(.opacity)
            case .history:  HistoryView().transition(.opacity)
            case .settings: SettingsView().transition(.opacity)
            }
        }
        // (the existing comments on the animation and on `safeAreaInset`, unchanged)
        .animation(.smooth(duration: 0.28), value: selection)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassTabBar(selection: $selection)
        }
    }
}
```

`GlassTabBar.tabButton` — the glyph's box, so the three captions start at one height:

```swift
                Image(systemName: tab.symbol)
                    .font(.system(size: glyph, weight: .semibold))
                    // One box for three glyphs of three heights. Without it each caption hung
                    // under its own glyph, and *History* stood 2.5 pt above the other two
                    // (`testTheBarsCaptionsShareALine`).
                    .frame(height: glyph * 1.2)
```

- [ ] **Step 4: End each screen's state when it disappears**

`HomeView` — the hook written in Task 3:

```swift
        // Leaving the tab ends the offer. The app's own container did this by rebuilding the
        // screen; Apple's keeps it (`testAnUndoOfferDoesNotOutliveItsScreen`).
        .onDisappear {
            arrived = false
            undoOffer = nil
        }
```

`undoOffer`'s DocC: "Presentation state: it lives with the screen, and the screen ends it when it
disappears — leaving the tab ends the offer."

`HistoryView` — likewise:

```swift
        // Leaving the tab returns the screen to today (`testHistoryReturnsToTodayWhenItsTabIsLeft`).
        // A sheet over this screen is not a disappearance, so the day a serving was just saved to
        // stays shown.
        .onDisappear {
            arrived = false
            selectedDay = nil
        }
```

`selectedDay`'s DocC already says "leaving the tab resets it to today"; add "— on disappear".

- [ ] **Step 5: Run, green on both bars**

On *WaterBuddy Probe 27* and *WaterBuddy Probe 26.5*: the drag test passes;
`testHistoryReturnsToTodayWhenItsTabIsLeft`, `testAnUndoOfferDoesNotOutliveItsScreen`,
`testAScreenComesBackWholeAfterItsTabIsLeft`, `testTheTabBarSwitchesBetweenHomeAndHistory`,
`testSettingsIsReachableFromHomeAsATab` and `testTheTitleHoldsItsPlaceOnEveryTab` pass. On
*WaterBuddy Fallback 18.6*: `testTheBarsCaptionsShareALine` passes, with the same six.

- [ ] **Step 6: See the two pins fail for the defect, once each**

On *WaterBuddy Probe 27*: remove `selectedDay = nil` for one run of
`testHistoryReturnsToTodayWhenItsTabIsLeft` — expected `History came back on the day it was left
on`; restore. Remove `undoOffer = nil` for one run of `testAnUndoOfferDoesNotOutliveItsScreen` —
expected `the offer came back with the tab`; restore. `git diff` shows both back.

---

### Task 5: What a touch does

**Files:** Modify `WaterBuddy/HomeView.swift`, `WaterBuddy/HistoryView.swift`.

**Interfaces:**
- Consumes: `Haptics.select`, `Haptics.remove` (Task 2).

No new test can feel a haptic or see a bounce; the existing UI tests hold the behaviour these sit
beside, and Task 6 records the motion.

- [ ] **Step 1: Home — the disc, the capsule, the flame**

State, beside `pours`:

```swift
    /// How many times each vessel has been poured from this screen, by slot. Drives that disc's
    /// own bounce, so only the one that was pressed answers.
    @State private var poured: [String: Int] = [:]
```

In `pour(_:)`, after `pours += 1`:

```swift
        poured[serving.id, default: 0] += 1
```

In `disc(_:)`, the glyph:

```swift
        let glyph = Image(systemName: serving.symbol)
            // A ratio of the disc it sits in, never its own text style, so it cannot grow through
            // the edge at the accessibility sizes (rule `65-accessibility`).
            .font(.system(size: diameter * 0.4, weight: .semibold))
            // Once per pour, on the disc that was pressed — feedback under a finger, like the
            // recoil beside it (rule `65-accessibility`).
            .symbolEffect(.bounce, value: poured[serving.id, default: 0])
            .frame(width: diameter, height: diameter)
```

In `quietLine`, the capsule's transition, and in `body` the animation that drives it:

```swift
            undoCapsule(offer)
                // It arrives from a little small, on a spring: something that has just landed.
                .transition(.scale(scale: 0.92).combined(with: .opacity))
```

```swift
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: standingOffer)
```

In `streakChip`, the flame:

```swift
                Image(systemName: Self.streakSymbol)
                    .foregroundStyle(Aurora.cyan)
                    // Once, when the count moves.
                    .symbolEffect(.bounce, value: manager.streak)
```

- [ ] **Step 2: History — the ticks**

State on `HistoryView`:

```swift
    /// Bumped when a day is picked, and when a serving is swiped away: the haptics fire on the
    /// user's own action, never on a change to the model (rule `60-design-system`).
    @State private var picks = 0
    @State private var removals = 0
```

The card's closure and the swipe action each gain one line:

```swift
                        selectedDay = Self.selection(forDay: ordinal, in: manager.history)
                        picks += 1
```

```swift
                    manager.deleteLog(log)
                    removals += 1
```

On `body`, beside `.onAppear`:

```swift
        .sensoryFeedback(Haptics.select, trigger: picks)
        .sensoryFeedback(Haptics.remove, trigger: removals)
```

On `ServingSheet.body`, beside its `.sensoryFeedback(Haptics.pour, trigger: commits)`:

```swift
        // A tick for each step of the slider and for a vessel picked: the amount under the
        // finger, which is the sheet's own state and no model value.
        .sensoryFeedback(Haptics.select, trigger: amount)
```

- [ ] **Step 3: Build and run what sits beside them**

On *WaterBuddy Probe 27*: `testUndoTakesBackThePourJustMade`,
`testADiscAndUndoAnswerOffTheirGlyphs`, `testTheSheetsVesselShortcutsSetTheAmount`,
`testTheWeekCardIsOneSummaryAndOneButtonPerDay`. Expected: passed.

---

### Task 6: On the simulator — render, measure, record

**Files:** Create, then **delete**, `WaterBuddyUITests/ZZMotionProbe.swift`. Scripts already in
`"$SP/tools"`: `frames.swift`, `sheet.py`, `barcrop.py`, `barcontrast.py`, `cuts.py`.

- [ ] **Step 1: The probe**

A UI test class with three tests, each attaching `XCUIScreen.main.screenshot()` under a name:
`testSweepTheBar` — a capture every three seconds for a minute on Home, then on History scrolled
until the week card's white bar is under the bar, then on Settings scrolled until a slider is
under it; `testMove` — every tab tapped, then, where `#available(iOS 26.0, *)`, the press dragged
both ways; `testHeader` — the three headers, read as frames into a text attachment. A variant
(`TEST_RUNNER_WB_VARIANT`) names the run. Seeded data is already on the two Probe devices.

- [ ] **Step 2: Captions on Apple's bar**

`testSweepTheBar` on *WaterBuddy Probe 27* and *WaterBuddy Probe 26.5*, then `barcontrast.py` over
each set. **Each caption must read 4.5:1 or better at its worst frame, over each ground.** If the
selected caption is under with `.tint(.white)`, or an unselected one is under over the white bar,
apply `.scrollEdgeEffectStyle(.soft, for: .bottom)` to the three screens' scroll views inside
`#available(iOS 26.0, *)`, render again, and record both. If it is still under, **stop and report
to the owner**: the bar was chosen on the condition that it could be read.

- [ ] **Step 3: Cyan, tried once**

One run of the sweep with `.tint(Aurora.cyan)`. Keep cyan only if the selected caption reads
4.5:1 or better on **both** systems; otherwise white stays, and the figures say why.

- [ ] **Step 4: The recordings**

`testMove` under `xcrun simctl io <udid> recordVideo`, on *WaterBuddy Probe 27*, *WaterBuddy Probe
26.5* and *WaterBuddy Fallback 18.6* — each booted first, and shut down by its own id after.
`cuts.py` over one change of tab in each: Apple's bar, one frame; the app's own, the cross-fade.
Frames at 1/30 s through one arrival, as a contact sheet, **looked at**: the title in one place in
every frame, the sections rising in order. Trimmed copies go to
`.superpowers/sdd/2026-10-11-navigation-and-motion/`.

- [ ] **Step 5: The header where it is tightest**

`testHeader` on *WaterBuddy Small 26.5* at the ordinary size and with
`UICTContentSizeCategoryAccessibilityXXXL` in Russian. Read the captures: the title and the line
under it whole on Home and on a past day in History; the streak chip and the `+` on the title's
line.

- [ ] **Step 6: The three settings**

On *WaterBuddy Probe 27*, each switched on with `xcrun simctl ui` or the Settings app, rendered,
and switched off again: Reduce Motion (the arrival is a fade — frames show no rise), Reduce
Transparency, Increase Contrast.

- [ ] **Step 7: Delete the probe**

`git status --short WaterBuddyUITests` shows `GoalSetupUITests.swift` modified and nothing
untracked.

---

### Task 7: The rules — written, shown, left unstaged

**Files:** `.claude/rules/15-project.md`, `50-views.md`, `60-design-system.md`,
`65-accessibility.md`, `85-testing.md`.

- [ ] **Step 1: Write each change** exactly as the spec's §8 table describes, keeping each rule's
voice. In `50-views.md`, *Navigation*: the first bullet names the two containers and where
`TabView` may be written; a new bullet says a screen ends its own presentation state on disappear;
*Composition* gains `ScreenHeader`. In `60-design-system.md`, *Haptics*: five rungs. In
`65-accessibility.md`, *Reduce Motion*: the arrival's fade; *Tap targets*: the three-slot bar is
the app's own. In `15-project.md`: the third version check. In `85-testing.md`: the skip.

- [ ] **Step 2: Leave them unstaged**, and list them for the owner beside stage 3's two.

---

### Task 8: The review, the gate, the warning comparison

- [ ] **Step 1: A fresh, read-only reviewer** is given the unstaged diff, the spec and this plan,
and builds nothing. Its report is saved beside the ledger as it arrives. Every finding is opened in
the code; what is real is fixed test-first, and what is left is listed.

- [ ] **Step 2: The gate**, each a foreground call, no `-collect-test-diagnostics`:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -derivedDataPath "$DD"
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/GoalSetupUITests -parallel-testing-enabled NO -derivedDataPath "$DD"
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -skip-testing:WaterBuddyUITests/GoalSetupUITests -parallel-testing-enabled NO -derivedDataPath "$DD"
```

The last two again for `OS=26.5,name=WaterBuddy Gate 26.5` and `OS=18.6,name=WaterBuddy Gate 18.6`.
If `GoalSetupUITests` no longer fits one 600-second call, it is split in two by `-only-testing`
of named tests, and the ledger says which. Then:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -derivedDataPath "$DD"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -derivedDataPath "$DD"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -derivedDataPath "$DD"
```

- [ ] **Step 3: Warnings.** A clean build of the tree into an empty folder, the two schemes of
Task 0, and the distinct warning lines — path and position cut — compared with Task 0's: the same
lines, or the difference explained line by line.

---

### Task 9: Records, docs — then stop

- [ ] **Step 1:** `HISTORY.md` gains a checkpoint; `tasks/lessons.md` its entries; `/doc_sync`.
- [ ] **Step 2:** The ledger's last section: what is unstaged and why, what the owner is asked.
- [ ] **Step 3: Stop.** Nothing is staged and nothing is committed. The owner runs `/commit` for
stage 3 from the index; this stage is staged after it.
