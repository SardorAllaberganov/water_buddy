# The Premium Redesign, Stage 3 (History) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent ("Planning, test authorship, implementation and review
> all happen in the main loop"). Steps use checkbox (`- [ ]`) syntax for tracking. **No step commits:**
> each task ends by staging its paths, and nothing is committed until the owner runs `/commit`.

**Goal:** History becomes one scrolling screen — the day's header, the week card with its *Goal met*
count and bars coloured by whether the goal was reached, a strip showing when the day's servings
were poured, and lighter serving rows that name their vessel — and the serving sheet gains three
one-tap vessel amounts.

**Architecture:** Nothing is stored and `DataManager` gains only what a view cannot compute without
a calendar: `DaySummary.daysMet(in:goal:)`, `dayFraction(of:)` and `hours(_:onDayOf:)`. Everything
else is a pure `nonisolated static` on `HistoryView` taking its state as parameters — the strip's
bars, the vessel a row is drawn as, the slider's bounds — so a suite off the main actor pins it.
The header, the two cards and the servings become rows of the one `List` the servings already use,
with the list's own surfaces cleared; visible volumes go through `Bundle.figure(_:_:locale:)`.

**Tech Stack:** Swift (language mode 5; the app target defaults to main-actor isolation), SwiftUI
(iOS 17 floor; Apple's glass on iOS 26 and later through `.liquidGlass`), SwiftData, swift-testing,
XCTest (the UI suite and one throwaway probe), Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-09-premium-redesign-design.md` — §6 (History), §3.1
(grouped figures), §11 (verification), §12 (differences from the canvas), §14 (stages). Approved by
the owner on 2026-10-09 with all of §13. **The canvas:** boards *History*
(`project/History.dc.html`) and *Add a serving* (`project/ServingSheet.dc.html`) of
<https://claude.ai/artifact/UYGcabBfVjduqkzvqtZ5bt>, read on 2026-10-11.

**Authority for running it:** the owner's "go" of 2026-10-11 to this stage's outline and its five
decisions (below), on top of the 2026-10-09 ruling "build the remaining stages straight through …
stopping only at each stage's `/commit` or a real design decision". This plan is therefore executed
without a second approval.

**The five decisions the owner's "go" took as recommended (2026-10-11):**

1. The header scrolls away with the list, as spec §6.2 says. The `+` is reached by scrolling back up.
2. The test behind known issue #62 is rewritten in this stage: with two cards above the rows a
   count of visible rows fails after a handful of runs.
3. The sheet's selected shortcut is drawn with `LiquidGlass.Selection`'s fill and rim, not white:
   a screen carries one primary surface (rule `60-design-system`) and *Save* is it.
4. Known issue #93 (a swipe-delete on an unreadable store) is **not** part of this stage.
5. Contrast is recorded by both yardsticks of known issue #95, with clean ground as the floor.

## Global Constraints

- **Floors stay iOS 17.0 and watchOS 26.0.** No new `#available`.
- **Nothing is stored.** No new `DataManager.Key`, no change to `WaterLog`, `WaterSnapshot` or
  `WristMirror`. `Key.all` still holds eleven keys.
- **No new file in a shared set and no `project.pbxproj` edit.** `DataManager.swift` compiles into
  four bundles; every change to it is followed by building the other three schemes.
- **One writer.** Every mutation is one call into `DataManager`. A view owns presentation state
  only; a `WaterLog` sits in `@State` only as the sheet's selection (rule `50-views`).
- **A view holds no calendar.** What a day is, where an instant falls in it and when its hours are
  come from the model (rule `30-rollover`). No `Calendar.current`, no 86,400.
- **No unpinned `Date()` in logic.** Volumes are `Int`; a `Double` is a drawing fraction only.
- **Every label the UI tests query today is kept**: `N millilitres` on a serving row, the day
  buttons by weekday with `N millilitres` as their value, *Last 7 days* as one element, *Add a
  serving*, *Edit serving*, *Serving amount*, *Save*, *Cancel*. **Spoken strings keep `%d` keys;
  visible volumes use `%@` keys fed by `Bundle.figure`.**
- **A row's vessel name is drawn, never spoken** (spec §6.2): a log stores an amount and nothing
  else, so the name is an inference from today's vessels.
- **Every new string has explicit `en`, `ru` and `uz` values** in `WaterBuddy/Localizable.xcstrings`
  and is resolved through `@Environment(\.strings)`. None reaches a notification, the widget or the
  watch. A key that loses its last reader is removed in the same change.
- **No colour literal, no `glassEffect` at a call site**, no bare `withAnimation`, no bare `print`.
  A selected control is marked with `LiquidGlass.Selection`'s fill **and** rim, present at zero
  opacity when unselected.
- **New statics a test outside the main actor reads are `nonisolated`**; a new file-scope value type
  is `nonisolated` and `Sendable` (rule `43-concurrency`).
- **Tests first.** Write the test, run it, see it fail for the predicted reason, then implement.
  Never narrow an assertion to make it pass. Test names are not reused across suites.
- **A contrast figure is measured off a render, the worst frame of a sweep at least as long as the
  aurora's slowest light (28.5 s), on every iOS the pane draws on**, where the pane is lightest —
  History's rows scroll over the magenta light. Floors: 4.5:1 for text, 3:1 for a glyph, a rule or a
  rim, 3:1 for text of 24 pt or more. Text on the aurora itself is recorded on clean ground **and**
  beside its glyphs (known issue #95).
- **Edits with `Edit`/`Write` only.** A script reads; it never writes into the repository.
  `Bash(sed -i:*)` and `Bash(xcrun simctl erase:*)` are denied; a refused call is a stop.
- Every `xcodebuild` in the foreground, `-parallel-testing-enabled NO`. **Never
  `xcrun simctl shutdown all`** — another project's simulators run on this Mac; shut down by UDID.
  **Reuse the eight *WaterBuddy …* simulators**; a new one is made only for a screen size none of
  them has, is named *WaterBuddy …*, and is listed for the owner at the end.
- **Probes pour on Probe devices; the gate's UI suite runs on Gate devices** (known issue #62).
- No new warning against a clean build of HEAD `e16221e` (Task 0 takes the baseline).
- **Never touch or stage** what was unstaged before this stage: `.claude/settings.json`, the two
  watch schemes, `WaterBuddy/AppShortcuts.xcstrings`, the two watch catalogues, `Screenshots/census/`.

## Review Focus

Conditions the spec implies that the unit tests cannot drive, most likely to bite first, each with
the check that owns it:

1. **A day button, a serving row and a vessel shortcut tapped off their glyphs on iOS 26.5.** Stage 1
   found a pane inside History's `List` that was not part of its button's hit region there. The
   header and both cards are now list rows too. → Task 5's
   `testTheSheetsVesselShortcutsSetTheAmount` and the kept `testAServingRowOpensItsSheetWhereverItIsTapped`,
   run on iOS 26.5 in Task 8; Task 6's probe taps a day off its bar.
2. **The first serving row below the fold.** With two cards above it, on a 375 × 667 pt phone the
   day's first serving is not on screen at rest, and a lazy list does not build it. → Task 5 makes
   the row tests bring the row into view; Task 6 renders the small phone.
3. **A serving at 00:30 and one at 23:59, and two in the same minute.** The strip must keep both
   inside its plot and draw overlapping bars without losing one. → Task 2's
   `aBarNeverLeavesThePlot` and `twoServingsInOneMinuteAreTwoBars`; Task 6 renders them.
4. **A serving larger than every vessel** — the seeded log that carries a whole day's total. The
   strip's scale and the sheet's slider must contain it, and a shortcut tapped from it must land
   inside the slider. → Task 2's `aServingLargerThanEveryVesselSetsTheScale` and
   `theSliderBoundsContainEveryVesselShortcut`.
5. **The largest text size in Russian.** Three stat columns do not fit; the fallback must not cut
   *Goal met* or a figure short. → Task 6 renders `AccessibilityXXXL` in English and Russian.

---

## File structure

| File | Change | Responsibility |
|---|---|---|
| `WaterBuddy/DataManager.swift` | modify | `DaySummary.reached(_:)`, `DaySummary.daysMet(in:goal:)`, `dayFraction(of:)`, `hours(_:onDayOf:)` and their `nonisolated static` halves |
| `WaterBuddy/HistoryView.swift` | modify | the screen: one `List`; the header; the week card's colours and three figures; `DayStrip`; `ServingRow`; the sheet's shortcuts; the pure statics |
| `WaterBuddy/AuroraBackground.swift` | modify | `legibleOnBackdrop()`, moved here from `HomeView.swift` now that a second screen draws text on the aurora |
| `WaterBuddy/HomeView.swift` | modify | loses its private copy of `legibleOnBackdrop()`; nothing else |
| `WaterBuddy/Localizable.xcstrings` | modify | six new keys; four removed with their last reader |
| `WaterBuddyTests/HistoryRangeTests.swift` | modify | `DaysMetTests`, `DayFractionTests` (pure), one test in `HistoryWindowTests` |
| `WaterBuddyTests/HistoryViewTests.swift` | modify | `HistoryLayoutTests` (pure), one test in `HistoryServingTests` |
| `WaterBuddyTests/LocalizationTests.swift` | modify | `historyKeys`, `HistoryStringTests`, one test in `GroupedFigureTests` |
| `WaterBuddyUITests/GoalSetupUITests.swift` | modify | #62's test rewritten; the row tests bring their row into view; two new tests |
| `WaterBuddyUITests/ZZHistoryProbe.swift` | create, then **delete** | Task 6's throwaway captures |
| `.claude/rules/50-views.md`, `65-accessibility.md` | modify, **left unstaged** | Task 7's wording, for the owner's yes |
| `HISTORY.md`, `tasks/lessons.md`, `docs/` | modify | Task 9 |

Shell variable used below — **each `Bash` call is a fresh shell**, so set it in every command:

```bash
SP=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/f5251597-7c1c-4123-b6e8-8b2a31a7f480/scratchpad
```

One unit suite (replace `SUITE` and the log's name). `-collect-test-diagnostics never` is for
development runs only — a failed `xcodebuild test` otherwise does not exit for about ten minutes
(known issue #101); the gate's commands do not carry it:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:WaterBuddyTests/SUITE -parallel-testing-enabled NO \
  -collect-test-diagnostics never > $SP/t.log 2>&1; echo "exit $?"
grep -E 'error:|✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/t.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-220
```

The three other schemes, after any change to `DataManager.swift`:

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' > $SP/b-widget.log 2>&1; echo "widget exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'generic/platform=watchOS Simulator' > $SP/b-watch.log 2>&1; echo "watch exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'generic/platform=watchOS Simulator' > $SP/b-watchwidget.log 2>&1; echo "watchwidget exit $?"
grep -hE 'error:|\*\* BUILD' $SP/b-widget.log $SP/b-watch.log $SP/b-watchwidget.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-220
```

The simulators, all existing (`xcrun simctl list devices | grep WaterBuddy`):

| Name | Runtime | Used for |
|---|---|---|
| *WaterBuddy Probe 27* | iOS 27.0 | Task 6 on Apple's glass, newest |
| *WaterBuddy Probe 26.5* | iOS 26.5 | Task 6 on Apple's glass, oldest — run first |
| *WaterBuddy Fallback 18.6* | iOS 18.6 | Task 6 on the hand-made glass |
| *WaterBuddy Gate 27*, *Gate 26.5*, *Gate 18.6* | 27.0, 26.5, 18.6 | Task 8's UI suite |
| *WaterBuddy Watch 27* | watchOS 27.0 | Task 8's watch run, if the pinned device still has no data |

The ledger — one line per finding, ruling or deviation:
`.superpowers/sdd/2026-10-11-premium-redesign-stage-3/progress.md` (ignored by git). A subagent's
report is saved beside it the moment it arrives.

---

### Task 0: The ledger and the baseline

**Files:** none in the repository.

- [ ] **Step 1: Open the ledger** with the plan's path, HEAD (`git rev-parse --short HEAD`), the
  scratchpad path and the five decisions above.

- [ ] **Step 2: Clean builds of HEAD into empty DerivedData, four schemes**, each its own foreground
  invocation. The tree is taken with `git archive`, so the baseline is HEAD and not the working
  tree's five unstaged build inputs:

```bash
mkdir -p $SP/wc/base && git archive HEAD | tar -x -C $SP/wc/base && ls $SP/wc/base | head -5
```

```bash
xcodebuild build-for-testing -project $SP/wc/base/WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath $SP/wc/dd-base > $SP/wc/base-app.log 2>&1; echo "app exit $?"
```

```bash
xcodebuild build -project $SP/wc/base/WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath $SP/wc/dd-base > $SP/wc/base-widget.log 2>&1; echo "widget exit $?"
xcodebuild build -project $SP/wc/base/WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'generic/platform=watchOS Simulator' -derivedDataPath $SP/wc/dd-base > $SP/wc/base-watch.log 2>&1; echo "watch exit $?"
xcodebuild build -project $SP/wc/base/WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'generic/platform=watchOS Simulator' -derivedDataPath $SP/wc/dd-base > $SP/wc/base-watchwidget.log 2>&1; echo "watchwidget exit $?"
```

```bash
for log in app widget watch watchwidget; do
  grep -E ': warning: ' $SP/wc/base-$log.log | grep -vE '^\s+\|' \
    | sed -E 's#^/[^ ]*/(WaterBuddy[A-Za-z]*/[^:]+):[0-9]+:[0-9]+: #\1: #' | sort | uniq -c > $SP/wc/base-$log.warn
  echo "$log: $(wc -l < $SP/wc/base-$log.warn) unique"
done
```

  Expected: four exits of 0 and four counts written to the ledger with their unit — distinct lines
  after the path and position are cut, of a `build-for-testing` for the app and a `build` for the
  rest, all four sharing one DerivedData folder that only the first starts empty. Stage 2 read
  38 / 19 / 2 / 19; a different figure is recorded, not explained away.

- [ ] **Step 3: Read the simulators** — `xcrun simctl list devices | grep -E 'WaterBuddy|Booted'` —
  and record the eight UDIDs. Make nothing.

---

### Task 1: The model — days met, and where an instant falls in its day

**Files:**
- Modify: `WaterBuddy/DataManager.swift` (the `DaySummary` extension; the instance methods after
  `suggestedTime(onDay:)`; the statics after `nextDayBoundary(after:calendar:)`)
- Test: `WaterBuddyTests/HistoryRangeTests.swift`

**Interfaces:**
- Consumes: `DaySummary.series(from:days:endingOn:in:)`, `DataManager.nextDayBoundary(after:calendar:)`,
  the file's `gregorian(in:)`, `utcDay`, `utc(_:_:_:_:_:)`, `log(_:at:)` and `withHistoryStore`.
- Produces:
  - `nonisolated func reached(_ goal: Int) -> Bool` on `DaySummary`
  - `nonisolated static func daysMet(in series: [DaySummary], goal: Int) -> Int` on `DaySummary`
  - `nonisolated static func dayFraction(of instant: Date, in calendar: Calendar) -> Double` and
    `func dayFraction(of instant: Date) -> Double` on `DataManager`
  - `nonisolated static func hours(_ hours: [Int], onDayOf instant: Date, in calendar: Calendar) -> [Date]`
    and `func hours(_ hours: [Int], onDayOf instant: Date) -> [Date]` on `DataManager`

- [ ] **Step 1: Write the failing tests.** In `HistoryRangeTests.swift`, after `DaySummaryTests`'
  closing brace and before `// MARK: - Store fixtures`:

```swift
// MARK: - Goal met

/// ``DaySummary/daysMet(in:goal:)`` — the week card's *Goal met*. Not `@MainActor`, for
/// ``DaySummaryTests``' reason: it is a pure count over values.
struct DaysMetTests {

    private func week(_ totals: [Int]) -> [DaySummary] {
        let logs = totals.enumerated().compactMap { index, total in
            total > 0 ? log(total, at: utc(2026, 8, 24 + index, 9)) : nil
        }
        return DaySummary.series(from: logs, days: totals.count, endingOn: utc(2026, 8, 23 + totals.count, 21), in: utcDay)
    }

    @Test func theCountIsOfTheDaysThatReachedTheGoal() {
        let series = week([2_150, 2_300, 2_000, 2_050, 2_400, 2_100, 1_300])

        #expect(DaySummary.daysMet(in: series, goal: 2_000) == 6)
    }

    @Test func aDayExactlyOnTheGoalCounts() {
        #expect(DaySummary.daysMet(in: week([2_000]), goal: 2_000) == 1)
        #expect(DaySummary.daysMet(in: week([1_999]), goal: 2_000) == 0)
    }

    /// Today is the last entry and is still open: it counts once it gets there, and not before.
    @Test func anOpenTodayIsNotCountedUntilItReachesTheGoal() {
        #expect(DaySummary.daysMet(in: week([2_000, 2_000, 500]), goal: 2_000) == 2)
        #expect(DaySummary.daysMet(in: week([2_000, 2_000, 2_000]), goal: 2_000) == 3)
    }

    /// No past goal is stored, so every day is judged against the one handed in — and the card
    /// says "Measured against your current goal".
    @Test func aHigherGoalReJudgesTheWeek() {
        let series = week([2_150, 2_300, 2_000, 2_050, 2_400, 2_100, 1_300])

        #expect(DaySummary.daysMet(in: series, goal: 2_200) == 2)
        #expect(DaySummary.daysMet(in: series, goal: 1_000) == 7)
    }

    @Test func anEmptyWindowHasMetNothing() {
        #expect(DaySummary.daysMet(in: [], goal: 2_000) == 0)
    }

    @Test func aDayAsksOnceWhetherItReachedTheGoal() {
        let day = week([1_500])[0]

        #expect(day.reached(1_500))
        #expect(!day.reached(1_501))
    }

    /// A day is one local date whatever its length: two servings 24 h 29 min apart on the
    /// 25-hour day are one day's water, and it is met once.
    @Test func aTwentyFiveHourDayIsMetOnce() {
        let newYork = gregorian(in: "America/New_York")
        let early = newYork.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 0, minute: 30))!
        let late = newYork.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 23, minute: 59))!

        let series = DaySummary.series(from: [log(1_200, at: early), log(900, at: late)], days: 2, endingOn: late, in: newYork)

        #expect(DaySummary.daysMet(in: series, goal: 2_000) == 1)
    }

    @Test func aTwentyThreeHourDayIsMetOnce() {
        let newYork = gregorian(in: "America/New_York")
        let springForward = newYork.date(from: DateComponents(year: 2026, month: 3, day: 8, hour: 12))!
        let dayBefore = newYork.date(from: DateComponents(year: 2026, month: 3, day: 7, hour: 12))!

        let series = DaySummary.series(
            from: [log(2_000, at: dayBefore), log(2_000, at: springForward)],
            days: 2,
            endingOn: springForward,
            in: newYork
        )

        #expect(DaySummary.daysMet(in: series, goal: 2_000) == 2)
    }
}

// MARK: - Where an instant falls in its day

/// ``DataManager/dayFraction(of:in:)`` and ``DataManager/hours(_:onDayOf:in:)`` — what History's
/// strip is placed by. Not `@MainActor`: both are `nonisolated static` and take their calendar.
struct DayFractionTests {

    private func close(_ a: Double, _ b: Double) -> Bool { abs(a - b) < 1e-9 }

    @Test func noonIsHalfwayThroughAnOrdinaryDay() {
        #expect(close(DataManager.dayFraction(of: utc(2026, 8, 30, 12), in: utcDay), 0.5))
        #expect(close(DataManager.dayFraction(of: utc(2026, 8, 30, 6), in: utcDay), 0.25))
    }

    @Test func midnightOpensTheDayAtZero() {
        #expect(DataManager.dayFraction(of: utc(2026, 8, 30, 0), in: utcDay) == 0)
    }

    @Test func theLastMinuteIsShortOfOne() {
        let fraction = DataManager.dayFraction(of: utc(2026, 8, 30, 23, 59), in: utcDay)

        #expect(fraction < 1)
        #expect(fraction > 0.99)
    }

    /// The fall-back day in New York is 25 hours long, and noon is 13 of them in.
    @Test func noonIsPastHalfwayOnATwentyFiveHourDay() {
        let newYork = gregorian(in: "America/New_York")
        let noon = newYork.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 12))!

        #expect(close(DataManager.dayFraction(of: noon, in: newYork), 13.0 / 25.0))
    }

    /// The spring-forward day is 23 hours long, and noon is 11 of them in.
    @Test func noonIsShortOfHalfwayOnATwentyThreeHourDay() {
        let newYork = gregorian(in: "America/New_York")
        let noon = newYork.date(from: DateComponents(year: 2026, month: 3, day: 8, hour: 12))!

        #expect(close(DataManager.dayFraction(of: noon, in: newYork), 11.0 / 23.0))
    }

    /// One instant, two days: 00:30 in Paris is 23:30 the evening before in London.
    @Test func theSameInstantFallsElsewhereInAnotherZonesDay() {
        let paris = gregorian(in: "Europe/Paris")
        let london = gregorian(in: "Europe/London")
        let instant = paris.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 0, minute: 30))!

        #expect(close(DataManager.dayFraction(of: instant, in: paris), 0.5 / 24))
        #expect(close(DataManager.dayFraction(of: instant, in: london), 23.5 / 24))
    }

    @Test func theHoursOfADayAreThatDaysOwnInstants() {
        let hours = DataManager.hours([6, 12, 18], onDayOf: utc(2026, 8, 30, 21, 15), in: utcDay)

        #expect(hours == [utc(2026, 8, 30, 6), utc(2026, 8, 30, 12), utc(2026, 8, 30, 18)])
    }

    /// Six o'clock on the wall is five hours after midnight on the day the clocks go forward, so
    /// its label stands where a serving poured at six stands.
    @Test func sixOClockIsFiveHoursIntoATwentyThreeHourDay() {
        let newYork = gregorian(in: "America/New_York")
        let noon = newYork.date(from: DateComponents(year: 2026, month: 3, day: 8, hour: 12))!

        let six = DataManager.hours([6], onDayOf: noon, in: newYork)

        #expect(six.count == 1)
        #expect(six.first.map { close(DataManager.dayFraction(of: $0, in: newYork), 5.0 / 23.0) } == true)
    }

    @Test func noHoursAskedForIsNoHours() {
        #expect(DataManager.hours([], onDayOf: utc(2026, 8, 30), in: utcDay).isEmpty)
    }
}
```

  And in `HistoryWindowTests`, after `historyPicksUpAServingWrittenByASecondInstance`:

```swift
    /// The instance halves answer on the model's own calendar — a view holds none
    /// (rule `30-rollover`).
    @Test func theModelPlacesAnInstantOnItsOwnCalendar() throws {
        try withHistoryStore(now: { utc(2026, 8, 30, 12) }) { manager, _ in
            #expect(abs(manager.dayFraction(of: utc(2026, 8, 30, 18)) - 0.75) < 1e-9)
            #expect(manager.hours([6], onDayOf: utc(2026, 8, 29, 23)) == [utc(2026, 8, 29, 6)])
        }
    }
```

- [ ] **Step 2: Run them and see them fail.** `SUITE` = `DaysMetTests`, log `t1-red.log`.
  Expected: a build failure naming `daysMet`, `reached`, `dayFraction` and `hours` as missing
  members, and nothing else.

- [ ] **Step 3: Implement.** In the `DaySummary` extension, after `best(of:)`:

```swift
    /// Whether this day's water reached `goal` — the one comparison a bar's colour, the streak
    /// and the *Goal met* count share.
    nonisolated func reached(_ goal: Int) -> Bool {
        total >= goal
    }

    /// How many days of `series` reached `goal`: the week card's *Goal met*.
    ///
    /// A plain count, today included once it gets there. Every day is judged against the one
    /// `goal` handed in, for ``streak(of:goal:)``'s reason: no past goal is stored.
    nonisolated static func daysMet(in series: [DaySummary], goal: Int) -> Int {
        series.filter { $0.reached(goal) }.count
    }
```

  and `streak`, `streakFillsWindow` and `closedDays` spell their comparison through it:
  `prefix { $0.reached(goal) }`, `allSatisfy { $0.reached(goal) }` and
  `guard let today = series.last, !today.reached(goal)`.

  After `suggestedTime(onDay:)`:

```swift
    /// Where `instant` falls in its own local day — `0` at the midnight that opens it, `1` at the
    /// one that closes it. A drawing fraction, for History's strip of the day's servings.
    ///
    /// On this model's calendar, like every other question about a day: a view holds none
    /// (rule `30-rollover`).
    func dayFraction(of instant: Date) -> Double {
        Self.dayFraction(of: instant, in: calendar)
    }

    /// The instants at which `hours` o'clock fall on the local day containing `instant`, for
    /// labelling that day's strip.
    func hours(_ hours: [Int], onDayOf instant: Date) -> [Date] {
        Self.hours(hours, onDayOf: instant, in: calendar)
    }
```

  After `nextDayBoundary(after:calendar:)`:

```swift
    /// Where `instant` falls in the local day that contains it, from `0` at its first midnight to
    /// `1` at its last.
    ///
    /// **A fraction of that day's real length** — from the start of the day to
    /// ``nextDayBoundary(after:calendar:)`` — never of 86,400 seconds. A daylight-saving day is 23
    /// or 25 hours long, and noon on one is not half-way through it (rule `30-rollover`).
    nonisolated static func dayFraction(of instant: Date, in calendar: Calendar) -> Double {
        let start = calendar.startOfDay(for: instant)
        let length = nextDayBoundary(after: instant, calendar: calendar).timeIntervalSince(start)
        guard length > 0 else { return 0 }
        return min(max(instant.timeIntervalSince(start) / length, 0), 1)
    }

    /// The instants at which `hours` o'clock fall on the local day containing `instant`.
    ///
    /// Each is set on the day's own midnight with `date(bySettingHour:minute:second:of:)`, the
    /// way a reminder's slot is (rule `80-notifications`), so six o'clock is six on the wall
    /// whatever the day's length. An hour the calendar cannot place is left out rather than
    /// force-unwrapped.
    nonisolated static func hours(_ hours: [Int], onDayOf instant: Date, in calendar: Calendar) -> [Date] {
        let start = calendar.startOfDay(for: instant)
        return hours.compactMap { calendar.date(bySettingHour: $0, minute: 0, second: 0, of: start) }
    }
```

- [ ] **Step 4: Run them green**, one suite at a time: `DaysMetTests` (8), `DayFractionTests` (9),
  `HistoryWindowTests` (7), and `StreakCountTests` (11), whose three functions were respelt.

- [ ] **Step 5: Build the other three schemes** (the block above). Expected: `** BUILD SUCCEEDED **`
  three times, no `error:`.

- [ ] **Step 6: Stage** `WaterBuddy/DataManager.swift` and `WaterBuddyTests/HistoryRangeTests.swift`.

---

### Task 2: What the screen decides — the strip's bars, a row's vessel, the slider's bounds

**Files:**
- Modify: `WaterBuddy/HistoryView.swift` (file scope, above `struct HistoryView`; and the statics at
  the top of `HistoryView`)
- Test: `WaterBuddyTests/HistoryViewTests.swift`

**Interfaces:**
- Consumes: `HomeView.servings(amounts:) -> [HomeView.Serving]` (`nameKey`, `amount`, `symbol`,
  `isUsual`), `HistoryView.servingRange`, `DataManager.usualSlot`.
- Produces:
  - `nonisolated struct StripBar: Equatable, Sendable, Identifiable { let id: UUID; let position: Double; let height: Double }`
  - `HistoryView.stripHours: [Int]`, `HistoryView.stripFloor: Double`
  - `nonisolated static func stripBars(for servings: [(id: UUID, amount: Int, position: Double)], vessels: [Int]) -> [StripBar]`
  - `nonisolated static func vessel(forAmount amount: Int, amounts: [Int]) -> HomeView.Serving?`
  - `static func sliderBounds(forAmount amount: Int, vessels: [Int] = []) -> ClosedRange<Int>`

- [ ] **Step 1: Write the failing tests.** In `HistoryViewTests.swift`, inside `HistoryServingTests`
  after `theSliderBoundsAlwaysContainTheServingBeingEdited`:

```swift
    /// The sheet's three shortcuts set the amount to a vessel's, so the slider under them has to
    /// be able to show every one — including a vessel a hand-edited suite put outside the offer.
    @Test(arguments: [[150, 250, 500], [1, 30, 5_000], [1_000, 1_000, 1_000], []])
    func theSliderBoundsContainEveryVesselShortcut(vessels: [Int]) {
        let bounds = HistoryView.sliderBounds(forAmount: 250, vessels: vessels)

        for vessel in vessels {
            #expect(bounds.contains(vessel))
        }
        #expect(bounds.contains(250))
        #expect(bounds.lowerBound <= HistoryView.servingRange.lowerBound)
        #expect(bounds.upperBound >= HistoryView.servingRange.upperBound)
        #expect(bounds.lowerBound >= 1)
    }
```

  And at the end of the file, a new suite:

```swift
// MARK: - Layout, as values

/// The parts of History that are decisions rather than drawing, pinned without building a view.
/// Not `@MainActor`: everything read here is `nonisolated` on purpose (rule `43-concurrency`).
struct HistoryLayoutTests {

    private let first = UUID()
    private let second = UUID()

    // MARK: A row's vessel

    @Test func aServingIsNamedForTheVesselItsAmountEquals() {
        let amounts = [150, 250, 500]

        #expect(HistoryView.vessel(forAmount: 150, amounts: amounts)?.nameKey == "Cup")
        #expect(HistoryView.vessel(forAmount: 250, amounts: amounts)?.nameKey == "Glass")
        #expect(HistoryView.vessel(forAmount: 500, amounts: amounts)?.nameKey == "Bottle")
    }

    /// A log stores an amount and nothing else, so any other amount has no name to draw.
    @Test func anAmountNoVesselHoldsIsNotNamed() {
        #expect(HistoryView.vessel(forAmount: 300, amounts: [150, 250, 500]) == nil)
        #expect(HistoryView.vessel(forAmount: 250, amounts: []) == nil)
    }

    /// Two vessels may hold one amount — the user is allowed to choose that. The Glass is what
    /// every one-tap door logs, so it is the likelier source and is checked first.
    @Test func theGlassIsCheckedFirstWhenTwoVesselsShareAnAmount() {
        #expect(HistoryView.vessel(forAmount: 250, amounts: [250, 250, 500])?.nameKey == "Glass")
        #expect(HistoryView.vessel(forAmount: 250, amounts: [250, 300, 250])?.nameKey == "Cup")
    }

    // MARK: The strip

    @Test func aBarStandsWhereItsServingFellInTheDay() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: 0.25), (id: second, amount: 500, position: 0.6)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.id) == [first, second])
        #expect(bars.map(\.position) == [0.25, 0.6])
    }

    /// A day lists its servings newest first; the strip reads left to right.
    @Test func barsAreDrawnInTheOrderOfTheDay() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: 0.9), (id: second, amount: 250, position: 0.1)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.id) == [second, first])
    }

    /// The largest current vessel fills the plot, so a day of Cups reads as small drinks and not
    /// as a day of full bars.
    @Test func aBarIsSizedAgainstTheLargestVessel() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: 0.3), (id: second, amount: 500, position: 0.5)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.height) == [0.5, 1])
    }

    /// The seeded log carries a whole day's total in one row. It sets the scale, rather than
    /// running through the top of the plot.
    @Test func aServingLargerThanEveryVesselSetsTheScale() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 2_000, position: 0.3), (id: second, amount: 500, position: 0.5)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.height) == [1, 0.25])
    }

    @Test func aSipStillDrawsABar() {
        let bars = HistoryView.stripBars(for: [(id: first, amount: 1, position: 0.5)], vessels: [150, 250, 500])

        #expect(bars.first?.height == HistoryView.stripFloor)
    }

    /// 00:00 and the last minute of the day are both inside the plot; a position from a clock
    /// that ran ahead is pulled back in.
    @Test func aBarNeverLeavesThePlot() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: -0.2), (id: second, amount: 250, position: 1.4)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.position) == [0, 1])
    }

    @Test func twoServingsInOneMinuteAreTwoBars() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: 0.5), (id: second, amount: 250, position: 0.5)],
            vessels: [150, 250, 500]
        )

        #expect(bars.count == 2)
        #expect(Set(bars.map(\.id)) == [first, second])
    }

    /// A row the store should never hold — nothing poured, or less — and no vessels at all: a
    /// floor-high bar, never a division by zero.
    @Test func aCorruptServingAndNoVesselsStillDrawABar() {
        let bars = HistoryView.stripBars(for: [(id: first, amount: 0, position: 0.5)], vessels: [])

        #expect(bars.first?.height == HistoryView.stripFloor)
    }

    @Test func theStripLabelsTheMorningNoonAndEvening() {
        #expect(HistoryView.stripHours == [6, 12, 18])
        #expect(HistoryView.stripFloor > 0 && HistoryView.stripFloor < 1)
    }
}
```

- [ ] **Step 2: Run them and see them fail.** `SUITE` = `HistoryLayoutTests`, log `t2-red.log`.
  Expected: a build failure naming `vessel(forAmount:amounts:)`, `stripBars`, `stripHours`,
  `stripFloor` and the extra argument `vessels` — and nothing else.

- [ ] **Step 3: Implement.** In `HistoryView.swift`, at file scope above `struct HistoryView`:

```swift
/// One serving on the strip of the day.
///
/// A value at file scope, and `nonisolated`, so `HistoryLayoutTests` can read it off the main
/// actor (rule `43-concurrency`). Both figures are drawing fractions — the one place a `Double`
/// may stand for anything in this product.
nonisolated struct StripBar: Equatable, Sendable, Identifiable {

    /// The serving's own id, so a bar keeps its identity when a neighbour is added or removed.
    let id: UUID

    /// Where it stands across the day: `0` at the midnight that opens it, `1` at the one that
    /// closes it.
    let position: Double

    /// How tall it stands, as a fraction of the plot.
    let height: Double
}
```

  `sliderBounds` becomes:

```swift
    static func sliderBounds(forAmount amount: Int, vessels: [Int] = []) -> ClosedRange<Int> {
        let offered = ([amount] + vessels).map { max(1, $0) }
        let least = offered.min() ?? servingRange.lowerBound
        let most = offered.max() ?? servingRange.upperBound
        return min(servingRange.lowerBound, least)...max(servingRange.upperBound, most)
    }
```

  with its DocC gaining: "`vessels` are the sheet's three shortcuts: a tap on one sets the amount
  to that vessel's, and a slider that could not show it would be handed a value outside its own
  range."

  And after `selection(forDay:in:)`:

```swift
    /// The hours the strip labels: the morning, noon and the evening. Its two ends are midnight
    /// and need no label.
    nonisolated static let stripHours = [6, 12, 18]

    /// The shortest a bar is drawn, as a fraction of the plot. A sip still has to be seen.
    nonisolated static let stripFloor = 0.12

    /// The strip's bars: one per serving, left to right through the day, each as tall as its
    /// amount is of the largest thing on the scale.
    ///
    /// **The scale is the larger of the day's largest serving and the largest current vessel.**
    /// Against the day's own largest alone, a day of nothing but Cups would draw every bar at full
    /// height and read as a day of large drinks. The seeded log — one row carrying a whole day's
    /// total (rule `25-shared-storage`) — is larger than any vessel, and sets the scale itself.
    ///
    /// Takes each serving's position rather than its instant, and the vessels rather than the
    /// model that holds them, which is what keeps it pure and `nonisolated`: where an instant
    /// falls in a day is the model's answer, on the model's calendar (rule `30-rollover`).
    nonisolated static func stripBars(
        for servings: [(id: UUID, amount: Int, position: Double)],
        vessels: [Int]
    ) -> [StripBar] {
        let scale = max(1, servings.map(\.amount).max() ?? 0, vessels.max() ?? 0)

        return servings
            .sorted { $0.position < $1.position }
            .map { serving in
                StripBar(
                    id: serving.id,
                    position: min(max(serving.position, 0), 1),
                    height: min(max(Double(max(serving.amount, 0)) / Double(scale), stripFloor), 1)
                )
            }
    }

    /// The vessel a serving of `amount` is drawn as: one of the current three whose amount it
    /// equals, or `nil`.
    ///
    /// **An inference, and drawn as one.** A log stores an amount and nothing else, so the name is
    /// a guess from today's vessels: it is shown, never spoken, and it changes when the vessels
    /// do. The Glass is checked first — it is what the widget, Siri, the Control Center control
    /// and the watch all log, so when two vessels hold one amount it is the likelier source.
    nonisolated static func vessel(forAmount amount: Int, amounts: [Int]) -> HomeView.Serving? {
        let row = HomeView.servings(amounts: amounts)
        return row.first { $0.isUsual && $0.amount == amount } ?? row.first { $0.amount == amount }
    }
```

- [ ] **Step 4: Run them green.** `HistoryLayoutTests` (12) and `HistoryServingTests` (9 with the
  new argument sets: five tests, one of them over seven arguments and one over four).

- [ ] **Step 5: Stage** `WaterBuddy/HistoryView.swift` and `WaterBuddyTests/HistoryViewTests.swift`.

---

### Task 3: The strings

**Files:**
- Modify: `WaterBuddy/Localizable.xcstrings`
- Test: `WaterBuddyTests/LocalizationTests.swift`

**Interfaces:**
- Produces: the six keys below, each with `en`, `ru` and `uz`.

| Key | ru | uz | Drawn or spoken |
|---|---|---|---|
| `Average` | `В среднем` | `O‘rtacha` | drawn |
| `Best day` | `Лучший день` | `Eng yaxshi kun` | drawn |
| `Goal met` | `Цель достигнута` | `Maqsadga erishildi` | drawn |
| `%1$@ of %2$@` | `%1$@ из %2$@` | `%2$@ dan %1$@` | drawn (`6 of 7`) |
| `When you drank` | `Когда вы пили` | `Qachon ichdingiz` | drawn, and a heading |
| `Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.` | `В среднем %1$d миллилитров. Лучший день %2$d миллилитров. Цель достигнута в %3$d из %4$d дней.` | `O‘rtacha %1$d millilitr. Eng yaxshi kun %2$d millilitr. %4$d kundan %3$d kunida maqsadga erishildi.` | spoken |

  *Goal met* takes the words *Goal reached* already has in both languages. The spoken key's noun
  is safe without plural forms (known issue #40) because its count is the window, which is seven:
  *из 7 дней* is right, and Uzbek does not inflect after a numeral.

- [ ] **Step 1: Write the failing tests.** In `LocalizationTests.swift`, after `homeKeys`:

```swift
/// History's strings that the build's extraction cannot see — resolved with
/// `localizedString(forKey:)` or through ``Bundle/figure(_:_:locale:)`` — and the labels drawn
/// beside them.
private let historyKeys = [
    "Average",
    "Best day",
    "Goal met",
    "%1$@ of %2$@",
    "When you drank",
    "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.",
]
```

  After `HomeStringTests`:

```swift
// MARK: - History

/// History's own strings, in every language the app ships.
struct HistoryStringTests {

    @Test(arguments: ["en"] + translated)
    func everyHistoryStringExistsAndKeepsItsArguments(language: String) {
        for key in historyKeys {
            let resolved = value(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            if let resolved {
                #expect(specifiers(in: resolved) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments")
            }
        }
    }

    /// Only the card's spoken summary takes raw numbers; everything drawn takes a figure already
    /// grouped (spec §3.1).
    @Test func onlyTheSpokenHistoryStringTakesRawNumbers() {
        let raw = historyKeys.filter { $0.contains("$d") }

        #expect(raw == ["Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days."])
    }

    /// The keys History's ungrouped figures were drawn from are gone with their last reader, so
    /// nothing can draw `2000` beside Home's `2,000` again.
    @Test(arguments: ["Average %1$d ml", "Best %1$d ml", "%1$d of %2$d ml", "Average %1$d millilitres. Best %2$d millilitres."])
    func theUngroupedHistoryKeysAreGone(key: String) {
        #expect(value(appBundle, "en", key) == nil, "\"\(key)\" is still in the catalogue with no reader")
    }
}
```

  And in `GroupedFigureTests`, after `theArgumentsFollowTheKeysNumberingNotTheSentencesOrder`:

```swift
    /// *Goal met* is a count set into a key of its own, and Uzbek puts the whole first here too.
    @Test func aCountOfDaysFollowsTheLanguagesOrder() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")
        let russian = try #require(localization(appBundle, "ru"), "the app ships no ru table")
        let uzbek = try #require(localization(appBundle, "uz"), "the app ships no uz table")

        #expect(english.figure("%1$@ of %2$@", 6, 7, locale: Locale(identifier: "en_US")) == "6 of 7")
        #expect(russian.figure("%1$@ of %2$@", 6, 7, locale: Locale(identifier: "ru_RU")) == "6 из 7")
        #expect(uzbek.figure("%1$@ of %2$@", 6, 7, locale: Locale(identifier: "uz_UZ")) == "7 dan 6")
    }
```

- [ ] **Step 2: Run them and see them fail.** `SUITE` = `HistoryStringTests`, then
  `GroupedFigureTests`. Expected: the six keys reported missing in each language;
  `theUngroupedHistoryKeysAreGone` failing four times (the keys are still there until Task 4
  removes their readers); `aCountOfDaysFollowsTheLanguagesOrder` drawing the raw key.

- [ ] **Step 3: Add the six keys** to `WaterBuddy/Localizable.xcstrings` with `Edit`, each in the
  catalogue's own shape (`"extractionState": "manual"`, three `stringUnit`s, `"state":
  "translated"`), at its alphabetical place.

- [ ] **Step 4: Run them.** `HistoryStringTests`: the first two tests green;
  `theUngroupedHistoryKeysAreGone` **still failing, on purpose**, until Task 4 Step 6.
  `GroupedFigureTests` green (4). `LocalizationTests` green — `bothLanguagesCoverExactlyTheSameKeys`
  and `everyDrawnStringIsTranslatedUnlessDeliberatelyNot` are the ones a half-added key would fail.

- [ ] **Step 5: Stage** `WaterBuddy/Localizable.xcstrings` and `WaterBuddyTests/LocalizationTests.swift`.

---

### Task 4: The screen

**Files:**
- Modify: `WaterBuddy/AuroraBackground.swift`, `WaterBuddy/HomeView.swift`,
  `WaterBuddy/HistoryView.swift`, `WaterBuddy/Localizable.xcstrings`

**Interfaces:**
- Consumes: Task 1's `reached(_:)`, `daysMet(in:goal:)`, `dayFraction(of:)`, `hours(_:onDayOf:)`;
  Task 2's `StripBar`, `stripBars`, `stripHours`, `vessel(forAmount:amounts:)`; Task 3's keys;
  `Bundle.figure(_:_:locale:)`; `DataManager.nextReminder`; `HomeView.reminderSymbol`;
  `LiquidGlass.Selection`.
- Produces: `View.legibleOnBackdrop()` (internal, in `AuroraBackground.swift`); the screen.

- [ ] **Step 1: Move `legibleOnBackdrop()`.** Delete the `private extension View` at the foot of
  `HomeView.swift` and add to `AuroraBackground.swift`, after the `AuroraBackground` type:

```swift
extension View {

    /// For text that sits straight on the aurora, with no pane under it.
    ///
    /// The aurora's lights swing under this text, and at their brightest white alone falls short
    /// of 4.5:1 — Home's Bottle caption read 4.2:1 over the magenta light. These are the widget
    /// readout's two shadows (rule `65-accessibility`: "a contrast threshold, not taste"): a soft
    /// one for depth, and a tight one that is a local halo and goes wherever the glyphs go.
    ///
    /// Here, beside the backdrop it answers, since History's heading became the second screen to
    /// draw text on it; it was `HomeView`'s own until then. Which of two yardsticks its figures
    /// are read by is the owner's ruling (`docs/DESIGN.md`, `docs/AI_CONTEXT.md` known issue #95).
    func legibleOnBackdrop() -> some View {
        shadow(color: .black.opacity(0.3), radius: 6, y: 1)
            .shadow(color: .black.opacity(0.45), radius: 2)
    }
}
```

- [ ] **Step 2: The list.** `HistoryView.body` becomes one `List` over the aurora. The header, the
  week card and the strip are rows; each row clears the list's own surfaces through one helper:

```swift
    var body: some View {
        ZStack {
            AuroraBackground()

            // One list, and everything on the screen is a row of it (spec §6.2). The header and
            // the week card were fixed above a list of servings until a second card arrived:
            // with both fixed, a small phone had no room left for the rows they describe.
            List {
                header
                    .historyRow(top: 24, bottom: 10)

                // Drawn only once there is a past to show. A fresh install would otherwise open on
                // seven empty bars, which reads as a broken chart rather than as a new account —
                // and this is the one screen guaranteed to render its empty state for every new
                // user. Note the condition is `history`, not `todaysLogs`: the morning after a
                // rollover, today is empty and the week is exactly what the user wants to see.
                if hasSomethingToShow {
                    HistoryCard(shown: shownPastDay?.dayOrdinal ?? manager.history.last?.dayOrdinal) { ordinal in
                        selectedDay = Self.selection(forDay: ordinal, in: manager.history)
                    }
                    .historyRow()
                }

                if shownLogs.isEmpty {
                    emptyState
                        .historyRow(top: 22)
                } else {
                    // Today's strip also marks the next reminder; a past day has none to mark.
                    DayStrip(logs: shownLogs, marksReminder: shownPastDay == nil)
                        .historyRow()

                    ForEach(shownLogs, id: \.id) { log in
                        ServingRow(
                            log: log,
                            vessel: Self.vessel(forAmount: log.amount, amounts: manager.servings)
                        ) { editor = .editing(log) }
                        .historyRow(top: 5, bottom: 5, sides: Self.margin)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            // The model deletes the row *and* recomputes the total; the doorbell is
                            // rung by the setter, not from here (rule `20-state`).
                            Button(role: .destructive) {
                                manager.deleteLog(log)
                            } label: {
                                // The closure form, because `Label(_:systemImage:)` has no bundle
                                // parameter and this string has to follow the chosen language like
                                // every other one.
                                Label {
                                    Text("Delete", bundle: strings)
                                } icon: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            // Scoped to the value that actually changed — never a bare `withAnimation` around a model
            // mutation. Identity, not amount: an edit redraws its own row and must not slide the list.
            .animation(.smooth(duration: 0.35), value: shownLogs.map(\.id))
        }
        // (the modifiers that follow — `.onAppear`, `.onChange`, `.sheet` — are unchanged)
    }
```

  with, at the top of `HistoryView`:

```swift
    /// The screen's side margin. The week card's seven day buttons are budgeted against it:
    /// `(375 − 2 × 28) / 7 = 45.6` pt on the narrowest supported iPhone, over the 44-pt floor.
    nonisolated static let margin: CGFloat = 28
```

  and, at file scope:

```swift
private extension View {

    /// One row of History's list, with the list's own surfaces cleared: a `List`'s background
    /// and separators would draw a second surface behind glass that is already lit
    /// (rule `60-design-system`).
    ///
    /// `sides` is zero for the header and the cards, which carry the screen's margin themselves —
    /// the week card's day row is budgeted against it — and the margin for a serving.
    func historyRow(top: CGFloat = 8, bottom: CGFloat = 8, sides: CGFloat = 0) -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: top, leading: sides, bottom: bottom, trailing: sides))
    }
}
```

  `emptyState` loses its `.padding(.top, 40)` (the row's inset carries it) and uses `Self.margin`.

- [ ] **Step 3: The header.** The title is the heading, with the total as its value and the drawn
  figure hidden — Home's shape, for Home's reason:

```swift
    /// The shown day, its total against the goal, and the `+`.
    ///
    /// **One heading, not two stops** — and the title itself is that heading, with the total as
    /// its value and the drawn figure hidden, as Home's is. A wrapper built with
    /// `.accessibilityElement(children: .ignore)` reads the same to VoiceOver and leaves the title
    /// inside it as a second element for anything that walks the tree.
    ///
    /// The first row of the list, so it scrolls away with it (spec §6.2).
    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                dayTitle
                    .font(.largeTitle.weight(.bold))
                    // Rigid in height: it may shrink for a long day's name at a large text size,
                    // and for nothing else.
                    .fixedSize(horizontal: false, vertical: true)
                    .legibleOnBackdrop()
                    .accessibilityLabel(spokenDay)
                    .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d of %2$d millilitres", value: nil, table: nil), shownTotal, manager.dailyGoal))
                    .accessibilityAddTraits(.isHeader)

                // Both figures come off the model. The list adds up to this number, and a `body`
                // that computed it for itself is how the two start disagreeing
                // (rule `10-architecture`). Grouped by the app's locale, like Home's.
                Text(strings.figure("%1$@ of %2$@ ml", shownTotal, manager.dailyGoal, locale: locale))
                    .font(.headline)
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .legibleOnBackdrop()
                    .contentTransition(.numericText(value: Double(shownTotal)))
                    .accessibilityHidden(true)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(.white)

            Spacer(minLength: 0)

            addButton
        }
        .padding(.horizontal, Self.margin)
        .animation(.smooth(duration: 0.5), value: shownTotal)
    }
```

  `addButton`, `dayTitle` and `spokenDay` are unchanged, except that `addButton`'s DocC no longer
  says a trailing button "scrolls out of reach" as its reason for sitting in the header: it now
  scrolls with the header, and says so.

- [ ] **Step 4: The week card.** Three changes inside `HistoryCard`:

  (a) a bar is cyan when its day reached the goal and white when it did not:

```swift
    private func bar(for day: DaySummary) -> some View {
        let fraction = min(Double(day.total) / Double(scale), 1)

        return ZStack(alignment: .bottom) {
            Capsule()
                .fill(.white.opacity(0.12))

            // Cyan for a day that reached the goal, white for one that did not (spec §6.1) — one
            // fill whose colour changes, so a day that crosses the goal animates a colour and not
            // a layer (rule `50-views`). **Colour is not the only carrier**: a met bar also stands
            // at or above the goal line (rule `65-accessibility`).
            //
            // Solid `Aurora.cyan`, **not** a `Aurora.blue` → `Aurora.cyan` gradient, and the
            // reason is a measurement rather than taste: pure `Aurora.blue` composites to
            // **2.72:1** against this pane, under the 3:1 non-text floor, and a nearly-empty day
            // is drawn almost entirely in that end.
            Capsule()
                .fill(day.reached(manager.dailyGoal) ? Aurora.cyan : Color.white)
                // A day with nothing logged still draws a sliver, so the bar reads as an empty day
                // rather than as a missing one. The series is zero-filled for the same reason.
                .frame(height: max(barHeight * fraction, day.total > 0 ? 6 : 2))
        }
    }
```

  (b) three figures, each over its label, in columns while they fit and in rows when they do not:

```swift
    /// *Average*, *Best day* and *Goal met*: three figures over their labels, side by side while
    /// they fit and one above the other when they do not.
    ///
    /// The chooser is offered the card's whole width and picks among whole layouts, and the
    /// columns are drawn at their own size or not at all (`tasks/lessons.md`, 2026-10-11): a
    /// column shrunk to fit is how *Goal met* would lose its last letters at the large sizes.
    ///
    /// Hidden from VoiceOver: the title already speaks all three as its value.
    private var figures: some View {
        let stats: [(figure: String, label: LocalizedStringKey)] = [
            (strings.figure("%1$@ ml", DaySummary.average(of: manager.history), locale: locale), "Average"),
            (strings.figure("%1$@ ml", DaySummary.best(of: manager.history), locale: locale), "Best day"),
            (strings.figure("%1$@ of %2$@", DaySummary.daysMet(in: manager.history, goal: manager.dailyGoal), manager.history.count, locale: locale), "Goal met"),
        ]

        return ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(stats.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 2) {
                        figure(stats[index].figure)
                        label(stats[index].label)
                    }
                    .fixedSize()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(stats.indices, id: \.self) { index in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        label(stats[index].label)
                        Spacer(minLength: 8)
                        figure(stats[index].figure)
                    }
                }
            }
            .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
        .accessibilityHidden(true)
    }

    private func figure(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.bold))
            .fontDesign(.rounded)
            .monospacedDigit()
    }

    private func label(_ key: LocalizedStringKey) -> some View {
        Text(key, bundle: strings)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white.opacity(0.9))
    }
