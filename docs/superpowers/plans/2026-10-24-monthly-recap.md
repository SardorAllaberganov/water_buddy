# Monthly recap Implementation Plan

> **For agentic workers:** this project forbids an implementation subagent (`CLAUDE.md`, *Implementation —
> one loop, tests first*). Execute inline with superpowers:executing-plans, task by task, in the main loop.
> Steps use checkbox (`- [ ]`) syntax for tracking. **Never commit** — every "stage" step is
> `git add <explicit paths>` and nothing more; the owner runs `/commit`.

**Goal:** Set A's step 5 — a holder's finished month gets a *Monthly recap* sheet whose card can be
shared as an image on the user's own tap, and set A goes on sale.

**Architecture:** The recap is a finished month's existing `MonthHistory`, read on demand by a new
`DataManager.recap(of:)` that publishes nothing; `MonthHistory.make` gains `recap: Neighbour?`, naming the
month a page offers. Two app-only views — `RecapCard` (drawn and rendered by `ImageRenderer`) and
`RecapSheet` — and a row in History's Month mode. `PremiumSet.understand.isOnSale` flips to `true`.

**Tech Stack:** Swift 5 mode, SwiftUI (`ImageRenderer`, `ShareLink` or a wrapped
`UIActivityViewController`), SwiftData through `DataManager`, swift-testing, XCTest for the probe only.

**Spec:** `docs/superpowers/specs/2026-10-24-monthly-recap-design.md` (approved 2026-10-24; corrected while
planning: five new keys, not six; the share footnote on frosted glass). Read it before each task.

## Global Constraints

- `IPHONEOS_DEPLOYMENT_TARGET = 17.0` — every API used here is iOS 16 or earlier; no `#available` added.
- No new key on `DataManager.Key`, no stored figure, no new `role` site; `recap(of:)` writes neither store.
- No `NS*UsageDescription` key; notification authorization stays the only permission (rule `70-privacy`).
- No third-party dependency; no `import` beyond `SwiftUI`, `Foundation`, `SwiftData` (tests) and `XCTest`
  (the throwaway probe only); `UIImage` comes through SwiftUI.
- Every user-visible string through `@Environment(\.strings)` with `\.locale`; `strings.figure` for
  grouped volumes, `strings.localized` otherwise; never `String(format:)` over a resolved key.
- Volumes stay `Int`; `Double` only as a drawing fraction.
- No bare `print` in product code; no `Date()` in logic; no `withAnimation`; no force unwrap in product
  code or previews; no `fatalError`/`precondition`.
- `RecapCard.swift`, `RecapSheet.swift` (and `ShareSheet.swift`) are app-only — in no exception set.
- **Every file change goes through `Edit` or `Write`** — the scratchpad's included; never `sed -i`, a
  heredoc or a script that rewrites a file (`tasks/lessons.md`, 2026-10-22). A refused tool call stops
  the work and is reported.
