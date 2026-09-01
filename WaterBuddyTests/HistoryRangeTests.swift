//
//  HistoryRangeTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 30/08/26.
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

/// A Gregorian/UTC day, so a window test cannot flake on a machine sitting near local midnight
/// or in the middle of a DST transition.
private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// A serving at an instant, with no store behind it.
///
/// ``DaySummary/series(from:days:endingOn:in:)`` takes rows rather than a `ModelContext`, which is
/// what lets this whole suite run off the main actor — see the note on the suite below.
private func log(_ amount: Int, at date: Date) -> WaterLog {
    WaterLog(amount: amount, timestamp: date)
}

// MARK: - Tests

/// The per-day roll-up, tested with no store, no `DataManager` and no main actor.
///
/// **This suite is deliberately not `@MainActor`, and that is load-bearing** rather than an
/// oversight. `DaySummary` and its aggregation are a pure value transformation over `[WaterLog]`
/// and a `Calendar`; if either ever reached for instance state on `DataManager` — the goal, the
/// clock, the `ModelContext` — this suite would stop compiling, which is exactly the warning
/// wanted. `ReminderPlanTests` is the precedent (rule `43-concurrency`).
///
/// The day the chart draws is derived at read time from each `timestamp`, because ``WaterLog``
/// carries no day column and rule `30-rollover` forbids adding one. Every bucket is therefore
/// recomputed under whatever time zone is current — pinned by
/// ``theSameInstantsRegroupUnderAWestwardTimeZone`` so the choice is a decision rather than an
/// accident.
struct DaySummaryTests {

    // MARK: The shape of the window

