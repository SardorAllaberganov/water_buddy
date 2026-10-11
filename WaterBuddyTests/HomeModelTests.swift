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

    /// "Today's rows cannot be read" is not "no such row", and nothing is derived from it.
    @Test func undoDoesNothingWhenTodaysRowsCannotBeRead() throws {
        let store = try UnreadableStore()
        defer { store.remove() }

        let name = "test.waterbuddy.home.unreadable.\(UUID().uuidString)"
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
        let id = try #require(manager.addLog(amount: 250))

        try store.breakReads()
        #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")

        manager.undoLog(id: id)

        #expect(manager.currentWater == 250, "a failed read must leave the total exactly as it stood")
        #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 250)

        // "Does nothing", said of the row itself and not only of the total: with the table back,
        // the serving is still there. An undo that deleted the row it remembered from before the
        // failure does not get this far — Core Data faults the row to delete it, cannot read it,
        // and the process dies on an uncaught exception, which is how this test was seen to fail.
        try store.restoreReads()
        #expect(manager.allLogs().map(\.id) == [id], "the serving was taken from rows read before the store failed")
    }
}

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