```

  (c) the title speaks all three:

```swift
            .accessibilityValue(String(
                format: strings.localizedString(forKey: "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.", value: nil, table: nil),
                DaySummary.average(of: manager.history),
                DaySummary.best(of: manager.history),
                DaySummary.daysMet(in: manager.history, goal: manager.dailyGoal),
                manager.history.count
            ))
```

  The type's DocC paragraph "Every bar shares one fill. Goal-met is carried by height …, never by
  colour" is rewritten to say what is now true: colour **and** height. The two comments that say
  the card "sits above a `List`" and is "not in a `ScrollView`" are corrected — it is a row of
  the list now; the `fixedSize` they explain stays.

- [ ] **Step 5: The strip and the row.** A new `private struct DayStrip` after `HistoryCard`:

```swift
// MARK: - The day

/// When the shown day's servings were poured: one bar each, across the whole day.
///
/// **Midnight to midnight**, not the waking hours the canvas drew: a drink at 00:30 has to
/// appear (spec §6.2). A bar's place is a fraction of that day's real length, asked of the model
/// — a view holds no calendar (rule `30-rollover`) — so a 23- or 25-hour day draws correctly and
/// the hour labels stand where a serving poured on the hour stands.
///
/// **VoiceOver hears the title, as a heading, and nothing else.** The bars repeat the rows under
/// this card, each of which speaks its own amount and time; the reminder's mark repeats Home's
/// line (rule `65-accessibility`).
private struct DayStrip: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings

    /// The shown day's servings.
    let logs: [WaterLog]

    /// Whether to mark the next reminder — today only.
    let marksReminder: Bool

    /// A real magnitude, capped at its use site (rule `65-accessibility`): a decorative
    /// dimension that grew with the text would push the servings off the screen.
    @ScaledMetric(relativeTo: .footnote) private var scaledPlotHeight: CGFloat = 64

    private var plotHeight: CGFloat { min(scaledPlotHeight, 92) }

    /// A bar's width. The plot's travel is its own width less this, so the first and the last
    /// minute of the day both draw inside it.
    private let barWidth: CGFloat = 8

    private var bars: [StripBar] {
        HistoryView.stripBars(
            for: logs.map { (id: $0.id, amount: $0.amount, position: manager.dayFraction(of: $0.timestamp)) },
            vessels: manager.servings
        )
    }

    /// The labelled hours, as instants on the shown day. Any of its servings names the day.
    private var hours: [Date] {
        guard let anchor = logs.first?.timestamp else { return [] }
        return manager.hours(HistoryView.stripHours, onDayOf: anchor)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When you drank", bundle: strings)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 6) {
                plot
                axis
            }
            .accessibilityHidden(true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        // The week card's pair: sibling panes on one screen share one (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
    }

    private var plot: some View {
        GeometryReader { proxy in
            let travel = max(proxy.size.width - barWidth, 0)

            ZStack(alignment: .bottomLeading) {
                // The ground the bars stand on.
                Capsule()
                    .fill(.white.opacity(0.3))
                    .frame(height: 1)

                ForEach(bars) { bar in
                    Capsule()
                        .fill(Aurora.cyan)
                        .frame(width: barWidth, height: max(proxy.size.height * bar.height, barWidth))
                        .offset(x: travel * bar.position)
                }

                reminderMark(travel: travel, height: proxy.size.height)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomLeading)
        }
        .frame(height: plotHeight)
        .animation(.smooth(duration: 0.45), value: bars)
    }

    /// The next reminder, as a white rule under a bell — told from a serving by its shape as well
    /// as its colour. Re-read every minute, as Home's line is: a reminder that has passed stops
    /// being "next", and nothing else would say so on a screen nobody is touching.
    @ViewBuilder
    private func reminderMark(travel: CGFloat, height: CGFloat) -> some View {
        if marksReminder {
            TimelineView(.everyMinute) { _ in
                if let next = manager.nextReminder {
                    VStack(spacing: 2) {
                        Image(systemName: HomeView.reminderSymbol)
                            // A ratio of the plot it sits in, never its own text style.
                            .font(.system(size: height * 0.19, weight: .semibold))
                        Capsule()
                            .frame(width: 1.5, height: height * 0.5)
                    }
                    .foregroundStyle(.white)
                    .frame(width: barWidth)
                    .offset(x: travel * manager.dayFraction(of: next))
                }
            }
        }
    }

    private var axis: some View {
        GeometryReader { proxy in
            let travel = max(proxy.size.width - barWidth, 0)

            ForEach(hours, id: \.self) { hour in
                // The phone's own 12- or 24-hour form under the app's locale, as every time here.
                Text(hour, format: .dateTime.hour())
                    // A ratio of the plot it annotates, never a text style of its own
                    // (rule `65-accessibility`). 0.18 × 64 pt is 11.5 pt.
                    .font(.system(size: plotHeight * 0.18, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize()
                    .position(x: travel * manager.dayFraction(of: hour) + barWidth / 2, y: proxy.size.height / 2)
            }
        }
        .frame(height: plotHeight * 0.24)
    }
}
```

  And `ServingRow` takes its vessel:

```swift
private struct ServingRow: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let log: WaterLog

    /// The vessel this amount is drawn as, or `nil` — ``HistoryView/vessel(forAmount:amounts:)``.
    let vessel: HomeView.Serving?

    let edit: () -> Void

    /// The glyph's disc, a real magnitude scaled with the row's own text and capped at its use
    /// site (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .body) private var scaledDisc: CGFloat = 36

    var body: some View {
        let disc = min(scaledDisc, 52)

        return Button(action: edit) {
            HStack(spacing: 14) {
                // The vessel's glyph when the amount is one of the current three; the drop
                // otherwise.
                Image(systemName: vessel?.symbol ?? "drop.fill")
                    .font(.system(size: disc * 0.44, weight: .semibold))
                    .foregroundStyle(Aurora.cyan)
                    .frame(width: disc, height: disc)
                    .background(Circle().fill(Aurora.cyan.opacity(0.16)))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 1) {
                    Text(strings.figure("%1$@ ml", log.amount, locale: locale))
                        .font(.body.weight(.bold))
                        .fontDesign(.rounded)
                        .monospacedDigit()

                    // Drawn, never spoken: the name is an inference from today's vessels.
                    if let vessel {
                        Text(vessel.name(in: strings))
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                Spacer(minLength: 8)

                // Rendered through the phone's own 12/24-hour setting rather than a fixed pattern:
                // "14:32" on a 24-hour device, "2:32 PM" on a 12-hour one. Forcing HH:mm would
                // override a preference the user actually chose.
                Text(log.timestamp, format: .dateTime.hour().minute())
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.94))
            }
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.leading, 12)
            .padding(.trailing, 20)
            .padding(.vertical, 10)
            // A list row is a control, and a `minHeight` lets it grow with Dynamic Type instead of
            // clipping.
            .frame(minHeight: 56)
            .liquidGlass(in: Capsule(), density: .frosted, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
        // (the label, value and hint that follow are unchanged)
    }
}
```

- [ ] **Step 6: Remove the four keys that lost their reader.** Prove it first:

```bash
grep -rnE '"%1\$d of %2\$d ml"|"Average %1\$d ml"|"Best %1\$d ml"|"Average %1\$d millilitres\. Best %2\$d millilitres\."' WaterBuddy WaterBuddyWidget WaterBuddyWatch WaterBuddyWatchWidget | grep -v xcstrings | wc -l
```

  Expected: `0`. Then remove the four entries from `WaterBuddy/Localizable.xcstrings` with `Edit`.

- [ ] **Step 7: Build and run what exists.** `SUITE` = `HistoryStringTests` (now all green, the
  four removals included), then the whole unit target, then the UI suite as it stands, on
  *WaterBuddy Gate 27*:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO -collect-test-diagnostics never \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests > $SP/t4-ui.log 2>&1; echo "exit $?"
grep -E 'Executed [0-9]+ test|error:|XCTAssert|\*\* TEST' $SP/t4-ui.log | sort -u | cut -c1-260
```

  Expected: the unit target green; the UI suite's History tests green as written, **or** failing
  for a reason Task 5 is about to remove (a row below the fold, a row count that no longer moves).
  Each failure is read from its log and written in the ledger before Task 5 changes a test.