- Every `xcodebuild test` passes `-collect-test-diagnostics never` while
  `theLinksAreApplesTermsAndAPageOfOurs` is a known red (#159) — every run here is "a run with known
  reds" (`tasks/lessons.md`, 2026-10-22). Foreground, one simulator, `-parallel-testing-enabled NO`,
  `xcrun simctl shutdown all` first.
- Never touch the real `group.sardor.WaterBuddy` suite or `UserDefaults.standard`; every test fixture
  passes a UUID-named suite, an in-memory store, `reloadWidgets`, `rescheduleReminders: { _ in }` and
  `publishWrist: { _ in }`.
- Never weaken an assertion to go green; if a test and the code disagree, stop and report.

The phone unit-test command used throughout (`<FILTER>` is replaced per step):

```bash
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:<FILTER> -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | tail -40
```

## Review Focus

1. **The first-week window at the 7th/8th boundary, read in another time zone** — a traveller whose
   phone says the 7th still sees last month's recap; pinned by
   `MonthRecapTests.theWindowFollowsTheCalendarsDay` (Task 1).
2. **A month that drops below seven days of water after a deletion** — the row goes, and a stale tap
   opens nothing; pinned by `RecapReadingTests.aMonthThatDropsBelowTheBarIsNoLongerRead` (Task 2).
3. **The sender's accessibility text size** — the image someone receives must not change with it;
   pinned by `RecapImageTests.theImageIgnoresTheSendersTextSize` (Task 4).
4. **The largest month there can be** — 31 days at `maximumDailyIntake`, a large change: the image stays
   1,080 px wide and renders; pinned by `RecapImageTests.theLargestMonthStillRenders` (Task 4). Wrapping
   and cut words in Russian and Uzbek are read by eye in the walk (Task 8).
5. **Premium lapsing with the sheet open** — the sheet closes; proved in the walk with a refund (Task 8),
   because no UI run can hold Premium (spec §2).

---

### Task 0: Measure whether *Save Image* needs the Photos key

No product code. A throwaway probe in a scratch copy decides spec §3.5's branch.

**Files (scratch only, never the repository):**
- Copy: the repository → `$SCRATCH/probe/` where
  `SCRATCH=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-Games-WaterBuddy/b8f2e928-70d8-44a5-a298-12f692dd2c5a/scratchpad`
- Create: `$SCRATCH/probe/WaterBuddy/SaveImageProbe.swift`
- Modify: `$SCRATCH/probe/WaterBuddy/WaterBuddyApp.swift` (the `WindowGroup` at `:128`)
- Create: `$SCRATCH/probe/WaterBuddyUITests/SaveImageProbeUITests.swift`
- Modify (repository, at the end): the spec's §2 bullet on *Save Image*, and a §4a recording the result

**Interfaces:**
- Produces: the branch — **ShareLink** (no crash) or **ShareSheet** (crash) — used by Task 5.

- [ ] **Step 1: Copy the repository**

```bash
SCRATCH=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-Games-WaterBuddy/b8f2e928-70d8-44a5-a298-12f692dd2c5a/scratchpad
mkdir -p "$SCRATCH/probe"
rsync -a --exclude '.git' --exclude 'build' --exclude 'DerivedData' --exclude 'Screenshots' ./ "$SCRATCH/probe/"
ls "$SCRATCH/probe"
```

- [ ] **Step 2: Write the probe view** (`Write`, `$SCRATCH/probe/WaterBuddy/SaveImageProbe.swift`)

```swift
import SwiftUI

/// Throwaway: shares one rendered image, so a UI test can press Save Image without the Photos key.
struct SaveImageProbe: View {
    @State private var image: UIImage?

    var body: some View {
        VStack {
            if let image {
                ShareLink(item: Image(uiImage: image), preview: SharePreview("Probe", image: Image(uiImage: image))) {
                    Text("Probe Share")
                }
            }
        }
        .task {
            let renderer = ImageRenderer(content: Color.blue.frame(width: 120, height: 120))
            renderer.scale = 3
            image = renderer.uiImage
        }
    }
}
```

- [ ] **Step 3: Show it on a launch argument** (`Read`, then `Edit` the copy's `WaterBuddyApp.swift`)

Replace, inside `WindowGroup {`:

```swift
            RootView()
                .environment(manager)
                .environment(premium)
                .environment(writer)
```

with:

```swift
            if ProcessInfo.processInfo.arguments.contains("-SaveImageProbe") {
                SaveImageProbe()
            } else {
                RootView()
                    .environment(manager)
                    .environment(premium)
                    .environment(writer)
            }
```

- [ ] **Step 4: Write the probe test** (`Write`, `$SCRATCH/probe/WaterBuddyUITests/SaveImageProbeUITests.swift`)

```swift
import XCTest

/// Throwaway: does the share sheet's Save Image end an app that carries no NSPhotoLibraryAddUsageDescription?
final class SaveImageProbeUITests: XCTestCase {

    func testSaveImageWithoutTheKey() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-SaveImageProbe"]
        app.launch()

        let share = app.buttons["Probe Share"]
        XCTAssertTrue(share.waitForExistence(timeout: 10))
        share.tap()

        let save = app.buttons["Save Image"]
        XCTAssertTrue(save.waitForExistence(timeout: 10), app.debugDescription)
        save.tap()

        sleep(3)
        print("PROBE-STATE \(app.state.rawValue)")
        XCTAssertEqual(app.state, .runningForeground, "the app did not survive Save Image")
    }
}
```

- [ ] **Step 5: Run it on iOS 27.0**

```bash
xcrun simctl shutdown all
xcodebuild test -project "$SCRATCH/probe/WaterBuddy.xcodeproj" -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -derivedDataPath "$SCRATCH/probe-dd" \
  -only-testing:WaterBuddyUITests/SaveImageProbeUITests -parallel-testing-enabled NO \
  -collect-test-diagnostics never 2>&1 | grep -E "PROBE-STATE|error|passed|failed|Save Image|NSPhotoLibrary" | head -30
```

Expected: either `passed` with `PROBE-STATE 4` (the app survived — no key needed), or `failed` with the
app no longer running (state `1`) and, in the log, a privacy-violation message naming
`NSPhotoLibraryAddUsageDescription`. If *Save Image* is not found, read the printed `debugDescription`
for the share sheet's element names and adjust the query once with `Edit`; if it is still not reachable
after a second attempt, **stop and ask the owner** (CLAUDE.md, rabbit holes).

- [ ] **Step 6: Run it on iOS 26.5** — the same command with `OS=26.5,name=iPhone 17`.

- [ ] **Step 7: Record the result in the spec** (`Edit` the repository's spec): replace §2's
  *unconfirmed* bullet with what was measured on each runtime (state and log line), and add a `## 4a.
  Task 0's measurement (2026-10-24)` section naming the branch Task 5 takes. If the two runtimes disagree,
  take **ShareSheet** (the stricter) and say so.

- [ ] **Step 8: Stage the spec**

```bash
git add docs/superpowers/specs/2026-10-24-monthly-recap-design.md
```

---

### Task 1: Which month a page offers (`MonthHistory.recap`)

**Files:**
- Modify: `WaterBuddy/DataManager.swift` — `MonthHistory` (`:2650`), its stored properties (`:2683–2707`),
  `make` (`:2755–2808`), a new private helper beside `longestRun`
- Create: `WaterBuddyTests/MonthRecapTests.swift`

**Interfaces:**
- Produces: `MonthHistory.recap: MonthHistory.Neighbour?`; `nonisolated static let MonthHistory.recapDays = 7`;
  `MonthHistory: Identifiable` with `var id: Int { firstDay }`.

- [ ] **Step 1: Write the failing tests** (`Write`, `WaterBuddyTests/MonthRecapTests.swift`)

```swift
//
//  MonthRecapTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 24/10/26.
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

/// A Gregorian/UTC day, so no test can flake near local midnight or across a DST change.
private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// `amount` at noon UTC on each of `days` of `month` 2026.
private func servings(_ month: Int, _ days: [Int], _ amount: Int = 500) -> [WaterLog] {
    days.map { WaterLog(amount: amount, timestamp: utc(2026, month, $0)) }
}

private func month(
    _ firstDay: Int,
    rows: [WaterLog],
    now: Date,
    first: Date? = utc(2026, 8, 1),
    calendar: Calendar = utcDay
) -> MonthHistory? {
    MonthHistory.make(rows: rows, month: firstDay, firstServing: first, goal: 3_000, now: now, calendar: calendar)
}

/// Thursday 22 October 2026, 14:00 UTC — an ordinary *today*, past the first week.
private let october22 = utc(2026, 10, 22, 14)

// MARK: - Which month a page offers

/// Which recap a month page offers (spec `2026-10-24-monthly-recap-design.md` §3.1), worked out with no
/// store and no main actor. Not `@MainActor`, on purpose: a canary for ``MonthHistory`` staying a pure
/// value (rule `43-concurrency`), as `MonthHistoryTests` is. Fix the declaration it reads, never this suite.
struct MonthRecapTests {

    @Test func aFinishedMonthWithWaterOnSevenDaysOffersItsOwnRecap() {
        let rows = servings(9, Array(1...MonthPatterns.minimumDays))
        #expect(month(20260901, rows: rows, now: october22)?.recap?.firstDay == 20260901)
    }

    @Test func oneDayShortOffersNothing() {
        let rows = servings(9, Array(1..<MonthPatterns.minimumDays))
        #expect(month(20260901, rows: rows, now: october22)?.recap == nil)
    }

    @Test func aDayWithAnyWaterCounts() {
        let rows = servings(9, Array(1...MonthPatterns.minimumDays), 1)
        #expect(month(20260901, rows: rows, now: october22)?.recap?.firstDay == 20260901)
    }

    @Test func theMonthHoldingTodayNeverOffersItself() {
        let rows = servings(10, Array(1...20))
        #expect(month(20261001, rows: rows, now: october22)?.recap == nil)
    }

    @Test func theFirstWeekOffersTheMonthBefore() {
        let rows = servings(9, Array(1...7))
        #expect(month(20261001, rows: rows, now: utc(2026, 10, 1, 0, 1))?.recap?.firstDay == 20260901)
        #expect(month(20261001, rows: rows, now: utc(2026, 10, 7, 23, 59))?.recap?.firstDay == 20260901)
    }

    @Test func theEighthOffersNothing() {
        let rows = servings(9, Array(1...7))
        #expect(month(20261001, rows: rows, now: utc(2026, 10, 8, 0, 0))?.recap == nil)
    }

    @Test func aMonthBeforeThatFallsShortIsNotOffered() {
        let rows = servings(9, Array(1...6))
        #expect(month(20261001, rows: rows, now: utc(2026, 10, 3))?.recap == nil)
    }

    @Test func aFirstMonthIsJudgedOnItsOwnDays() throws {
        let rows = servings(9, Array(20...26))
        let september = try #require(month(20260901, rows: rows, now: october22, first: utc(2026, 9, 20)))
        #expect(september.recap?.firstDay == 20260901)
        #expect(september.daysCounted == 11, "the 20th to the 30th")
    }

    /// Review Focus 1. 03:00 UTC on the 8th is still the evening of the 7th in Los Angeles.
    @Test func theWindowFollowsTheCalendarsDay() {
        let losAngeles = gregorian(in: "America/Los_Angeles")
        let rows = servings(9, Array(1...7))
        let instant = utc(2026, 10, 8, 3)
        #expect(month(20261001, rows: rows, now: instant, calendar: losAngeles)?.recap?.firstDay == 20260901)
        #expect(month(20261001, rows: rows, now: instant, calendar: utcDay)?.recap == nil)
    }

    @Test func theOfferCarriesTheOfferedMonthsFirstInstant() {
        let rows = servings(9, Array(1...7))
        #expect(month(20261001, rows: rows, now: utc(2026, 10, 3))?.recap
                == MonthHistory.Neighbour(firstDay: 20260901, start: utc(2026, 9, 1, 0)))
    }

    @Test func aMonthIsIdentifiedByItsFirstDay() {
        #expect(month(20260901, rows: [], now: october22)?.id == 20260901)
        #expect(MonthHistory.recapDays == 7)
    }
}
```

- [ ] **Step 2: Run them and verify RED** — `<FILTER>` = `WaterBuddyTests/MonthRecapTests`.
  Expected: build fails — `value of type 'MonthHistory' has no member 'recap'` (and `id`, `recapDays`).

- [ ] **Step 3: Implement** (`Edit`, `WaterBuddy/DataManager.swift`)

The declaration (`:2650`):

```swift
nonisolated struct MonthHistory: Sendable, Equatable, Identifiable {
```

After `let patterns: MonthPatterns?` (`:2707`), before the closing brace:

```swift

    /// The month whose recap this page offers, or `nil` (spec `2026-10-24-monthly-recap-design.md` §3.1):
    /// a finished month offers its own once ``MonthPatterns/minimumDays`` of its days hold water; the
    /// month holding today offers the month before's, on the same bar, while today is one of its first
    /// ``recapDays`` days; no page offers more than one. Its instant is for formatting the row's label and
    /// nothing else, as a ``Neighbour``'s always is.
    let recap: Neighbour?

    /// A `.sheet(item:)` selection names a month by its 1st (rule `50-views`).
    var id: Int { firstDay }

    /// How many of a month's first days still offer the month before's recap — the turn of the month.
    nonisolated static let recapDays = 7
```

In `make`'s DocC (`:2751–2754`), after "the month before's are what ``change`` compares with", add
"— and what the first-week offer of a recap reads".

In `make`, before `let firstMonth = …` (`:2794`):

```swift
        // A finished month offers its own recap; the first days of the month holding today offer the
        // month before's (spec §3.1). The day of the month is today's ordinal's, on this calendar.
        let thisMonth = Self.firstDay(ofMonthHolding: now, in: calendar)
        var offered: Int?
        if firstDay < thisMonth {
            offered = holdsARecap(firstDay, totals: totals, in: calendar) ? firstDay : nil
        } else if firstDay == thisMonth, today % 100 <= recapDays,
                  let before = Self.firstDay(of: firstDay, movedBy: -1, in: calendar),
                  holdsARecap(before, totals: totals, in: calendar) {
            offered = before
        }
```

In the `return MonthHistory(` call, after `patterns: …` (`:2804–2806`):

```swift
            ),
            recap: offered.flatMap { neighbour(of: $0, by: 0, exists: true, in: calendar) }
        )
```

(replacing the call's closing `)` and `)` so `recap:` is the last argument). Beside `longestRun` (`:2838`):

```swift
    /// Whether the month whose 1st is `firstDay` holds water on ``MonthPatterns/minimumDays`` days — the
    /// patterns' own bar, by name, so the two cannot drift (spec §3.1). A day before the first serving
    /// holds none.
    nonisolated private static func holdsARecap(_ firstDay: Int, totals: [Int: Int], in calendar: Calendar) -> Bool {
        days(of: firstDay, in: calendar).filter { (totals[$0.ordinal] ?? 0) > 0 }.count >= MonthPatterns.minimumDays
    }
```

`neighbour(of:by:exists:in:)` with `by: 0` returns the month itself with its first instant — the one
existing spelling of a `Neighbour`.

- [ ] **Step 4: Run them and verify GREEN** — the same filter. Expected: `✔ Test run with 11 tests passed`
  (the swift-testing count; the known red is outside this filter).

- [ ] **Step 5: Run the month's own suites** — `<FILTER>` = `WaterBuddyTests/MonthHistoryTests` and
  `WaterBuddyTests/MonthPublishingTests` (two `-only-testing:` flags). Expected: all pass; the new
  field changes no figure they pin.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/MonthRecapTests.swift
```

---

### Task 2: Reading a recap (`DataManager.recap(of:)`)

**Files:**
- Modify: `WaterBuddy/DataManager.swift` — `republishMonth()` (`:1202–1231`), a new `readMonth(_:)` and
  `recap(of:)` beside it
- Modify: `WaterBuddyTests/MonthRecapTests.swift` — a second suite

**Interfaces:**
- Consumes: `MonthHistory.recap` (Task 1).
- Produces: `func recap(of firstDay: Int) -> MonthHistory?` on `DataManager` (main actor).

- [ ] **Step 1: Write the failing tests** (`Edit`, append to `WaterBuddyTests/MonthRecapTests.swift`)

```swift

// MARK: - Reading a recap

private final class Counter: @unchecked Sendable {
    var count = 0
}

/// Every change to what `read` reads, counted (as `MonthHistoryTests`' tally is).
@MainActor
private final class ChangeTally {
    private(set) var count = 0
    private let read: @MainActor () -> Void

    init(_ read: @escaping @MainActor () -> Void) {
        self.read = read
        arm()
    }

    private func arm() {
        withObservationTracking { read() } onChange: { [weak self] in
            MainActor.assumeIsolated {
                self?.count += 1
                self?.arm()
            }
        }
    }
}

/// A `DataManager` over a throwaway suite and an in-memory store — or `container`, for the failed read —
/// with every side effect injected away and the widget doorbell counted (rule `85-testing`).
@MainActor
private func withRecapStore<T>(
    now: @escaping () -> Date,
    container: ModelContainer? = nil,
    reloads: Counter = Counter(),
    _ body: (DataManager, UserDefaults) throws -> T
) throws -> T {
    let name = "test.waterbuddy.recap.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        modelContainer: try container ?? ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        calendar: utcDay,
        now: now,
        reloadWidgets: { reloads.count += 1 },
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    return try body(manager, defaults)
}

/// The recap as `DataManager` reads it (spec §3.6): on demand, a value, published nowhere.
@MainActor
struct RecapReadingTests {

    @Test func aQualifyingMonthIsReadWithTheMonthViewsFigures() throws {
        try withRecapStore(now: { utc(2026, 10, 3) }) { manager, _ in
            manager.addLog(amount: 900, at: utc(2026, 8, 31))
            for day in 1...8 { manager.addLog(amount: 2_000 + day * 100, at: utc(2026, 9, day)) }

            let recap = try #require(manager.recap(of: 20260901))
            manager.showMonth(20260901)

            #expect(recap == manager.month, "the recap is the month view's month, read the same way")
            #expect(recap.change != nil, "the month before was read for the change")
        }
    }

    @Test func aMonthThatFallsShortIsNotRead() throws {
        try withRecapStore(now: { october22 }) { manager, _ in
            for day in 1...6 { manager.addLog(amount: 500, at: utc(2026, 9, day)) }
            #expect(manager.recap(of: 20260901) == nil)
        }
    }

    @Test func theMonthHoldingTodayIsNotRead() throws {
        try withRecapStore(now: { october22 }) { manager, _ in
            for day in 1...20 { manager.addLog(amount: 500, at: utc(2026, 10, day)) }
            #expect(manager.recap(of: 20261001) == nil)
        }
    }

    /// Review Focus 2.
    @Test func aMonthThatDropsBelowTheBarIsNoLongerRead() throws {
        try withRecapStore(now: { october22 }) { manager, _ in
            for day in 1...7 { manager.addLog(amount: 500, at: utc(2026, 9, day)) }
            #expect(manager.recap(of: 20260901) != nil)

            // `allLogs()` is newest first: its first row is the 7th's.
            manager.deleteLog(try #require(manager.allLogs().first))

            #expect(manager.recap(of: 20260901) == nil)
        }
    }

    @Test func readingARecapWritesNothingAndPublishesNothing() throws {
        let reloads = Counter()
        try withRecapStore(now: { october22 }, reloads: reloads) { manager, defaults in
            for day in 1...7 { manager.addLog(amount: 500, at: utc(2026, 9, day)) }
            let stored = { DataManager.Key.all.map { defaults.object(forKey: $0).map { "\($0)" } } }
            let before = stored()
            let rings = reloads.count
            let months = ChangeTally { _ = manager.month }
            let rows = ChangeTally { _ = manager.monthLogs }

            _ = manager.recap(of: 20260901)

            #expect(stored() == before, "a read writes no key")
            #expect(reloads.count == rings, "a read rings no doorbell")
            #expect(months.count == 0)
            #expect(rows.count == 0)
            #expect(manager.month == nil)
        }
    }

    /// A failed read is no recap, never an empty one (rule `20-state`).
    @Test func aFailedReadIsNoRecap() throws {
        let store = try UnreadableStore()
        defer { store.remove() }
        try withRecapStore(now: { october22 }, container: store.container) { manager, _ in
            for day in 1...7 { manager.addLog(amount: 500, at: utc(2026, 9, day)) }
            #expect(manager.recap(of: 20260901) != nil, "the store must be healthy before it is broken")

            try store.breakReads()
            #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")

            #expect(manager.recap(of: 20260901) == nil)
        }
    }
}
```

- [ ] **Step 2: Run them and verify RED** — `<FILTER>` = `WaterBuddyTests/RecapReadingTests`.
  Expected: build fails — `value of type 'DataManager' has no member 'recap'`.

- [ ] **Step 3: Implement** (`Edit`, `WaterBuddy/DataManager.swift`)

Replace `republishMonth()`'s body from its first `guard` through `else { return }` (`:1203–1218`) with:

```swift
        guard Self.role.drawsHistory, let wanted = wantedMonth, let read = readMonth(wanted) else { return }
        let rows = read.rows
        let month = read.month
```

leaving the rest (`// The month before's rows …` onward) unchanged. After `republishMonth()`:

```swift

    /// The finished month whose 1st is `firstDay`, for its recap — or `nil` (spec
    /// `2026-10-24-monthly-recap-design.md` §3.6).
    ///
    /// **A read, not a mutation.** It returns a value and publishes nothing: it **writes neither store**,
    /// rings no doorbell, reschedules nothing and leaves ``month`` and ``monthLogs`` as they stand. The
    /// sheet it feeds covers the screen, and nothing can change a finished month under it, so publishing
    /// it would be machinery with nothing to keep fresh.
    ///
    /// The month is returned only when its own ``MonthHistory/recap`` names itself — finished, and on the
    /// bar. A failed read is `nil`, never an empty month. Behind `role.drawsHistory` for
    /// ``republishMonth()``'s reason.
    func recap(of firstDay: Int) -> MonthHistory? {
        guard Self.role.drawsHistory, let read = readMonth(firstDay), read.month.recap?.firstDay == firstDay
        else { return nil }
        return read.month
    }

    /// The month whose 1st is `firstDay`, and the rows it was worked out from — ``republishMonth()``'s
    /// two reads and ``recap(of:)``'s, spelled once.
    ///
    /// **Two reads**: the store's one range query (``readLogs(from:to:)``), from the 1st of the month
    /// before — whose average ``MonthHistory/change`` compares with, and whose days the first-week recap
    /// offer counts — to the end of the month; and the first serving ever (``readOldestLog()``). **Either
    /// failing returns `nil`**: an empty month is indistinguishable from a user who never drank.
    private func readMonth(_ firstDay: Int) -> (rows: [WaterLog], month: MonthHistory)? {
        guard let shown = MonthHistory.interval(of: firstDay, in: calendar),
              let before = MonthHistory.firstDay(of: firstDay, movedBy: -1, in: calendar),
              let start = MonthHistory.interval(of: before, in: calendar)?.start,
              let rows = readLogs(from: start, to: shown.end),
              let oldest = readOldestLog(),
              let month = MonthHistory.make(
                  rows: rows,
                  month: firstDay,
                  firstServing: oldest.first?.timestamp,
                  goal: storedDailyGoal,
                  now: now(),
                  calendar: calendar
              )
        else { return nil }
        return (rows, month)
    }
```

Trim `republishMonth()`'s DocC: its **Two reads** paragraph now points at ``readMonth(_:)``.

- [ ] **Step 4: Run them and verify GREEN** — `<FILTER>` = `WaterBuddyTests/RecapReadingTests`. Expected:
  `✔ Test run with 6 tests passed`.

- [ ] **Step 5: Run the month's suites again** — `MonthHistoryTests`, `MonthPublishingTests`,
  `MonthRecapTests`, `InsightsPublishingTests`. Expected: all pass (the read is the same read).

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/MonthRecapTests.swift
```

---

### Task 3: The five words

**Files:**
- Modify: `WaterBuddy/Localizable.xcstrings` — five entries appended after `"Half your water came before %1$@."`
- Modify: `WaterBuddyTests/LocalizationTests.swift` — `historyKeys` (`:125–196`)

**Interfaces:**
- Produces: the keys *Monthly recap*, *A day, on average*, *Share as an image*, *Stays in the app, not on
  the image*, *The image leaves your phone only when you send it.* — read by Tasks 4–6.

- [ ] **Step 1: Write the failing test** (`Edit`, `historyKeys`): after `"Half your water came before %1$@.",`

```swift
    // The monthly recap (spec 2026-10-24 §3.10).
    "Monthly recap",
    "A day, on average",
    "Share as an image",
    "Stays in the app, not on the image",
    "The image leaves your phone only when you send it.",
```

- [ ] **Step 2: Run it and verify RED** — `<FILTER>` = `WaterBuddyTests/HistoryStringTests`. Expected:
  `en has no value for "Monthly recap"` (and the other four, in all three languages).

- [ ] **Step 3: Add the entries** (`Edit`, `WaterBuddy/Localizable.xcstrings`) — replace the file's tail

```json
            "value": "Suvingizning yarmi soat %1$@ gacha ichildi."
          }
        }
      }
    }
  },
  "version": "1.0"
}
```

with:

```json
            "value": "Suvingizning yarmi soat %1$@ gacha ichildi."
          }
        }
      }
    },
    "Monthly recap": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Monthly recap" } },
        "ru": { "stringUnit": { "state": "translated", "value": "Итоги месяца" } },
        "uz": { "stringUnit": { "state": "translated", "value": "Oylik xulosa" } }
      }
    },
    "A day, on average": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "A day, on average" } },
        "ru": { "stringUnit": { "state": "translated", "value": "В среднем за день" } },
        "uz": { "stringUnit": { "state": "translated", "value": "Kuniga o‘rtacha" } }
      }
    },
    "Share as an image": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Share as an image" } },
        "ru": { "stringUnit": { "state": "translated", "value": "Поделиться картинкой" } },
        "uz": { "stringUnit": { "state": "translated", "value": "Rasm sifatida ulashish" } }
      }
    },
    "Stays in the app, not on the image": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "Stays in the app, not on the image" } },
        "ru": { "stringUnit": { "state": "translated", "value": "Остаётся в приложении, не на картинке" } },
        "uz": { "stringUnit": { "state": "translated", "value": "Ilovada qoladi, rasmda emas" } }
      }
    },
    "The image leaves your phone only when you send it.": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "The image leaves your phone only when you send it." } },
        "ru": { "stringUnit": { "state": "translated", "value": "Картинка покидает телефон, только когда вы её отправите." } },
        "uz": { "stringUnit": { "state": "translated", "value": "Rasm telefoningizdan faqat siz yuborganingizda chiqadi." } }
      }
    }
  },
  "version": "1.0"
}
```

Shown compact here for reading: write each entry in the file's own expanded layout, as the entry above
it is laid out (one key per line, two-space indent), so Xcode's next save of the catalogue moves nothing.

- [ ] **Step 4: Check the JSON parses** (read-only)

```bash
python3 -I -c "import json,sys; d=json.load(open(sys.argv[1],encoding='utf-8')); print(len(d['strings']))" WaterBuddy/Localizable.xcstrings
```

Expected: `231` (226 + 5).

- [ ] **Step 5: Run and verify GREEN** — `<FILTER>` = `WaterBuddyTests/HistoryStringTests` and
  `WaterBuddyTests/LocalizationTests`. Expected: pass (the known red is in `PaywallOfferTests`, outside).

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/Localizable.xcstrings WaterBuddyTests/LocalizationTests.swift
```

