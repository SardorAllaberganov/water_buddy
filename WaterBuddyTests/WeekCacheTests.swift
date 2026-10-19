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

    /// The mirror of the one above, from the final review: a corrupt negative row must not reach the
    /// cache as a negative day, which the reader would reject — the widget saying *Open WaterBuddy*
    /// forever while the app was opened, and every pass rewriting the key and ringing. Clamped on the
    /// way in, as the `currentWater` setter clamps today's.
    @Test func aCorruptNegativeServingIsClampedInTheCachedDay() throws {
        try withWeekStore { store in
            let manager = store.manager(MovableClock(utc(2026, 10, 19, 14)))
            let other = ModelContext(store.container)
            other.insert(WaterLog(amount: -500, timestamp: utc(2026, 10, 18, 9)))
            try other.save()

            manager.addLog(amount: 250)

            let week = try #require(store.cached(), "the reader rejected the week its own writer wrote")
            #expect(week[20261018] == 0)
            #expect(week[20261019] == 250)
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