- [ ] **Step 8: Stage** the four source files and the catalogue.

---

### Task 5: The sheet's shortcuts, and the UI tests

**Files:**
- Modify: `WaterBuddy/HistoryView.swift` (`ServingSheet`), `WaterBuddyUITests/GoalSetupUITests.swift`

**Interfaces:**
- Consumes: Task 2's `sliderBounds(forAmount:vessels:)`; `HomeView.servings(amounts:)`;
  `LiquidGlass.Selection.fillOpacity` / `.rimOpacity`.

- [ ] **Step 1: Write the UI tests first.** In `GoalSetupUITests.swift`:

  (a) a helper beside `dayNames()`, and the rewrite of the test behind known issue #62 — it asserts
  on the day's own total, which the week card's button carries, and never on a count of rows a lazy
  list happens to have built:

```swift
    /// A day's total, off its button on the week card: the value reads "<n> millilitres".
    private static func millilitres(on day: XCUIElement) -> Int {
        Int((day.value as? String ?? "").split(separator: " ").first ?? "") ?? -1
    }

    /// Brings a serving row clear of the tab bar. With two cards above the servings, a day's
    /// first row can start under the bar or below the screen, and a lazy list builds only what is
    /// on it.
    @MainActor
    private func bringIntoView(_ row: XCUIElement, in app: XCUIApplication) {
        let bar = app.buttons["History"]
        var swipes = 0
        while swipes < 4, !(row.exists && row.frame.maxY < bar.frame.minY - 8) {
            app.swipeUp()
            swipes += 1
        }
    }
```

  In `testAServingAddedToYesterdayShowsUnderYesterday`, everything from `let rows = …` to the end
  becomes:

```swift
        // The day's total, off its own button. **Not a count of rows**: a lazy list builds only
        // the rows on screen, so a count stopped moving once a day held more than the screen
        // shows — and with two cards above the servings that is three or four of them
        // (`docs/AI_CONTEXT.md`, known issue #62).
        let before = Self.millilitres(on: yesterday)
        XCTAssertGreaterThanOrEqual(before, 0, "a day's button did not carry its total")

        XCTAssertEqual(
            app.buttons.matching(identifier: "Add a serving").count, 1,
            "the + must resolve to exactly one element"
        )
        app.buttons["Add a serving"].tap()

        XCTAssertTrue(app.datePickers.firstMatch.waitForExistence(timeout: 5), "the sheet did not open on its wheel")
        app.buttons["Save"].tap()

        let grew = NSPredicate { day, _ in
            (day as? XCUIElement).map { Self.millilitres(on: $0) > before } ?? false
        }
        let added = XCTNSPredicateExpectation(predicate: grew, object: yesterday)
        XCTAssertEqual(XCTWaiter().wait(for: [added], timeout: 5), .completed, "the new serving is not under yesterday")
        XCTAssertTrue(yesterday.isSelected, "the screen did not stay on the day the serving landed on")
```

  and its DocC's last sentence becomes: "Idempotent like the rest of this suite: it compares
  yesterday's total before and after rather than assuming an empty day, because the simulator
  keeps every serving an earlier run added."

  (b) in `testAServingRowOpensItsSheetWhereverItIsTapped`, the row is found and brought into view
  before its centre is tapped:

```swift
        let row = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", " millilitres")).firstMatch
        bringIntoView(row, in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 5), "History shows no serving for today")
```

  (c) two new tests, after it:

```swift
    /// History is one list now, and its second card is new: a heading, exactly once, above the
    /// rows it describes — and only on a day that has servings to place.
    @MainActor
    func testTheStripIsOneHeadingOverADaysServings() throws {
        let app = launchedOnHome()
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["When you drank"].waitForExistence(timeout: 5), "a day with a serving draws no strip")
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: "When you drank").count, 1,
            "the strip's heading must resolve to exactly one element"
        )
    }

    /// The sheet's three vessels, from outside the process: each is one button, the one whose
    /// amount the sheet shows is selected, and a tap on another moves the slider to its amount.
    ///
    /// Matched by name and compared by value, never by a literal amount: the vessels are the
    /// user's to edit, and this suite never resets the device. Nothing is saved.
    @MainActor
    func testTheSheetsVesselShortcutsSetTheAmount() throws {
        let app = launchedOnHome()
        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        app.buttons["Add a serving"].tap()

        let slider = app.sliders["Serving amount"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5), "the sheet did not open")

        for name in ["Cup", "Glass", "Bottle"] {
            XCTAssertEqual(
                app.buttons.matching(identifier: name).count, 1,
                "\(name) must be exactly one button in the sheet"
            )
        }

        // A new serving opens on the Glass's amount, so the Glass is the one selected.
        let glass = app.buttons["Glass"]
        XCTAssertEqual(slider.value as? String, glass.value as? String, "the sheet did not open on the Glass's amount")
        XCTAssertTrue(glass.isSelected, "the shortcut whose amount is showing is not marked selected")

        // Low on the capsule and to one side: off its glyph and its figure, on nothing but the
        // control's own surface.
        let bottle = app.buttons["Bottle"]
        bottle.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.8)).tap()

        let moved = NSPredicate(format: "value == %@", bottle.value as? String ?? "")
        let set = XCTNSPredicateExpectation(predicate: moved, object: slider)
        XCTAssertEqual(XCTWaiter().wait(for: [set], timeout: 5), .completed, "a tap on the Bottle did not set its amount")
        XCTAssertTrue(bottle.isSelected, "the Bottle was tapped and is not marked selected")
        if glass.value as? String != bottle.value as? String {
            XCTAssertFalse(glass.isSelected, "two vessels of different amounts are both marked selected")
        }

        app.buttons["Cancel"].tap()
        XCTAssertTrue(slider.waitForNonExistence(timeout: 5), "Cancel did not dismiss the sheet")
    }
```