---

### Task 4: The card and its image (`RecapCard`)

**Files:**
- Modify: `WaterBuddy/HistoryView.swift` — lift `MonthFigures`' change helpers (`:1871–1889`) and its glyph
  choice (`:1857`) to `nonisolated static` functions on `HistoryView`, used by both
- Create: `WaterBuddy/RecapCard.swift`
- Create: `WaterBuddyTests/RecapImageTests.swift`

**Interfaces:**
- Consumes: `MonthHistory` (Task 1), the Task 3 keys.
- Produces: `struct RecapCard: View { init(month: MonthHistory) }`;
  `@MainActor static func RecapCard.image(of: MonthHistory, strings: Bundle, locale: Locale) -> UIImage?`;
  `struct RecapCard.Rendered: View { init(month: MonthHistory) }`; `RecapCard.imageWidth` (360),
  `RecapCard.imageScale` (3); `HistoryView.changeSymbol(_:)`, `HistoryView.drawnChange(_:strings:locale:)`,
  `HistoryView.spokenChange(_:strings:locale:)`.

- [ ] **Step 1: Write the failing tests** (`Write`, `WaterBuddyTests/RecapImageTests.swift`)

```swift
//
//  RecapImageTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import Foundation
import SwiftUI
import Testing
@testable import WaterBuddy

private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// September 2026 with water on twenty days and a month before to compare with, read on 22 October.
private func september(amount: Int = 2_400) -> MonthHistory? {
    let rows = (1...31).map { WaterLog(amount: 1_800, timestamp: utc(2026, 8, $0)) }
        + (1...20).map { WaterLog(amount: amount, timestamp: utc(2026, 9, $0)) }
    return MonthHistory.make(rows: rows, month: 20260901, firstServing: utc(2026, 8, 1), goal: 2_500,
                             now: utc(2026, 10, 22), calendar: utcDay)
}

@MainActor
private func render<V: View>(_ view: V) -> UIImage? {
    let renderer = ImageRenderer(content: view)
    renderer.scale = RecapCard.imageScale
    return renderer.uiImage
}

/// The image the recap shares (spec `2026-10-24-monthly-recap-design.md` §3.4): a fixed width, the default
/// text size whatever the sender's, in every language.
@MainActor
struct RecapImageTests {

    @Test func theImageIsTenEightyPixelsWide() throws {
        let month = try #require(september())
        let image = try #require(RecapCard.image(of: month, strings: AppLanguage.english.bundle,
                                                 locale: AppLanguage.english.locale))
        #expect(image.size.width * image.scale == 1_080)
    }

    /// Review Focus 3.
    @Test func theImageIgnoresTheSendersTextSize() throws {
        let month = try #require(september())
        let strings = AppLanguage.english.bundle
        let plain = try #require(render(RecapCard.Rendered(month: month)
            .environment(\.strings, strings).environment(\.dynamicTypeSize, .large)))
        let huge = try #require(render(RecapCard.Rendered(month: month)
            .environment(\.strings, strings).environment(\.dynamicTypeSize, .accessibility5)))
        #expect(plain.size == huge.size)
    }

    @Test(arguments: [AppLanguage.english, .russian, .uzbek])
    func itRendersInEveryLanguage(language: AppLanguage) throws {
        let month = try #require(september())
        #expect(language.bundle.bundleURL.lastPathComponent == "\(language.code ?? "").lproj",
                "the \(language.code ?? "") strings did not resolve")
        let image = try #require(RecapCard.image(of: month, strings: language.bundle, locale: language.locale))
        #expect(image.size.width * image.scale == 1_080)
    }

    /// Review Focus 4.
    @Test func theLargestMonthStillRenders() throws {
        let month = try #require(september(amount: DataManager.maximumDailyIntake))
        let image = try #require(RecapCard.image(of: month, strings: AppLanguage.russian.bundle,
                                                 locale: AppLanguage.russian.locale))
        #expect(image.size.width * image.scale == 1_080)
        #expect(image.size.height > 0)
    }
}
```

