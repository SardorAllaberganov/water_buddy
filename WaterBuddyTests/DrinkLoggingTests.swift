//
//  DrinkLoggingTests.swift
//  WaterBuddyTests
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// A throwaway suite and an in-memory store, with every side effect injected (rule `85-testing`).
@MainActor
private func withTempStore<T>(_ body: (DataManager, UserDefaults) throws -> T) throws -> T {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: { utc(2026, 8, 28) },
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    return try body(manager, defaults)
}

// MARK: - Tests

/// A serving's drink: stored by `addLog`, changed by `updateLog`, and counted in full everywhere a total is
/// (spec `2026-11-27-other-drinks-design.md` R2, §3.3, §4).
@MainActor
struct DrinkLoggingTests {

    @Test func aServingKeepsTheDrinkItWasLoggedAs() throws {
        try withTempStore { manager, _ in
            manager.addLog(amount: 150, drink: .coffee)
            #expect(manager.fetchLogsForToday().map(\.drink) == [.coffee])
        }
    }

    /// Every caller from before drinks logs water, the one-tap doors' `addWater` among them (R4).
    @Test func aServingLoggedWithoutADrinkIsWater() throws {
        try withTempStore { manager, _ in
            manager.addLog(amount: 250)
            manager.addWater(amount: 300)
            let logs = manager.fetchLogsForToday()
            #expect(logs.map(\.drink) == [.water, .water])
            #expect(logs.allSatisfy { $0.drinkCode == nil })
        }
    }

    /// R2: 250 ml of anything adds 250 ml, to the total the app draws and to the one the widget reads.
    @Test func everyDrinkCountsInFullTowardTheDay() throws {
        try withTempStore { manager, defaults in
            manager.addLog(amount: 250)
            manager.addLog(amount: 150, drink: .coffee)
            manager.addLog(amount: 200, drink: .milk)
            #expect(manager.currentWater == 600)
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 600)
        }
    }

    /// The week the widget draws and the month History draws count a day's coffee as they count its water.
    @Test func everyDrinkCountsInFullInTheWeekAndTheMonth() throws {
        try withTempStore { manager, defaults in
            manager.addLog(amount: 250, at: utc(2026, 8, 27, 9))
            manager.addLog(amount: 150, at: utc(2026, 8, 27, 10), drink: .coffee)
            manager.addLog(amount: 300, at: utc(2026, 8, 27, 15), drink: .juice)

            let yesterday = DataManager.dayOrdinal(for: utc(2026, 8, 27), in: utcDay)
            #expect(DataManager.readWeekTotals(from: defaults)?[yesterday] == 700)

            manager.showMonth(manager.thisMonth)
            #expect(manager.month?.days[26].summary.total == 700)
        }
    }

    @Test func anEditThatChangesOnlyTheDrinkIsSaved() throws {
        try withTempStore { manager, _ in
            let id = try #require(manager.addLog(amount: 250))
            let log = try #require(manager.todaysLogs.first { $0.id == id })
            manager.updateLog(log, newAmount: 250, drink: .tea)

            let read = try #require(manager.fetchLogsForToday().first { $0.id == id })
            #expect(read.drink == .tea)
            #expect(read.amount == 250)
            #expect(manager.currentWater == 250)
        }
    }

    /// An amount or a time edited alone keeps the serving's drink.
    @Test func anEditOfTheAmountKeepsTheDrink() throws {
        try withTempStore { manager, _ in
            let id = try #require(manager.addLog(amount: 150, drink: .coffee))
            let log = try #require(manager.todaysLogs.first { $0.id == id })
            manager.updateLog(log, newAmount: 200)

            let read = try #require(manager.fetchLogsForToday().first { $0.id == id })
            #expect(read.drink == .coffee)
            #expect(read.amount == 200)
        }
    }

    /// Home's *Undo* takes back the row it was handed, whatever was drunk.
    @Test func undoTakesBackADrink() throws {
        try withTempStore { manager, _ in
            manager.addLog(amount: 250)
            let id = try #require(manager.addLog(amount: 150, drink: .coffee))
            manager.undoLog(id: id)
            #expect(manager.fetchLogsForToday().map(\.drink) == [.water])
            #expect(manager.currentWater == 250)
        }
    }
}
