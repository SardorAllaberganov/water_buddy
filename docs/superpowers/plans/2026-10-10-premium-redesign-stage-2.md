# The Premium Redesign, Stage 2 (Home) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent ("Planning, test authorship, implementation and review
> all happen in the main loop"). Steps use checkbox (`- [ ]`) syntax for tracking. **No step commits:**
> each task ends by staging its paths, and nothing is committed until the owner runs `/commit`.

**Goal:** Home shows the day at a glance — the date and *Today*, a streak, a larger vessel, what is
left to drink, when the user last drank and when the next reminder is due — and a mis-tapped pour can
be taken back from the same screen, with the Glass drawn as the screen's one main action.

**Architecture:** Everything Home newly shows is derived on `DataManager` and stored nowhere:
`remaining`, `hasReachedGoal`, `lastDrink`, `nextReminder` are computed from the observable state, and
`streak` is published from the history republish through a pure `DaySummary.streak(of:goal:)`.
`addLog` returns the id of the row it inserted and `undoLog(id:)` deletes that row, so a view never
holds a `WaterLog`. The quick-add row's two glass discs sit in a `.glassGroup()` (Apple's
`GlassEffectContainer`, a pass-through below iOS 26), the Glass disc is `.primarySurface(in:)`, and
visible volumes are grouped by one `Bundle.figure(_:_:locale:)` helper.

**Tech Stack:** Swift (language mode 5; the app target defaults to main-actor isolation, the test,
widget and watch targets do not), SwiftUI (iOS 17 floor, `glassEffect` and `GlassEffectContainer` from
the iOS 26 SDK), SwiftData, swift-testing, XCTest (the UI suite and one throwaway probe), Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-09-premium-redesign-design.md` — §5 (Home), §3.1 (grouped
figures), §3.2 (the glass container), §10 (rule changes), §11 (verification), §14 (stages). Approved by
the owner on 2026-10-09 with all of §13. **The canvas:** boards *Home* (`project/Main.dc.html`) and
*Home · just poured* (`project/HomeUndo.dc.html`) of
<https://claude.ai/artifact/UYGcabBfVjduqkzvqtZ5bt>, read on 2026-10-10.

**Authority for running it:** the owner's "go" of 2026-10-10 to the stage's outline, on top of the
2026-10-09 ruling "build the remaining stages straight through … stopping only at each stage's
`/commit` or a real design decision". This plan is therefore executed without a second approval.

## Global Constraints

- **Floors stay iOS 17.0 and watchOS 26.0.** No new `#available` beyond `if #available(iOS 26.0, *)`
  inside `#if os(iOS)`, in `LiquidGlassModifier.swift` only.
- **Nothing is stored.** No new `DataManager.Key`, no change to `WaterLog`, no change to
  `WaterSnapshot` or `WristMirror`. `Key.all` still holds eleven keys.
- **No new file in a shared set and no `project.pbxproj` edit.** `DataManager.swift` and
  `LiquidGlassModifier.swift` compile into four bundles; every change to either is followed by
  building the other three schemes.
- **One writer.** Every mutation is one call into `DataManager`. A view holds an id, never a
  `WaterLog`, outside a sheet's selection (rule `50-views`).
- **A failed read is never written back**, and never published as zero (rule `20-state`).
- **No unpinned `Date()` in logic.** The model's injected `now()` decides what "today", "last" and
  "next" mean. The view's `lastPour = Date()` is presentation state and stays as it is.
- **Volumes are `Int`.** A `Double` is a drawing fraction only.
- **Every label the UI tests query today is kept**: the vessel as one element with the value
  `%1$d percent. %2$d of %3$d millilitres.`, and `<Name>, add N millilitres` on the three buttons.
  **Spoken strings keep `%d` keys; visible volumes use `%@` keys fed by `Bundle.figure`.**
- **Every new string has explicit `en`, `ru` and `uz` values** in `WaterBuddy/Localizable.xcstrings`
  and is resolved through `@Environment(\.strings)`. None reaches a notification, the widget or the
  watch.
- **No colour literal, no `glassEffect` or `GlassEffectContainer` at a call site**, no bare
  `withAnimation`, no bare `print`.
- **New statics a test outside the main actor reads are `nonisolated`**; a new file-scope value type
  is `nonisolated` and `Sendable`. A main-actor warning on a new declaration is fixed on the
  declaration, never by annotating the suite (rule `43-concurrency`).
- **Tests first.** Write the test, run it, see it fail for the predicted reason, then implement.
  Never narrow an assertion to make it pass. Test names are not reused across suites.
- **A contrast figure is measured off a render, the worst frame of a sweep at least as long as the
  aurora's slowest light (28.5 s), on every iOS the pane draws on** (rule `65-accessibility`, lessons
  of 2026-10-10). Floors: 4.5:1 for text, 3:1 for a glyph or a rim, 3:1 for text of 24 pt or more.
- **Edits with `Edit`/`Write` only.** A script reads; it never writes into the repository.
  `Bash(sed -i:*)` and `Bash(xcrun simctl erase:*)` are denied; a refused call is a stop.
- Every `xcodebuild` in the foreground, `-parallel-testing-enabled NO`, one simulator at a time.
  **Probes pour on simulators made for probing; the gate's UI suite runs on simulators made for the
  gate** (known issues #62, #90).
- No new warning against a clean build of HEAD `b8a1386` (Task 0 takes the baseline).
- **Never touch or stage** what was unstaged before this stage: `.claude/settings.json`, the two
  watch schemes, `WaterBuddy/AppShortcuts.xcstrings`, the two watch catalogues, `Screenshots/census/`.

## Review Focus

Conditions the spec implies that the model's unit tests cannot drive, most likely to bite first, each
with the check that owns it:

1. **Two pours in quick succession, then Undo.** Only the second is taken back, and the first pour's
   eight-second timer must not clear the second's offer. → Task 7's
   `testUndoAfterTwoPoursTakesBackOnlyTheLast`.
2. **An Undo that outlives midnight.** The pour is yesterday's water by then; Undo must do nothing and
   the offer must go. → Task 1's `undoingAfterTheDayTurnedLeavesYesterdayAlone`; the view withdraws
   the offer when its row leaves `todaysLogs` (Task 7).
3. **A tap on a quick-add disc on iOS 26.5, inside the glass container.** Stage 1 found a pane on
   26.5 that was not part of its button's hit region. → Task 8's probe taps each disc off its glyph on
   iOS 26.5, 27.0 and 18.6; Task 10 runs the UI suite on all three.
4. **The smallest phone at the largest text size.** Home must scroll, keep every disc at 44 pt or
   more and clip nothing. → Task 8's captures on a 375 × 667 pt simulator at `AccessibilityXXXL`.
5. **A longer language on the quiet line.** *Next reminder* and *Last drink* side by side do not fit
   in Russian. → `ViewThatFits` stacks them; Task 8 captures Home in Russian.

---

## File structure

| File | Change | Responsibility |
|---|---|---|
| `WaterBuddy/DataManager.swift` | modify | `addLog` returns an id, `undoLog(id:)`, `remaining`, `hasReachedGoal`, `lastDrink`, `nextReminder`, `streak` and its publishing, `dayDidTurn()`, `windowStart(days:endingOn:calendar:)`, `DaySummary.streak` / `streakFillsWindow`, `Bundle.figure` |
| `WaterBuddy/LiquidGlassModifier.swift` | modify | `.glassGroup()`; `routed` branches the background only (#91a) |
| `WaterBuddy/HomeView.swift` | modify | the screen: header, streak chip, vessel, status, quiet line, Undo, ranked quick-add row, scroll |
| `WaterBuddy/Localizable.xcstrings` | modify | ten new keys; `%1$d / %2$d ml` removed with its only reader |
| `WaterBuddyTests/HomeModelTests.swift` | create | `UndoTests`, `HomeFiguresTests`, `DayTurnTests` |
| `WaterBuddyTests/StreakTests.swift` | create | `StreakCountTests` (pure), `StreakPublishingTests` |
| `WaterBuddyTests/HomeViewTests.swift` | modify | `HomeLayoutTests` (pure) |
| `WaterBuddyTests/LocalizationTests.swift` | modify | `homeKeys`, `GroupedFigureTests` |
| `WaterBuddyUITests/GoalSetupUITests.swift` | modify | Undo's four tests, Home's heading, History found by *Add a serving* |
| `WaterBuddyUITests/AppStoreScreenshotUITests.swift` | modify | History found by *Add a serving* (compiled, not run) |
| `WaterBuddyUITests/ZZHomeProbe.swift` | create, then **delete** | Task 8's throwaway captures |
| `.claude/rules/20-state.md`, `30-rollover.md`, `50-views.md`, `60-design-system.md`, `65-accessibility.md`, `CLAUDE.md` | modify, **left unstaged** | Task 9's wording, for the owner's yes |
| `HISTORY.md`, `tasks/lessons.md`, `docs/` | modify | Task 11 |

Shell variable used below — **each `Bash` call is a fresh shell**, so set it in every command:

```bash
SP=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/8ca202ef-728b-4bc5-a62d-d42f136d9786/scratchpad
```

One unit suite (replace `SUITE`):

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:WaterBuddyTests/SUITE -parallel-testing-enabled NO > $SP/t.log 2>&1; echo "exit $?"
grep -E 'error:|✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/t.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-220
```

The three other schemes, after any change to `DataManager.swift` or `LiquidGlassModifier.swift`:

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' > $SP/b-widget.log 2>&1; echo "widget exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'generic/platform=watchOS Simulator' > $SP/b-watch.log 2>&1; echo "watch exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'generic/platform=watchOS Simulator' > $SP/b-watchwidget.log 2>&1; echo "watchwidget exit $?"
grep -hE 'error:|\*\* BUILD' $SP/b-widget.log $SP/b-watch.log $SP/b-watchwidget.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-220
```

The ledger — one line per finding, ruling or deviation, as stage 1 kept:
`.superpowers/sdd/2026-10-10-premium-redesign-stage-2/progress.md` (ignored by git).

---

### Task 0: The baseline and the simulators

**Files:** none in the repository.

- [ ] **Step 1: Open the ledger.** Create
  `.superpowers/sdd/2026-10-10-premium-redesign-stage-2/progress.md` with the plan's path, HEAD and
  the scratchpad path.

- [ ] **Step 2: Clean builds of HEAD into empty DerivedData, four schemes**, each its own foreground
  invocation:

```bash
rm -rf $SP/wc && mkdir -p $SP/wc/base && git archive HEAD | tar -x -C $SP/wc/base
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

Expected: four exits of 0 and four counts written to the ledger. Stage 1 read 38 / 19 / 2 / 19 on
this toolchain; a different figure is recorded, not explained away.

- [ ] **Step 3: Make the probe simulators** and record their UDIDs in the ledger:

```bash
xcrun simctl create "WB2 Probe 27" "iPhone 17" com.apple.CoreSimulator.SimRuntime.iOS-27-0
xcrun simctl create "WB2 Probe 26.5" "iPhone 17" com.apple.CoreSimulator.SimRuntime.iOS-26-5
xcrun simctl create "WB2 Probe 18.6" "iPhone 16" com.apple.CoreSimulator.SimRuntime.iOS-18-6
xcrun simctl create "WB2 Small 26.5" "iPhone SE (3rd generation)" com.apple.CoreSimulator.SimRuntime.iOS-26-5
xcrun simctl create "WB2 Large 27" "iPhone 17 Pro Max" com.apple.CoreSimulator.SimRuntime.iOS-27-0
```

If iOS 26.5 refuses the SE, make it on iOS 18.6 ("WB2 Small 18.6") and say so: the smallest screen is
then rendered on the hand-made glass only.

---

### Task 1: A pour has an id, and Undo takes it back

**Files:**
- Create: `WaterBuddyTests/HomeModelTests.swift`
- Modify: `WaterBuddy/DataManager.swift` (`addLog(amount:at:)`, and after `deleteLog(_:)`)

**Interfaces:**
- Produces: `@discardableResult func addLog(amount: Int, at date: Date? = nil) -> UUID?`;
  `func undoLog(id: UUID)`.

- [ ] **Step 1: Write the failing suite.** `WaterBuddyTests/HomeModelTests.swift`:

```swift
//
//  HomeModelTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 10/10/26.
//

import Foundation
import Observation
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

/// A Gregorian/UTC day, so nothing here can flake on a machine sitting near local midnight.
private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// A clock a test can move, so one instance can be built before midnight and used after it.
private final class MovableClock: @unchecked Sendable {
    var now: Date
    init(_ now: Date) { self.now = now }
}

/// What the manager rang while a test watched.
private final class Taps {
    var reloads = 0
    var plans: [[ReminderPlan.Slot]] = []
}

/// `withObservationTracking`'s `onChange` is `@Sendable`, so the tally needs a reference box.
private final class Counter: @unchecked Sendable {
    var count = 0
}

/// One manager over a UUID-named throwaway suite **and** an in-memory store, on a clock the test
/// moves, every side effect routed to ``Taps``. All seven `init` arguments are passed: the
/// defaults of `modelContainer:`, `rescheduleReminders:` and `publishWrist:` are the live App Group
/// store, a real `UNUserNotificationCenter` and a real `WCSession` (rule `85-testing`).
@MainActor
private func withHomeStore<T>(
    clock: MovableClock,
    _ body: (DataManager, Taps, UserDefaults) throws -> T
) throws -> T {
    let name = "test.waterbuddy.home.model.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let taps = Taps()
    let manager = DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: { clock.now },
        reloadWidgets: { taps.reloads += 1 },
        rescheduleReminders: { taps.plans.append($0) },
        publishWrist: { _ in }
    )
    return try body(manager, taps, defaults)
}

/// Whether a plan holds today's reminder at `hour`.
private func plan(_ slots: [ReminderPlan.Slot]?, holds hour: Int, on day: Int) -> Bool {
    (slots ?? []).contains { $0.dayOrdinal == day && $0.hour == hour }
}

// MARK: - Undo

/// ``DataManager/addLog(amount:at:)``'s id and ``DataManager/undoLog(id:)`` — what Home's *Undo*
/// stands on. The view holds an id, never a row.
@MainActor
struct UndoTests {

    @Test func addingAServingReturnsTheIdOfTheRowItInserted() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, _, _ in
            let id = try #require(manager.addLog(amount: 250))

            #expect(manager.todaysLogs.map(\.id) == [id])
        }
    }

    @Test func aRefusedAmountReturnsNoId() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, _, _ in
            #expect(manager.addLog(amount: 0) == nil)
            #expect(manager.addLog(amount: -250) == nil)
            #expect(manager.todaysLogs.isEmpty, "a refused amount must not have reached the store")
        }
    }

    @Test func undoRemovesExactlyTheRowItNames() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, _, defaults in
            manager.addLog(amount: 150)
            let glass = try #require(manager.addLog(amount: 250))
            manager.addLog(amount: 500)

            manager.undoLog(id: glass)

            #expect(manager.todaysLogs.map(\.amount).sorted() == [150, 500])
            #expect(manager.currentWater == 650)
            // A total that never reached the cache is invisible to the widget.
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 650)
        }
    }

    /// A drink at 14:10 answers the 15:00 reminder in advance; taking the drink back has to put
    /// the reminder back, and tell the widget, as any delete does.
    @Test func undoRePlansTheRemindersAndRingsTheWidget() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14, 10))) { manager, taps, _ in
            manager.remindersEnabled = true
            let id = try #require(manager.addLog(amount: 250))
            #expect(!plan(taps.plans.last, holds: 15, on: 20261010), "the drink should have silenced 15:00")
            let reloads = taps.reloads

            manager.undoLog(id: id)

            #expect(plan(taps.plans.last, holds: 15, on: 20261010))
            #expect(taps.reloads == reloads + 1)
        }
    }

    @Test func undoingAnUnknownIdChangesNothing() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, taps, _ in
            manager.addLog(amount: 250)
            let reloads = taps.reloads
            let plans = taps.plans.count

            manager.undoLog(id: UUID())

            #expect(manager.currentWater == 250)
            #expect(manager.todaysLogs.count == 1)
            #expect(taps.reloads == reloads)
            #expect(taps.plans.count == plans, "nothing changed, so nothing is re-planned")
        }
    }

    /// An Undo that outlived midnight names yesterday's water, and yesterday is history.
    @Test func undoingAfterTheDayTurnedLeavesYesterdayAlone() throws {
        let clock = MovableClock(utc(2026, 10, 10, 23, 59))
        try withHomeStore(clock: clock) { manager, _, _ in
            let id = try #require(manager.addLog(amount: 250))

            clock.now = utc(2026, 10, 11, 0, 1)
            manager.undoLog(id: id)

            #expect(manager.allLogs().map(\.id) == [id], "yesterday's serving must still be there")
        }
    }

    /// "Today's rows cannot be read" is not "no such row", and nothing is derived from it. The
    /// store is corrupted under the open context, the way `WristSyncTests` does it.
    @Test func undoDoesNothingWhenTodaysRowsCannotBeRead() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let storeURL = directory.appendingPathComponent("corrupt.store")
        defer { try? FileManager.default.removeItem(at: directory) }

        let name = "test.waterbuddy.home.corrupt.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let schema = Schema([WaterLog.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: storeURL))
        let manager = DataManager(
            defaults: defaults, modelContainer: container, calendar: utcDay,
            now: { utc(2026, 10, 10, 14) },
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
        let id = try #require(manager.addLog(amount: 250))

        let size = try FileManager.default.attributesOfItem(atPath: storeURL.path)[.size] as? Int ?? 4_096
        try Data((0..<size).map { _ in UInt8.random(in: 0...255) }).write(to: storeURL)
        for suffix in ["-wal", "-shm"] {
            try? FileManager.default.removeItem(atPath: storeURL.path + suffix)
        }

        manager.undoLog(id: id)

        #expect(manager.currentWater == 250, "a failed read must leave the total exactly as it stood")
    }
}
```

- [ ] **Step 2: Run it and see it fail.** The unit-suite command with `SUITE` = `UndoTests`.
  Expected: a build failure — `value of type 'DataManager' has no member 'undoLog'`, and `addLog`'s
  `()` not unwrapping as an optional. Nothing else.

- [ ] **Step 3: Implement.** In `WaterBuddy/DataManager.swift`, replace `addLog(amount:at:)`'s
  signature and body (its DocC stays, with one paragraph added):

```swift
    ///
    /// - Returns: the id of the row it inserted, or `nil` for a refused amount. `HomeView` is the
    ///   one caller that keeps it — it is what ``undoLog(id:)`` takes back — and every other
    ///   caller discards it.
    @discardableResult
    func addLog(amount: Int, at date: Date? = nil) -> UUID? {
        guard amount > 0 else { return nil }
        refresh()

        let log = WaterLog(amount: amount, timestamp: date ?? now())
        modelContext.insert(log)
        saveAndRecompute()
        return log.id
    }
