# The store page, retaken — implementation plan

> **For agentic workers:** executed inline in this session (CLAUDE.md: there is no implementation
> subagent). Steps use checkbox (`- [ ]`) syntax for tracking. **Never commit** — stage with explicit
> paths and stop (rule `90-git`).

**Goal:** ten iPhone shots and three Apple Watch shots of everything built (spec §1), captured by two
scripts — one unattended, one with a human at its pauses.

**Architecture:** two DEBUG launch arguments, effective only beside `-WaterBuddyFreshStart`, give the
unattended capture a fixed month of history (`StoreSample`, through `addLog(amount:at:)`) and a Premium
holder (`PremiumStore.Source.held()`). A second harness method builds a lived-in week through History's
sheet on a simulator pair the new pair script makes, where a human places the widgets and complications.

**Tech stack:** Swift 5 mode, SwiftUI, SwiftData, swift-testing, XCUITest, bash, `simctl`.

**Spec:** `docs/superpowers/specs/2026-10-25-store-page-design.md`.

## Global constraints

- DEBUG only: `StoreSample.swift`'s whole body, `Source.held()`, both arguments and their statics sit
  inside `#if DEBUG`; a Release build contains none of them.
- The seed and the held source act **only** beside `-WaterBuddyFreshStart` — never on a device's App
  Group.
- The seed writes through `DataManager.addLog(amount:at:)` alone (rule `20-state`).
- No bare `Date()` in logic: `now` is injected, defaulted to `Date.init` at the composition root only.
- Days by `calendar.date(byAdding: .day, …)`, times by `calendar.date(bySettingHour:minute:second:of:)`.
- Every amount is one of `DataManager.defaultServings` — Cup 150, Glass 250, Bottle 500.
- No `print` outside `#if DEBUG`; no StoreKit reached by a test except through `PremiumStore.Source`.
- `StoreSampleTests` is not `@MainActor` (a canary); `FreshStartTests` becomes `.serialized`.
- Edit with the Edit tool — `sed -i` is denied, a scratch copy included (`tasks/lessons.md`).
- One `xcodebuild` per `Bash` call, in the foreground; read `Executed N tests`, never the exit alone.

## Review focus

1. **A seeded launch is slow.** ~540 `addLog` calls at launch; the harness's first wait is 30 s, and
   Task 2 times a seeded `freshStartManager` once and records it.
2. **A launch before 1:30 PM** holds no future serving — `nothingIsLaterThanNow` (Task 1).
3. **A DST day** keeps each serving on its own day — `aDSTDayKeepsEveryServingOnItsDay` (Task 1).
4. **The arguments alone, without the fresh start**, do nothing — two tests (Tasks 2 and 3).
5. **The pair's own region** (`en_UZ`) would draw *1 300* on the widgets and the watch — the lived-in
   method chooses English in Settings (Task 5), and the pair script's pauses check it by eye.

---

### Task 1: `StoreSample`, the seed's pure table

**Files:**
- Create: `WaterBuddy/StoreSample.swift`
- Test: `WaterBuddyTests/StoreSampleTests.swift`

**Interfaces — produces:**
- `nonisolated enum StoreSample` (DEBUG)
- `struct StoreSample.Serving: Equatable, Sendable { let at: Date; let amount: Int }`
- `static func servings(endingAt now: Date, calendar: Calendar) -> [StoreSample.Serving]`

- [ ] **Step 1: Write the failing tests** — `WaterBuddyTests/StoreSampleTests.swift`:

```swift
//
//  StoreSampleTests.swift
//  WaterBuddyTests
//

#if DEBUG
import Foundation
import Testing
@testable import WaterBuddy

/// The store capture's history (spec `2026-10-25-store-page-design.md` §3.1). Not `@MainActor`: a
/// canary for `StoreSample`'s isolation (rule `43-concurrency`).
struct StoreSampleTests {

    /// New York, so the DST test has a fall-back day to cross; the rest only need a fixed zone.
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }()

    private static func instant(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    private static func totals(_ servings: [StoreSample.Serving]) -> [Int: Int] {
        servings.reduce(into: [:]) { $0[DataManager.dayOrdinal(for: $1.at, in: calendar), default: 0] += $1.amount }
    }

    @Test func todayIsTheSetsFiveServings() {
        let servings = StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar)
        let today = servings.filter { DataManager.dayOrdinal(for: $0.at, in: Self.calendar) == 20261025 }
        #expect(today.map(\.amount) == [250, 150, 500, 250, 150])
        #expect(today.map { Self.calendar.dateComponents([.hour, .minute], from: $0.at) }
                == [(7, 40), (9, 15), (10, 50), (12, 25), (13, 30)].map { DateComponents(hour: $0.0, minute: $0.1) })
    }

    @Test func theSixDaysBeforeAreTheSetsWeek() {
        let totals = Self.totals(StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar))
        #expect((19...24).map { totals[20261000 + $0] } == [1_650, 2_000, 2_250, 2_150, 2_500, 2_000])
    }

    @Test func nothingIsLaterThanNow() {
        let now = Self.instant(2026, 10, 25, 10)
        let servings = StoreSample.servings(endingAt: now, calendar: Self.calendar)
        #expect(servings.allSatisfy { $0.at <= now })
        #expect(Self.totals(servings)[20261025] == 400, "only 7:40 and 9:15 are before 10 AM")
    }

    @Test func everyAmountIsAFreshStartsVessel() {
        let servings = StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar)
        #expect(servings.allSatisfy { DataManager.defaultServings.contains($0.amount) })
    }

    @Test func theHistoryOpensOnTheFirstOfTheMonthTwoMonthsBack() {
        let totals = Self.totals(StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar))
        #expect(totals.keys.min() == 20260801)
        #expect(totals.count == 31 + 30 + 25, "every day from 1 August to today holds water")
    }

    @Test func thePreviousMonthHoldsARecapAndBothKindsOfDay() {
        let totals = Self.totals(StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar))
        let september = (1...30).compactMap { totals[20260900 + $0] }
        #expect(september.count >= MonthHistory.recapDays)
        #expect(september.contains { $0 >= DataManager.defaultDailyGoal })
        #expect(september.contains { $0 < DataManager.defaultDailyGoal })
    }

    @Test func aDSTDayKeepsEveryServingOnItsDay() {
        // 1 November 2026 is the fall-back Sunday in New York: a 25-hour day.
        let servings = StoreSample.servings(endingAt: Self.instant(2026, 11, 1, 14), calendar: Self.calendar)
        let totals = Self.totals(servings)
        #expect(totals[20261101] == 1_300)
        #expect((26...31).map { totals[20261000 + $0] } == [1_650, 2_000, 2_250, 2_150, 2_500, 2_000])
    }
}
#endif
```

- [ ] **Step 2: Run it, verify RED** — `build-for-testing` fails to compile: `cannot find 'StoreSample'`.

```bash
xcodebuild build-for-testing -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | grep -E 'error:|BUILD' | head
```

- [ ] **Step 3: Implement** — `WaterBuddy/StoreSample.swift`:

```swift
//
//  StoreSample.swift
//  WaterBuddy
//

#if DEBUG
import Foundation

/// The store capture's history: three months of servings ending at `now`, for the fresh start's
/// in-memory store and nothing else (spec `2026-10-25-store-page-design.md` §3.1).
///
/// History's sheet offers seven days, so a UI test cannot enter what the month, Patterns and the recap
/// need. `WaterBuddyApp.freshStartManager(arguments:now:)` logs these through `addLog(amount:at:)` —
/// the one writer — only beside the fresh start's own argument, so a seed can never reach a device's
/// App Group. Pure: no clock, no store, no `DataManager` instance.
nonisolated enum StoreSample {

    /// One serving to log.
    struct Serving: Equatable, Sendable {
        let at: Date
        let amount: Int
    }

    /// A serving as a time of day, before it has a day.
    private typealias Pour = (hour: Int, minute: Int, amount: Int)

    // The fresh start's three vessels — the store set's servings are always one of them.
    private static let cup = DataManager.defaultServings[0]
    private static let glass = DataManager.defaultServings[1]
    private static let bottle = DataManager.defaultServings[2]

    /// Today: 1,300 ml, 65 % of the default goal — the set's figure since 1.1.
    private static let today: [Pour] = [
        (7, 40, glass), (9, 15, cup), (10, 50, bottle), (12, 25, glass), (13, 30, cup),
    ]

    /// The six days before today, oldest first: 1,650 (short), 2,000, 2,250, 2,150, 2,500, 2,000 —
    /// five met, so Home's chip reads *5 days*.
    private static let week: [[Pour]] = [
        [(7, 45, glass), (10, 30, bottle), (13, 0, cup), (16, 20, bottle), (19, 40, glass)],
        [(7, 40, glass), (10, 15, bottle), (12, 40, glass), (15, 30, bottle), (18, 50, bottle)],
        [(7, 20, bottle), (9, 45, glass), (12, 15, bottle), (14, 50, glass), (17, 30, bottle), (20, 10, glass)],
        [(7, 50, glass), (10, 20, bottle), (12, 30, cup), (15, 10, bottle), (17, 45, glass), (20, 30, bottle)],
        [(7, 15, glass), (9, 30, bottle), (11, 45, glass), (14, 0, bottle), (16, 15, glass), (18, 40, bottle), (20, 50, glass)],
        [(8, 5, glass), (10, 40, bottle), (13, 10, glass), (15, 50, bottle), (18, 20, glass), (20, 40, glass)],
    ]

    // Every day before those: a weekday starts early, a weekend late, so Patterns has a difference to
    // draw; one day in four is short of the goal, so the month has misses and the recap a real count.
    private static let weekdayMet: [Pour] = [
        (7, 30, glass), (9, 45, bottle), (12, 0, glass), (14, 30, bottle), (17, 0, cup), (19, 15, glass), (21, 0, cup),
    ]
    private static let weekdayShort: [Pour] = [
        (7, 45, glass), (10, 30, bottle), (13, 15, glass), (17, 0, bottle), (20, 30, cup),
    ]
    private static let weekendMet: [Pour] = [
        (9, 30, cup), (11, 15, bottle), (12, 45, glass), (14, 30, glass), (17, 0, bottle), (19, 30, glass), (21, 30, cup),
    ]
    private static let weekendShort: [Pour] = [
        (10, 0, cup), (12, 30, glass), (15, 30, bottle), (19, 0, glass), (21, 15, cup),
    ]

    /// Every serving from the 1st of the month two months before `now`'s to `now`, oldest first —
    /// none later than `now`, so a launch before 1:30 PM never holds a future serving.
    static func servings(endingAt now: Date, calendar: Calendar) -> [Serving] {
        let today = calendar.startOfDay(for: now)
        guard let thisMonth = calendar.dateInterval(of: .month, for: today)?.start,
              let opening = calendar.date(byAdding: .month, value: -2, to: thisMonth),
              let days = calendar.dateComponents([.day], from: opening, to: today).day
        else { return [] }

        var servings: [Serving] = []
        for offset in stride(from: days, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            for pour in pours(offset: offset, day: day, calendar: calendar) {
                guard let at = calendar.date(bySettingHour: pour.hour, minute: pour.minute, second: 0, of: day),
                      at <= now
                else { continue }
                servings.append(Serving(at: at, amount: pour.amount))
            }
        }
        return servings
    }

    /// The day `offset` days before today: today's five, the set's week, or a generated day.
    private static func pours(offset: Int, day: Date, calendar: Calendar) -> [Pour] {
        if offset == 0 { return today }
        if offset <= week.count { return week[week.count - offset] }
        // Sunday is 1 and Saturday 7 on every Gregorian calendar.
        let weekday = calendar.component(.weekday, from: day)
        let weekend = weekday == 1 || weekday == 7
        let short = calendar.component(.day, from: day) % 4 == 0
        switch (weekend, short) {
        case (false, false): return weekdayMet
        case (false, true): return weekdayShort
        case (true, false): return weekendMet
        case (true, true): return weekendShort
        }
    }
}
#endif
```