- [ ] **Step 2: Run them and verify RED** — `<FILTER>` = `WaterBuddyTests/RecapImageTests`. Expected: build
  fails — `cannot find 'RecapCard' in scope`.

- [ ] **Step 3: Lift the change helpers** (`Edit`, `WaterBuddy/HistoryView.swift`). Beside
  `litres(_:locale:)` (`:229`), add:

```swift

    /// The month's change, drawn — naming no month: Russian would need it in the prepositional case,
    /// which Foundation does not produce (spec `2026-10-22-month-view-design.md` §3.11). The month's
    /// figures and the recap's card both draw it.
    nonisolated static func drawnChange(_ change: Int, strings: Bundle, locale: Locale) -> String {
        if change > 0 { return strings.figure("Up %1$@ ml on the month before", change, locale: locale) }
        if change < 0 { return strings.figure("Down %1$@ ml on the month before", -change, locale: locale) }
        return strings.localizedString(forKey: "The same as the month before", value: nil, table: nil)
    }

    /// The month's change, spoken in millilitres.
    nonisolated static func spokenChange(_ change: Int, strings: Bundle, locale: Locale) -> String {
        if change > 0 { return strings.localized("Up %1$d millilitres on the month before", change, locale: locale) }
        if change < 0 { return strings.localized("Down %1$d millilitres on the month before", -change, locale: locale) }
        return strings.localizedString(forKey: "The same as the month before", value: nil, table: nil)
    }

    /// The month's change, as a glyph.
    nonisolated static func changeSymbol(_ change: Int) -> String {
        change > 0 ? "arrow.up.right" : change < 0 ? "arrow.down.right" : "equal"
    }
```