```

  and insert after `deleteLog(_:)`:

```swift
    /// Takes back one serving, by the id ``addLog(amount:at:)`` returned for it.
    ///
    /// For Home's *Undo*, which holds an id and not a row: a ``WaterLog`` may sit in a view's
    /// state only as a sheet's selection (rule `50-views`). The row is looked up among
    /// **today's**, read fresh — an Undo that outlived midnight names yesterday's water, and
    /// yesterday is history. It goes through ``deleteLog(_:)``, so the total, the widget and the
    /// reminder plan follow as they do for any delete.
    ///
    /// Does nothing when the row is gone, or when today's rows cannot be read: a failed read is
    /// not "no such row", and nothing is derived from one (rule `20-state`).
    func undoLog(id: UUID) {
        guard let log = readTodaysLogs()?.first(where: { $0.id == id }) else { return }
        deleteLog(log)
    }
```

- [ ] **Step 4: Run it and see it pass.** Same command. Expected: `✔ Test run with 7 tests in 1
  suite passed`. Then look for a closure that now returns the id by accident:

```bash
grep -E 'warning: .*(unused|never used)' $SP/t.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-200
```

  Expected: nothing naming `addLog`. A hit is a single-expression closure; give it a second statement
  or `_ =`, never a narrowed assertion.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/HomeModelTests.swift
```

---

### Task 2: What is left, the last drink, the next reminder

**Files:**
- Modify: `WaterBuddyTests/HomeModelTests.swift` (append), `WaterBuddy/DataManager.swift` (after
  `progressUnclamped`; `currentReminderSlots()`)

**Interfaces:**
- Produces: `var remaining: Int`, `var hasReachedGoal: Bool`, `var lastDrink: Date?`,
  `var nextReminder: Date?` on `DataManager`.

- [ ] **Step 1: Write the failing suite.** Append to `WaterBuddyTests/HomeModelTests.swift`:

```swift
// MARK: - The figures Home draws

/// Everything here is derived on read and stored nowhere (spec §5.3).
@MainActor
struct HomeFiguresTests {

    @Test func remainingIsTheGoalLessTodaysWaterAndNeverNegative() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, _, _ in
            #expect(manager.remaining == DataManager.defaultDailyGoal)

            manager.addLog(amount: 1_300)
            #expect(manager.remaining == 700)

            manager.addLog(amount: 900)
            #expect(manager.remaining == 0, "past the goal there is nothing left, not minus 200")
        }
    }

    @Test func theGoalIsReachedExactlyAtTheGoal() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, _, _ in
            manager.addLog(amount: 1_999)
            #expect(!manager.hasReachedGoal)

            manager.addLog(amount: 1)
            #expect(manager.hasReachedGoal)
        }
    }

    @Test func aPourRedrawsWhatReadsRemainingAndTheGoalFlag() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, _, _ in
            let remaining = Counter()
            let reached = Counter()
            withObservationTracking { _ = manager.remaining } onChange: { remaining.count += 1 }
            withObservationTracking { _ = manager.hasReachedGoal } onChange: { reached.count += 1 }

            manager.addLog(amount: 250)

            #expect(remaining.count == 1)
            #expect(reached.count == 1)
        }
    }

    @Test func theLastDrinkIsTodaysLatestServing() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 18))) { manager, _, _ in
            #expect(manager.lastDrink == nil)

            manager.addLog(amount: 250, at: utc(2026, 10, 10, 9))
            manager.addLog(amount: 250, at: utc(2026, 10, 10, 14, 25))
            manager.addLog(amount: 250, at: utc(2026, 10, 10, 11))

            #expect(manager.lastDrink == utc(2026, 10, 10, 14, 25))
        }
    }

    /// A watch pour carries the watch's own clock.
    @Test func aDrinkStampedAheadOfTheClockIsShownAsNow() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, _, _ in
            manager.addLog(amount: 250, at: utc(2026, 10, 10, 14, 30))

            #expect(manager.lastDrink == utc(2026, 10, 10, 14))
        }
    }

    @Test func yesterdaysDrinkIsNotTheLastDrink() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 8))) { manager, _, _ in
            manager.addLog(amount: 250, at: utc(2026, 10, 9, 22))

            #expect(manager.lastDrink == nil)
        }
    }

    @Test func aPourRedrawsWhatReadsTheLastDrink() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14))) { manager, _, _ in
            let counter = Counter()
            withObservationTracking { _ = manager.lastDrink } onChange: { counter.count += 1 }

            manager.addLog(amount: 250)

            #expect(counter.count == 1)
        }
    }

    @Test func theNextReminderIsTheFirstSlotStillAheadToday() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14, 10))) { manager, _, _ in
            manager.remindersEnabled = true

            #expect(manager.nextReminder == utc(2026, 10, 10, 15))
        }
    }

    @Test func thereIsNoNextReminderWhileRemindersAreOff() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14, 10))) { manager, _, _ in
            #expect(manager.nextReminder == nil)
        }
    }

    /// Tomorrow's 09:00 is planned, and it is not "next" on a screen headed *Today*.
    @Test func thereIsNoNextReminderOnceTodaysLastSlotHasPassed() throws {
        let clock = MovableClock(utc(2026, 10, 10, 21))
        try withHomeStore(clock: clock) { manager, _, _ in
            manager.remindersEnabled = true
            #expect(manager.nextReminder == nil, "a slot at exactly now has had its moment")

            clock.now = utc(2026, 10, 10, 22, 30)
            #expect(manager.nextReminder == nil)
        }
    }

    @Test func thereIsNoNextReminderOnceTheGoalIsReached() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 10))) { manager, _, _ in
            manager.remindersEnabled = true
            manager.addLog(amount: DataManager.defaultDailyGoal, at: utc(2026, 10, 10, 8))

            #expect(manager.nextReminder == nil)
        }
    }

    @Test func aDrinkInTheHourBeforeASlotMovesTheNextReminderOn() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14, 10))) { manager, _, _ in
            manager.remindersEnabled = true
            manager.addLog(amount: 250)

            #expect(manager.nextReminder == utc(2026, 10, 10, 17))
        }
    }

    /// The line Home draws and the request iOS holds come from one plan.
    @Test func theNextReminderIsTheFirstOfTheSlotsThePlanFilesForToday() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 12, 40))) { manager, taps, _ in
            manager.remindersEnabled = true
            manager.addLog(amount: 250)

            let filed = taps.plans.last?.first { $0.dayOrdinal == 20261010 }?.fireDate
            #expect(filed != nil)
            #expect(manager.nextReminder == filed)
        }
    }

    @Test func switchingRemindersOnRedrawsWhatReadsTheNextReminder() throws {
        try withHomeStore(clock: MovableClock(utc(2026, 10, 10, 14, 10))) { manager, _, _ in
            let counter = Counter()
            withObservationTracking { _ = manager.nextReminder } onChange: { counter.count += 1 }

            manager.remindersEnabled = true

            #expect(counter.count == 1)
        }
    }
}
```

- [ ] **Step 2: Run it and see it fail.** `SUITE` = `HomeFiguresTests`. Expected: a build failure
  naming `remaining`, `hasReachedGoal`, `lastDrink` and `nextReminder` as missing members.

- [ ] **Step 3: Implement.** In `WaterBuddy/DataManager.swift`, insert after `progressUnclamped`:

```swift
    /// Millilitres still to drink today — zero once the goal is met, never negative.
    var remaining: Int {
        max(0, dailyGoal - currentWater)
    }

    /// Whether today's water has reached the goal. The one spelling of "reached" a view reads;
    /// ``ReminderPlan`` makes the same comparison to silence the rest of the day.
    var hasReachedGoal: Bool {
        currentWater >= dailyGoal
    }

    /// When the user last drank today, or `nil` before the day's first serving.
    ///
    /// Never later than now: a watch pour carries the watch's own clock, and one stamped ahead of
    /// this one would otherwise be drawn as a drink that has not happened yet.
    var lastDrink: Date? {
        todaysLogs.lazy.map(\.timestamp).max().map { min($0, now()) }
    }

    /// The next reminder still planned for **today**, or `nil` — reminders off, the goal reached,
    /// or the day's last slot behind us. Tomorrow's 09:00 is planned too, and is not "next" on a
    /// screen headed *Today*.
    ///
    /// **The planned time, not a delivery promise**: iOS may hold a reminder for the Notification
    /// Summary, which Settings discloses (rule `80-notifications`).
    ///
    /// It is the first slot of the plan ``currentReminderSlots()`` files, cut to today, so the
    /// line a screen draws and the request iOS holds cannot disagree. The four `access` calls
    /// are what make a view that reads this redraw: the plan is computed from stored values, which
    /// register nothing by themselves.
    var nextReminder: Date? {
        access(keyPath: \.remindersEnabled)
        access(keyPath: \.currentWater)
        access(keyPath: \.dailyGoal)
        access(keyPath: \.todaysLogs)
        return reminderSlots(horizonDays: 0).first?.fireDate
    }
```

  and replace the body of `currentReminderSlots()` (its DocC stays) and add the helper under it:

```swift
    func currentReminderSlots() -> [ReminderPlan.Slot] {
        reminderSlots(horizonDays: ReminderPlan.horizonDays)
    }

    /// The plan out to `horizonDays`, from the state this instance holds. One spelling of the
    /// plan's inputs, for the schedule that is filed and for ``nextReminder``.
    private func reminderSlots(horizonDays: Int) -> [ReminderPlan.Slot] {
        ReminderPlan.slots(
            enabled: storedRemindersEnabled,
            currentWater: storedCurrentWater,
            dailyGoal: storedDailyGoal,
            // `max()`, not `.first`, though the rows are fetched newest first: the plan should not
            // lean on a sort order chosen for a list.
            lastDrink: storedTodaysLogs.lazy.map(\.timestamp).max(),
            now: now(),
            calendar: calendar,
            horizonDays: horizonDays
        )
    }
```

- [ ] **Step 4: Run it and see it pass.** `SUITE` = `HomeFiguresTests`: `✔ Test run with 13 tests in
  1 suite passed`. Then the reminder suites the refactor could have moved, each with the same command:
  `ReminderPlanTests`, `EarlierServingTests`, `DataManagerTests`. Expected: each passes with the count
  it had.

- [ ] **Step 5: Stage** — `git add WaterBuddy/DataManager.swift WaterBuddyTests/HomeModelTests.swift`.

---

### Task 3: The streak

**Files:**
- Create: `WaterBuddyTests/StreakTests.swift`
- Modify: `WaterBuddy/DataManager.swift` (state, `streak`, `republishHistory()`, the `dailyGoal`
  setter, `historyWindowStart`, the `DaySummary` extension)

**Interfaces:**
- Consumes: `DaySummary.series(from:days:endingOn:in:)`, `readLogs(from:to:)`,
  `nextDayBoundary(after:calendar:)`, `role.drawsHistory`.
- Produces: `DataManager.streak: Int` (get-only); `DataManager.streakWindows: [Int]`;
  `nonisolated static func windowStart(days: Int, endingOn now: Date, calendar: Calendar) -> Date?`;
  `DaySummary.streak(of:goal:) -> Int`; `DaySummary.streakFillsWindow(_:goal:) -> Bool`.

- [ ] **Step 1: Write the failing suites.** `WaterBuddyTests/StreakTests.swift`:

```swift
//
//  StreakTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 10/10/26.
//

import Foundation
import Observation
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

/// In 2026 New York leaves daylight time on Sunday 1 November (a 25-hour day) and enters it on
/// Sunday 8 March (a 23-hour one).
private let newYorkDay = gregorian(in: "America/New_York")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

private func newYork(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    newYorkDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// A window of days with these totals, oldest first, today last.
private func days(_ totals: [Int]) -> [DaySummary] {
    totals.enumerated().map { index, total in
        DaySummary(dayOrdinal: 20260901 + index, total: total, date: utc(2026, 9, 1 + index, 0))
    }
}

private final class MovableClock: @unchecked Sendable {
    var now: Date
    init(_ now: Date) { self.now = now }
}

private final class Counter: @unchecked Sendable {
    var count = 0
}

// MARK: - Counting

/// ``DaySummary/streak(of:goal:)`` — a pure count over a window, with no store, no `DataManager`
/// and no main actor. Deliberately not `@MainActor`, like `DaySummaryTests`: if the count ever
/// reached for instance state this suite would stop compiling (rule `43-concurrency`).
struct StreakCountTests {

    @Test func todayCountsOnlyOnceItHasReachedTheGoal() {
        #expect(DaySummary.streak(of: days([2_000, 2_000, 500]), goal: 2_000) == 2)
        #expect(DaySummary.streak(of: days([2_000, 2_000, 2_000]), goal: 2_000) == 3)
    }

    @Test func aMissedDayEndsTheRun() {
        #expect(DaySummary.streak(of: days([2_000, 0, 2_000, 2_000, 100]), goal: 2_000) == 2)
    }

    @Test func aMissedYesterdayLeavesOnlyToday() {
        #expect(DaySummary.streak(of: days([2_000, 500, 2_000]), goal: 2_000) == 1)
        #expect(DaySummary.streak(of: days([2_000, 500, 100]), goal: 2_000) == 0)
    }

    @Test func noDayMetIsNoStreak() {
        #expect(DaySummary.streak(of: days([0, 0, 0]), goal: 2_000) == 0)
        #expect(DaySummary.streak(of: [], goal: 2_000) == 0)
    }

    @Test func everyDayIsJudgedAgainstTheGoalHandedIn() {
        let window = days([1_500, 1_500, 1_500])

        #expect(DaySummary.streak(of: window, goal: 1_500) == 3)
        #expect(DaySummary.streak(of: window, goal: 2_000) == 0)
    }

    /// The model widens its window only while this is true.
    @Test func aRunThatReachesTheWindowsOldestDaySaysSo() {
        #expect(DaySummary.streakFillsWindow(days([2_000, 2_000, 2_000]), goal: 2_000))
        #expect(DaySummary.streakFillsWindow(days([2_000, 2_000, 100]), goal: 2_000),
                "today is still open, and every day before it was met")
        #expect(!DaySummary.streakFillsWindow(days([100, 2_000, 2_000]), goal: 2_000))
        #expect(!DaySummary.streakFillsWindow(days([100]), goal: 2_000))
        #expect(!DaySummary.streakFillsWindow([], goal: 2_000))
    }

    @Test func aStreakRunsAcrossATwentyFiveHourDay() {
        let logs = [30, 31].map { WaterLog(amount: 2_000, timestamp: newYork(2026, 10, $0)) }
            + [1, 2].map { WaterLog(amount: 2_000, timestamp: newYork(2026, 11, $0)) }

        let window = DaySummary.series(from: logs, days: 4, endingOn: newYork(2026, 11, 2, 20), in: newYorkDay)

        #expect(DaySummary.streak(of: window, goal: 2_000) == 4)
    }

    @Test func aStreakRunsAcrossATwentyThreeHourDay() {
        let logs = [6, 7, 8, 9].map { WaterLog(amount: 2_000, timestamp: newYork(2026, 3, $0)) }

        let window = DaySummary.series(from: logs, days: 4, endingOn: newYork(2026, 3, 9, 20), in: newYorkDay)

        #expect(DaySummary.streak(of: window, goal: 2_000) == 4)
    }

    @Test func aWindowStartsAtMidnightThatManyDaysBack() {
        #expect(DataManager.windowStart(days: 30, endingOn: utc(2026, 10, 10, 15), calendar: utcDay)
                == utc(2026, 9, 11, 0))
        #expect(DataManager.windowStart(days: 1, endingOn: utc(2026, 10, 10, 15), calendar: utcDay)
                == utc(2026, 10, 10, 0))
        // Stepped by calendar days: three days ending on the Monday after the 25-hour Sunday.
        #expect(DataManager.windowStart(days: 3, endingOn: newYork(2026, 11, 2), calendar: newYorkDay)
                == newYork(2026, 10, 31, 0))
    }

    @Test func theHistoryWindowStartsWhereAWindowOfItsLengthDoes() {
        let now = utc(2026, 10, 10, 15)

        #expect(DataManager.historyWindowStart(endingOn: now, calendar: utcDay)
                == DataManager.windowStart(days: DataManager.historyWindow, endingOn: now, calendar: utcDay))
    }

    @Test func theStreaksWindowsOnlyEverWiden() {
        #expect(DataManager.streakWindows == DataManager.streakWindows.sorted())
        #expect(Set(DataManager.streakWindows).count == DataManager.streakWindows.count)
        #expect((DataManager.streakWindows.first ?? 0) >= DataManager.historyWindow)
    }
}

// MARK: - Publishing

@MainActor
private func withStreakStore<T>(
    clock: MovableClock,
    _ body: (DataManager) throws -> T
) throws -> T {
    let name = "test.waterbuddy.streak.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: { clock.now },
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    return try body(manager)
}

/// Logs `amount` on each of the `count` days ending `endingDaysAgo` days before the clock.
@MainActor
private func fill(_ manager: DataManager, days count: Int, endingDaysAgo: Int, amount: Int, clock: MovableClock) {
    for offset in endingDaysAgo..<(endingDaysAgo + count) {
        manager.addLog(amount: amount, at: utcDay.date(byAdding: .day, value: -offset, to: clock.now)!)
    }
}

/// ``DataManager/streak`` as the model publishes it (spec §5.3).
@MainActor
struct StreakPublishingTests {

    @Test func theStreakCountsBackFromYesterdayUntilTodayIsReached() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withStreakStore(clock: clock) { manager in
            #expect(manager.streak == 0)

            fill(manager, days: 2, endingDaysAgo: 1, amount: 2_000, clock: clock)
            #expect(manager.streak == 2)

            manager.addLog(amount: 2_000)
            #expect(manager.streak == 3)
        }
    }

    @Test func aRunLongerThanTheFirstWindowIsCountedInFull() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withStreakStore(clock: clock) { manager in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)

            #expect(manager.streak == 45)
        }
    }

    /// Twenty-nine met days and an open today fill the thirty-day window exactly; the run must be
    /// read from the wider one, where the thirtieth day back is seen to have missed.
    @Test func aRunThatEndsAtTheFirstWindowsEdgeIsNotOvercounted() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withStreakStore(clock: clock) { manager in
            fill(manager, days: 29, endingDaysAgo: 1, amount: 2_000, clock: clock)
            manager.addLog(amount: 500, at: utcDay.date(byAdding: .day, value: -30, to: clock.now)!)

            #expect(manager.streak == 29)
        }
    }

    /// No past goal is stored, so every day is judged against today's (spec §5.3).
    @Test func changingTheGoalReJudgesTheStreak() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withStreakStore(clock: clock) { manager in
            fill(manager, days: 3, endingDaysAgo: 1, amount: 1_500, clock: clock)
            #expect(manager.streak == 0)

            manager.saveDailyGoal(ml: 1_500)
            #expect(manager.streak == 3)

            manager.saveDailyGoal(ml: 2_000)
            #expect(manager.streak == 0)
        }
    }

    @Test func theStreakRedrawsItsReadersOnlyWhenItMoves() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withStreakStore(clock: clock) { manager in
            let counter = Counter()
            withObservationTracking { _ = manager.streak } onChange: { counter.count += 1 }

            manager.refresh()
            manager.addLog(amount: 250)
            #expect(counter.count == 0, "nothing reached the goal, so nothing should redraw")

            manager.addLog(amount: 2_000)
            #expect(counter.count == 1)
        }
    }

    @Test func aDeletedServingThatUnmeetsADayShortensTheStreak() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withStreakStore(clock: clock) { manager in
            let id = try #require(manager.addLog(amount: 2_000))
            #expect(manager.streak == 1)

            manager.undoLog(id: id)
            #expect(manager.streak == 0)
        }
    }

    /// A failed read is not "no streak" (rule `20-state`).
    @Test func aFailedReadLeavesTheStreakAsItStands() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let storeURL = directory.appendingPathComponent("corrupt.store")
        defer { try? FileManager.default.removeItem(at: directory) }

        let name = "test.waterbuddy.streak.corrupt.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let schema = Schema([WaterLog.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: storeURL))
        let manager = DataManager(
            defaults: defaults, modelContainer: container, calendar: utcDay,
            now: { utc(2026, 10, 10, 14) },
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
        manager.addLog(amount: 2_000, at: utc(2026, 10, 9, 12))
        manager.addLog(amount: 2_000)
        #expect(manager.streak == 2, "the store must be healthy before it is corrupted")

        let size = try FileManager.default.attributesOfItem(atPath: storeURL.path)[.size] as? Int ?? 4_096
        try Data((0..<size).map { _ in UInt8.random(in: 0...255) }).write(to: storeURL)
        for suffix in ["-wal", "-shm"] {
            try? FileManager.default.removeItem(atPath: storeURL.path + suffix)
        }

        manager.refresh()

        #expect(manager.streak == 2)
    }

    /// It never leaves the app (spec §5.3): not in the widget's snapshot, not on the wire.
    @Test func theStreakStaysOutOfTheSnapshotAndTheWristMirror() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withStreakStore(clock: clock) { manager in
            manager.addLog(amount: 2_000)
            #expect(manager.streak == 1)
        }
        let name = "test.waterbuddy.streak.wire.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let mirror = DataManager.composeWristMirror(from: defaults, calendar: utcDay, now: utc(2026, 10, 10, 14))
        let wire = String(decoding: try JSONEncoder().encode(mirror), as: UTF8.self)
        let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 10, 14))

        #expect(!wire.lowercased().contains("streak"))
        #expect(!String(describing: snapshot).lowercased().contains("streak"))
    }
}
```

- [ ] **Step 2: Run them and see them fail.** `SUITE` = `StreakCountTests`, then
  `StreakPublishingTests`. Expected: a build failure naming `streak(of:goal:)`,
  `streakFillsWindow`, `windowStart(days:endingOn:calendar:)`, `streakWindows` and `streak`.

- [ ] **Step 3: Implement the pure half.** In `WaterBuddy/DataManager.swift`, inside
  `extension DaySummary`, after `best(of:)`:

```swift

    /// How many days in a row the goal was reached, counted back from the end of `series`.
    ///
    /// The last entry is **today**, and today is still open: it joins the run once it has reached
    /// the goal, and does not break one before then. So the count starts from today if today has
    /// reached it, otherwise from yesterday.
    ///
    /// Every day is judged against the one `goal` handed in. No past goal is stored
    /// (``DaySummary`` deliberately has no `goal` field), so this is the current goal — raising
    /// it can shorten a run, and the week card already says "Measured against your current goal".
    nonisolated static func streak(of series: [DaySummary], goal: Int) -> Int {
        closedDays(of: series, goal: goal).reversed().prefix { $0.total >= goal }.count
    }

    /// Whether the run ``streak(of:goal:)`` counts reaches the window's oldest day — in which
    /// case the real run may be longer than this window can show, and the caller should look
    /// further back.
    nonisolated static func streakFillsWindow(_ series: [DaySummary], goal: Int) -> Bool {
        let days = closedDays(of: series, goal: goal)
        return !days.isEmpty && days.allSatisfy { $0.total >= goal }
    }

    /// The days a run is counted over: the whole window, less a today that has not reached the
    /// goal yet.
    nonisolated private static func closedDays(of series: [DaySummary], goal: Int) -> ArraySlice<DaySummary> {
        guard let today = series.last, today.total < goal else { return series[...] }
        return series.dropLast()
    }
```

  and replace `historyWindowStart(endingOn:calendar:)`'s body, adding its sibling above it:

```swift
    /// Midnight, `days` − 1 calendar days before the day containing `now`: where a window of
    /// `days` days, today included, starts.
    ///
    /// The one definition of where a window starts, as ``nextDayBoundary(after:calendar:)`` is of
    /// where a day ends. Stepped with `date(byAdding: .day,…)`: a DST day is 23 or 25 hours long,
    /// so a walk in multiples of 86,400 seconds can land an hour off midnight (rule `30-rollover`).
    ///
    /// `nil` only if the calendar cannot step back.
    nonisolated static func windowStart(days: Int, endingOn now: Date, calendar: Calendar) -> Date? {
        calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: now))
    }
```

```swift
    nonisolated static func historyWindowStart(endingOn now: Date, calendar: Calendar) -> Date? {
        windowStart(days: historyWindow, endingOn: now, calendar: calendar)
    }
```

  In `historyWindowStart`'s DocC, replace the sentence beginning "Stepped with" by "It is
  ``windowStart(days:endingOn:calendar:)`` at ``historyWindow`` days." and keep the rest.

- [ ] **Step 4: Implement the published half.** Beside `historyWindow`:

```swift

    /// How far back ``streak`` looks, in days, a step at a time.
    ///
    /// The first window answers nearly everyone: a run of under a month ends inside it. The count
    /// reads the next one only while the run reaches the window's oldest day, so a long run costs
    /// its owner one wider fetch and nobody else anything. A run longer than the last window is
    /// reported as that window's length.
    nonisolated static let streakWindows = [30, 120, 480, 1_920]
```

  Beside the other stored fields: `@ObservationIgnored private var storedStreak = 0`.

  After `historyLogs`:

```swift

    /// How many days in a row the goal has been reached, today included once today reaches it.
    ///
    /// Derived, never stored: ``DaySummary/streak(of:goal:)`` over the rows, republished with the
    /// history and whenever the goal moves — every day is judged against the **current** goal,
    /// because no past goal is recorded. Days are bucketed from each serving's instant on this
    /// model's calendar, so a change of time zone can regroup them, as it does the week card.
    ///
    /// **Equality-guarded**, like ``history``: an `Int` that did not move redraws nothing, and
    /// ``refresh()`` runs on every foreground. **A failed read leaves it as it stands** — an
    /// unreadable store is not a broken streak (rule `20-state`).
    ///
    /// It never leaves the app: not the widget's snapshot, not a notification, not the wrist's
    /// mirror. Zero wherever ``role`` does not draw history. Read-only — a consequence of the
    /// rows, never an input.
    var streak: Int {
        access(keyPath: \.streak)
        return storedStreak
    }
```

  In `republishHistory()`, directly after `guard Self.role.drawsHistory else { return }`:

```swift

        // Before the window below, and not inside it: the bars can return early — a failed read,
        // or a series that did not move — while a run further back still did.
        republishStreak()
```

  After `republishHistory()`:

```swift

    /// Recounts ``streak`` and publishes it if it moved.
    ///
    /// Behind `role.drawsHistory` for ``republishHistory()``'s reason: a widget tap must not run
    /// a month's fetch in a process that draws one number.
    private func republishStreak() {
        guard Self.role.drawsHistory else { return }
        guard let counted = readStreak(), counted != storedStreak else { return }
        withMutation(keyPath: \.streak) { storedStreak = counted }
    }

    /// The run as the store holds it now, or `nil` when the store could not be read.
    ///
    /// Reads ``streakWindows`` in turn and stops at the first window the run ends inside. Each
    /// window is one fetch and one roll-up through ``DaySummary/series(from:days:endingOn:in:)``,
    /// the same bucketing the week card uses, so the two cannot count a day differently.
    private func readStreak() -> Int? {
        let instant = now()
        let end = Self.nextDayBoundary(after: instant, calendar: calendar)
        var counted = 0

        for days in Self.streakWindows {
            guard let start = Self.windowStart(days: days, endingOn: instant, calendar: calendar),
                  let logs = readLogs(from: start, to: end)
            else { return nil }

            let series = DaySummary.series(from: logs, days: days, endingOn: instant, in: calendar)
            counted = DaySummary.streak(of: series, goal: storedDailyGoal)
            guard DaySummary.streakFillsWindow(series, goal: storedDailyGoal) else { break }
        }
        return counted
    }
```

  In the `dailyGoal` setter, after `rescheduleRemindersNow()`:

```swift
            // The goal is half of "a day that reached it", for every day the streak counts.
            republishStreak()
```

- [ ] **Step 5: Run them and see them pass.** `StreakCountTests`: `✔ Test run with 11 tests in 1
  suite passed`. `StreakPublishingTests`: `✔ Test run with 8 tests in 1 suite passed`. Then
  `DaySummaryTests`, `HistoryWindowTests` and `HistoryLogsTests`, each unchanged.

- [ ] **Step 6: The other three targets compile.** The three-scheme command. Expected: `** BUILD
  SUCCEEDED **` three times, no `error:`.

- [ ] **Step 7: Stage** — `git add WaterBuddy/DataManager.swift WaterBuddyTests/StreakTests.swift`.

---

### Task 4: The day turning with the app open

**Files:**
- Modify: `WaterBuddyTests/HomeModelTests.swift` (append), `WaterBuddy/DataManager.swift` (after
  `resetIfNeeded()`; `startObservingDayChanges()`)

**Interfaces:**
- Produces: `func dayDidTurn()`.

- [ ] **Step 1: Write the failing suite.** Append to `WaterBuddyTests/HomeModelTests.swift`:

```swift
// MARK: - The day turning with the app open

/// What the day-change observers call. `resetIfNeeded()` alone zeroes the total and leaves
/// yesterday's rows, yesterday's window and yesterday's streak on screen until the next refresh.
@MainActor
struct DayTurnTests {

    @Test func theDayTurningEmptiesTodaysRowsAndMovesTheWindow() throws {
        let clock = MovableClock(utc(2026, 10, 10, 22))
        try withHomeStore(clock: clock) { manager, _, _ in
            manager.addLog(amount: 500)
            #expect(manager.lastDrink != nil)

            clock.now = utc(2026, 10, 11, 0, 0)
            manager.dayDidTurn()

            #expect(manager.currentWater == 0)
            #expect(manager.todaysLogs.isEmpty, "yesterday's rows are not today's")
            #expect(manager.lastDrink == nil)
            #expect(manager.history.last?.dayOrdinal == 20261011)
            #expect(manager.history.first { $0.dayOrdinal == 20261010 }?.total == 500)
            // Only the cache was cleared; yesterday is history (rule `30-rollover`).
            #expect(manager.allLogs().count == 1)
        }
    }

    /// The 9th was met and the 10th was not. On the 10th the run still stands, counted from
    /// yesterday; on the 11th yesterday is the 10th, and the run is over.
    @Test func theDayTurningReJudgesTheStreak() throws {
        let clock = MovableClock(utc(2026, 10, 10, 22))
        try withHomeStore(clock: clock) { manager, _, _ in
            manager.addLog(amount: 2_000, at: utc(2026, 10, 9, 12))
            manager.addLog(amount: 500)
            #expect(manager.streak == 1)

            clock.now = utc(2026, 10, 11, 0, 0)
            manager.dayDidTurn()

            #expect(manager.streak == 0)
        }
    }

    @Test func aTurnThatIsNotANewDayRepublishesNothing() throws {
        let clock = MovableClock(utc(2026, 10, 10, 22))
        try withHomeStore(clock: clock) { manager, taps, _ in
            manager.addLog(amount: 500)
            let rows = Counter()
            withObservationTracking { _ = manager.todaysLogs } onChange: { rows.count += 1 }
            let reloads = taps.reloads

            clock.now = utc(2026, 10, 10, 23, 30)
            manager.dayDidTurn()

            #expect(rows.count == 0)
            #expect(taps.reloads == reloads)
            #expect(manager.currentWater == 500)
        }
    }
}
```