    @Test func aWeekOfServingsRollsUpToOneTotalPerDay() {
        let logs = [
            log(250, at: utc(2026, 8, 24, 9)),
            log(500, at: utc(2026, 8, 24, 18)),
            log(150, at: utc(2026, 8, 26, 11)),
            log(750, at: utc(2026, 8, 30, 8)),
        ]

        let series = DaySummary.series(from: logs, days: 7, endingOn: utc(2026, 8, 30, 21), in: utcDay)

        #expect(series.map(\.dayOrdinal) == [
            20260824, 20260825, 20260826, 20260827, 20260828, 20260829, 20260830,
        ])
        #expect(series.map(\.total) == [750, 0, 150, 0, 0, 0, 750])
    }

    @Test func theSeriesIsOldestFirstAndEndsOnTheDayContainingNow() {
        let series = DaySummary.series(from: [], days: 3, endingOn: utc(2026, 8, 30, 23, 59), in: utcDay)

        #expect(series.first?.dayOrdinal == 20260828)
        #expect(series.last?.dayOrdinal == 20260830, "the window ends on today, never on tomorrow")
    }

    @Test func aDayWithNoServingsReportsZeroRatherThanBeingOmitted() {
        let logs = [log(500, at: utc(2026, 8, 30, 10))]

        let series = DaySummary.series(from: logs, days: 4, endingOn: utc(2026, 8, 30, 10), in: utcDay)

        #expect(series.count == 4, "a missing day would make a four-bar axis describe five days")
        #expect(series.map(\.total) == [0, 0, 0, 500])
    }

    @Test func theSeriesAlwaysHoldsExactlyTheRequestedNumberOfDays() {
        for days in [1, 7, 30, 365] {
            let series = DaySummary.series(from: [], days: days, endingOn: utc(2026, 8, 30), in: utcDay)
            #expect(series.count == days)
        }
    }

    @Test func servingsOlderThanTheWindowAreExcluded() {
        let logs = [
            log(500, at: utc(2026, 8, 20, 12)),   // outside a 3-day window ending on the 30th
            log(250, at: utc(2026, 8, 29, 12)),
        ]

        let series = DaySummary.series(from: logs, days: 3, endingOn: utc(2026, 8, 30, 12), in: utcDay)

        #expect(series.map(\.total) == [0, 250, 0])
        #expect(series.reduce(0) { $0 + $1.total } == 250, "the 20th must not leak into the window")
    }

    @Test func servingsDatedAfterNowAreExcluded() {
        let logs = [log(500, at: utc(2026, 8, 31, 12))]

        let series = DaySummary.series(from: logs, days: 3, endingOn: utc(2026, 8, 30, 12), in: utcDay)

        #expect(series.reduce(0) { $0 + $1.total } == 0, "tomorrow is not part of any window ending today")
    }

    /// Degrades rather than trapping, the way `ReminderPlan.slots` bounds its loop with
    /// `0...max(0, horizonDays)` rather than letting a caller's number reach a `Range`.
    @Test func aNonPositiveWindowYieldsAnEmptySeries() {
        #expect(DaySummary.series(from: [], days: 0, endingOn: utc(2026, 8, 30), in: utcDay).isEmpty)
        #expect(DaySummary.series(from: [], days: -5, endingOn: utc(2026, 8, 30), in: utcDay).isEmpty)
    }

    // MARK: Arithmetic

    /// Plain `+` or `reduce(0, +)` traps on a corrupt `Int.max` row and crashes the app instead of
    /// degrading, which is why ``DataManager`` sums with `addingReportingOverflow` (rule `20-state`).
    @Test func theDailyTotalSaturatesRatherThanTrappingOnACorruptRow() {
        let logs = [
            log(Int.max, at: utc(2026, 8, 30, 9)),
            log(500, at: utc(2026, 8, 30, 10)),
        ]

        let series = DaySummary.series(from: logs, days: 1, endingOn: utc(2026, 8, 30, 12), in: utcDay)

        #expect(series.first?.total == DataManager.maximumDailyIntake)
    }

    /// The **other** order, and the only one that actually reaches the overflow branch.
    ///
    /// `theDailyTotalSaturatesRatherThanTrappingOnACorruptRow` above puts the corrupt row first, so
    /// the running total is `0 + Int.max` — which does not overflow — and the clamp alone produces
    /// the right answer. That test therefore passes even with a plain `+`, and pins the clamp
    /// rather than the guard. Corrupt row *second* is the case where the running total is already
    /// `maximumDailyIntake` and `+ Int.max` genuinely overflows, so `addingReportingOverflow` is
    /// the only thing standing between a corrupt store and a crash.
    ///
    /// `fetch(_:)` returns rows newest-first, so which order a corrupt row arrives in is not
    /// something this code gets to choose.
    @Test func aCorruptRowArrivingSecondSaturatesInsteadOfTrapping() {
        let logs = [
            log(500, at: utc(2026, 8, 30, 9)),
            log(Int.max, at: utc(2026, 8, 30, 10)),
        ]

        let series = DaySummary.series(from: logs, days: 1, endingOn: utc(2026, 8, 30, 12), in: utcDay)

        #expect(series.first?.total == DataManager.maximumDailyIntake)
    }

    @Test func theAverageIsTheIntegerMeanOverEveryDayInTheWindow() {
        let logs = [
            log(1_000, at: utc(2026, 8, 29, 9)),
            log(1_500, at: utc(2026, 8, 30, 9)),
        ]

        let series = DaySummary.series(from: logs, days: 4, endingOn: utc(2026, 8, 30, 12), in: utcDay)

        // 2,500 ml over four days — the empty days count, because they are days the user did drink
        // nothing rather than days that did not happen.
        #expect(DaySummary.average(of: series) == 625)
    }

    @Test func theAverageOfAnEmptyWindowIsZeroRatherThanADivideByZero() {
        #expect(DaySummary.average(of: []) == 0)
    }

    @Test func theBestDayIsTheLargestTotalInTheWindow() {
        let logs = [
            log(900, at: utc(2026, 8, 28, 9)),
            log(2_100, at: utc(2026, 8, 29, 9)),
            log(400, at: utc(2026, 8, 30, 9)),
        ]

        let series = DaySummary.series(from: logs, days: 3, endingOn: utc(2026, 8, 30, 12), in: utcDay)

        #expect(DaySummary.best(of: series) == 2_100)
        #expect(DaySummary.best(of: []) == 0)
    }

    // MARK: Calendar edge cases

    /// 00:30 EDT and 23:59 EST fall on the *same* local date across the 25-hour fall-back day, even
    /// though 24h29m separates them. Bucketing by interval arithmetic against 86,400 seconds would
    /// split them across two bars; bucketing by day ordinal does not.
    @Test func aTwentyFiveHourDayStaysOneBar() {
        let newYork = gregorian(in: "America/New_York")
        let justAfterMidnight = newYork.date(
            from: DateComponents(year: 2025, month: 11, day: 2, hour: 0, minute: 30)
        )!
        let justBeforeMidnight = newYork.date(
            from: DateComponents(year: 2025, month: 11, day: 2, hour: 23, minute: 59)
        )!
        #expect(justBeforeMidnight.timeIntervalSince(justAfterMidnight) > 86_400)

        let series = DaySummary.series(
            from: [log(500, at: justAfterMidnight), log(250, at: justBeforeMidnight)],
            days: 1,
            endingOn: justBeforeMidnight,
            in: newYork
        )

        #expect(series.count == 1)
        #expect(series.first?.total == 750, "one local date is one bar, whatever the hour count")
    }

    /// A 23-hour spring-forward day is still one bar, and the day either side of it is still its own.
    @Test func aTwentyThreeHourDayStaysOneBar() {
        let newYork = gregorian(in: "America/New_York")
        let springForward = newYork.date(
            from: DateComponents(year: 2026, month: 3, day: 8, hour: 12)
        )!
        let dayBefore = newYork.date(
            from: DateComponents(year: 2026, month: 3, day: 7, hour: 12)
        )!

        let series = DaySummary.series(
            from: [log(300, at: dayBefore), log(600, at: springForward)],
            days: 2,
            endingOn: springForward,
            in: newYork
        )

        #expect(series.map(\.dayOrdinal) == [20260307, 20260308])
        #expect(series.map(\.total) == [300, 600])
    }

    /// **The deliberate cost of not storing a day.** ``WaterLog`` records an instant, and rule
    /// `30-rollover` forbids it gaining a day column — so a historical bucket is recomputed under
    /// whatever zone is current, and a user who flies west sees a serving move to the previous bar.
    ///
    /// This is the opposite trade from `Key.lastActiveDay`, which *is* an ordinal precisely so it
    /// cannot move. The difference is that the active-day marker decides whether to destroy today's
    /// total, and a chart only decides which bar a past serving is drawn in. Pinned here so the
    /// choice stays a decision: if this test is ever seen to fail, the fix is a product argument,
    /// not a nudge to the calendar.
    @Test func theSameInstantsRegroupUnderAWestwardTimeZone() {
        let paris = gregorian(in: "Europe/Paris")
        let london = gregorian(in: "Europe/London")
        // 00:30 on the 28th in Paris is 23:30 on the 27th in London — one instant, two dates.
        let instant = paris.date(
            from: DateComponents(year: 2026, month: 8, day: 28, hour: 0, minute: 30)
        )!

        let inParis = DaySummary.series(from: [log(500, at: instant)], days: 2, endingOn: instant, in: paris)
        let inLondon = DaySummary.series(from: [log(500, at: instant)], days: 2, endingOn: instant, in: london)

        #expect(inParis.last?.dayOrdinal == 20260828)
        #expect(inParis.last?.total == 500)

        #expect(inLondon.last?.dayOrdinal == 20260827)
        #expect(inLondon.last?.total == 500, "the serving followed the instant, not the bar")
    }
}