In `MonthFigures`: delete its private `drawnChange` and `spokenChange` (`:1871–1889`); its
`Text(drawnChange(change))` becomes `Text(HistoryView.drawnChange(change, strings: strings, locale: locale))`;
its `Image(systemName: change > 0 ? … )` becomes `Image(systemName: HistoryView.changeSymbol(change))`; its
`.accessibilityValue(month.change.map(spokenChange) ?? "")` becomes
`.accessibilityValue(month.change.map { HistoryView.spokenChange($0, strings: strings, locale: locale) } ?? "")`.

- [ ] **Step 4: Write the card** (`Write`, `WaterBuddy/RecapCard.swift`)

```swift
//
//  RecapCard.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import SwiftUI

/// A finished month in one card — the monthly recap's, drawn in its sheet and rendered as the image the
/// user may share (spec `2026-10-24-monthly-recap-design.md` §3.4).
///
/// **The card is the image**: one view from one ``MonthHistory``, so what is sent is what was seen.
///
/// **Flat, because it is rendered.** Its canvas is `Aurora.gradient`, not glass, and its tiles take
/// ``LiquidGlass/Base/archived`` — the widget's base — because `ImageRenderer`, like a widget snapshot,
/// has no live backdrop for a `Material` to sample (rule `40-widget`'s ruling, in its second case).
///
/// **No streak, no goal, no serving, no time of day.** The streak never leaves the app (rule
/// `20-state`): the sheet draws it beside the card, never on it.
struct RecapCard: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let month: MonthHistory

    var body: some View {
        VStack(alignment: .leading, spacing: Self.gap) {
            header
            hero
            dots
            tiles
            if let change = month.change {
                changeLine(change)
            }
        }
        .foregroundStyle(.white)
        .padding(Self.inset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)
                .fill(Aurora.gradient)
        )
        .premiumRim()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Monthly recap", bundle: strings))
        .accessibilityValue(spokenFigures)
    }

    /// The month's first instant, for formatting its name and nothing else (``DaySummary/date``).
    private var start: Date? {
        month.days.first?.summary.date
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let start {
                // Small cyan text is assumed to fail until a render says otherwise
                // (`tasks/lessons.md`, 2026-10-22): measured in the walk, white if under 4.5:1.
                Text(start, format: .dateTime.month(.wide).year())
                    .textCase(.uppercase)
                    .font(.footnote.weight(.heavy))
                    .tracking(Self.tracking)
                    .foregroundStyle(Aurora.cyan)
            }
            Spacer(minLength: 8)
            Label {
                Text("WaterBuddy", bundle: strings)
            } icon: {
                Image(systemName: "drop.fill")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(.white.opacity(Self.quiet))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(strings.figure("%1$@/%2$@", month.daysMet, month.daysCounted, locale: locale))
                .font(.largeTitle.weight(.heavy))
                .fontDesign(.rounded)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text("Days on goal", bundle: strings)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    /// One dot a day, in date order, rows of ``dotsPerRow`` — no weekday alignment, so no first weekday
    /// enters the image. A `Grid`, not a lazy one: `ImageRenderer` draws no lazy container.
    private var dots: some View {
        let rows = stride(from: 0, to: month.days.count, by: Self.dotsPerRow).map {
            Array(month.days[$0..<min($0 + Self.dotsPerRow, month.days.count)])
        }
        return Grid(alignment: .leading, horizontalSpacing: Self.dotGap, verticalSpacing: Self.dotGap) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(row, id: \.summary.dayOrdinal) { day in
                        dot(for: day)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    /// Met and unmet differ in shape, never in colour alone (rule `65-accessibility`).
    @ViewBuilder
    private func dot(for day: MonthHistory.Day) -> some View {
        if !day.isCounted {
            Circle().fill(.white.opacity(Self.uncountedDot))
        } else if day.isMet {
            Circle().fill(Aurora.cyan)
        } else {
            Circle().strokeBorder(.white.opacity(Self.unmetRing), lineWidth: Self.ringWidth)
        }
    }

    /// Offered the card's whole width; a row, or a column where a row does not fit
    /// (`tasks/lessons.md`), as `MonthFigures`' tiles are.
    private var tiles: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: Self.tileGap) { tileViews }
            VStack(spacing: Self.tileGap) { tileViews }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var tileViews: some View {
        tile(
            strings.localized("%1$@ L", HistoryView.litres(month.total, locale: locale), locale: locale),
            label: Text("This month", bundle: strings)
        )
        if let average = month.average {
            tile(strings.figure("%1$@ ml", average, locale: locale), label: Text("A day, on average", bundle: strings))
        }
    }

    private func tile(_ figure: String, label: Text) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(figure)
                .font(.title3.weight(.heavy))
                .fontDesign(.rounded)
                .monospacedDigit()
            label
                .font(.footnote)
                .foregroundStyle(.white.opacity(Self.quiet))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: LiquidGlass.innerCornerRadius, base: .archived, density: .sheer, elevation: .flush)
    }

    private func changeLine(_ change: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: HistoryView.changeSymbol(change))
                .font(.body.weight(.semibold))
                .foregroundStyle(Aurora.cyan)
            Text(HistoryView.drawnChange(change, strings: strings, locale: locale))
                .font(.subheadline.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// The month and every figure the card draws, in millilitres — each an existing spoken key.
    private var spokenFigures: String {
        var parts: [String] = []
        if let start {
            parts.append(start.formatted(.dateTime.month(.wide).year().locale(locale)))
        }
        parts.append(strings.localized("%1$d of %2$d days on goal", month.daysMet, month.daysCounted, locale: locale))
        parts.append(strings.localized("%1$d millilitres", month.total, locale: locale))
        if let average = month.average {
            parts.append(strings.localized("Average %1$d millilitres a day", average, locale: locale))
        }
        if let change = month.change {
            parts.append(HistoryView.spokenChange(change, strings: strings, locale: locale))
        }
        return parts.joined(separator: ", ")
    }

    // MARK: - Measures — the concept board's, each pair measured off renders in the walk

    private static let gap: CGFloat = 18
    private static let inset: CGFloat = 22
    private static let tracking: CGFloat = 1.2
    private static let quiet: Double = 0.86
    private static let dotsPerRow = 10
    private static let dotGap: CGFloat = 6
    private static let uncountedDot: Double = 0.12
    private static let unmetRing: Double = 0.4
    private static let ringWidth: CGFloat = 2
    private static let tileGap: CGFloat = 10
    private static let imageMargin: CGFloat = 20
}

// MARK: - The image

extension RecapCard {

    /// The image's width in points, and its scale: 360 × 3 = 1,080 px (spec §3.4).
    nonisolated static let imageWidth: CGFloat = 360
    nonisolated static let imageScale: CGFloat = 3

    /// The card rendered as the image the user may share — in memory only: no file, no key, neither
    /// store (rule `70-privacy`). `nil` if the renderer draws nothing.
    static func image(of month: MonthHistory, strings: Bundle, locale: Locale) -> UIImage? {
        let renderer = ImageRenderer(
            content: Rendered(month: month)
                .environment(\.strings, strings)
                .environment(\.locale, locale)
        )
        renderer.scale = imageScale
        return renderer.uiImage
    }

    /// The card on its margin, at the image's width, at the default text size and in the dark
    /// appearance — what ``image(of:strings:locale:)`` renders.
    struct Rendered: View {

        let month: MonthHistory

        var body: some View {
            RecapCard(month: month)
                .padding(RecapCard.imageMargin)
                .frame(width: RecapCard.imageWidth)
                .background(Aurora.top)
                // The picture never depends on the sender's text size (spec §3.4).
                .dynamicTypeSize(.large)
                // A renderer has no hosting controller for `.preferredColorScheme` to reach — the app's
                // one use of the widget's spelling (spec §3.11).
                .environment(\.colorScheme, .dark)
        }
    }
}

#Preview("The card, September") {
    RecapCardPreview.card
}

/// A month for the canvas, made from a few rows with no store and no `DataManager`.
private enum RecapCardPreview {

    @MainActor static var card: some View {
        let calendar = Calendar.waterBuddyDay
        let september = calendar.date(from: DateComponents(year: 2026, month: 9, day: 1, hour: 12))
        let october = calendar.date(from: DateComponents(year: 2026, month: 10, day: 22, hour: 12))
        let rows = september.map { start in
            (0..<24).compactMap { offset in
                calendar.date(byAdding: .day, value: offset, to: start).map { WaterLog(amount: 2_000 + offset * 40, timestamp: $0) }
            }
        } ?? []
        let month = october.flatMap {
            MonthHistory.make(rows: rows, month: 20260901, firstServing: september, goal: 2_500, now: $0, calendar: calendar)
        }
        return ZStack {
            AuroraBackground()
            if let month {
                RecapCard(month: month).padding(24)
            }
        }
        .environment(\.strings, AppLanguage.english.bundle)
        .environment(\.locale, AppLanguage.english.locale)
        .preferredColorScheme(.dark)
    }
}
```