- [ ] **Step 2: Run the two new tests and see them fail** on *WaterBuddy Gate 27*, with
  `-only-testing:WaterBuddyUITests/GoalSetupUITests/testTheSheetsVesselShortcutsSetTheAmount` and
  `…/testTheStripIsOneHeadingOverADaysServings`. Expected: the first fails at "Cup must be exactly
  one button in the sheet" (0 found); the second passes already — Task 4 drew the strip — which is
  recorded as such, not called RED. To see the second fail, the strip's title is taken out for one
  run and put back (`git checkout -- WaterBuddy/HistoryView.swift` restores the staged copy).

- [ ] **Step 3: Implement the shortcuts.** In `ServingSheet`, `bounds` contains the vessels:

```swift
    private var bounds: ClosedRange<Int> {
        HistoryView.sliderBounds(forAmount: openingAmount, vessels: manager.servings)
    }
```

  and `card` gains `shortcuts` between the slider and the wheel:

```swift
    /// The three vessels as one-tap amounts, under the slider they set (spec §6.3).
    ///
    /// **Selected with the selection tokens, not with the white the canvas drew**: a screen
    /// carries one primary surface, and *Save* is it (rule `60-design-system`). The fill and the
    /// rim are present at zero opacity when unselected, so moving the selection animates a colour
    /// and not a layer (rule `50-views`) — and selection is never colour alone: the rim, the
    /// weight and the `.isSelected` trait all carry it (rule `65-accessibility`).
    ///
    /// Two vessels that hold one amount are both selected, which is the truth.
    private var shortcuts: some View {
        HStack(spacing: 8) {
            ForEach(HomeView.servings(amounts: manager.servings)) { serving in
                shortcut(serving)
            }
        }
        .padding(.horizontal, 16)
        .animation(.smooth(duration: 0.3), value: amount)
    }

    private func shortcut(_ serving: HomeView.Serving) -> some View {
        let isSelected = amount == serving.amount

        return Button {
            amount = serving.amount
        } label: {
            HStack(spacing: 6) {
                Image(systemName: serving.symbol)
                Text(serving.amount, format: .number)
                    .monospacedDigit()
            }
            .font(.subheadline.weight(isSelected ? .bold : .semibold))
            .fontDesign(.rounded)
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 8)
            // The whole slot is the target, never just the glyph (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
                Capsule()
                    .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
                    .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // The glyph is what says "cup" on screen; the name is what says it aloud, and the amount
        // is the value.
        .accessibilityLabel(Text(verbatim: serving.name(in: strings)))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), serving.amount))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
```

