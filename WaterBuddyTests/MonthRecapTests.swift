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

/// The recap as `DataManager` reads it (spec `2026-10-24-monthly-recap-design.md` §3.6): on demand, a
/// value, published nowhere.
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