- [ ] **Step 4: Run it GREEN** — `build-for-testing` (one call), then:

```bash
xcodebuild test-without-building -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -parallel-testing-enabled NO \
  -only-testing:WaterBuddyTests/StoreSampleTests 2>&1 | grep -E '✔|✘|Test run with|error' | tail -12
```
Expected: `Test run with 7 tests … passed`.

### Task 2: the seed in the fresh start

**Files:**
- Modify: `WaterBuddy/WaterBuddyApp.swift` (the `#if DEBUG` block, `freshStartManager`)
- Test: `WaterBuddyTests/WelcomeTests.swift` (`FreshStartTests`)

**Interfaces:**
- Consumes: `StoreSample.servings(endingAt:calendar:)`
- Produces: `static let storeSampleArgument = "-WaterBuddyStoreSample"`;
  `static func freshStartManager(arguments: [String], now: @escaping () -> Date = Date.init) -> DataManager?`

- [ ] **Step 1: Write the failing tests** — in `FreshStartTests`, which becomes
  `@MainActor @Suite(.serialized) struct FreshStartTests` (its tests share the fixed suite):

```swift
    /// 2026-10-25 at 2 PM on the app's own calendar: after today's last serving, on the 25th.
    private static let afternoon = Calendar.waterBuddyDay.date(
        from: DateComponents(year: 2026, month: 10, day: 25, hour: 14)
    )!

    @Test func theStoreSampleNeedsTheFreshStart() {
        #expect(WaterBuddyApp.freshStartManager(arguments: ["WaterBuddy", WaterBuddyApp.storeSampleArgument, "YES"]) == nil)
    }

    @Test func aFreshStartAloneHoldsNoServings() throws {
        defer { UserDefaults(suiteName: WaterBuddyApp.freshStartSuite)?.removePersistentDomain(forName: WaterBuddyApp.freshStartSuite) }
        let manager = try #require(WaterBuddyApp.freshStartManager(
            arguments: ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES"], now: { Self.afternoon }
        ))
        #expect(manager.currentWater == 0)
        #expect(manager.recap(of: 20260901) == nil)
    }

    @Test func theStoreSampleLandsInTheFreshStart() throws {
        defer { UserDefaults(suiteName: WaterBuddyApp.freshStartSuite)?.removePersistentDomain(forName: WaterBuddyApp.freshStartSuite) }
        let manager = try #require(WaterBuddyApp.freshStartManager(
            arguments: ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES", WaterBuddyApp.storeSampleArgument, "YES"],
            now: { Self.afternoon }
        ))
        #expect(manager.currentWater == 1_300)
        #expect(manager.streak == 5)
        let september = try #require(manager.recap(of: 20260901), "September offers no recap")
        #expect(september.daysCounted == 30)
        #expect(manager.isGoalSet == false, "the seed finished the welcome")
    }
```

- [ ] **Step 2: Run, verify RED** — compile error: `extra argument 'now'` / `storeSampleArgument`.
- [ ] **Step 3: Implement** — in `WaterBuddyApp.swift`'s `#if DEBUG` block:

```swift
    /// The argument the store capture adds beside ``freshStartArgument`` to open on a lived-in history
    /// (``StoreSample``; spec `2026-10-25-store-page-design.md` §3.1). Alone it does nothing.
    static let storeSampleArgument = "-WaterBuddyStoreSample"
```

and `freshStartManager(arguments:now:)` — the signature gains `now: @escaping () -> Date = Date.init`,
the DocC a paragraph: *"Given ``storeSampleArgument`` too, ``StoreSample``'s servings are logged
through ``DataManager/addLog(amount:at:)``, the one writer, before the manager is handed back — only
here, so a seed can only ever land in this in-memory store. `now` is the manager's clock and the
seed's; the app passes none."* The body builds the manager with `now: now` and then:

```swift
        let manager = DataManager(
            defaults: defaults,
            modelContainer: store,
            now: now,
            reloadWidgets: {},
            rescheduleReminders: { _ in },
            publishWrist: { _ in }
        )
        if arguments.contains(storeSampleArgument) {
            for serving in StoreSample.servings(endingAt: now(), calendar: .waterBuddyDay) {
                _ = manager.addLog(amount: serving.amount, at: serving.at)
            }
        }
        return manager
```
(`_ =` only if `addLog` is not `@discardableResult` — read its declaration first.)

- [ ] **Step 4: GREEN** — `build-for-testing`, then `test-without-building
  -only-testing:WaterBuddyTests/FreshStartTests`. Expected: 5 passed. Record the seeded test's duration
  from the log (Review focus 1).

### Task 3: the held Premium

**Files:**
- Modify: `WaterBuddy/PremiumStore.swift` (beside `silent()`), `WaterBuddy/WaterBuddyApp.swift`
  (`init()` and the DEBUG block), `WaterBuddy/HistoryView.swift:3489-3491` (the *Month, held* preview)
- Test: `WaterBuddyTests/WelcomeTests.swift` (`FreshStartTests`)

**Interfaces — produces:** `PremiumStore.Source.held() -> PremiumStore.Source` (DEBUG);
`WaterBuddyApp.premiumHeldArgument = "-WaterBuddyPremiumHeld"`;
`static func premiumSource(arguments: [String]) -> PremiumStore.Source?` (DEBUG).

- [ ] **Step 1: Failing tests** — in `FreshStartTests`:

```swift
    @Test func theHeldPremiumNeedsTheFreshStart() {
        #expect(WaterBuddyApp.premiumSource(arguments: ["WaterBuddy", WaterBuddyApp.premiumHeldArgument, "YES"]) == nil)
        #expect(WaterBuddyApp.premiumSource(arguments: ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES"]) == nil)
    }

    @Test func theHeldPremiumReadsALifetimePurchase() async throws {
        let source = try #require(WaterBuddyApp.premiumSource(
            arguments: ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES", WaterBuddyApp.premiumHeldArgument, "YES"]
        ))
        let store = PremiumStore(source: source)
        await store.refresh()
        #expect(store.state == .known(.lifetime))
    }
```

- [ ] **Step 2: RED** — `cannot find 'premiumSource'`.
- [ ] **Step 3: Implement.** `PremiumStore.swift`, after `silent()`:

```swift
    #if DEBUG
    /// A source that holds the lifetime purchase and reaches no store — for a `#Preview`, and for the
    /// store capture's held launch (`WaterBuddyApp.premiumHeldArgument`). Nothing is bought or stored.
    static func held() -> Self {
        var source = silent()
        source.entitlements = { [PremiumAccess.Entitlement(productID: PremiumAccess.lifetimeID, expires: nil, revoked: nil)] }
        return source
    }
    #endif
```

`WaterBuddyApp.swift` — `init()`:

```swift
        #if DEBUG
        premium = Self.premiumSource(arguments: ProcessInfo.processInfo.arguments).map { PremiumStore(source: $0) }
            ?? PremiumStore()
        #else
        premium = PremiumStore()
        #endif
```

and in the DEBUG block:

```swift
    /// The argument the store capture adds beside ``freshStartArgument`` to draw a Premium holder's
    /// screens (spec `2026-10-25-store-page-design.md` §3.2). Alone it does nothing.
    static let premiumHeldArgument = "-WaterBuddyPremiumHeld"

    /// The held source, given both arguments; otherwise `nil`, and the app reads StoreKit as a Release
    /// build does. Nothing is bought, verified against the App Store or stored.
    static func premiumSource(arguments: [String]) -> PremiumStore.Source? {
        guard arguments.contains(freshStartArgument), arguments.contains(premiumHeldArgument) else { return nil }
        return .held()
    }