- [ ] **Step 5: Run them and verify GREEN** — `<FILTER>` = `WaterBuddyTests/RecapImageTests`. Expected:
  every test passes, the language test in all three of its arguments (read the count off the run's own
  line; never type it from here). If
  `theImageIgnoresTheSendersTextSize` fails, the `.dynamicTypeSize(.large)` is not reaching the content —
  fix the declaration, never the test.

- [ ] **Step 6: Run History's own suites** — `<FILTER>` = `WaterBuddyTests/HistoryViewTests` and
  `WaterBuddyTests/HistoryStringTests`. Expected: pass — the lifted helpers say the same words.

- [ ] **Step 7: Stage**

```bash
git add WaterBuddy/HistoryView.swift WaterBuddy/RecapCard.swift WaterBuddyTests/RecapImageTests.swift
```

---

### Task 5: The sheet (`RecapSheet`), and the share control Task 0 chose

**Files:**
- Create: `WaterBuddy/RecapSheet.swift`
- Create (**ShareSheet branch only**): `WaterBuddy/ShareSheet.swift`

**Interfaces:**
- Consumes: `RecapCard`, `RecapCard.image(of:strings:locale:)` (Task 4); Task 0's branch.
- Produces: `struct RecapSheet: View { init(month: MonthHistory) }`.

The sheet has no automated coverage beyond its build (no UI run can hold Premium); the walk proves it.

- [ ] **Step 1: Write the sheet** (`Write`, `WaterBuddy/RecapSheet.swift`) — with the share control of
  Task 0's branch in `shareButton` (both shown; keep one)

```swift
//
//  RecapSheet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import SwiftUI

/// The monthly recap: the month's card, its best streak beside it, and *Share as an image* (spec
/// `2026-10-24-monthly-recap-design.md` §3.3).
///
/// **The image leaves on the user's own tap, and only the card's figures go** (rule `70-privacy`). The
/// best streak is drawn here and never on the card, because the streak never leaves the app (rule
/// `20-state`). The image is rendered when the sheet appears and kept in memory — no file, no key.
struct RecapSheet: View {

    let month: MonthHistory

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss

    /// The card, rendered — presentation state, gone with the sheet.
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            AuroraBackground()

            // Whole at every ordinary size, scrolling once the type outgrows the sheet
            // (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Self.gap) {
                        topBar
                        RecapCard(month: month)
                        streak
                        shareButton
                        footnote
                    }
                    .padding(.horizontal, ScreenMetrics.margin)
                    .padding(.vertical, Self.verticalInset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .task { image = RecapCard.image(of: month, strings: strings, locale: locale) }
    }

    /// The heading, on the aurora with its shadows, and the paywall's close button, labelled *Done*: this
    /// sheet makes no offer to decline.
    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Monthly recap", bundle: strings)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: Self.closeSize, height: Self.closeSize)
                    .liquidGlass(in: Circle(), density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(Text("Done", bundle: strings))
        }
    }

    /// The month's best run — here, never on the image.
    private var streak: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text("Best streak", bundle: strings)
                Spacer(minLength: 8)
                Text(strings.localized("%1$d days", month.bestRun, locale: locale))
                    .monospacedDigit()
            }
            .font(.subheadline.weight(.bold))
            Text("Stays in the app, not on the image", bundle: strings)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .combine)
    }

    /// Sentence-length text never stands bare on the aurora (`tasks/lessons.md`, 2026-10-22): the streak
    /// pane's pair.
    private var footnote: some View {
        Text("The image leaves your phone only when you send it.", bundle: strings)
            .font(.footnote)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .liquidGlass(density: .frosted, elevation: .raised)
    }

    /// The screen's one primary surface. Its label is the surface's colour (rule `60-design-system`).
    private var shareLabel: some View {
        Label {
            Text("Share as an image", bundle: strings)
        } icon: {
            Image(systemName: "square.and.arrow.up")
        }
        .font(.headline)
        .frame(maxWidth: .infinity, minHeight: 56)
        .contentShape(Capsule())
        .primarySurface(in: Capsule())
    }

    // ── ShareLink branch (Task 0: Save Image survives without the key) ──
    @ViewBuilder
    private var shareButton: some View {
        if let image {
            let picture = Image(uiImage: image)
            ShareLink(
                item: picture,
                preview: SharePreview(strings.localizedString(forKey: "Monthly recap", value: nil, table: nil), image: picture)
            ) {
                shareLabel
            }
            .buttonStyle(PressStyle())
        } else {
            shareLabel.opacity(0.5).accessibilityHidden(true)
        }
    }

    // ── ShareSheet branch (Task 0: Save Image needs the key) — replaces the above ──
    // @State private var sharing: SharedImage?
    //
    // private var shareButton: some View {
    //     Button { sharing = image.map(SharedImage.init) } label: { shareLabel }
    //         .buttonStyle(PressStyle())
    //         .disabled(image == nil)
    //         .sheet(item: $sharing) { shared in
    //             ShareSheet(image: shared.image).presentationDetents([.medium, .large])
    //         }
    // }

    private static let gap: CGFloat = 16
    private static let verticalInset: CGFloat = 24
    /// The paywall's close button's, the 44-pt floor (rule `65-accessibility`).
    private static let closeSize: CGFloat = 44
}

#Preview("The recap sheet") {
    RecapSheetPreview.sheet
}

/// A month for the canvas, made from a few rows with no store and no `DataManager`.
private enum RecapSheetPreview {

    @MainActor static var sheet: some View {
        let calendar = Calendar.waterBuddyDay
        let september = calendar.date(from: DateComponents(year: 2026, month: 9, day: 1, hour: 12))
        let october = calendar.date(from: DateComponents(year: 2026, month: 10, day: 22, hour: 12))
        let rows = september.map { start in
            (0..<24).compactMap { offset in
                calendar.date(byAdding: .day, value: offset, to: start).map { WaterLog(amount: 2_000 + offset * 40, timestamp: $0) }
            }
        } ?? []
        let month = october.flatMap {
            MonthHistory.make(rows: rows, month: 20260901, firstServing: september, goal: 2_500, now: $0, calendar: calendar)
        }
        return Group {
            if let month {
                RecapSheet(month: month)
            }
        }
        .environment(\.strings, AppLanguage.english.bundle)
        .environment(\.locale, AppLanguage.english.locale)
    }
}
```