- [ ] **Step 2: Run it and see it fail.** `SUITE` = `DayTurnTests`. Expected: a build failure,
  `value of type 'DataManager' has no member 'dayDidTurn'`.

- [ ] **Step 3: Implement.** In `WaterBuddy/DataManager.swift`, after `resetIfNeeded()`:

```swift

    /// The day turned, or the time zone moved, while the app was open.
    ///
    /// What the two observers in ``startObservingDayChanges()`` call. ``resetIfNeeded()`` clears
    /// the cached total and nothing else; a screen left open across midnight also draws today's
    /// rows, the week and the streak, and none of those is republished until the next
    /// ``refresh()`` or mutation. So when the day really did turn, republish them — after the
    /// reset, as ``refresh()`` orders it (rule `30-rollover`).
    ///
    /// The rows are republished and the total is **not** recomputed from them, for the reason on
    /// ``republishTodaysLogs()``.
    func dayDidTurn() {
        guard resetIfNeeded() else { return }
        republishTodaysLogs()
        republishHistory()
    }
```

  and in `startObservingDayChanges()` replace `_ = self?.resetIfNeeded()` with
  `self?.dayDidTurn()`.

- [ ] **Step 4: Run it and see it pass.** `SUITE` = `DayTurnTests`: `✔ Test run with 3 tests in 1
  suite passed`. Then `DataManagerTests` once more, unchanged.

- [ ] **Step 5: The other three targets compile.** The three-scheme command.

- [ ] **Step 6: Stage** — `git add WaterBuddy/DataManager.swift WaterBuddyTests/HomeModelTests.swift`.

---

### Task 5: Grouped figures, and Home's strings

**Files:**
- Modify: `WaterBuddyTests/LocalizationTests.swift`, `WaterBuddy/DataManager.swift` (after the
  `EnvironmentValues.strings` extension), `WaterBuddy/Localizable.xcstrings`

**Interfaces:**
- Produces: `extension Bundle { nonisolated func figure(_ key: String, _ volumes: Int..., locale: Locale) -> String }`.

- [ ] **Step 1: Write the failing tests.** In `WaterBuddyTests/LocalizationTests.swift`, after
  `sharedKeys`:

```swift

/// Home's strings. Listed by name because each is resolved with `localizedString(forKey:)` or
/// through ``Bundle/figure(_:_:locale:)``, which the build's extraction cannot see: a key that
/// went missing would fall back to drawing itself, in English, with nothing to notice.
private let homeKeys = [
    "%1$@ of %2$@ ml",
    "%1$@ ml",
    "%1$@ ml to go",
    "%1$d millilitres to go",
    "Goal reached",
    "Next reminder %1$@",
    "Last drink %1$@",
    "Added %1$@ ml",
    "Undo",
    "Day streak",
]
```

  and at the end of the file:

```swift

// MARK: - Home

/// Home's own strings, in every language the app ships.
struct HomeStringTests {

    @Test(arguments: ["en"] + translated)
    func everyHomeStringExistsAndKeepsItsArguments(language: String) {
        for key in homeKeys {
            let resolved = value(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            if let resolved {
                #expect(specifiers(in: resolved) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments")
            }
        }
    }

    /// Nothing Home says may be spoken with a figure it also hides: the visible keys take `%@`
    /// (a grouped figure) and the spoken one takes `%d`, the split spec §3.1 sets.
    @Test func onlyTheSpokenHomeStringTakesARawNumber() {
        let raw = homeKeys.filter { $0.contains("$d") }

        #expect(raw == ["%1$d millilitres to go"])
    }
}

/// ``Bundle/figure(_:_:locale:)`` — a volume grouped the way the language groups it, set into a
/// `%@` key. Not `@MainActor`: the widget's stage will call it from a view the extension draws.
struct GroupedFigureTests {

    @Test func figuresAreGroupedTheWayTheLocaleGroups() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")
        let russian = try #require(localization(appBundle, "ru"), "the app ships no ru table")
        let en = Locale(identifier: "en_US")
        let ru = Locale(identifier: "ru_RU")

        #expect(english.figure("%1$@ of %2$@ ml", 1_300, 2_000, locale: en) == "1,300 of 2,000 ml")

        let grouped = 1_300.formatted(.number.locale(ru))
        #expect(grouped != "1300", "a Russian thousand is grouped too, with its own separator")
        #expect(russian.figure("%1$@ of %2$@ ml", 1_300, 2_000, locale: ru)
                == "\(grouped) из \(2_000.formatted(.number.locale(ru))) мл")
    }

    @Test func aFigureUnderAThousandCarriesNoSeparator() throws {
        let english = try #require(localization(appBundle, "en"), "the app ships no en table")

        #expect(english.figure("%1$@ ml to go", 700, locale: Locale(identifier: "en_US")) == "700 ml to go")
    }

    /// Uzbek puts the goal first: "2,000 dan 1,300 ml". The arguments follow the key's order,
    /// not the sentence's.
    @Test func theArgumentsFollowTheKeysNumberingNotTheSentencesOrder() throws {
        let uzbek = try #require(localization(appBundle, "uz"), "the app ships no uz table")
        let uz = Locale(identifier: "uz_UZ")

        let drawn = uzbek.figure("%1$@ of %2$@ ml", 1_300, 2_000, locale: uz)
        let total = 1_300.formatted(.number.locale(uz))
        let goal = 2_000.formatted(.number.locale(uz))

        #expect(drawn == "\(goal) dan \(total) ml")
    }
}
```

- [ ] **Step 2: Run them and see them fail.** `SUITE` = `GroupedFigureTests`. Expected: a build
  failure, `value of type 'Bundle' has no member 'figure'`.

- [ ] **Step 3: Implement the helper.** In `WaterBuddy/DataManager.swift`, after the closing brace of
  `extension EnvironmentValues` (the one declaring `strings`):

```swift

extension Bundle {

    /// A sentence with volumes in it: each figure grouped the way `locale` groups a number, then
    /// set into the `%n$@` key this bundle resolves.
    ///
    /// `%1$d` never groups — `String(format:)` prints `1300` in every language — so a visible
    /// figure is formatted first and handed over as text (`1,300`, `1 300`). **Spoken strings
    /// keep their `%d` keys**: VoiceOver reads a bare number correctly, and the UI tests assert
    /// those values as they are.
    ///
    /// Here, beside the strings environment it reads from, because every bundle that draws a
    /// volume compiles this file and the shared set does not grow (rule `15-project`).
    /// `nonisolated`, so a suite off the main actor can pin it.
    nonisolated func figure(_ key: String, _ volumes: Int..., locale: Locale) -> String {
        String(
            format: localizedString(forKey: key, value: nil, table: nil),
            arguments: volumes.map { $0.formatted(.number.locale(locale)) }
        )
    }
}
```

- [ ] **Step 4: Run and see the figure tests still fail, for the right reason.** `SUITE` =
  `GroupedFigureTests`. Expected: three failures whose text shows the **key drawn as itself**
  (`%1$@ of %2$@ ml` has no value yet) — the helper compiles and the strings are what is missing.

- [ ] **Step 5: Add the strings.** In `WaterBuddy/Localizable.xcstrings`, with `Edit`, ten entries
  in the file's existing shape (`"extractionState" : "manual"`, a `stringUnit` with
  `"state" : "translated"` per language), each inserted in the file's sorted position:

| Key and `en` | `ru` | `uz` |
|---|---|---|
| `%1$@ of %2$@ ml` | `%1$@ из %2$@ мл` | `%2$@ dan %1$@ ml` |
| `%1$@ ml` | `%1$@ мл` | `%1$@ ml` |
| `%1$@ ml to go` | `Осталось %1$@ мл` | `%1$@ ml qoldi` |
| `%1$d millilitres to go` | `Осталось %1$d миллилитров` | `%1$d millilitr qoldi` |
| `Goal reached` | `Цель достигнута` | `Maqsadga erishildi` |
| `Next reminder %1$@` | `Напоминание в %1$@` | `Keyingi eslatma %1$@` |
| `Last drink %1$@` | `Последняя порция в %1$@` | `Oxirgi porsiya %1$@` |
| `Added %1$@ ml` | `Добавлено %1$@ мл` | `%1$@ ml qo‘shildi` |
| `Undo` | `Отменить` | `Qaytarish` |
| `Day streak` | `Серия дней` | `Ketma-ket kunlar` |

  `Undo` is not *Cancel* (`Отмена`, `Bekor qilish`), which the sheet already uses for a different
  act. The Uzbek apostrophe is the catalogue's own `‘` (U+2018). `%1$d millilitres to go` has one
  plural form in Russian, like every spoken key in the catalogue (known issue #40).

  Then prove the file is still a catalogue:

```bash
python3 -I -c "import json,sys; d=json.load(open('WaterBuddy/Localizable.xcstrings')); print(len(d['strings']), 'keys')"
```

  Expected: `74 keys`.

- [ ] **Step 6: Run and see them pass.** `SUITE` = `GroupedFigureTests`: `✔ Test run with 3 tests in
  1 suite passed`. `SUITE` = `HomeStringTests`: `✔ Test run with 2 tests in 1 suite passed`. Then
  `LocalizationTests`, unchanged in count and green — it reads every compiled table whole, so a key
  translated into one language and not the other fails here.

- [ ] **Step 7: The other three targets compile.** The three-scheme command.

- [ ] **Step 8: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddy/Localizable.xcstrings WaterBuddyTests/LocalizationTests.swift
```

---

### Task 6: The glass group, and a pane that keeps its content

**Files:**
- Modify: `WaterBuddy/LiquidGlassModifier.swift` (`routed`, `systemPane`, the `View` extension, one
  DocC)

**Interfaces:**
- Produces: `func glassGroup() -> some View` on `View`.

No unit test can see either change: one is a system container, the other is a view's identity. The
existing suites pin what must not move, and Task 8 renders both.

- [ ] **Step 1: The glass suites pass before the edit.** `SUITE` = `LiquidGlassRoutingTests`, then
  `LiquidGlassInteractionTests`, `LiquidGlassBaseTests`, `PrimarySurfaceTests`. Record the four
  counts.

- [ ] **Step 2: Route the background, not the content.** In `LiquidGlassModifier`, replace `routed`
  and `systemPane` (the whole of both, with their DocC) by:

```swift
    /// Draws the pane this call asked for **without moving the content between branches**.
    ///
    /// The first version switched the content itself — `systemPane(content)` in one case,
    /// `content.background(…)` in the others — so flipping Reduce Transparency rebuilt everything
    /// inside the pane, and anything in there that owned state would have lost it. Now the only
    /// things that change with ``rendering`` are the background and the glass handed to
    /// `glassEffect`: `.identity`, which draws nothing, when the pane is not Apple's.
    ///
    /// The one branch left around the content is on `base`, which a call site fixes for good. A
    /// `.flat` base never meets `glassEffect` at all: it exists for the widget, whose archive
    /// cannot sample a backdrop (rule `40-widget`).
    @ViewBuilder
    private func routed(_ content: Content) -> some View {
        switch base {
        case .flat: content.background(ownPane(systemGlassDrawn: false))
        case .material: sampling(content)
        }
    }

    /// Apple's glass is applied **to** the content rather than laid behind it, because that is
    /// what the API is: it anchors its shape behind the view and applies the glass's foreground
    /// effects over it.
    ///
    /// The `else` and the `#else` draw this file's own pane. They are also reached, as
    /// `.handMade`, if ``rendering`` and this check ever disagreed, which
    /// `theAvailabilityFlagMatchesTheRunningSystem` exists to prevent.
    @ViewBuilder
    private func sampling(_ content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content
                .background(ownPane(systemGlassDrawn: true))
                .glassEffect(rendering == .system ? systemGlass : .identity, in: shape)
                // A pane answers a tap anywhere inside its shape. The hand-made stack gets that
                // from its fills; Apple's glass does not promise it. On iOS 26.5 a serving row in
                // History's `List` took a tap on its text and ignored one on the bare glass
                // between, while iOS 27.0 took both — so say it rather than rely on it
                // (`testAServingRowOpensItsSheetWhereverItIsTapped`).
                .contentShape(shape)
        } else {
            content.background(ownPane(systemGlassDrawn: false))
        }
        #else
        content.background(ownPane(systemGlassDrawn: false))
        #endif
    }

    /// What this file draws behind the content: the opaque pane, the hand-made stack, or nothing
    /// where the system is drawing its own glass.
    @ViewBuilder
    private func ownPane(systemGlassDrawn: Bool) -> some View {
        switch rendering {
        case .opaque: opaquePane
        case .handMade: handMadePane
        case .system:
            if !systemGlassDrawn { handMadePane }
        }
    }
```

- [ ] **Step 3: Add the group.** After the closing brace of `struct PrimarySurfaceModifier` (before
  `// MARK: - View API`):

```swift

// MARK: - The glass group

/// Groups sibling glass panes that sit close together.
///
/// On iOS 26 and later this is Apple's `GlassEffectContainer`: the system samples the backdrop
/// once for the panes inside it and draws them as one layer of glass. Everywhere else it is the
/// content, untouched — the hand-made stack needs no container.
///
/// The branch is on the system and nothing else, so it cannot change while the app runs and
/// nothing inside is rebuilt. `#if os(iOS)` keeps the watch on the pass-through until its own
/// stage, as ``LiquidGlass/systemGlassAvailable`` does for the panes.
private struct GlassGroupModifier: ViewModifier {

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            GlassEffectContainer { content }
        } else {
            content
        }
        #else
        content
        #endif
    }
}
```

  and inside `extension View`, after `primarySurface(in:ring:)`:

```swift

    /// Groups the glass panes inside this view, for siblings that sit close together — a row of
    /// discs. Never write `GlassEffectContainer` at a call site (rule `60-design-system`).
    func glassGroup() -> some View {
        modifier(GlassGroupModifier())
    }
```

- [ ] **Step 4: Correct two comments this file was already wrong about** (known issue #91d, in the
  lines this task touches). `systemGlassAvailable`'s DocC: replace the sentence "but no watchOS 26
  simulator runtime was installed where this was built, and a pane nobody has rendered is not one to
  ship." by "but the watch's panes have not been rendered on Apple's glass, and a pane nobody has
  rendered is not one to ship." `glassIsPressed`'s DocC: replace "Set by ``PressStyle`` and read by
  ``LiquidGlassModifier``." by "Set by ``PressStyle`` and read by ``LiquidGlassModifier`` and
  ``PrimarySurfaceModifier``."

- [ ] **Step 5: The glass suites still pass, with the counts of Step 1.**

- [ ] **Step 6: The other three targets compile.** The three-scheme command. The widget's panes are
  `.flat`: they take the first branch of `routed`, which draws what `content.background(…)` drew
  before.

- [ ] **Step 7: Stage** — `git add WaterBuddy/LiquidGlassModifier.swift`.

---

### Task 7: Home

**Files:**
- Modify: `WaterBuddyTests/HomeViewTests.swift`, `WaterBuddyUITests/GoalSetupUITests.swift`,
  `WaterBuddyUITests/AppStoreScreenshotUITests.swift`, `WaterBuddy/HomeView.swift`,
  `WaterBuddy/Localizable.xcstrings`

**Interfaces:**
- Consumes: `addLog` → `UUID?`, `undoLog(id:)`, `remaining`, `hasReachedGoal`, `lastDrink`,
  `nextReminder`, `streak`, `history`, `todaysLogs` (Tasks 1–4); `Bundle.figure` (Task 5);
  `glassGroup()`, `primarySurface(in:)`, `liquidGlass(in:…)` (Task 6, stage 1).
- Produces: `nonisolated struct UndoOffer`; `HomeView.Serving.isUsual`;
  `HomeView.vesselRange(scaled:)`, `HomeView.discDiameter(scaled:ceiling:)`, `HomeView.glyphs`.

- [ ] **Step 1: Write the failing pure tests.** Append to `WaterBuddyTests/HomeViewTests.swift`:

```swift

// MARK: - Layout and Undo, as values

/// The parts of Home that are decisions rather than drawing, pinned without building a view.
/// Not `@MainActor`: everything read here is `nonisolated` on purpose (rule `43-concurrency`).
struct HomeLayoutTests {

    /// The Glass is ranked above Cup and Bottle (spec §5.2): it is the slot the widget, Siri, the
    /// Control Center control and the watch all log.
    @Test func onlyTheGlassIsRankedAboveTheOthers() {
        let row = HomeView.servings(amounts: [150, 250, 500])

        #expect(row.map(\.isUsual) == [false, true, false])
        #expect(row.first(where: \.isUsual)?.nameKey == vesselSlots[DataManager.usualSlot].nameKey)
    }