// MARK: - Store fixtures

/// `withObservationTracking`'s `onChange` is `@Sendable`, so the tally needs a reference box —
/// a captured local `var` would be a data race (rule `43-concurrency`).
private final class Counter: @unchecked Sendable {
    var count = 0
}

/// A `DataManager` over a throwaway suite and an in-memory store.
///
/// **Grafted from `DataManagerTests.makeManager`, not from `WaterLogTests.withTempStore`.** The
/// latter is the more attractive template — it is the only other fixture with `now:` and
/// `onReload:` parameters, which is exactly the surface a multi-day suite wants — and it omits
/// `rescheduleReminders:`. That parameter defaults to `DataManager.requestReminderReschedule`,
/// which builds a **real** `UNUserNotificationCenter`; `init` ends in `rescheduleRemindersNow()`,
/// so merely constructing a manager would reconcile against it and remove the machine's live
/// pending requests under `ReminderPlan.identifierPrefix`. Rule `85-testing` forbids that outright,
/// and `tasks/lessons.md` records this exact omission spreading once already by fixture-copying.
///
/// Every argument is passed explicitly and was diffed against `DataManager.init` by hand.
@MainActor
private func withHistoryStore<T>(
    now: @escaping () -> Date,
    onReload: @escaping () -> Void = {},
    _ body: (DataManager, UserDefaults) throws -> T
) throws -> T {
    let name = "test.waterbuddy.history.\(UUID().uuidString)"
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
        now: now,
        reloadWidgets: onReload,
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    return try body(manager, defaults)
}