- [ ] **Step 4: Run the UI suite green** on *WaterBuddy Gate 27*: all of `GoalSetupUITests`, the
  two new tests and the rewritten one among them. Then the same on *WaterBuddy Gate 26.5* — the
  system where a pane in this list once ignored a tap.

- [ ] **Step 5: See the rewritten test fail under its defect.** With `manager.addLog` in the sheet's
  *Save* made to add to today whatever the wheel says, `testAServingAddedToYesterdayShowsUnderYesterday`
  must fail at "the new serving is not under yesterday". Restore from the index and prove the tree
  is clean of the mutation (`git status --short WaterBuddy/HistoryView.swift` shows `M ` with an
  empty second column once staged). The ledger names the mutation.

- [ ] **Step 6: Stage** `WaterBuddy/HistoryView.swift` and `WaterBuddyUITests/GoalSetupUITests.swift`.

---

### Task 6: On the simulator — render, operate and measure

**Files:** create `WaterBuddyUITests/ZZHistoryProbe.swift`, then **delete it** before anything else
is staged. The sampler and its scripts stay in the scratchpad.

A green suite cannot see a pane that renders wrong, text that cannot be read, or a layout that does
not fit. Every finding goes into the ledger as one line with its figure.

- [ ] **Step 1: The sampler.** Copy stage 2's and compile it:

```bash
cp /private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/8ca202ef-728b-4bc5-a62d-d42f136d9786/scratchpad/measure.swift $SP/measure.swift
xcrun swiftc -O -o $SP/measure $SP/measure.swift && $SP/measure 2>&1 | head -2
```

- [ ] **Step 2: Write the probe** — `ZZHistoryProbe`, headed `// THROWAWAY`, on stage 2's pattern
  (`shot`, `report`, `launched()` with `WB_VARIANT` = `axxxl`, `ru` or `uz`). Its tests:

  - `testA_Walk` — pour a Cup, a Glass and a Bottle on Home; open History; capture; report the
    frames of the heading, the `+`, *Last 7 days*, each day button, *When you drank*, the first
    row and the tab bar; tap yesterday **off its bar, low in its slot**; capture; add a serving to
    yesterday through the sheet, capturing the sheet as it opens and after the Bottle's shortcut is
    tapped; capture yesterday with its serving; open a row for editing and capture; cancel;
    swipe-delete yesterday's serving and capture what is left; scroll today's list to its foot and
    capture.
  - `testB_Sweep` — History on today, every three seconds for a minute, at rest; then the same
    with the list scrolled so the rows are over the magenta light.
  - `testC_Week` — through the sheet, give three past days enough to reach the goal and one a
    single serving, so the card draws cyan and white bars and a *Goal met* that is not zero.
  - `testD_Reminders` — reminders on through the app's own switch and the system's alert, then
    History: the strip's bell.
  - `testR_ToggleReduceTransparency` — stage 2's, ending on History.

- [ ] **Step 3: Run it on Apple's glass, oldest system first** — *WaterBuddy Probe 26.5*, then
  *WaterBuddy Probe 27* — each with `-resultBundlePath` into a **new** directory under `$SP`, and
  export the attachments with `xcrun xcresulttool export attachments`.

- [ ] **Step 4: Look at every capture** with `Read`, and write down what is seen: the heading and
  its total on one side, the `+` on the other; the week card's bars in two colours, the shown day
  ringed, three figures over three labels; the strip's bars inside its plot with the three hours
  under them; rows with a glyph, an amount, a name where there is one, and a time; the sheet's
  three shortcuts under the slider with one ringed; nothing blank, clipped or overlapping; the
  whole screen moving as one when scrolled.

- [ ] **Step 5: Measure every pair, through the sweep**, the worst of twenty frames, at rest and
  scrolled:

| Pair | Foreground | Floor |
|---|---|---|
| The heading (34 pt bold), on the aurora | white | 3 |
| The total under it, on the aurora | white | 4.5 |
| The `+` on its disc | white | 3 |
| Week card: its title; a figure; a label | white; white; white 0.9 | 4.5 |
| Week card: the disclosure | white 0.70 | 4.5 |
| Week card: a weekday letter, unselected | white 0.72 | 4.5 |
| Week card: a met bar; an unmet bar; the goal line; the shown day's rim | `Aurora.cyan`; white; white 0.55; white 0.55 | 3 |
| Strip: its title; an hour label | white; white 0.9 | 4.5 |
| Strip: a bar; the reminder's rule and bell; the ground line | `Aurora.cyan`; white; white 0.3 | 3; 3; — (decorative) |
| Row: the amount; the name; the time | white; white 0.9; white 0.94 | 4.5 |
| Row: the glyph on its disc | `Aurora.cyan` on the tinted disc | 3 |
| Sheet: a shortcut's figure and glyph; the selected rim | white; white 0.55 | 4.5 / 3; 3 |

  Text on the aurora — the first two rows — is read on clean ground **and** beside its glyphs, and
  both figures are recorded (known issue #95).

- [ ] **Step 6: Decide from the table.** A pair under its floor is a defect of this stage unless it
  is older than it. The remedies this plan authorises, each re-rendered and re-measured:

  1. **A dimmed white goes toward full white** (a label, the name, an hour).
  2. **A cyan glyph on its tinted disc that reads under 3:1** loses the disc's tint first, then
     goes white.
  3. **A pair that fails on the hand-made pane alone, for known issue #85's reason** — the pane is
     lighter than its records — is recorded against #85 with its figure and not fixed by retuning
     the hand-made stack, which is the owner's decision.
  4. **Text on the aurora that still fails on clean ground at full white with its two shadows** is
     left as drawn and taken to the owner with both figures; it is Home's question again (#95).

- [ ] **Step 7: The settings**, on *WaterBuddy Probe 27*, the device booted first and each setting
  read back before and after: Increase Contrast, Reduce Motion, Reduce Transparency — each followed
  by `testA_Walk`. Under Reduce Transparency every pane is the opaque fill with its rim, and a day,
  a row and a shortcut still answer off their glyphs.

- [ ] **Step 8: The fallback, on iOS 18.6** — *WaterBuddy Fallback 18.6*: `testA_Walk`,
  `testB_Sweep`, `testC_Week`; look and measure as in Steps 4 to 6. The two elevation shadows of the
  cards and the rows must not be sliced by a list row's edge (rule `60-design-system`).

- [ ] **Step 9: Large text and the other languages.** On *WaterBuddy Probe 27*: `testA_Walk` with
  `WB_VARIANT=axxxl`, then `ru`, then `uz`; and `axxxl` in Russian by adding the language arguments
  to that variant for one run. The three figures fall back to rows without cutting a word; the
  strip's hours do not collide; a row's name and time stay whole; the sheet's shortcuts stay at
  least 44 pt high.

- [ ] **Step 10: The smallest phone.** A 375 × 667 pt device is the one size none of the eight
  simulators has. Make one, named for the project, and record its UDID for the owner:

```bash
xcrun simctl create "WaterBuddy Small 26.5" "iPhone SE (3rd generation)" com.apple.CoreSimulator.SimRuntime.iOS-26-5
```

  `testA_Walk` at the default size: the heading, the week card and the top of the strip are on
  screen at rest; the first serving is reached by scrolling; each day button is at least 44 pt wide.

- [ ] **Step 11: Delete the probe and prove it is gone** — `git status --short | grep -c ZZ` reads
  `0`. A copy stays in `$SP`.

- [ ] **Step 12: Stage** whatever Step 6 changed, by path.

---

### Task 7: The rules — written, shown, left unstaged

**Files:** `.claude/rules/50-views.md`, `.claude/rules/65-accessibility.md`. `.claude/` changes when
the owner decides (rule `99-docs-cascade`); **none of it is staged**. It is quoted in the report
for a yes.

- [ ] **Step 1: `50-views.md`.** In *Composition*, after the bullet on Home's column, add:

> - History is one `List`, and everything on the screen is a row of it: the header, the week card,
>   the strip and the servings, each with the list's own surfaces cleared. Nothing is fixed above
>   it, so the `+` scrolls away with the header
> - What History decides is a `nonisolated static` on `HistoryView` that takes its state as
>   parameters — `stripBars(for:vessels:)`, `vessel(forAmount:amounts:)`,
>   `sliderBounds(forAmount:vessels:)`. Where an instant falls in a day is the model's answer:
>   `dayFraction(of:)` and `hours(_:onDayOf:)`

- [ ] **Step 2: `65-accessibility.md`.** In *VoiceOver*, after the bullet on the week card, add:

> - The week card's summary speaks the average, the best day and the days the goal was met. A met
>   day's bar is cyan and an unmet day's white, and never by colour alone: a met bar also stands at
>   or above the goal line
> - The strip is one heading, *When you drank*, and its bars, hours and reminder mark are hidden:
>   the rows under it speak every serving
> - A serving row's vessel name is drawn and never spoken — it is an inference from today's
>   vessels. The sheet's three shortcuts are one button each: label the vessel's name, value its
>   amount, `.isSelected` on the one whose amount is showing

- [ ] **Step 3: Prove none of it is staged** — `git diff --cached --name-only | grep -cE '^(\.claude/|CLAUDE\.md)'`
  reads `0`.

---

### Task 8: The review, the gate, the warning comparison

**Files:** none changed, unless the review finds something.

- [ ] **Step 1: Read the diff against the rules** — `git diff --cached` for the source files. Check:
  no colour literal; no `glassEffect` outside `LiquidGlassModifier.swift`; no bare `withAnimation`,
  `print` or `Date()` in logic; no `Calendar` in a view; every new static a test reads is
  `nonisolated`; no `TODO`; comments say why and none describes the screen that was replaced;
  `.buttonStyle(PressStyle())` on every button whose label is a pane; every mutation one call into
  `DataManager`; every figure drawn is grouped and every figure spoken is not.

- [ ] **Step 2: One fresh reviewer, read-only, before the gate** — so its fixes land before the last
  measurement and the gate runs once, on the final source. A general-purpose agent with the spec,
  this plan, the ledger and `git diff --cached` for the source, test and catalogue files, asked for
  defects by severity with a failure scenario each, and told to write nothing. **Its report is
  saved to a file beside the ledger when it arrives.** Every Critical and Important finding is
  fixed test-first or answered in the ledger with its reason.

- [ ] **Step 3: The gate**, foreground, as rule `85-testing` writes it, without `shutdown all`. The
  unit run on the rule's own destination; the UI run on the Gate devices, once per system — iOS
  27.0 and 26.5 as the rule requires, 18.6 for the hand-made path:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO > $SP/g1.log 2>&1; echo "exit $?"
grep -E '✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/g1.log | cut -c1-220
```

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests > $SP/g2-27.log 2>&1; echo "exit $?"
grep -E 'Executed [0-9]+ test|error:|\*\* TEST' $SP/g2-27.log | sort -u | cut -c1-220
```

  (the same for `OS=26.5,name=WaterBuddy Gate 26.5` and `OS=18.6,name=WaterBuddy Gate 18.6`, one
  per `Bash` call)

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=27.0,name=Apple Watch Series 12 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO > $SP/g3.log 2>&1; echo "exit $?"
grep -E '✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/g3.log | cut -c1-220
```

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' > $SP/g4.log 2>&1; echo "exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=27.0,name=Apple Watch Series 12 (46mm)' > $SP/g5.log 2>&1; echo "exit $?"
grep -hE '\*\* BUILD' $SP/g4.log $SP/g5.log
```

  Expected: the unit count re-derived with
  `grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'` and every
  one passing; `Executed N tests, with 0 failures` three times; the watch's 57 tests in 6 suites;
  `** BUILD SUCCEEDED **` twice. If the watch's pinned device does not boot, both watch
  invocations run on *WaterBuddy Watch 27* and the record says so.

- [ ] **Step 4: Clean builds of the change**, into empty DerivedData, beside Task 0's baseline. The
  files come out of the **index**, so the comparison is of what will be committed:

```bash
mkdir -p $SP/wc/change && git archive HEAD | tar -x -C $SP/wc/change
git diff --cached --name-only --diff-filter=AM | grep -E '^(WaterBuddy|WaterBuddyTests|WaterBuddyUITests)/' | while read f; do
  mkdir -p "$SP/wc/change/$(dirname "$f")" && git show ":$f" > "$SP/wc/change/$f"
done
git diff --cached --name-only --diff-filter=AM | grep -cE '^(WaterBuddy|WaterBuddyTests|WaterBuddyUITests)/'
```

  Then Task 0's four builds with `base` replaced by `change`, the same reduction, and
  `diff $SP/wc/base-$log.warn $SP/wc/change-$log.warn` for each. Expected: identical four times. Any
  difference is a new warning: fix it at the declaration, then run Steps 3 and 4 again.

---

### Task 9: Records, docs — then stop

**Files:** `HISTORY.md`, `tasks/lessons.md`, and what `/doc_sync` writes under `docs/`.

- [ ] **Step 1: Append a checkpoint to `HISTORY.md`** with `Edit`, anchored on the file's last
  lines, headed `## [<the day it is written>] — The redesign's stage 3: History`. It records what
  changed; the rulings it rests on, each the owner's to overturn; the files; **the verification
  actually run**, with real figures and their conditions — the unit and UI counts and their
  destinations, the watch run, the two builds, the warning comparison with its unit, Task 6's
  measured table on each system with the sweep's length and both yardsticks, each setting and what
  was operated under it, the phones and sizes rendered; what was **not** run; where the build
  differs from the canvas; and what is left unstaged for the owner. Every count comes from a
  command run in that step.

- [ ] **Step 2: Append to `tasks/lessons.md`**, with `Edit`, what this stage taught that the next
  would repeat. If nothing did, append nothing.

- [ ] **Step 3: Run `/doc_sync`.** It starts from the tree and runs the git block first: stage 2 is
  committed (`1ced514`, `e7406a5`, `6b5f319`, `e16221e`), which the docs still call staged; this
  stage's state, counts and gate; known issues #39 (closed for History; Settings and both widgets
  remain), #62 (the test rewritten), #83 (what the probe read from the heading's value), #84(c),
  #85 and #95 (History's figures), #103 (the comments this stage rewrote); `docs/DESIGN.md`'s
  tables for History.

- [ ] **Step 4: Stage, explicit paths only, and stop**

```bash
git add HISTORY.md tasks/lessons.md docs/AI_CONTEXT.md docs/DESIGN.md docs/STATE.md docs/WIDGET.md docs/superpowers/plans/2026-10-11-premium-redesign-stage-3.md
git diff --cached --name-status
git diff --name-status
```

  Expected: the second list shows the two rule files of Task 7 and the paths left unstaged before
  this stage; `Screenshots/census/` stays untracked. **Do not commit.** Report to the owner: what
  was built, the measured table, what was not run, the rule wording for their yes, any decision
  Task 6 Step 6 left for them, the simulator made in Task 6 Step 10, and the device check below.

**The owner's device check for this stage** — what no simulator shows:

1. History in daylight on an iPhone on iOS 26 or later: the heading and the total read easily over
   the aurora as it moves, and the cards' small text reads on the glass.
2. Scroll a day with many servings: the header and both cards move away with the list, and come
   back at the top with the `+`.
3. Tap each day on the week card, anywhere in its slot: it rings, the strip and the rows change,
   and a day that reached the goal is plainly a different colour from one that did not.
4. The strip: a drink logged now appears at the right place for the time of day; with reminders
   on, the bell stands at the next reminder and moves on after it passes.
5. Add a serving with the `+`: tap Cup, Glass and Bottle under the slider — the figure follows, the
   one showing is ringed, and *Save* files it on the day the wheel says.
6. Swipe a serving away and tap another to edit it: both answer anywhere on the row.
7. With VoiceOver on: the heading reads the day and its total once; the week card reads its three
   figures; *When you drank* is a heading; a row reads its amount and time and not a vessel's name;
   the three shortcuts read their names and amounts, and which is selected.
8. The largest text size: nothing is cut short, and the screen scrolls.
9. Russian and Uzbek: every new line reads naturally — the Uzbek is mine and wants a native eye.

---

## Where the build left this plan

Written at the end of the build, 2026-10-11. The plan above is as it was approved; what was built
differs from its printed code in the places below. Each is a ruling in the stage's ledger and in
`HISTORY.md`'s checkpoint of that day, and each is the owner's to overturn.

**Built as the plan prints it:** the model's four answers and their tests (Task 1), the pure
statics (Task 2), the six keys and the four removals (Task 3). **Built on its lines, with the
differences below:** the one list, the week card's two colours and three figures, the strip
and the row's parts (Task 4), the shortcuts and the rewritten yesterday test (Task 5).

**Different from the printed code:**

- The list carries `.padding(.top, 1)`: with nothing fixed above it, its rows were drawn on up
  under the status bar.
- Each strip bar has a 1 pt dark hairline; a row's glyph sits in a dark well, not on a cyan
  wash. The plan's remedy for a glyph under its floor was that it "loses the disc's tint first,
  then goes white".
- The week card's figures have a third, stacked layout. The shortcuts' glyph and figure share
  one size that stops at 30 pt, in one of two layouts. A row is one of two whole layouts. The
  sheet's slider, shortcuts and wheel sit 8 pt apart.
- The header: the `+` shares the title's line and the total has the row's whole width; at an
  accessibility text size a past day's title is two lines, the weekday and then the date, and
  it may shrink to 0.5. The week's and the strip's titles may take two lines.
- The "day's total grew" check is a five-second poll. `week(_:)` in the tests starts on the
  20th, not the 24th. No assertion differs from the plan's.
- Three UI tests the plan does not print, each written from a defect a render showed: the
  shortcuts' figures, a row's amount and a past day's heading at the largest text size. With
  the plan's two that is five new, and `GoalSetupUITests` holds twenty-five.
- After the review: yesterday's test also asserts that a serving is listed as one button in its
  row; `onlyTheSpokenHistoryStringTakesRawNumbers`, which compared two literals, is replaced by
  `theOnlyRawVolumesLeftToDrawAreOtherScreens`, which reads the built table.

**Not in the plan at all:** known issue #92's test moved onto `UnreadableStore` — two test
files, staged beside the stage as its own change, after the unit gate failed on it twice in
three runs.

**Task 6's measurements** are in `docs/DESIGN.md`, *History, measured*. One line ships under
the floor the stage took — the total under the heading, by the clean-ground yardstick — and
went to the owner with both figures, as Step 6.4 says. The reminder's mark was rendered from a
stand-in time: reminders could not be switched on on a simulator.

**Task 8** ran the UI target as two invocations a system, 25 tests and 18, because one no
longer fits a foreground call; and the three settings were walked on a build older than the
final one.

**The device check above still stands**, with two additions: in item 8, at the largest text
size a past day's heading is on two lines; and in item 4, the bell on the strip has not been
seen drawn from a real reminder at all.