    @Test func theVesselIsHeldBetweenItsFloorAndItsCeiling() {
        #expect(HomeView.vesselRange(scaled: 300) == 200...300)
        #expect(HomeView.vesselRange(scaled: 600) == 200...HomeView.vesselCeiling)
        #expect(HomeView.vesselRange(scaled: 150) == 150...150, "the floor never rises above the ceiling")
    }

    @Test func aDiscIsNeverSmallerThanAFingerNorLargerThanItsCeiling() {
        #expect(HomeView.discDiameter(scaled: 30, ceiling: HomeView.sideDiscCeiling) == 44)
        #expect(HomeView.discDiameter(scaled: 68, ceiling: HomeView.sideDiscCeiling) == 68)
        #expect(HomeView.discDiameter(scaled: 400, ceiling: HomeView.sideDiscCeiling) == HomeView.sideDiscCeiling)
    }

    @Test func theGlassDiscOutgrowsItsNeighboursAllTheWayUp() {
        #expect(HomeView.glassDiscCeiling > HomeView.sideDiscCeiling)
        #expect(HomeView.sideDiscCeiling >= 44)
    }

    @Test func anUndoOfferStandsEightSecondsAndDoesNotExpireUnderVoiceOver() {
        #expect(UndoOffer.lifetime(voiceOverRunning: false) == .seconds(8))
        #expect(UndoOffer.lifetime(voiceOverRunning: true) == nil)
    }

    @Test func twoPoursOfOneAmountAreTwoOffers() {
        #expect(UndoOffer(id: UUID(), amount: 250) != UndoOffer(id: UUID(), amount: 250))
    }

    /// An SF Symbol that does not resolve draws nothing at all.
    @Test(arguments: HomeView.glyphs)
    func everyHomeGlyphResolves(symbol: String) {
        #expect(UIImage(systemName: symbol) != nil, "an unresolved SF Symbol draws an empty space")
    }
}
```

- [ ] **Step 2: Run it and see it fail.** `SUITE` = `HomeLayoutTests`. Expected: a build failure
  naming `isUsual`, `vesselRange`, `discDiameter`, the ceilings, `glyphs` and `UndoOffer`.

- [ ] **Step 3: Write the failing UI tests.** In `WaterBuddyUITests/GoalSetupUITests.swift`:

  (a) In `testTheTabBarSwitchesBetweenHomeAndHistory`, replace
  `let logHeading = app.staticTexts["Today"]` by
  `let logHeading = app.buttons["Add a serving"]`, and in that test's DocC replace "the *Today*
  heading in the log" by "the `+` in the log's header — Home has a *Today* heading of its own now".

  (b) In `testSettingsIsReachableFromHomeAsATab`, replace
  `XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 5))` by
  `XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))`.

  (c) Before `dayNames()`, add:

```swift
    // MARK: - Home's header and Undo

    /// The vessel's value ends "… <total> of <goal> millilitres." — the one place a UI test can
    /// read today's total, and why that spoken string keeps its `%d` keys.
    private static func total(in app: XCUIApplication) -> Int {
        let words = (app.otherElements["Today's hydration"].value as? String ?? "").split(separator: " ")
        return words.count > 2 ? Int(words[2]) ?? -1 : -1
    }

    /// Waits until the vessel speaks `total`, and says whether it did.
    private static func waitForTotal(_ total: Int, in app: XCUIApplication) -> Bool {
        let spoken = NSPredicate(format: "value CONTAINS %@", " \(total) of ")
        let reached = XCTNSPredicateExpectation(predicate: spoken, object: app.otherElements["Today's hydration"])
        return XCTWaiter().wait(for: [reached], timeout: 5) == .completed
    }

    @MainActor
    private func launchedOnHome() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        let getStarted = app.buttons["Get Started"]
        if getStarted.waitForExistence(timeout: 5) {
            getStarted.tap()
        }
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5), "the app did not open on Home")
        return app
    }

    /// Home's heading is one element, not a date and a title read as two.
    @MainActor
    func testHomeIsHeadedTodayOnce() throws {
        let app = launchedOnHome()

        XCTAssertEqual(
            app.staticTexts.matching(identifier: "Today").count, 1,
            "Home's heading must resolve to exactly one element"
        )
    }

    /// The whole of Undo, from outside the process: a pour offers it, and taking it removes that
    /// pour and nothing else. Idempotent like the rest of this suite — it compares totals rather
    /// than assuming an empty day.
    @MainActor
    func testUndoTakesBackThePourJustMade() throws {
        let app = launchedOnHome()
        let before = Self.total(in: app)
        XCTAssertGreaterThanOrEqual(before, 0, "the vessel's value did not carry today's total")

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()

        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5), "a pour from Home did not offer Undo")
        XCTAssertEqual(app.buttons.matching(identifier: "Undo").count, 1, "Undo resolves to more than one element")
        XCTAssertGreaterThan(Self.total(in: app), before, "the pour did not reach today's total")

        undo.tap()

        XCTAssertTrue(Self.waitForTotal(before, in: app), "Undo did not take the pour back")
        XCTAssertTrue(undo.waitForNonExistence(timeout: 5), "the offer stood after it was taken")
    }

    /// Two pours, one Undo: only the second comes back, and the first pour's timer must not have
    /// cleared the second's offer.
    @MainActor
    func testUndoAfterTwoPoursTakesBackOnlyTheLast() throws {
        let app = launchedOnHome()
        let before = Self.total(in: app)

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 5))
        let afterGlass = Self.total(in: app)
        XCTAssertGreaterThan(afterGlass, before)

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Cup,")).firstMatch.tap()
        let moved = NSPredicate(format: "NOT (value CONTAINS %@)", " \(afterGlass) of ")
        let poured = XCTNSPredicateExpectation(predicate: moved, object: app.otherElements["Today's hydration"])
        XCTAssertEqual(XCTWaiter().wait(for: [poured], timeout: 5), .completed, "the second pour did not land")

        app.buttons["Undo"].tap()

        XCTAssertTrue(Self.waitForTotal(afterGlass, in: app), "Undo took back something other than the last pour")
    }

    /// An offer lasts eight seconds. Nothing in the unit suite runs the view's timer.
    @MainActor
    func testAnUndoOfferExpires() throws {
        let app = launchedOnHome()

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))

        XCTAssertTrue(undo.waitForNonExistence(timeout: 14), "the offer was still standing after its eight seconds")
    }

    /// Undo is for a pour made from this screen, while this screen is up.
    @MainActor
    func testAnUndoOfferDoesNotOutliveItsScreen() throws {
        let app = launchedOnHome()

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Glass,")).firstMatch.tap()
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 5))

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        app.buttons["Home"].tap()
        XCTAssertTrue(app.otherElements["Today's hydration"].waitForExistence(timeout: 5))

        XCTAssertFalse(app.buttons["Undo"].exists, "the offer came back with the tab")
    }
```

  (d) In `WaterBuddyUITests/AppStoreScreenshotUITests.swift`, all six `app.staticTexts["Today"]`
  (lines 121, 236, 263, 309, 322 and 329 at HEAD) become `app.buttons["Add a serving"]`. Each one
  proves History is showing — after a tap on the *History* tab, after the sheet's *Cancel*, or as
  `returnToTop(of: "History", …)`'s proof — and on the new Home a *Today* text would pass every one
  of them without History ever drawing. **This file is compiled by the gate and never run by it**
  (the capture harness is skipped, and needs an erased device); say so in the record.

- [ ] **Step 4: Run the UI tests on the probe simulator and see them fail.** On the 27.0 probe
  device (its name in every command, so the gate's devices stay clean):

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=WB2 Probe 27' \
  -only-testing:WaterBuddyUITests/GoalSetupUITests -parallel-testing-enabled NO > $SP/u.log 2>&1; echo "exit $?"
grep -E 'Executed [0-9]+ test|error:|XCTAssert|\*\* TEST' $SP/u.log | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-240
```

  This needs the app to build, so do it **after Step 5's pure declarations exist but before the view
  draws Undo**: implement Step 5, run this, and expect `testUndoTakesBackThePourJustMade`,
  `testUndoAfterTwoPoursTakesBackOnlyTheLast`, `testAnUndoOfferExpires` and
  `testAnUndoOfferDoesNotOutliveItsScreen` to fail on "a pour from Home did not offer Undo" (or the
  equivalent first wait), with every older test passing. `testHomeIsHeadedTodayOnce` fails on a
  count of 0.

- [ ] **Step 5: The pure declarations.** In `WaterBuddy/HomeView.swift`:

  Above `struct HomeView`, at file scope:

```swift
/// What Home offers to take back: the one pour just made from this screen.
///
/// A value at file scope, and `nonisolated`, so `HomeLayoutTests` can read it off the main actor
/// (rule `43-concurrency`). It holds the row's **id**, never the row: a `WaterLog` may sit in a
/// view's state only as a sheet's selection (rule `50-views`).
nonisolated struct UndoOffer: Equatable, Sendable {

    /// The serving ``DataManager/addLog(amount:at:)`` returned. Two pours of one amount are two
    /// offers, which is what lets an older pour's timer tell that it has been replaced.
    let id: UUID

    /// Millilitres, for the line that says what would be taken back.
    let amount: Int

    /// How long an offer stands: long enough to notice a mis-tap, short enough that the line it
    /// replaces is not hidden for long.
    static let window: Duration = .seconds(8)

    /// How long this offer stands, or `nil` when it does not time out.
    ///
    /// **VoiceOver gets no deadline.** Eight seconds is a sighted glance; finding a button that
    /// has just appeared, by swiping, is not. The next pour or leaving the screen still ends it.
    static func lifetime(voiceOverRunning: Bool) -> Duration? {
        voiceOverRunning ? nil : window
    }
}
```

  In `Serving`, after `symbol`:

```swift
        /// Whether this is the Glass — the slot every one-tap door logs
        /// (``DataManager/usualSlot``), and so the one Home draws as its main action.
        let isUsual: Bool
```

  Replace `servings(amounts:)`'s body:

```swift
    nonisolated static func servings(amounts: [Int]) -> [Serving] {
        zip(vesselSlots, amounts).enumerated().map { index, pair in
            Serving(
                nameKey: pair.0.nameKey,
                amount: pair.1,
                symbol: pair.0.symbol,
                isUsual: index == DataManager.usualSlot
            )
        }
    }
```

  After it:

```swift

    // MARK: Sizes

    /// The vessel never grows past this, whatever the text size: at 340 pt it is already most of
    /// the narrowest phone's width.
    nonisolated static let vesselCeiling: CGFloat = 340

    /// The vessel never shrinks below this. Under it the readout's second line falls below a
    /// legible size, and a screen that is short of room scrolls instead.
    nonisolated static let vesselFloor: CGFloat = 200

    /// Ceilings for the quick-add discs, so one vessel cannot fill the screen at the
    /// accessibility sizes. The row scrolls sideways before a disc gives up its size.
    nonisolated static let sideDiscCeiling: CGFloat = 92
    nonisolated static let glassDiscCeiling: CGFloat = 120

    /// The diameters the vessel may take: its scaled design size at most, less when the screen
    /// is short, and never under the floor.
    nonisolated static func vesselRange(scaled: CGFloat) -> ClosedRange<CGFloat> {
        let ceiling = min(scaled, vesselCeiling)
        return min(vesselFloor, ceiling)...ceiling
    }

    /// A quick-add disc's diameter: scaled with type, held between the 44 pt floor rule
    /// `65-accessibility` sets and its ceiling.
    nonisolated static func discDiameter(scaled: CGFloat, ceiling: CGFloat) -> CGFloat {
        min(max(scaled, 44), ceiling)
    }

    /// The SF Symbols Home draws beside its own text. `everyHomeGlyphResolves` proves each one,
    /// because an unknown symbol draws nothing at all.
    nonisolated static let streakSymbol = "flame.fill"
    nonisolated static let reminderSymbol = "bell.fill"
    nonisolated static let lastDrinkSymbol = "clock"
    nonisolated static let undoSymbol = "arrow.uturn.backward"
    nonisolated static let glyphs = [streakSymbol, reminderSymbol, lastDrinkSymbol, undoSymbol]
```

  Run `SUITE` = `HomeLayoutTests`: `✔ Test run with 7 tests in 1 suite passed` (one of the seven
  runs over four arguments). Then run Step 4 and see the UI tests fail as predicted.

- [ ] **Step 6: The screen.** Replace `HomeView`'s stored properties, `body` and everything below
  `servings(amounts:)`'s helpers down to `// MARK: - Vessel` by:

```swift
    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverRunning

    /// Bumped on every pour. Drives the haptic, so a daily rollover cannot fire one.
    @State private var pours = 0
    /// Bumped when a pour is taken back.
    @State private var undos = 0
    /// Bumped each time the goal is crossed **upward**, and used as the confetti's seed as well as
    /// its trigger — so two celebrations in one day are two different bursts, not a replay.
    @State private var goalBursts = 0
    /// When water last landed. The waves read this to slosh and settle.
    @State private var lastPour = Date.distantPast
    /// The pour this screen can take back. Presentation state: it lives and dies with the view,
    /// which `RootTabView` rebuilds on every tab change — so leaving the tab ends the offer.
    @State private var undoOffer: UndoOffer?

    /// Real magnitudes, never a unitless `1`: `@ScaledMetric` resolves through `UIFontMetrics`,
    /// which rounds to the nearest third of a point (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .largeTitle) private var scaledVessel: CGFloat = 300
    @ScaledMetric(relativeTo: .title3) private var scaledSideDisc: CGFloat = 68
    @ScaledMetric(relativeTo: .title3) private var scaledGlassDisc: CGFloat = 88

    var body: some View {
        ZStack {
            AuroraBackground()

            // The app's idiom for a screen that can outgrow the display: it centres itself at
            // ordinary sizes and scrolls at the accessibility ones, and on the smallest phone.
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        header
                        Spacer(minLength: 16)
                        vessel
                        status
                            .padding(.top, 24)
                        Spacer(minLength: 20)
                        quickAddRow
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
                // The vessel floats 44 pt of shadow and throws confetti past its rim; a scroll
                // view clips to its bounds, and both would be sliced off square
                // (rule `60-design-system`).
                .scrollClipDisabled()
            }
        }
        // The dark-appearance ruling lives on `RootTabView`: one hosting controller, one place to
        // declare the preference.
        .sensoryFeedback(Haptics.pour, trigger: pours)
        .sensoryFeedback(Haptics.confirm, trigger: undos)
        .sensoryFeedback(trigger: manager.hasReachedGoal) { wasReached, isReached in
            // Only on the way up — crossing back down is a new day or an Undo, not an achievement.
            isReached && !wasReached ? Haptics.goalReached : nil
        }
        // Same edge, a second consumer. `sensoryFeedback`'s closure cannot mutate state, so the
        // burst counter is bumped here rather than folded into the modifier above.
        .onChange(of: manager.hasReachedGoal) { wasReached, isReached in
            if isReached && !wasReached { goalBursts += 1 }
        }
        .task(id: undoClock) { await expire(undoClock) }
        .animation(.smooth(duration: 0.3), value: standingOffer)
        .animation(.smooth(duration: 0.3), value: manager.streak)
        .onAppear { manager.refresh() }
    }

    private var percentage: Int {
        Int((manager.progressUnclamped * 100).rounded())
    }

    // MARK: - Header

    /// The day, the title, and the streak.
    ///
    /// The date is **the model's today** — the start of the last day in ``DataManager/history``,
    /// which the model republishes when the day turns — not a `Date()` read here, which would
    /// keep showing yesterday on a screen left open across midnight. Formatting a label is the
    /// one use `DaySummary.date` exists for.
    private var header: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                if let today = manager.history.last?.date {
                    Text(today, format: .dateTime.weekday(.wide).day().month(.wide))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                }
                Text("Today", bundle: strings)
                    .font(.largeTitle.weight(.bold))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
            // One heading, not a date and a title read as two stops.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today", bundle: strings))
            .accessibilityValue(spokenDate)
            .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            streakChip
        }
    }

    /// The month spelled out, which is how the drawn date already reads.
    private var spokenDate: Text {
        guard let today = manager.history.last?.date else { return Text(verbatim: "") }
        return Text(today.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale)))
    }

    /// A flame and a count: the days in a row the goal was reached. Absent at zero.
    ///
    /// **No noun.** "12 days" needs plural forms in English and Russian that this app's string
    /// path cannot produce yet (known issue #40), so the glyph says what the number counts and
    /// VoiceOver is given the words.
    ///
    /// `.frosted` like the discs, and `.resting` where they are `.raised`: it is a label, and
    /// sitting lower is what keeps it from reading as something to press.
    @ViewBuilder
    private var streakChip: some View {
        if manager.streak > 0 {
            HStack(spacing: 6) {
                Image(systemName: Self.streakSymbol)
                    .foregroundStyle(Aurora.cyan)
                Text(manager.streak, format: .number)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(manager.streak)))
            }
            .font(.subheadline.weight(.bold))
            .fontDesign(.rounded)
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.leading, 10)
            .padding(.trailing, 14)
            .frame(minHeight: 36)
            .liquidGlass(in: Capsule(), density: .frosted, elevation: .resting)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Day streak", bundle: strings))
            .accessibilityValue(Text(manager.streak, format: .number))
            .transition(.opacity)
        }
    }

    // MARK: - Vessel

    /// The vessel, as large as the screen allows.
    ///
    /// It is the one flexible thing in the column: `layoutPriority` hands it whatever height the
    /// header, the status and the row leave, the frame holds that between
    /// ``vesselRange(scaled:)``'s floor and ceiling, and the reader inside tells the vessel what
    /// it got — it needs the number, because its waves and its readout are ratios of it. When
    /// even the floor does not fit, the column grows past the screen and the screen scrolls.
    private var vessel: some View {
        let range = Self.vesselRange(scaled: scaledVessel)

        return GeometryReader { slot in
            WaterVessel(
                level: manager.progress,
                percentage: percentage,
                volume: manager.currentWater,
                goal: manager.dailyGoal,
                diameter: min(slot.size.width, slot.size.height),
                lastPour: lastPour
            )
            // On the vessel, not on the screen. The celebration belongs to the thing that just
            // filled up, and an `overlay` does not clip, so the pieces still travel past the rim.
            .overlay { ConfettiOverlay(burst: goalBursts) }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(
            minWidth: range.lowerBound, maxWidth: range.upperBound,
            minHeight: range.lowerBound, maxHeight: range.upperBound
        )
        .layoutPriority(1)
    }

    // MARK: - Status

    /// What is left, and under it one quiet line — or, straight after a pour, the way to take it
    /// back.
    private var status: some View {
        VStack(spacing: 8) {
            Text(statusText)
                .font(.title2.weight(.bold))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
                .contentTransition(.numericText(value: Double(manager.remaining)))
                .animation(.smooth(duration: 0.5), value: manager.remaining)
                // The figure is drawn grouped and spoken as a number of millilitres.
                .accessibilityLabel(spokenStatus)

            quietLine
                // One height for both of its states, so the row below does not jump when Undo
                // arrives and leaves.
                .frame(minHeight: 44)
        }
    }

    private var statusText: String {
        manager.hasReachedGoal
            ? strings.localizedString(forKey: "Goal reached", value: nil, table: nil)
            : strings.figure("%1$@ ml to go", manager.remaining, locale: locale)
    }

    private var spokenStatus: String {
        manager.hasReachedGoal
            ? strings.localizedString(forKey: "Goal reached", value: nil, table: nil)
            : String(format: strings.localizedString(forKey: "%1$d millilitres to go", value: nil, table: nil), manager.remaining)
    }

    @ViewBuilder
    private var quietLine: some View {
        if let offer = standingOffer {
            undoButton(offer)
                .transition(.opacity)
        } else {
            // Re-read every minute: a reminder that has passed stops being "next", and nothing
            // else would say so on a screen nobody is touching.
            TimelineView(.everyMinute) { _ in
                times(next: manager.nextReminder, last: manager.lastDrink)
            }
            .transition(.opacity)
        }
    }

    /// *Next reminder* and *Last drink*, whichever apply. Side by side when they fit, stacked
    /// when they do not — in Russian they do not, on any phone.
    private func times(next: Date?, last: Date?) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                timeItems(next: next, last: last, divided: true)
            }
            VStack(spacing: 4) {
                timeItems(next: next, last: last, divided: false)
            }
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.white.opacity(0.88))
        .lineLimit(1)
        .shadow(color: .black.opacity(0.25), radius: 6, y: 1)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func timeItems(next: Date?, last: Date?, divided: Bool) -> some View {
        if let next {
            timeItem(Self.reminderSymbol, key: "Next reminder %1$@", at: next)
        }
        if divided, next != nil, last != nil {
            Circle()
                .fill(.white.opacity(0.7))
                .frame(width: 3, height: 3)
                .accessibilityHidden(true)
        }
        if let last {
            timeItem(Self.lastDrinkSymbol, key: "Last drink %1$@", at: last)
        }
    }

    /// One time, in the phone's own 12- or 24-hour form under the app's locale — the spelling
    /// History's rows use.
    private func timeItem(_ symbol: String, key: String, at date: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .accessibilityHidden(true)
            Text(String(
                format: strings.localizedString(forKey: key, value: nil, table: nil),
                date.formatted(.dateTime.hour().minute().locale(locale))
            ))
        }
    }

    // MARK: - Undo

    /// The offer, while the row it names is still one of today's.
    ///
    /// The model is asked rather than trusted from memory: the day can turn, and the row can be
    /// deleted, while an offer stands. An offer whose row has gone is not drawn.
    private var standingOffer: UndoOffer? {
        guard let undoOffer, manager.todaysLogs.contains(where: { $0.id == undoOffer.id }) else { return nil }
        return undoOffer
    }

    /// What the expiry task is keyed on: a new pour, or VoiceOver starting or stopping, restarts
    /// it; nothing else does.
    private var undoClock: UndoClock {
        UndoClock(offer: undoOffer, lifetime: UndoOffer.lifetime(voiceOverRunning: voiceOverRunning))
    }

    private func expire(_ clock: UndoClock) async {
        guard let offer = clock.offer, let lifetime = clock.lifetime else { return }
        do { try await Task.sleep(for: lifetime) } catch { return }
        // Re-checked after the sleep: an older pour's timer must not clear a newer pour's offer
        // (rule `43-concurrency`).
        if undoOffer == offer { undoOffer = nil }
    }

    /// *Added 250 ml · Undo*, as one control.
    ///
    /// The whole capsule is the button: the amount beside the word is what makes it safe to
    /// press. The discs' recipe — `.frosted`, `.raised`, pressable — because it sits among them
    /// and is pressed the same way. Its label is the one word it draws; the amount is its value.
    private func undoButton(_ offer: UndoOffer) -> some View {
        Button {
            manager.undoLog(id: offer.id)
            undoOffer = nil
            undos += 1
        } label: {
            HStack(spacing: 10) {
                Text(strings.figure("Added %1$@ ml", offer.amount, locale: locale))
                    .font(.subheadline.weight(.medium))
                Capsule()
                    .fill(.white.opacity(0.4))
                    .frame(width: 1, height: 16)
                HStack(spacing: 6) {
                    Image(systemName: Self.undoSymbol)
                        .foregroundStyle(Aurora.cyan)
                    Text("Undo", bundle: strings)
                }
                .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 18)
            .frame(minHeight: 44)
            .liquidGlass(in: Capsule(), density: .frosted, elevation: .raised, interactive: true)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(Text("Undo", bundle: strings))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), offer.amount))
    }

    // MARK: - Quick add

    private var sideDisc: CGFloat {
        Self.discDiameter(scaled: scaledSideDisc, ceiling: Self.sideDiscCeiling)
    }

    private var glassDisc: CGFloat {
        Self.discDiameter(scaled: scaledGlassDisc, ceiling: Self.glassDiscCeiling)
    }

    /// The three vessels, side by side under the water.
    ///
    /// **The horizontal scroll is a Dynamic Type escape hatch, not a carousel** — so it is reached
    /// through `ViewThatFits` rather than being the row itself. Three discs fit every iPhone at
    /// the default text sizes; at the accessibility sizes the scaled discs and their captions
    /// overflow, and scrolling is what lets them keep their size instead of being squeezed under
    /// the 44 pt floor (rule `65-accessibility`).
    ///
    /// A bare `ScrollView` is wrong here, for a reason a green suite cannot show: a scroll view's
    /// content aligns to its leading edge, so at the sizes where the row fits — nearly always —
    /// the three would sit against the left margin. `ViewThatFits` gives the common case a plain,
    /// self-centring `HStack` and keeps the scroll for the case that needs it.
    private var quickAddRow: some View {
        ViewThatFits(in: .horizontal) {
            vesselRow
            ScrollView(.horizontal) {
                vesselRow
            }
            .scrollIndicators(.hidden)
            // `.raised` throws a 28 pt shadow, more than any sane padding would reserve.
            .scrollClipDisabled()
        }
    }

    /// Factored out because ``quickAddRow`` builds it **twice**.
    ///
    /// **The Glass is ranked above the other two.** It used to be one of three equal choices, on
    /// the argument that ranking one "would be a claim about the user's glass that this app
    /// cannot make". The app now makes that claim everywhere else: slot 1 is what the widget,
    /// Siri, the Control Center control and the watch all log. So it is the screen's one primary
    /// surface, and Cup and Bottle are glass beside it (spec §5.2, decision D4).
    ///
    /// Aligned at the bottom, so the three captions share a line and the larger disc rises above
    /// its neighbours rather than pushing its caption below theirs.
    private var vesselRow: some View {
        HStack(alignment: .bottom, spacing: 24) {
            ForEach(Self.servings(amounts: manager.servings)) { serving in
                servingButton(serving)
            }
        }
        .padding(.vertical, 8)
        // The two glass discs are siblings a few points apart: one container, one sample of the
        // aurora (rule `60-design-system`).
        .glassGroup()
    }

    /// One vessel: the glyph on its disc, then its amount, then its name.
    ///
    /// The label goes on the `Button` itself rather than on an enclosing
    /// `.accessibilityElement(children: .ignore)`, which **adds** a stop when what it wraps is a
    /// control (`tasks/lessons.md`). Both captions are hidden: the label already says the name and
    /// the amount.
    private func servingButton(_ serving: Serving) -> some View {
        VStack(spacing: 8) {
            Button {
                pour(serving)
            } label: {
                disc(serving)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(String(format: strings.localizedString(forKey: "%1$@, add %2$d millilitres", value: nil, table: nil), serving.name(in: strings), serving.amount))

            VStack(spacing: 1) {
                Text(strings.figure("%1$@ ml", serving.amount, locale: locale))
                    // Ratios of the disc they annotate, never text styles of their own: the disc
                    // is capped and a text style is not, so the two cross over at the
                    // accessibility sizes (rule `65-accessibility`). 0.22 x 68 pt is 15 pt.
                    .font(.system(size: sideDisc * 0.22, weight: serving.isUsual ? .heavy : .bold, design: .rounded))
                    .monospacedDigit()
                Text(serving.name(in: strings))
                    .font(.system(size: sideDisc * 0.18, weight: .semibold))
                    .foregroundStyle(.white.opacity(serving.isUsual ? 1 : 0.92))
            }
            .foregroundStyle(.white)
            .lineLimit(1)
            .shadow(color: .black.opacity(0.3), radius: 4, y: 1)
            .accessibilityHidden(true)
        }
    }

    /// The disc: the primary surface for the Glass, glass for the other two.
    ///
    /// The branch is on the slot, which never changes for a button, so nothing is rebuilt. The
    /// primary surface colours its own content — a glyph that set `.white` there would be white
    /// on white.
    @ViewBuilder
    private func disc(_ serving: Serving) -> some View {
        let diameter = serving.isUsual ? glassDisc : sideDisc
        let glyph = Image(systemName: serving.symbol)
            // A ratio of the disc it sits in, never its own text style, so it cannot grow through
            // the edge at the accessibility sizes (rule `65-accessibility`).
            .font(.system(size: diameter * 0.4, weight: .semibold))
            .frame(width: diameter, height: diameter)

        if serving.isUsual {
            glyph.primarySurface(in: Circle())
        } else {
            glyph
                .foregroundStyle(.white)
                .liquidGlass(in: Circle(), density: .frosted, elevation: .raised, interactive: true)
        }
    }

    /// One call into the model, and the offer to take it back (rule `50-views`).
    private func pour(_ serving: Serving) {
        let id = manager.addLog(amount: serving.amount)
        undoOffer = id.map { UndoOffer(id: $0, amount: serving.amount) }
        pours += 1
        lastPour = Date()
    }
}

/// What Home's expiry task is keyed on.
private struct UndoClock: Equatable {
    let offer: UndoOffer?
    let lifetime: Duration?
}
```

  Then the vessel's readout. In `WaterVessel`: remove
  `@ScaledMetric(relativeTo: .largeTitle) private var readoutSize: CGFloat = 58`, add
  `@Environment(\.locale) private var locale`, and replace `readout`:

```swift
    /// The percentage and, under it, today's water against the goal.
    ///
    /// Sized as ratios of the vessel — which is itself scaled with the text size and bounded by
    /// the screen — never with text styles of their own, so the readout cannot grow through the
    /// rim at the accessibility sizes (rule `65-accessibility`). 0.28 x 300 pt is 84 pt.
    private var readout: some View {
        VStack(spacing: diameter * 0.02) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(percentage, format: .number)
                    .font(.system(size: diameter * 0.28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(percentage)))
                Text("%")
                    .font(.system(size: diameter * 0.1, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.88))
            }

            Text(strings.figure("%1$@ of %2$@ ml", volume, goal, locale: locale))
                .font(.system(size: diameter * 0.057, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        // An over-full vessel reads four digits. Bound the readout to the circle and let it
        // shrink instead of running through the rim.
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: diameter * 0.78)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 2)
        .animation(.smooth(duration: 0.5), value: percentage)
    }
```

  The vessel's `.accessibilityValue` line is **not touched**. In the `#Preview`, nothing changes.

  Last, the string `HomeView` no longer reads: delete the `%1$d / %2$d ml` entry from
  `WaterBuddy/Localizable.xcstrings` after proving nothing else reads it —

```bash
grep -rn --include='*.swift' -F '%1$d / %2$d ml' WaterBuddy WaterBuddyTests WaterBuddyUITests WaterBuddyWidget
```

  Expected: no line. (The watch has its own key, `%1$@ / %2$@ ml`, in its own catalogue.) The JSON
  check of Task 5 then reads `73 keys`.

- [ ] **Step 7: Unit suites.** `HomeLayoutTests`, `HomeServingTests`, `ServingSeamTests`,
  `LocalizationTests`, `HomeStringTests`: each green.

- [ ] **Step 8: The UI suite on the probe simulator.** Step 4's command. Expected: every test in
  `GoalSetupUITests` passes, the five new ones among them. A failure in an older test is read on
  HEAD's code on the same device before it is called a regression (lesson, 2026-10-10).

- [ ] **Step 9: Stage**

```bash
git add WaterBuddy/HomeView.swift WaterBuddy/Localizable.xcstrings WaterBuddyTests/HomeViewTests.swift \
  WaterBuddyUITests/GoalSetupUITests.swift WaterBuddyUITests/AppStoreScreenshotUITests.swift
```

---

### Task 8: On the simulator — render, operate and measure

**Files:** create `WaterBuddyUITests/ZZHomeProbe.swift`, then **delete it** before anything else is
staged. `$SP/measure.swift` and the sampling scripts stay in the scratchpad.

A green suite cannot see a pane that renders wrong, text that cannot be read, or a layout that does
not fit. Every finding goes into the ledger as one line with its figure.

- [ ] **Step 1: The sampler.** Copy stage 1's `measure.swift` into `$SP` and compile it:

```bash
cp /private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/8110631d-1fa6-42f2-80a0-56e7e948c766/scratchpad/measure.swift $SP/measure.swift
xcrun swiftc -O -o $SP/measure $SP/measure.swift && $SP/measure 2>&1 | head -2
```

  If the old scratchpad is gone, rewrite it from stage 1's plan, Task 5 Step 4: it reads a rectangle
  of ground from a PNG and prints, for each `white:<alpha>` or `rgb:<r>,<g>,<b>` foreground, the
  contrast against the rectangle's mean and against its lightest and darkest pixel.

- [ ] **Step 2: Write the probe.** `WaterBuddyUITests/ZZHomeProbe.swift`. One finding per line and
  little asserted, so one run reports everything. A variant is chosen with
  `TEST_RUNNER_WB_VARIANT=<axxxl|ru|uz>` on the `xcodebuild` line:

```swift
// THROWAWAY — deleted before anything is staged. Captures and checks for
// docs/superpowers/plans/2026-10-10-premium-redesign-stage-2.md, Task 8.
import XCTest

final class ZZHomeProbe: XCTestCase {

    private var variant: String { ProcessInfo.processInfo.environment["WB_VARIANT"] ?? "" }

    override func setUp() {
        continueAfterFailure = true
        XCUIDevice.shared.orientation = .portrait
    }

    private func named(_ name: String) -> String { variant.isEmpty ? name : "\(name)-\(variant)" }

    private func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = named(name)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func report(_ name: String, _ findings: [String]) {
        let attachment = XCTAttachment(string: findings.joined(separator: "\n"))
        attachment.name = named(name)
        attachment.lifetime = .keepAlways
        add(attachment)
        print("PROBEFINDINGS " + findings.joined(separator: " | "))
    }

    /// The app, past its first-run screen. In a language variant nothing is found by its English
    /// label, so the first-run screen's one button is taken by position.
    private func launched() -> XCUIApplication {
        let app = XCUIApplication()
        switch variant {
        case "axxxl":
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        case "ru":
            app.launchArguments += ["-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        case "uz":
            app.launchArguments += ["-AppleLanguages", "(uz)", "-AppleLocale", "uz_UZ"]
        default:
            break
        }
        app.launch()
        sleep(2)
        if app.sliders.count == 1, app.buttons.count == 1 {
            app.buttons.firstMatch.tap()
            sleep(2)
        } else if app.buttons["Get Started"].exists {
            if !app.buttons["Get Started"].isHittable { app.swipeUp() }
            app.buttons["Get Started"].tap()
            sleep(2)
        }
        return app
    }

    private func disc(_ app: XCUIApplication, _ name: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "\(name),")).firstMatch
    }

    private func total(_ app: XCUIApplication) -> Int {
        let words = (app.otherElements["Today's hydration"].value as? String ?? "").split(separator: " ")
        return words.count > 2 ? Int(words[2]) ?? -1 : -1
    }

    private func frames(_ app: XCUIApplication) -> [String] {
        let status = app.staticTexts.matching(
            NSPredicate(format: "label ENDSWITH %@ OR label == %@", "millilitres to go", "Goal reached")
        ).firstMatch
        let quiet = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@ OR label CONTAINS %@", "Last drink", "Next reminder")
        ).firstMatch
        let streak = app.descendants(matching: .any).matching(identifier: "Day streak").firstMatch
        let elements: [(String, XCUIElement)] = [
            ("heading", app.staticTexts["Today"]), ("vessel", app.otherElements["Today's hydration"]),
            ("status", status), ("quiet", quiet), ("undo", app.buttons["Undo"]), ("streak", streak),
            ("cup", disc(app, "Cup")), ("glass", disc(app, "Glass")), ("bottle", disc(app, "Bottle")),
            ("tab-home", app.buttons["Home"]),
        ]
        var lines = ["screen: \(app.windows.firstMatch.frame.size) scale: \(XCUIScreen.main.scale)"]
        for (name, element) in elements {
            lines.append(element.exists
                ? "\(name): \(element.frame) label=\(element.label) value=\(element.value as? String ?? "-")"
                : "\(name): MISSING")
        }
        return lines
    }

    /// Every state of Home, with one of each control operated off its label on the way.
    func testA_Walk() {
        let app = launched()
        var findings: [String] = []
        shot("01-home")
        report("01-frames", frames(app))
        guard variant.isEmpty || variant == "axxxl" else {
            // A language variant: by position. The three discs are the first three buttons.
            app.buttons.element(boundBy: 1).tap()
            sleep(1)
            shot("02-home-poured")
            sleep(10)
            shot("03-home-quiet")
            return
        }

        for name in ["Cup", "Glass", "Bottle"] {
            let before = total(app)
            let button = disc(app, name)
            if !button.isHittable { app.swipeUp() }
            // Off the glyph: a fifth of the way in, on the disc's bare surface.
            button.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5)).tap()
            sleep(1)
            findings.append("\(name), tapped off its glyph: \(before) -> \(total(app)); frame \(button.frame)")
        }
        shot("02-home-poured")
        report("02-frames", frames(app))

        let undo = app.buttons["Undo"]
        let beforeUndo = total(app)
        findings.append("Undo: exists \(undo.exists), frame \(undo.exists ? "\(undo.frame)" : "-"), value \(undo.value as? String ?? "-")")
        if undo.exists {
            // Off its label, at the capsule's leading end.
            undo.coordinate(withNormalizedOffset: CGVector(dx: 0.08, dy: 0.5)).tap()
            sleep(1)
            findings.append("Undo, tapped off its label: \(beforeUndo) -> \(total(app)); still shown \(undo.exists)")
        }
        shot("03-home-quiet")
        report("03-frames", frames(app))

        // A drag begun on the vessel: when everything fits, nothing should move.
        let vessel = app.otherElements["Today's hydration"]
        let top = vessel.frame.minY
        vessel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.1, thenDragTo: vessel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: -0.3)))
        sleep(1)
        findings.append("a drag begun on the vessel moved it: \(top) -> \(vessel.frame.minY)")
        if variant == "axxxl" {
            app.swipeUp()
            sleep(1)
            shot("03b-home-scrolled")
            report("03b-frames", frames(app))
            app.swipeDown()
            sleep(1)
        }

        var pours = 0
        while !app.staticTexts["Goal reached"].exists && pours < 14 {
            let bottle = disc(app, "Bottle")
            if !bottle.isHittable { app.swipeUp() }
            bottle.tap()
            pours += 1
            usleep(700_000)
        }
        findings.append("Goal reached after \(pours) more pours: \(app.staticTexts["Goal reached"].exists)")
        shot("04-home-goal")
        sleep(4)
        shot("04b-home-goal-settled")
        report("04-frames", frames(app))
        findings.append("headings named Today: \(app.staticTexts.matching(identifier: "Today").count)")
        report("A-findings", findings)
    }

    /// Home every three seconds for a minute: the aurora's lights swing for 16, 22.5 and 28.5 s,
    /// and a figure is the worst frame, never one capture. The first frames hold Undo.
    func testB_Sweep() {
        let app = launched()
        disc(app, "Glass").tap()
        report("S-frames", frames(app))
        for frame in 0..<20 {
            sleep(3)
            shot(String(format: "S-%02d", frame))
        }
        report("S-frames-end", frames(app))
    }

    /// Yesterday met through History's own sheet, so the chip has something to count.
    func testC_Streak() {
        let app = launched()
        var findings: [String] = []
        disc(app, "Cup").tap()
        app.buttons["History"].tap()

        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        let yesterday = formatter.string(from: Calendar.autoupdatingCurrent.date(byAdding: .day, value: -1, to: Date())!)
        XCTAssertTrue(app.buttons[yesterday].waitForExistence(timeout: 5), "no button for \(yesterday)")
        app.buttons[yesterday].tap()

        for _ in 0..<2 {
            app.buttons["Add a serving"].tap()
            let slider = app.sliders["Serving amount"]
            XCTAssertTrue(slider.waitForExistence(timeout: 5), "the sheet's slider did not appear")
            slider.adjust(toNormalizedSliderPosition: 1)
            sleep(1)
            findings.append("the sheet's slider reads \(slider.value as? String ?? "-")")
            app.buttons["Save"].tap()
            sleep(2)
        }

        app.buttons["Home"].tap()
        sleep(2)
        shot("05-home-streak")
        report("05-frames", frames(app) + findings)
    }

    /// Reminders on, through the app's own switch and the system's own alert.
    func testD_Reminders() {
        let app = launched()
        var findings: [String] = []
        app.buttons["Settings"].tap()
        app.swipeUp()
        let reminders = app.switches["Smart reminders"]
        XCTAssertTrue(reminders.waitForExistence(timeout: 5), "no reminders switch")
        if (reminders.value as? String) != "1" {
            reminders.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
            let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
            if alert.waitForExistence(timeout: 5) {
                findings.append("alert buttons: \(alert.buttons.allElementsBoundByIndex.map(\.label))")
                alert.buttons.element(boundBy: alert.buttons.count - 1).tap()
                sleep(2)
            }
        }
        findings.append("the switch reads \(reminders.value as? String ?? "-") at \(Date())")
        app.buttons["Home"].tap()
        sleep(2)
        shot("06-home-reminders")
        report("06-frames", frames(app) + findings)
    }

    /// Flips Reduce Transparency in the Settings app, as stage 1's probe did, then walks Home.
    /// Run once to switch it on and once more to switch it off.
    func testR_ToggleReduceTransparency() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.terminate()
        settings.launch()

        func open(_ label: String) {
            let cell = settings.staticTexts[label].firstMatch
            var swipes = 0
            while !(cell.exists && cell.isHittable) && swipes < 8 {
                settings.swipeUp()
                swipes += 1
            }
            guard cell.exists && cell.isHittable else {
                return XCTFail("Settings shows no row labelled \(label)")
            }
            cell.tap()
            sleep(1)
        }

        open("Accessibility")
        open("Display & Text Size")
        let toggle = settings.switches["Reduce Transparency"].firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5), "no Reduce Transparency switch")
        toggle.switches.firstMatch.exists ? toggle.switches.firstMatch.tap() : toggle.tap()
        sleep(1)
        report("R-switch", ["Reduce Transparency now reads \(toggle.value as? String ?? "-")"])

        // Back to WaterBuddy without relaunching it, so a pane that was drawn one way is asked
        // to draw the other while it is on screen.
        let app = XCUIApplication()
        app.activate()
        sleep(2)
        shot("R-home-after-flip")
    }
}
```

  The widget placement of Step 10 is written at that step, from the 2026-10-08 lesson, and capped at
  three attempts.

- [ ] **Step 3: Run it on Apple's glass, oldest system first** — `WB2 Probe 26.5`, then
  `WB2 Probe 27`:

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
rm -rf $SP/probe-26.xcresult $SP/shots-26
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=WB2 Probe 26.5' \
  -only-testing:WaterBuddyUITests/ZZHomeProbe -parallel-testing-enabled NO \
  -resultBundlePath $SP/probe-26.xcresult > $SP/p26.log 2>&1; echo "exit $?"
grep -E 'Executed [0-9]+ test|error:|XCTAssert|PROBEFINDINGS|\*\* TEST' $SP/p26.log | sort -u | cut -c1-300
xcrun xcresulttool export attachments --path $SP/probe-26.xcresult --output-path $SP/shots-26
```

- [ ] **Step 4: Look at every capture** with `Read`, and write down what is seen: the heading and
  the date on one side, the chip on the other; the vessel centred, its readout inside the rim; the
  status and the quiet line centred; the Glass a larger white disc between two glass discs, the
  three captions on one line; Undo a glass capsule that replaces the quiet line without moving the
  row; the tab bar as stage 1 left it. Nothing blank, clipped or overlapping.

- [ ] **Step 5: Measure every new pair, through the sweep.** For each row, find clean ground beside
  the text from the frames, and take the worst of the twenty sweep frames:

| Pair | Foreground | Floor |
|---|---|---|
| The date | white 0.92 | 4.5 |
| *Today* (34 pt bold) | white | 3 |
| The status (22 pt bold) | white | 4.5 |
| The quiet line | white 0.88 | 4.5 |
| A side disc's amount, and its name | white, white 0.92 | 4.5 |
| The Glass's amount and name | white | 4.5 |
| Undo: *Added …*, *Undo*, its glyph | white, white, `Aurora.cyan` | 4.5, 4.5, 3 |
| The chip: its number, its flame | white, `Aurora.cyan` | 4.5, 3 |
| The vessel's millilitre line, over water at 45 %, 65 % and full | white | 4.5 |
| The vessel's `%` | white 0.88 | 3 |
| The Glass disc's glyph | `Aurora.top` on white | 3 (derived: `thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade`) |

- [ ] **Step 6: Decide from the table.** A pair under its floor is a defect of this stage unless it
  is older than it. The remedies this plan authorises, in order, each re-rendered and re-measured:

  1. **A dimmed white goes to full white** (the date, the quiet line, a side disc's name, the `%`).
  2. **The cyan flame or the cyan Undo glyph goes white**, if cyan reads under 3:1 on any system.
     Colour was never the only carrier: the flame is a shape and *Undo* is a word.
  3. **Text straight on the aurora that still fails at full white** — the status, the quiet line, a
     caption — is the one case this plan does not settle. Putting that text on a pane changes the
     look the owner approved. Record the figures, leave the text as drawn, and take it to the owner
     in the report with the remedy and its render; the stage is finished without it, because the
     shipped History header and first-run screen set text on the same ground today.
  4. **The millilitre line over water** (known issue #81) is older than the redesign: 2.91–3.07:1 in
     the shipped 1.1. This stage redraws it larger, bolder and at full white. If it now clears
     4.5:1, #81 is closed. If it clears 3:1 and not 4.5:1, record that it is bold text of 14 pt or
     more — WCAG's "large text", whose floor is 3:1 — and that this project has used 24 pt as its
     own line; whether that settles #81 is the owner's call. The scrim is **not** retuned here
     (rule `60-design-system`: shared with the widget and the watch).

- [ ] **Step 7: The settings.** On `WB2 Probe 27`, device booted first, each read back before and
  after (lesson, 2026-10-10): Increase Contrast (`xcrun simctl ui <udid> increase_contrast
  enabled`), then the probe's `testA_Walk`; Reduce Motion and Reduce Transparency through the
  Settings app as stage 1's probe did, each followed by `testA_Walk`. Under Reduce Transparency:
  every pane is the opaque fill with its rim and **each disc and Undo still answer a tap off their
  label** — the `.identity` glass of Task 6 is on this path. Then switch Reduce Transparency off
  again **while WaterBuddy is running** and capture Home: the panes return to glass.

- [ ] **Step 8: The fallback, on iOS 18.6** — `WB2 Probe 18.6`: `testA_Walk`, `testB_Sweep`,
  `testC_Streak`; look and measure as in Steps 4 to 6. Known issue #85 (the hand-made pane reads
  lighter than its records) is on this path: a new pair that fails here for that reason is recorded
  against #85, with its figure, and not fixed by retuning the hand-made stack.

- [ ] **Step 9: The smallest and the largest phone.** `WB2 Small 26.5` (375 × 667 pt) and
  `WB2 Large 27`: `testA_Walk` at the default size and with `WB_VARIANT=axxxl`, and in `ru`. On the
  small phone at the default size the content fits without scrolling and the vessel is at least its
  floor; at `AccessibilityXXXL` the screen scrolls, every disc's frame is at least 44 × 44, the row
  scrolls sideways if it must, and nothing is clipped at either edge.

- [ ] **Step 10: The widget still draws.** `LiquidGlassModifier.swift` compiles into the widget, and
  Task 6 changed how it routes. Place the small and the medium widget on `WB2 Probe 27`'s Home
  Screen by the probe technique of 2026-10-08 (`tasks/lessons.md`, *A Home Screen widget can be
  placed, and read, by a probe*), capture them, and compare with stage 1's record: the same glass
  pane, vessel and button. If placing it cannot be done in three attempts, say so in the record as
  **not run** — the extension built, and its panes take a branch that draws what it drew.

- [ ] **Step 11: Delete the probe and prove it is gone**

```bash
rm WaterBuddyUITests/ZZHomeProbe.swift && git status --short | grep -c ZZHomeProbe
```

  Expected: `0`. A copy stays in `$SP`.

- [ ] **Step 12: Stage** whatever Step 6 changed, by path.

---

### Task 9: The rules — written, shown, left unstaged

**Files:** `.claude/rules/20-state.md`, `30-rollover.md`, `50-views.md`, `60-design-system.md`,
`65-accessibility.md`, `CLAUDE.md`. `.claude/` changes when the owner decides (rule
`99-docs-cascade`). The spec's §10 table, approved with the spec, names the subject of each change;
the wording below has not been seen by the owner, so **none of it is staged**. It is quoted in the
report for a yes.

- [ ] **Step 1: `20-state.md`.** In *One writer*, the mutation-surface bullet becomes:

> - The public mutation surface is `addLog(amount:at:)`, `addWater(amount:)`, `removeWater(amount:)`,
>   `deleteLog(_:)`, `undoLog(id:)`, `updateLog(_:newAmount:timestamp:)`, `saveDailyGoal(ml:)`,
>   `resetIfNeeded()`, `dayDidTurn()`, `resetDailyProgress()` and `refresh()`. Anything new joins that
>   list rather than reaching around it
> - `addLog(amount:at:)` returns the id of the row it inserted, `nil` for a refused amount. Home's
>   *Undo* is the one caller that keeps it. `undoLog(id:)` finds that row among today's, read fresh,
>   and deletes it through `deleteLog(_:)`; it does nothing when the row is gone or today's rows
>   cannot be read

  In *Clamps and guards*, the get-only bullet becomes:

> - `isGoalSet`, `todaysLogs`, `historyLogs` and `streak` stay get-only. All four are consequences,
>   not inputs
> - `streak` is published from `republishHistory()` and from the `dailyGoal` setter, behind
>   `role.drawsHistory`, with an equality guard. A failed read leaves it as it stands, never zero.
>   Every day is judged against the current goal. It never leaves the app: not the snapshot, not a
>   notification, not the wrist's mirror
> - `remaining`, `hasReachedGoal`, `lastDrink` and `nextReminder` are computed on read from the
>   observable state and stored nowhere. `nextReminder` is the first slot of the plan
>   `currentReminderSlots()` files, cut to today

- [ ] **Step 2: `30-rollover.md`.** In *Detecting the turn*, the observers bullet becomes:

> - Keep both observers in `startObservingDayChanges()`: `NSCalendarDayChanged` **and**
>   `NSSystemTimeZoneDidChange`, hopping to `dayDidTurn()` on the main queue, removed in `deinit`.
>   The time-zone one is what catches the traveller mid-flight
> - `dayDidTurn()` runs `resetIfNeeded()` and, only when it reports a new day, republishes today's
>   rows and the history. It never recomputes the total from the rows

- [ ] **Step 3: `50-views.md`.** In *Arithmetic belongs to the model*, add:

> - A visible volume is grouped: `strings.figure("%1$@ ml", amount, locale: locale)`, a `%n$@` key
>   fed a formatted figure. A spoken string keeps its `%n$d` key, so VoiceOver's values do not move

  In *Composition*, add:

> - Home scrolls, on the idiom for a screen that can outgrow the display, and its vessel takes the
>   height the rest of the column leaves, between `HomeView.vesselRange(scaled:)`'s bounds
> - On Home the Glass is ranked above Cup and Bottle: it is the screen's primary surface, because
>   slot `DataManager.usualSlot` is what every one-tap door logs
> - A view holds a serving's **id** when it must name one outside a sheet — `UndoOffer` — never the
>   `WaterLog`

- [ ] **Step 4: `60-design-system.md`.** In *Glass*, after the bullet on the three panes, add:

> - Sibling panes that sit close together — a row of discs — are wrapped with `.glassGroup()`:
>   Apple's `GlassEffectContainer` on iOS 26 and later, the content untouched elsewhere. Never write
>   `GlassEffectContainer` at a call site
> - A pane's content is never moved between branches by a setting. `LiquidGlassModifier` changes the
>   background and the glass handed to `glassEffect` — `.identity` when the pane is not Apple's — so
>   a Reduce Transparency flip rebuilds nothing inside a pane

- [ ] **Step 5: `65-accessibility.md`.** In *VoiceOver*, add:

> - Home's heading is one element: label *Today*, value the date, the header trait. The streak chip
>   is one element — label *Day streak*, value the count — and is absent at zero. The status line
>   speaks millilitres from a `%d` key while it draws a grouped figure
> - *Undo* is one button whose label is the word it draws and whose value is the amount. Its offer
>   lasts eight seconds, and does not time out while VoiceOver is running

- [ ] **Step 6: `CLAUDE.md`.** In *Architecture*, the bullet beginning "**`addLog` is how water
  enters.**" gains a last sentence:

> It returns the id of the row it inserted, which is what Home's *Undo* hands back to
> `undoLog(id:)` — a view holds the id, never the row

- [ ] **Step 7: Prove none of it is staged** — `git diff --cached --name-only | grep -cE '^(\.claude/|CLAUDE\.md)'`
  reads `0`.

---

### Task 10: The gate, the warning comparison, the review

**Files:** none changed, unless the review finds something.

- [ ] **Step 1: Read the diff against the rules** — `git diff --cached` for the source files. Check:
  no colour literal; no `glassEffect` or `GlassEffectContainer` outside `LiquidGlassModifier.swift`;
  no bare `withAnimation`, `print` or `Date()` in logic; every new static a test reads is
  `nonisolated`; no `TODO`; comments say why; `.buttonStyle(PressStyle())` on every button whose
  label is a pane; the vessel's `.accessibilityElement` and value untouched; every mutation one call
  into `DataManager`.

- [ ] **Step 2: Make the gate's simulators**, clean, one per system the UI suite runs on:

```bash
xcrun simctl create "WB2 Gate 27" "iPhone 17" com.apple.CoreSimulator.SimRuntime.iOS-27-0
xcrun simctl create "WB2 Gate 26.5" "iPhone 17" com.apple.CoreSimulator.SimRuntime.iOS-26-5
xcrun simctl create "WB2 Gate 18.6" "iPhone 16" com.apple.CoreSimulator.SimRuntime.iOS-18-6
```

- [ ] **Step 3: The invocations**, foreground, as rule `85-testing` writes them. The unit run on the
  rule's own destination; the UI run on the clean gate devices (known issues #62, #90), once per
  system — iOS 27.0 and 26.5 as the rule requires, 18.6 for the hand-made path (#87):

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO > $SP/g1.log 2>&1; echo "exit $?"
grep -E '✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/g1.log | cut -c1-220
```