/// One suite and one store that **two** `DataManager`s share — the shape this product actually
/// has, where the app and `AddWaterIntent` each hold their own instance over one container.
@MainActor
private func withSharedHistoryStore<T>(
    _ body: (UserDefaults, ModelContainer) throws -> T
) throws -> T {
    let name = "test.waterbuddy.history.shared.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults, container)
}

@MainActor
private func makeHistoryManager(
    _ defaults: UserDefaults,
    container: ModelContainer,
    now: @escaping () -> Date
) -> DataManager {
    DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: now,
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
}

// MARK: - The published window

/// ``DataManager/history`` — the observable channel the history screen reads.
///
/// Reading `allLogs()` from a `body` would register no `access(keyPath:)` and never redraw, which
/// is the trap ``DataManager/todaysLogs`` was created to close. These pin that the window is
/// published, that it moves with the day, and that it survives a write from a second instance.
@MainActor
struct HistoryWindowTests {

    @Test func historyRollsUpBackDatedServingsIntoTheirOwnDays() throws {
        try withHistoryStore(now: { utc(2026, 8, 30, 12) }) { manager, _ in
            manager.addLog(amount: 500, at: utc(2026, 8, 28, 9))
            manager.addLog(amount: 250, at: utc(2026, 8, 28, 18))
            manager.addLog(amount: 750, at: utc(2026, 8, 30, 8))

            let byDay = Dictionary(uniqueKeysWithValues: manager.history.map { ($0.dayOrdinal, $0.total) })
            #expect(byDay[20260828] == 750)
            #expect(byDay[20260829] == 0)
            #expect(byDay[20260830] == 750)
        }
    }

    @Test func historyHoldsExactlyTheWindowLengthAndEndsOnToday() throws {
        try withHistoryStore(now: { utc(2026, 8, 30, 12) }) { manager, _ in
            #expect(manager.history.count == DataManager.historyWindow)
            #expect(manager.history.last?.dayOrdinal == 20260830)
        }
    }

    @Test func loggingAServingRepublishesHistoryToObservers() throws {
        try withHistoryStore(now: { utc(2026, 8, 30, 12) }) { manager, _ in
            let counter = Counter()
            withObservationTracking { _ = manager.history } onChange: { counter.count += 1 }

            manager.addLog(amount: 250)

            #expect(counter.count == 1, "a history screen that never redraws is the whole hazard")
            #expect(manager.history.last?.total == 250)
        }
    }

    /// Unlike ``DataManager/todaysLogs``, this array *may* carry an equality guard: `DaySummary` is
    /// a value type compared by its fields, where a `[WaterLog]` after an amount edit compares
    /// equal to the array before it and a guard would swallow the edit. `refresh()` runs on every
    /// foreground, so an unguarded republish would redraw the card for nothing.
    @Test func aRefreshThatChangesNothingDoesNotChurnHistoryObservers() throws {
        try withHistoryStore(now: { utc(2026, 8, 30, 12) }) { manager, _ in
            manager.addLog(amount: 250)

            let counter = Counter()
            withObservationTracking { _ = manager.history } onChange: { counter.count += 1 }

            manager.refresh()

            #expect(counter.count == 0, "nothing moved, so nothing should redraw")
        }
    }

    @Test func aRolloverMovesTheHistoryWindowForward() throws {
        var clock = utc(2026, 8, 30, 12)
        try withHistoryStore(now: { clock }) { manager, _ in
            manager.addLog(amount: 500)
            #expect(manager.history.last?.dayOrdinal == 20260830)

            clock = utc(2026, 8, 31, 9)
            manager.refresh()

            #expect(manager.history.last?.dayOrdinal == 20260831)
            #expect(manager.history.last?.total == 0, "today starts empty")

            let byDay = Dictionary(uniqueKeysWithValues: manager.history.map { ($0.dayOrdinal, $0.total) })
            #expect(byDay[20260830] == 500, "yesterday is history, not deleted")
            #expect(manager.currentWater == 0)
        }
    }

    /// The app and the widget extension each hold their own `DataManager` over one store. An
    /// instance that has been idle must pick up the other's serving when it comes forward.
    @Test func historyPicksUpAServingWrittenByASecondInstance() throws {
        try withSharedHistoryStore { defaults, container in
            let app = makeHistoryManager(defaults, container: container, now: { utc(2026, 8, 30, 12) })
            let extensionSide = makeHistoryManager(defaults, container: container, now: { utc(2026, 8, 30, 13) })

            extensionSide.addLog(amount: 250)
            app.refresh()

            #expect(app.history.last?.total == 250)
        }
    }
}