In the file as written, **keep exactly one branch** and delete the other's lines and its marker comment —
no commented-out code is staged.

- [ ] **Step 2 (ShareSheet branch only): Write the wrapper** (`Write`, `WaterBuddy/ShareSheet.swift`), and
  in `RecapSheet` use the commented branch, uncommented, with this file-scope type in `ShareSheet.swift`

```swift
//
//  ShareSheet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import SwiftUI

/// The system's share sheet for one image, with *Save to Photos* left out: pressing it ends an app that
/// carries no `NSPhotoLibraryAddUsageDescription` (measured, spec `2026-10-24-monthly-recap-design.md`
/// §4a), and the app asks for one permission only — notifications (rule `70-privacy`). The user can still
/// send the image anywhere else, or save it to Files.
struct ShareSheet: UIViewControllerRepresentable {

    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.excludedActivityTypes = [.saveToCameraRoll]
        return controller
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
```

and, at the end of `RecapSheet.swift` (one type per file: the selection is the sheet's own):

```swift
/// The rendered image, as the share sheet's `.sheet(item:)` selection (rule `50-views`).
private struct SharedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
```

- [ ] **Step 3: Build the app** (foreground)

```bash
xcrun simctl shutdown all
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | grep -E "error|warning: .*Recap|BUILD" | tail -20
```

Expected: `** BUILD SUCCEEDED **`, no warning naming a `Recap`/`ShareSheet` file.

- [ ] **Step 4: Stage**

```bash
git add WaterBuddy/RecapSheet.swift   # and WaterBuddy/ShareSheet.swift on that branch
```

---

### Task 6: The row and the sheet in History

**Files:**
- Modify: `WaterBuddy/HistoryView.swift` — `@State` beside `paywall` (`:307–308`), `.onChange(of:
  holdsPremium)` (`:387–397`), the sheets (`:426`), `monthRows` after `MonthFigures` (`:564–567`), a new
  `openRecap(_:)` beside `choose(_:)`, a `private struct RecapRow` after `MonthFigures` (`:1891`), a
  `#Preview` of the first-week row

**Interfaces:**
- Consumes: `MonthHistory.recap` (Task 1), `DataManager.recap(of:)` (Task 2), `RecapSheet` (Task 5).

- [ ] **Step 1: Hold the selection** — after `@State private var paywall: PaywallView.Entry?`:

```swift

    /// The recap, while its sheet is open — read once on the row's tap, a value (spec
    /// `2026-10-24-monthly-recap-design.md` §3.7; rule `50-views`).
    @State private var recap: MonthHistory?
```

- [ ] **Step 2: Close it on a lapse** — first line inside `.onChange(of: holdsPremium) { _, holds in`:

```swift
            // A recap is a holder's: Premium refunded with its sheet open closes it (spec §3.3).
            if !holds { recap = nil }
```

- [ ] **Step 3: Present it** — after `.sheet(item: $paywall) { entry in PaywallView(entry: entry) }`:

```swift
        .sheet(item: $recap) { month in RecapSheet(month: month) }
```

- [ ] **Step 4: Draw the row** — in `monthRows`, after the `MonthFigures` block:

```swift

            // The month's recap — a finished month's own, or in the month's first days the month
            // before's (spec `2026-10-24-monthly-recap-design.md` §3.1).
            if let offered = manager.month?.recap {
                RecapRow(offered: offered) { openRecap(offered) }
                    .historyRow(top: 8)
            }
```

and beside `choose(_:)`:

```swift

    /// Reads the offered month once and opens its recap; a read that fails opens nothing (spec §3.2).
    private func openRecap(_ offered: MonthHistory.Neighbour) {
        recap = manager.recap(of: offered.firstDay)
    }
```

- [ ] **Step 5: Write the row** — after `MonthFigures`' closing brace:

```swift

// MARK: - The month's recap

/// The way in to the monthly recap: its title and the offered month's name, which no sentence holds —
/// Russian would need a case Foundation does not produce, and Uzbek writes *your* as a suffix (spec
/// `2026-10-24-monthly-recap-design.md` §3.2). One button.
private struct RecapRow: View {

    @Environment(\.strings) private var strings

    let offered: MonthHistory.Neighbour
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: 12) {
                Image(systemName: PremiumSet.Feature.recap.symbol)
                    .font(.body.weight(.semibold))
                    // A glyph on dark glass, read at 3:1 (`tasks/lessons.md`, 2026-10-22).
                    .foregroundStyle(Aurora.cyan)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Monthly recap", bundle: strings)
                        .font(.subheadline.weight(.bold))
                    Text(offered.start, format: .dateTime.month(.wide).year())
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .contentShape(Rectangle())
            .liquidGlass(density: .frosted, elevation: .raised, interactive: true)
        }
        .buttonStyle(PressStyle())
        .padding(.horizontal, HistoryView.margin)
        .accessibilityLabel(Text("Monthly recap", bundle: strings))
        .accessibilityValue(Text(offered.start, format: .dateTime.month(.wide).year()))
    }
}
```

- [ ] **Step 6: The first-week row's preview** — at the end of the file, beside History's previews:

```swift

#Preview("The recap row, in a month's first week") {
    RecapRowPreview.row
}

/// The new month's first days offering the month before's recap — the case the simulator's own date
/// cannot reach in a walk (spec §4). No store and no `DataManager`.
private enum RecapRowPreview {

    @MainActor static var row: some View {
        let calendar = Calendar.waterBuddyDay
        let september = calendar.date(from: DateComponents(year: 2026, month: 9, day: 1, hour: 12))
        let thirdOfOctober = calendar.date(from: DateComponents(year: 2026, month: 10, day: 3, hour: 9))
        let rows = september.map { start in
            (0..<7).compactMap { offset in
                calendar.date(byAdding: .day, value: offset, to: start).map { WaterLog(amount: 2_000, timestamp: $0) }
            }
        } ?? []
        let offered = thirdOfOctober.flatMap {
            MonthHistory.make(rows: rows, month: 20261001, firstServing: september, goal: 2_500, now: $0, calendar: calendar)
        }?.recap
        return ZStack {
            AuroraBackground()
            if let offered {
                RecapRow(offered: offered) {}
            }
        }
        .environment(\.strings, AppLanguage.english.bundle)
        .environment(\.locale, AppLanguage.english.locale)
        .preferredColorScheme(.dark)
    }
}
```

- [ ] **Step 7: Build, then run History's and the month's suites** — the build command of Task 5 Step 3,
  then `<FILTER>` = `WaterBuddyTests/HistoryViewTests`, `WaterBuddyTests/MonthRecapTests`,
  `WaterBuddyTests/RecapReadingTests`. Expected: `BUILD SUCCEEDED`, all pass.

- [ ] **Step 8: Run the UI tests that read History** — `<FILTER>` =
  `WaterBuddyUITests/PremiumUITests` and the History UI class (find it with
  `grep -l "History" WaterBuddyUITests/*.swift`). Expected: pass — an ordinary run still has no switch.

- [ ] **Step 9: Stage**

```bash
git add WaterBuddy/HistoryView.swift
```

---

### Task 7: Set A on sale

**Files:**
- Modify: `WaterBuddy/PremiumSet.swift` (`:93–99`)
- Modify: `WaterBuddyTests/PremiumSetTests.swift` (`:22–26`)
- Modify: `WaterBuddyTests/PremiumAccessTests.swift` — `PaywallOfferTests`, after `:339`

- [ ] **Step 1: Write the failing tests** (`Edit`). In `PremiumSetTests`, replace

```swift
    /// Step 5 of the spec's §1 puts set A on sale, with the recap — and changes this test with it.
    @Test func setAIsNotOnSaleUntilItsLastFeatureIsBuilt() {
        #expect(!PremiumSet.understand.isOnSale)
        #expect(PremiumSet.onSale.isEmpty)
    }
```

with

```swift
    /// Step 5 of the spec's §1 built the recap, set A's last feature, and put the set on sale (spec
    /// `2026-10-24-monthly-recap-design.md` §3.8).
    @Test func setAIsOnSaleNowEveryFeatureIsBuilt() {
        #expect(PremiumSet.understand.isOnSale)
        #expect(PremiumSet.onSale == [.understand])
    }
```

In `PaywallOfferTests`, after `aDebugSheetListsEverySetAndAReleaseOneOnlyThoseOnSale`:

```swift

    /// Set A on sale is not the paywall offered: a Release build still waits for the privacy policy's
    /// address (#159), so the token can never ship as a live link.
    @Test func setAOnSaleStillWaitsForThePrivacyLink() {
        #expect(!PaywallView.isOffered(debug: false, arguments: [], setsOnSale: PremiumSet.onSale.count,
                                       privacyPolicy: URL(string: "OWNER-PRIVACY-URL")))
        #expect(PaywallView.shownSets(debug: false) == [.understand])
    }
```

- [ ] **Step 2: Run and verify RED** — `<FILTER>` = `WaterBuddyTests/PremiumSetTests` and
  `WaterBuddyTests/PaywallOfferTests`. Expected: `setAIsOnSaleNowEveryFeatureIsBuilt` and
  `setAOnSaleStillWaitsForThePrivacyLink` fail (`isOnSale` is `false`; `shownSets` is empty), beside the
  known red `theLinksAreApplesTermsAndAPageOfOurs`.

- [ ] **Step 3: Implement** (`Edit`, `WaterBuddy/PremiumSet.swift`)

```swift
    /// Whether every feature the set lists is built. **Set A went on sale in step 5**, with the recap
    /// (spec `2026-10-24-monthly-recap-design.md` §3.8); a Release build offers it only once the privacy
    /// policy's address is set (`PaywallView.isOffered(arguments:)`).
    var isOnSale: Bool {
        switch self {
        case .understand: true
        }
    }
```

- [ ] **Step 4: Run and verify GREEN** — the same filter. Expected: all pass except the known red
  `theLinksAreApplesTermsAndAPageOfOurs`.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/PremiumSet.swift WaterBuddyTests/PremiumSetTests.swift WaterBuddyTests/PremiumAccessTests.swift
```

---

### Task 8: The walk

Proves what no test can (spec §4). In a scratch copy, never the tree; the harness is a throwaway
XCUITest file there (`tasks/lessons.md`, 2026-10-22); every file change by `Edit`/`Write`.

- [ ] **Step 1:** Build and install the staged tree on *iPhone 17* (27.0). Launch with `-WaterBuddyPremium`;
  open Settings' Premium card; buy the yearly plan through the scheme's local StoreKit configuration.
  Log at least seven days of water into the previous month through History's Week mode (adding to a past
  day of the shown week), or seed them in the scratch copy's DEBUG fresh start.
- [ ] **Step 2:** History → Month → the previous month: the row is there; tap it; the sheet opens.
  Screenshot (`xcrun simctl io booted screenshot`) in English.
- [ ] **Step 3:** *Share as an image*: the share sheet appears; *Save Image* is absent (ShareSheet branch)
  or saves without the app ending (ShareLink branch). Save to Files; open the PNG; it is 1,080 px wide
  (`sips -g pixelWidth`) and shows the card alone — no streak.
- [ ] **Step 4:** Russian, then Uzbek (Settings → Language): the sheet and the shared PNG — no word cut,
  the change line wrapping rather than truncating.
- [ ] **Step 5:** The largest accessibility text size (`xcrun simctl ui booted content_size
  accessibility-extra-extra-extra-large`): the sheet scrolls, the card's tiles stack; the PNG is the same
  size as at the default.
- [ ] **Step 6:** Reduce Transparency on: the tiles take their opaque fill, on screen and in the PNG.
- [ ] **Step 7:** With the sheet open, refund the purchase in the StoreKit configuration: the sheet closes
  (Review Focus 5).
- [ ] **Step 8:** Contrast off the screenshots and the PNG, each pair by the method `docs/DESIGN.md` uses:
  the cyan month label on the gradient (4.5:1 — white if under), the white labels at 0.86 and 0.9, the
  met and unmet dots and the change glyph (3:1), the row's and the panes' text. Record every figure.
- [ ] **Step 9:** The first-week row through its `#Preview` (Xcode canvas or a render of
  `RecapRowPreview`), since the simulator cannot be put on the 1st–7th.