```bash
for os in 27.0 26.5 18.6; do
  xcrun simctl shutdown all
  xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
    -destination "platform=iOS Simulator,OS=$os,name=WB2 Gate ${os%.0}" \
    -only-testing:WaterBuddyUITests -parallel-testing-enabled NO \
    -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests > $SP/g2-$os.log 2>&1; echo "$os exit $?"
  grep -E 'Executed [0-9]+ test|error:|\*\* TEST' $SP/g2-$os.log | sort -u | cut -c1-220
done
```

  (One system per `Bash` call if the three together near the 600 s limit. `${os%.0}` turns `27.0`
  into `27`, the device's name.)

```bash
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=27.0,name=Apple Watch Series 12 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO > $SP/g3.log 2>&1; echo "exit $?"
grep -E '✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/g3.log | cut -c1-220
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' > $SP/g4.log 2>&1; echo "exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=27.0,name=Apple Watch Series 12 (46mm)' > $SP/g5.log 2>&1; echo "exit $?"
grep -hE '\*\* BUILD' $SP/g4.log $SP/g5.log
```

  Expected: the unit count re-derived with
  `grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'` and every
  one passing; `Executed N tests, with 0 failures` three times, N being stage 1's 27 plus this
  stage's five; `✔ Test run with 57 tests in 6 suites passed` on the watch; `** BUILD SUCCEEDED **`
  twice. If the watch's pinned device does not boot, run it on *WaterBuddy Watch 27* and say so.

- [ ] **Step 4: Clean builds of the change**, into empty DerivedData, beside Task 0's baseline:

```bash
rm -rf $SP/wc/change $SP/wc/dd-change && cp -R $SP/wc/base $SP/wc/change
git diff --cached --name-only --diff-filter=AM | grep -E '^(WaterBuddy|WaterBuddyTests|WaterBuddyUITests)/' | while read f; do
  mkdir -p "$SP/wc/change/$(dirname "$f")" && git show ":$f" > "$SP/wc/change/$f"
done
git diff --cached --name-only --diff-filter=AM | grep -cE '^(WaterBuddy|WaterBuddyTests|WaterBuddyUITests)/'
```

  The files come out of the **index**, so the comparison is of what will be committed. Then the four
  builds of Task 0 Step 2 with `base` replaced by `change`, and:

```bash
for log in app widget watch watchwidget; do
  grep -E ': warning: ' $SP/wc/change-$log.log | grep -vE '^\s+\|' \
    | sed -E 's#^/[^ ]*/(WaterBuddy[A-Za-z]*/[^:]+):[0-9]+:[0-9]+: #\1: #' | sort | uniq -c > $SP/wc/change-$log.warn
  echo "== $log"; diff $SP/wc/base-$log.warn $SP/wc/change-$log.warn && echo identical
done
```

  Expected: `identical` four times. Any difference is a new warning: fix it at the declaration, then
  run Steps 3 and 4 again.

- [ ] **Step 5: One fresh reviewer, read-only.** Dispatch a general-purpose agent with the spec, this
  plan, the ledger and `git diff --cached` for the source, test and catalogue files, asked for
  defects by severity with a failure scenario each — and told to write nothing. Every Critical and
  Important finding is fixed test-first or answered in the ledger with its reason; Steps 3 and 4 run
  again on the final source.

---

### Task 11: Records, docs — then stop

**Files:** `HISTORY.md`, `tasks/lessons.md`, and what `/doc_sync` writes under `docs/` and
`CLAUDE.md`.

- [ ] **Step 1: Append a checkpoint to `HISTORY.md`**, headed
  `## [<the day it is written>] — The redesign's stage 2: Home`. It records what changed; the rulings
  it rests on; the files; **the verification actually run**, with real figures — the unit and UI
  counts and their destinations, the watch run, the two builds, the warning comparison, Task 8's
  measured table on each system with the sweep's length, each setting rendered, the phones rendered;
  what was **not** run; where the build differs from the canvas (*Added 250 ml*, not *Glass added,
  250 ml*: Russian would need the vessel's gender in the verb; the streak as a flame and a number);
  and what is left unstaged for the owner.

- [ ] **Step 2: Append to `tasks/lessons.md`** what this stage taught that the next would repeat. If
  nothing did, append nothing.

- [ ] **Step 3: Run `/doc_sync`.** It starts from the tree (lesson, 2026-10-10): stage 1 as committed
  and pushed, which the docs still call staged; this stage's state, counts and gate; known issues
  #39 (closed for Home), #81 (closed or re-stated with the new figure), #84(f), #85, #91(a) (retired)
  and #91(d) (two of three comments corrected); `docs/DESIGN.md`'s tables for Home;
  `docs/STATE.md`'s derived values.

- [ ] **Step 4: Stage, explicit paths only, and stop**

```bash
git add HISTORY.md tasks/lessons.md docs/ docs/superpowers/plans/2026-10-10-premium-redesign-stage-2.md
git diff --cached --name-status
git diff --name-status
```

  Expected: the second list shows the six rule and `CLAUDE.md` files of Task 9, and the paths left
  unstaged before this stage; `Screenshots/census/` stays untracked. **Do not commit.** Report to the
  owner: what was built, the measured table, what was not run, the rule wording for their yes, any
  decision Step 6 of Task 8 left for them, and the device check below.

**The owner's device check for this stage** — what no simulator shows:

1. Home in daylight on an iPhone on iOS 26 or later: the heading, the status and the quiet line read
   easily over the aurora as it moves.
2. Pour a Glass, a Cup and a Bottle: each disc answers under the finger, the Glass plainly the main
   one. *Undo* appears, takes back the last pour when pressed, and is gone after about eight seconds.
3. With VoiceOver on: the heading, the streak, the status and *Undo* each read once and sensibly,
   and *Undo* is still there after ten seconds.
4. Meet the goal two days running: the streak shows `2` on the second day, and `1` again the day
   after a missed one.
5. Leave the app open on Home across midnight: the date, the total, the rows and the streak all move
   to the new day without a touch.
6. With reminders on: *Next reminder* names the next slot, moves on after a drink within the hour
   before it, and disappears after 21:00.
7. The largest text size: Home scrolls, and no disc is smaller than a fingertip.
8. Russian and Uzbek: every new line reads naturally — the Uzbek is mine and wants a native eye.

---

## Where the build left this plan — added 2026-10-11, after its last task

Everything above is the plan as written on 2026-10-10 and is not edited. The code that was staged
differs from the code printed in it in these places. Each was a ruling made while building, recorded
at the time in the plan's ledger (whose last lines, from L113 on, were added by the doc passes that
followed), and summarised in `HISTORY.md`'s checkpoints of 2026-10-11; where the two disagree, the
staged source is right. *(The third `/doc_sync` of 2026-10-11 found this list short and one bullet
loose, and added the last seven items under "What was added or changed while rendering".)*

**Defects in the plan itself**

- **Task 7, the vessel's size.** `layoutPriority` and a flexible frame cannot shrink anything inside
  a `ScrollView`, which offers its content its ideal height, and a stack short of room squeezed the
  status line instead. The column is a `Layout`, `HomeColumn`, with
  `HomeView.vesselDiameter(available:others:range:)`; the vessel keeps the `GeometryReader` the
  plan printed and loses what the plan put after it — the `aspectRatio`, the flexible frame and
  the `layoutPriority`.
- **Task 3, `theStreakStaysOutOfTheSnapshotAndTheWristMirror`.** As printed it composed the mirror
  from a second, empty suite and could not have failed. It builds one manager and reads the suite
  that manager wrote.
- **Tasks 1 and 3, the tests for a failed read.** The technique copied from `WristSyncTests` —
  overwrite the store under an open context — is a race. They use `WaterBuddyTests/UnreadableStore.swift`,
  which this plan does not list: a store whose table is renamed away through a second connection.
- **Task 7, the header's accessibility.** A wrapper with `.accessibilityElement(children: .ignore)`
  leaves the title inside it as a second element named *Today*. The title itself carries the date
  as its value and the header trait; the drawn date is hidden.
- **Task 8 Step 5, the yardstick.** The plan measures on clean ground and reserves text that still
  fails at full white for the owner. **The build did measure on clean ground first** — the stage's
  first table, on iOS 26.5 — and pairs failed, some at full white. It then gave that text two
  shadows, ruled that a shadowed line is measured beside its glyphs, and recorded those figures as
  the result — where Step 6 says to leave such text as drawn and take it to the owner with the
  remedy. The clean-ground table for the final source, on all three systems, was taken only when
  the docs were written, and four pairs are under their floor by it. Both tables are in `docs/DESIGN.md`, and the ruling is the owner's (known issue
  #95). *(Corrected by the second `/doc_sync` of 2026-10-11: this bullet first said the
  clean-ground figures "were added afterwards", which hid that the first table was one.)*
- **Task 10, the order.** The reviewer was dispatched before the gate, so that its fixes landed
  before the last measurement pass and the gate ran once, on the final source.
- **Review Focus 1** names `testUndoAfterTwoPoursTakesBackOnlyTheLast` for the first pour's timer;
  that test presses Undo before either timer has anything to say.
  `testAnOlderPoursTimerDoesNotEndANewerOffer` is the one that runs it.
- **Review Focus 3** cannot fail on Home the way the plan feared: a finger's tolerance reaches the
  glyph from anywhere on a 68-point disc, so a pane outside its button's hit region still answers.

**What was added or changed while rendering**

- `legibleOnBackdrop()`, two shadows on every text that sits straight on the aurora, and three
  dimmed whites raised to full white.
- The *Undo* pane is `.opaque` where the discs are `.frosted`.
- The header: the date has the row's whole width, the chip shares the title's line, and the title is
  rigid in height.
- The *Undo* capsule draws the first of three forms that fits at its own size, chosen among three
  buttons in the row's whole width; the one-line forms and the quiet line's are `fixedSize`.
- The vessel's floor is the plan's fixed 200 points — after a floor that rose with the text size was
  built, rendered at every accessibility size, and withdrawn.
- An offer ends when the app goes to the background, which spec §5.2's list does not name.
- The date's own `minimumScaleFactor(0.5)`; six points of vertical padding on the streak chip.
- Six UI tests the plan does not list: the status line is never squeezed, nor the title; an offer
  does not outlive the app leaving the screen; an older pour's timer does not end a newer offer;
  a disc and *Undo* answer off their glyphs; and *Undo* draws its amount whole at the largest text
  size. With the plan's five that is eleven new, and `GoalSetupUITests` holds twenty.
- The quiet line is not built at all when there is neither a next reminder nor a last drink; as
  printed it was an empty element for VoiceOver to land on.
- The quiet line's stacked form may shrink to 0.6 and wrap to two lines.
- In the *Undo* capsule's stacked form the word stays on one line and shrinks before it breaks.
- Two unit tests the plan does not print, `theVesselTakesWhatTheRestOfTheColumnLeaves` and
  `largeTextRaisesTheCeilingAndNeverTheFloor`: `HomeLayoutTests` holds nine, the plan's seven and
  these.
- `UnreadableStore.restoreReads()`, so that the failed-read test can put the table back and assert
  the row survived.
- `_ =` before `addLog` in `HistoryViewTests.swift` and `WaterLogTests.swift`, two files the plan
  does not list: the call returns an id now, and a closure that ends in it warned.
- The plan's count of "13" for `HomeFiguresTests` is a miscount of its own listing, which prints
  fourteen.

**Rule wording.** Task 9's is written as amended by the above — `HomeColumn`, the fixed floor, the
three forms, the background ending, the `ViewThatFits` rule — and is unstaged. No rule was written
for the two-shadow text or its yardstick.

**The device check above still stands**, with two changes: in item 3, *Undo* is still there after
ten seconds **and is gone after the app has been to the background**; and item 7 should say that at
the largest text size on the smallest phone the quick-add row is reached by scrolling.