```

The *Month, held* preview: its two lines become `.environment(PremiumStore(source: .held()))`.

- [ ] **Step 4: GREEN** — `FreshStartTests`, 7 passed; then the unit target whole.

### Task 4: the store harness and `CaptureScreenshots.sh`

**Files:**
- Modify: `WaterBuddyUITests/AppStoreScreenshotUITests.swift` (class DocC, the store method, the
  sheet helpers), `Tools/CaptureScreenshots.sh`

**Interfaces — consumes:** the two arguments' spellings; labels *Get Started*, *Continue*, *Not now*,
*Today's hydration*, *Day streak*, *Add a serving*, *Last 7 days*, *Today*, *Week*/*Month*/*Insights*,
*See Premium*, *Monthly recap*, *Done*, *Patterns*, the earlier arrow (the previous month, `MMMMy` in
`en_US`, e.g. *September 2026*), the footer containing *Not medical advice*.

- [ ] **Step 1: The store method**, rewritten (gates; free launch → 09, 01, 03, 10; held launch → 05, 07,
  08, 06), with:

```swift
    /// What both store launches pass: a new install, the lived-in history, in `en_US`.
    private let storeLaunch = [
        "-WaterBuddyFreshStart", "YES",
        "-WaterBuddyStoreSample", "YES",
        "-AppleLanguages", "(en)",
        "-AppleLocale", "en_US",
    ]

    /// The day-of-month gate: Patterns need seven finished days of the month holding today, and the
    /// recap is then drawn on the month before's page.
    private let earliestDay = 8
```

The free launch: `app.launchArguments += storeLaunch + ["-WaterBuddyPremium", "YES"]`; *Get Started* waited
30 s (the seed's ~540 pours run at launch); the goal step → `capture("09-goal-setup")`; *Continue* ×2,
*Not now*; Home's vessel `"65 percent. \(listed(1_300)) of \(listed(2_000)) millilitres."` and the chip
`"5 days"` → `01-home`; History, *Last 7 days*, *Today* selected, `app.buttons["Month"]` exists →
`03-history`; Settings, the goal slider, `app.buttons["See Premium"]` exists → `10-settings`;
`app.terminate()`.

The held launch: `storeLaunch + ["-WaterBuddyPremiumHeld", "YES"]`; `completeWelcomeIfShown(held)`; History;
*Month*; the earlier arrow exists → `05-month`; `scroll(held, from: <the earlier arrow>, until: <Patterns
heading>)` → `07-patterns`; `returnToTop(of: "History", …)`, *Month*, the earlier arrow tapped; scrolled until
*Monthly recap* is hittable, tapped; *Done* exists → `08-recap`; *Done*; *Insights*; the footer exists →
`06-insights`. The Patterns heading is `held.descendants(matching: .any).matching(identifier: "Patterns")
.firstMatch`, as the chip is found.

Removed: the `today` wheel table, `setTime(hour:minute:period:in:)`, and the week loop (they move to
Task 5's method, minus the wheel). The class DocC's *Why History's sheet* section is replaced by *Why a
seed* (the seven-day sheet; the fresh start's in-memory store only) and *Why two launches* (a Release
build's free user, then a holder).

- [ ] **Step 2: `Tools/CaptureScreenshots.sh`** — its header says eight shots, the seed, the day gate;
  the top refuses a run before the 8th beside the clock check; step 4's echo; step 6's slugs
  `01-home,03-history,05-month,06-insights,07-patterns,08-recap,09-goal-setup,10-settings`; the last line
  names `Tools/CapturePairScreenshots.sh` for shots 02 and 04 and the watch.
- [ ] **Step 3: Compile** — `build-for-testing` green (the gate compiles the harness; only a capture runs it).

### Task 5: the lived-in week and `CapturePairScreenshots.sh`

**Files:**
- Modify: `WaterBuddyUITests/AppStoreScreenshotUITests.swift` (new `testBuildTheLivedInWeek`)
- Create: `Tools/CapturePairScreenshots.sh`; Delete (`git rm`): `Tools/CaptureWatchScreenshot.sh`

- [ ] **Step 1: The method**:

```swift
    /// Today's five, by vessel: 1,300 ml. The lived-in run logs them at the time the sheet opens on —
    /// no shot it makes draws a serving's time (spec §3.4).
    private let todaysVessels = ["Glass", "Cup", "Bottle", "Glass", "Cup"]

    @MainActor
    func testBuildTheLivedInWeek() throws {
        let clock = Calendar.current.dateComponents([.hour, .minute], from: Date())
        guard (clock.hour ?? 0) * 60 + (clock.minute ?? 0) < 23 * 60 + 45 else {
            XCTFail("the lived-in week is built before 11:45 PM: a run across midnight would split it")
            return
        }
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["Get Started"].waitForExistence(timeout: 10),
                      "no welcome — this is not the pair script's new phone")
        completeWelcomeIfShown(app)
        // History: today's five, then the six days before, each total read back off its day's button.
        // (The 2026-10-18 week loop, `earlierDays`, `amounts`, `openSheet`, `save`, `waitForTotal`.)
        // Settings: *English* — the widgets and the watch draw in the app's language, and the pair is in
        // the Mac's region, which prints *1 300*.
        // Home: the vessel's 65 % and the chip's *5 days* asserted; the app is left there.
    }