- [ ] **Step 10:** Any finding is fixed tests-first in the tree, re-walked, and recorded in the spec as a
  §4a amendment.

---

### Task 9: The rule wording (typed, unstaged, for the owner)

**Files (Edit; left unstaged):** `.claude/rules/70-privacy.md`, `20-state.md`, `60-design-system.md`,
`50-views.md`, `65-accessibility.md`, `15-project.md`, `85-testing.md`, `43-concurrency.md`.

- [ ] **Step 1:** Type spec §3.11's wording into each file, at the section it names — `70-privacy`'s new
  *The recap's image, on the user's own tap* after *FoundationModels, for the insights*, naming the branch
  Task 0 took; `MonthRecapTests` into both canary lists (`85-testing`'s *Isolation*, `43-concurrency`'s
  *Tests*).
- [ ] **Step 2:** `git diff --stat .claude/rules/` — eight files, none staged. Report them to the owner.

---

### Task 10: Final review and the gate

- [ ] **Step 1: Self-review the staged diff** against `CLAUDE.md` and the rules: one writer, no key, no
  `print`, no `Date()`, `.sheet(item:)`, strings through the bundle, `.legibleOnBackdrop()` on the
  heading, no Material in the rendered card, no commented-out code, the Global Constraints above. Then a
  read-only review subagent (`code-reviewer`) over `git diff --cached` with the spec — analysis only, it
  writes nothing. Fix findings tests-first; record them in the spec's §4a.
- [ ] **Step 2: The warning baseline** — a clean build of a `HEAD` export into empty DerivedData, and of a
  copy of the index, on all four schemes; compare primary `file:line:col: warning:` lines by file and
  message (`CLAUDE.md`'s warning trail). Expected: no line new.
- [ ] **Step 3: The gate** (rule `85-testing`), each in the foreground, `xcrun simctl shutdown all` first,
  every `test` with `-collect-test-diagnostics never`:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO -collect-test-diagnostics never

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO -collect-test-diagnostics never \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO -collect-test-diagnostics never \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests

xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=27.0,name=Apple Watch Series 12 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -collect-test-diagnostics never

xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17'

xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=27.0,name=Apple Watch Series 12 (46mm)'
```

Expected: unit — every test passes but `theLinksAreApplesTermsAndAPageOfOurs` (#159) and the skipped
`anExpiredYearlyReadsFree` (#157); UI on both runtimes, the watch, both widgets green. The widget and the
watch builds matter: `DataManager.swift` is compiled into all four targets, and `MonthHistory` changed.

- [ ] **Step 4: Count** — `grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'`
  (908 + 11 + 6 + 4 + 1 = 930 expected: Task 1's 11, Task 2's 6, Task 4's 4 attributes, Task 7's +1; the
  renamed test is not new). Print it; never type it from this line.

---

### Task 11: Records, and stop

- [ ] **Step 1:** `HISTORY.md` — a checkpoint headed `## [2026-10-24] — Set A's step 5, the monthly recap,
  …`: what changed, the rulings, the files, the gate as run, the staging block written last.
- [ ] **Step 2:** `docs/AI_CONTEXT.md` (*Current state*, *Targets*' counts, *Files on disk* rows by `wc -l`,
  known issues — #159 now the one thing between set A and a customer; the recap's device proofs; the
  drafts for the sweep), `docs/STATE.md` (`recap(of:)` among the reads), `docs/DESIGN.md` (*Recap,
  measured*), `docs/ROADMAP.md` (1.4.7's note; set A on sale in code), `CLAUDE.md` (the architecture line
  for the recap; the warning trail), `tasks/lessons.md` if the session earned one.
- [ ] **Step 3:** Stage every changed record by explicit path; print `git diff --cached --name-status` and
  `git diff --name-status`; write the staging block from what printed. **Do not commit.** Tell the owner the
  step is staged, the rule wording is unstaged for them, and `/doc_sync` and `/commit` are theirs.
