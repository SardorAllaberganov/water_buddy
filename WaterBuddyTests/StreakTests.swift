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
        let store = try UnreadableStore()
        defer { store.remove() }

        let name = "test.waterbuddy.streak.unreadable.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let manager = DataManager(
            defaults: defaults, modelContainer: store.container, calendar: utcDay,
            now: { utc(2026, 10, 10, 14) },
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
        manager.addLog(amount: 2_000, at: utc(2026, 10, 9, 12))
        manager.addLog(amount: 2_000)
        #expect(manager.streak == 2, "the store must be healthy before it is broken")

        try store.breakReads()
        #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")

        manager.refresh()

        #expect(manager.streak == 2)
    }

    /// It never leaves the app (spec §5.3): not in the widget's snapshot, not on the wire.
    @Test func theStreakStaysOutOfTheSnapshotAndTheWristMirror() throws {
        let name = "test.waterbuddy.streak.wire.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let manager = DataManager(
            defaults: defaults,
            modelContainer: try ModelContainer(
                for: WaterLog.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            ),
            calendar: utcDay,
            now: { utc(2026, 10, 10, 14) },
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
        manager.addLog(amount: 2_000)
        #expect(manager.streak == 1)

        // Both are composed from the suite the manager above has just written.
        let mirror = DataManager.composeWristMirror(from: defaults, calendar: utcDay, now: utc(2026, 10, 10, 14))
        let wire = String(decoding: try JSONEncoder().encode(mirror), as: UTF8.self)
        let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 10, 14))

        #expect(!wire.lowercased().contains("streak"))
        #expect(!String(describing: snapshot).lowercased().contains("streak"))
    }
}

// MARK: - Recounting

/// Like ``withStreakStore(clock:_:)``, and hands back the container too, so a test can change the
/// store behind the manager's back through a context of its own.
@MainActor
private func withOpenStreakStore<T>(
    clock: MovableClock,
    _ body: (DataManager, ModelContainer) throws -> T
) throws -> T {
    let name = "test.waterbuddy.streak.open.\(UUID().uuidString)"
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
    return try body(manager, container)
}

/// Takes every serving off the day `daysAgo` before the clock, through a context of the test's own —
/// a change the manager is not told about.
@MainActor
private func emptyBehindTheManagersBack(_ container: ModelContainer, daysAgo: Int, clock: MovableClock) throws {
    let context = ModelContext(container)
    let day = utcDay.startOfDay(for: utcDay.date(byAdding: .day, value: -daysAgo, to: clock.now)!)
    let next = utcDay.date(byAdding: .day, value: 1, to: day)!
    for log in try context.fetch(FetchDescriptor<WaterLog>(predicate: #Predicate { $0.timestamp >= day && $0.timestamp < next })) {
        context.delete(log)
    }
    try context.save()
}

/// The run of days before today is counted once and kept, and counted again only when the app
/// changes one of them, the goal moves or the day turns (spec `2026-10-18-the-streaks-cost-design.md`).
///
/// A pour used to recount it from the store — twice, and on every tab's `refresh()` — reading
/// back 30, then 120, 480 and 1,920 days as the run grew: 6 ms a pour at 45 days of history in a
/// Debug build, 75 ms at 500, on the main actor, inside the tap. The first two tests prove the
/// pour and the tab no longer read the past: the past is changed behind the manager's back, which
/// no process can do in the product — the app is the only one that writes an earlier day — and the
/// count does not see it. Every test after them holds a path that must recount.
@MainActor
struct StreakRecountTests {

    @Test func aPourDoesNotRecountThePastFromTheStore() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, container in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            #expect(manager.streak == 45)

            try emptyBehindTheManagersBack(container, daysAgo: 10, clock: clock)
            manager.addLog(amount: 250)

            #expect(manager.streak == 45)
        }
    }

    @Test func aTabsRefreshDoesNotRecountThePastFromTheStore() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, container in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            #expect(manager.streak == 45)

            try emptyBehindTheManagersBack(container, daysAgo: 10, clock: clock)
            manager.refresh()

            #expect(manager.streak == 45)
        }
    }

    @Test func todaysPourStillJoinsTheRun() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, _ in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            manager.addLog(amount: 1_000)
            #expect(manager.streak == 45)

            manager.addLog(amount: 1_000)
            #expect(manager.streak == 46)
        }
    }

    @Test func aServingAddedToAnEarlierDayRecountsTheRun() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, _ in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            let eleven = utcDay.date(byAdding: .day, value: -11, to: clock.now)!
            let short = try #require(manager.allLogs().first { utcDay.isDate($0.timestamp, inSameDayAs: eleven) })
            manager.updateLog(short, newAmount: 1_500)
            #expect(manager.streak == 10)

            manager.addLog(amount: 500, at: eleven)
            #expect(manager.streak == 45)
        }
    }

    @Test func aServingDeletedFromAnEarlierDayRecountsTheRun() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, _ in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            let ten = utcDay.date(byAdding: .day, value: -10, to: clock.now)!
            let row = try #require(manager.allLogs().first { utcDay.isDate($0.timestamp, inSameDayAs: ten) })

            manager.deleteLog(row)
            #expect(manager.streak == 9)
        }
    }

    @Test func aServingMovedOffAnEarlierDayRecountsTheRun() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, _ in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            let ten = utcDay.date(byAdding: .day, value: -10, to: clock.now)!
            let row = try #require(manager.allLogs().first { utcDay.isDate($0.timestamp, inSameDayAs: ten) })

            // Into today: the earlier day loses its water and today reaches the goal.
            manager.updateLog(row, newAmount: 2_000, timestamp: clock.now)
            #expect(manager.streak == 10)
        }
    }

    @Test func aWatchPourOnAnEarlierDayRecountsTheRun() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, _ in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            let eleven = utcDay.date(byAdding: .day, value: -11, to: clock.now)!
            let row = try #require(manager.allLogs().first { utcDay.isDate($0.timestamp, inSameDayAs: eleven) })
            manager.updateLog(row, newAmount: 1_500)
            #expect(manager.streak == 10)

            manager.ingest([WristPour(id: UUID(), amount: 500, at: eleven)])
            #expect(manager.streak == 45)
        }
    }

    /// The observer's hop on `NSCalendarDayChanged` and `NSSystemTimeZoneDidChange`: a new zone can
    /// regroup every day the run counts, so the next read counts it again. The hop itself still
    /// republishes nothing on a day that did not change (`aTurnThatIsNotANewDayRepublishesNothing`,
    /// rule `30-rollover`); the recount waits for the next refresh.
    @Test func theTurnOfTheDayMakesTheNextReadRecountTheRun() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, container in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            try emptyBehindTheManagersBack(container, daysAgo: 10, clock: clock)

            manager.dayDidTurn()
            manager.refresh()
            #expect(manager.streak == 9)
        }
    }

    @Test func aRunCarriesOverMidnight() throws {
        let clock = MovableClock(utc(2026, 10, 10, 14))
        try withOpenStreakStore(clock: clock) { manager, _ in
            fill(manager, days: 45, endingDaysAgo: 1, amount: 2_000, clock: clock)
            manager.addLog(amount: 2_000)
            #expect(manager.streak == 46)

            clock.now = utc(2026, 10, 11, 9)
            manager.refresh()
            #expect(manager.streak == 46, "yesterday closed at the goal; today is still open")

            clock.now = utc(2026, 10, 12, 9)
            manager.refresh()
            #expect(manager.streak == 0, "a whole day missed")
        }
    }
}