```
(written out in full in the file — the week loop is the 2026-10-18 code, moved, not retyped.)

- [ ] **Step 2: Probe** what the pair needs, read-only on the system: the device-type and runtime
  identifiers (`simctl list devicetypes|runtimes -j`); after the first run, whether the watch app arrived
  with the phone app (`simctl listapps <watch>`).
- [ ] **Step 3: `Tools/CapturePairScreenshots.sh`** — spec §3.5's five steps: delete by name, create,
  pair; shut every other down, boot both; dark, large, the phone's status bar frozen at the run's start
  (24-hour, as `CaptureScreenshots.sh`); `xcodebuild test -only-testing:…/testBuildTheLivedInWeek` on the
  phone into `build/screenshots-pair/`; `simctl install` the watch app from
  `Debug-watchsimulator/WaterBuddyWatch.app`, launch it, terminate and relaunch the phone app so its
  activation publish reaches the watch; five `read -r -p` pauses, each followed by
  `simctl io <device> screenshot --mask=ignored`; `FlattenPNG.swift` on any PNG `sips` says has alpha;
  `VerifyScreenshots.sh`. *(As built, 2026-10-25: `setup` and `shoot <name>` in place of the pauses —
  the session's shell answers no `read` — and the watch app taken from inside the phone app's
  `Watch/`, the copy that ships; `FlattenPNG.swift` runs on every shot, leaving an RGB one alone.)*
- [ ] **Step 4: Compile** — `build-for-testing` green; `bash -n Tools/CapturePairScreenshots.sh`.

### Task 6: the gate

- [ ] `xcrun simctl shutdown all`; `build-for-testing` once; the unit target; the UI target by class
  (`-skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests`), on 27.0 and again on 26.5; the watch
  unit run; both widget builds — one `xcodebuild` per call, each read for `Executed N tests` / `Test run
  with`.
- [ ] Warnings: clean builds of a `HEAD` export and of the export with the change's files laid over it,
  into empty DerivedData, all four schemes, by file and message, paths stripped by a marker inside the tree;
  the `HEAD` count checked first against 20, 17, 2, 17.

### Task 7: the captures

- [ ] `bash Tools/CaptureScreenshots.sh` between 1:45 PM and 11:45 PM — eight PNGs, each read by eye.
- [ ] `bash Tools/CapturePairScreenshots.sh` with the owner at its five pauses — five PNGs, each read.
- [ ] `git rm` `Screenshots/en-US/iPhone-6.9/02-history.png`, `03-settings.png`, `04-goal-setup.png`;
  `VerifyScreenshots.sh` green.

### Task 8: rule wording and records

- [ ] Rule wording (spec §5) typed into `85-testing`, `15-project`, `00-workspace` — **unstaged**, for
  the owner.
- [ ] Spec §7 updated: the Series 12 (46mm) reads 416 × 496 in its device-type profile — on the list.
- [ ] `HISTORY.md` checkpoint; `/doc_sync` (#32, #45, #82, #88 notes; the roadmap's 1.2.8 note);
  `tasks/lessons.md` for anything learned; stage with explicit paths; stop.
