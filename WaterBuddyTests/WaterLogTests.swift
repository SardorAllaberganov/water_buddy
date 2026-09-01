//
//  WaterLogTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 28/08/26.
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

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// The one place this file constructs a `DataManager`.
///
/// The two arguments that look optional are the dangerous ones. `modelContainer:` defaults to
/// ``DataManager/sharedModelContainer`` — the **real** App Group store — and
/// `rescheduleReminders:` defaults to ``DataManager/requestReminderReschedule(_:)``, which builds
/// a real `UNUserNotificationCenter`. `DataManager.init` ends in `rescheduleRemindersNow()`, so
/// omitting the latter makes *merely constructing a manager* remove real pending requests filed
/// under ``ReminderPlan/identifierPrefix`` (rule `85-testing`).
///
/// `tasks/lessons.md` carries this trap three times, and the third entry records how it spread:
/// not by writing a fresh call site, but by copying a fixture that looked handled. This file held
/// five construction sites, all five omitting the seam. One factory is the answer to that — there
/// is no second site left here to copy from, and
/// ``WaterLogStoreTests/theStoreFixtureRoutesTheReminderPlanToTheInjectedSeam()`` fails the moment
/// the argument below goes missing.
@MainActor
private func makeManager(
    defaults: UserDefaults,
    container: ModelContainer,
    now: @escaping () -> Date = { utc(2026, 8, 28) },
    onReload: @escaping () -> Void = {},
    onReschedule: @escaping ([ReminderPlan.Slot]) -> Void = { _ in }
) -> DataManager {
    DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: now,
        reloadWidgets: onReload,
        rescheduleReminders: onReschedule,
        publishWrist: { _ in }
    )
}

/// A throwaway suite *and* an in-memory store, for the same reason the rest of the suite takes a
/// UUID-named `UserDefaults`: `@Test` functions run in parallel inside one process, and a shared
/// store would let one test's water show up in another's assertions.
///
/// `isStoredInMemoryOnly` also keeps every one of these off disk entirely, so nothing here can
/// reach the real App Group store (rule `85-testing`).
@MainActor
private func withTempStore<T>(
    now: @escaping () -> Date = { utc(2026, 8, 28) },
    onReload: @escaping () -> Void = {},
    onReschedule: @escaping ([ReminderPlan.Slot]) -> Void = { _ in },
    _ body: (DataManager, UserDefaults) throws -> T
) throws -> T {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = makeManager(
        defaults: defaults,
        container: container,
        now: now,
        onReload: onReload,
        onReschedule: onReschedule
    )
    return try body(manager, defaults)
}

/// A suite and a store that **two** `DataManager`s can share.
///
/// ``withTempStore(now:onReload:_:)`` builds one manager, which cannot express the case this
/// product actually has: the app and `AddWaterIntent` in the widget extension each hold their own
/// instance over the same container. Both still get a UUID-named suite and an in-memory store, so
/// nothing here can reach the real App Group (rule `85-testing`).
@MainActor
private func withSharedTempStore<T>(
    _ body: (UserDefaults, ModelContainer) throws -> T
) throws -> T {
    let name = "test.waterbuddy.\(UUID().uuidString)"
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

/// `withObservationTracking`'s `onChange` is `@Sendable`, so the tally needs a reference box.
private final class Counter: @unchecked Sendable {
    var count = 0
}

// MARK: - Tests

@MainActor
struct WaterLogStoreTests {

    // MARK: Create

    @Test func addLogStoresTheServingAndUpdatesTheCachedTotal() throws {
        try withTempStore { manager, defaults in
            manager.addLog(amount: 250)

            let logs = manager.fetchLogsForToday()
            #expect(logs.count == 1)
            #expect(logs.first?.amount == 250)

            // The cache is what the widget reads; a log that never reached it is invisible
            // to the other process.
            #expect(manager.currentWater == 250)
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 250)
        }
    }

    @Test func theCachedTotalIsTheSumOfTodaysLogs() throws {
        try withTempStore { manager, defaults in
            manager.addLog(amount: 250)
            manager.addLog(amount: 400)
            manager.addLog(amount: 100)

            #expect(manager.fetchLogsForToday().count == 3)
            #expect(manager.currentWater == 750)
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 750)
        }
    }

    /// The whole point of asking for variable servings: `addLog` takes the amount it is given.
    @Test(arguments: [1, 125, 330, 500, 1_000])
    func aServingIsLoggedAtWhateverSizeItWas(amount: Int) throws {
        try withTempStore { manager, _ in
            manager.addLog(amount: amount)
            #expect(manager.fetchLogsForToday().first?.amount == amount)
            #expect(manager.currentWater == amount)
        }
    }

    @Test func aNonPositiveServingIsIgnored() throws {
        try withTempStore { manager, _ in
            manager.addLog(amount: 0)
            manager.addLog(amount: -250)
            #expect(manager.fetchLogsForToday().isEmpty)
            #expect(manager.currentWater == 0)
        }
    }

    // MARK: Read

    @Test func fetchLogsForTodayReturnsNewestFirst() throws {
        try withTempStore(now: { utc(2026, 8, 28, 18) }) { manager, _ in
            manager.addLog(amount: 100, at: utc(2026, 8, 28, 9))
            manager.addLog(amount: 200, at: utc(2026, 8, 28, 15))
            manager.addLog(amount: 300, at: utc(2026, 8, 28, 12))

            #expect(manager.fetchLogsForToday().map(\.amount) == [200, 300, 100])
        }
    }

    @Test func fetchLogsForTodayExcludesOtherDays() throws {
        try withTempStore(now: { utc(2026, 8, 28, 12) }) { manager, _ in
            manager.addLog(amount: 500, at: utc(2026, 8, 27, 23, 59))
            manager.addLog(amount: 250, at: utc(2026, 8, 28, 0, 1))
            manager.addLog(amount: 999, at: utc(2026, 8, 29, 0, 1))

            #expect(manager.fetchLogsForToday().map(\.amount) == [250])
        }
    }

    // MARK: Update

    @Test func updateLogChangesTheAmountAndRecomputesTheTotal() throws {
        try withTempStore { manager, defaults in
            manager.addLog(amount: 250)
            manager.addLog(amount: 400)
            let target = try #require(manager.fetchLogsForToday().first { $0.amount == 250 })

            manager.updateLog(target, newAmount: 600)

            #expect(manager.currentWater == 1_000)
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 1_000)
            #expect(manager.fetchLogsForToday().contains { $0.amount == 600 })
        }
    }

    @Test func updatingToANonPositiveAmountIsIgnored() throws {
        try withTempStore { manager, _ in
            manager.addLog(amount: 250)
            let target = try #require(manager.fetchLogsForToday().first)

            manager.updateLog(target, newAmount: 0)

            #expect(manager.fetchLogsForToday().first?.amount == 250)
            #expect(manager.currentWater == 250)
        }
    }

    // MARK: Delete

    @Test func deleteLogRemovesItAndRecomputesTheTotal() throws {
        try withTempStore { manager, defaults in
            manager.addLog(amount: 250)
            manager.addLog(amount: 400)
            let target = try #require(manager.fetchLogsForToday().first { $0.amount == 250 })

            manager.deleteLog(target)

            #expect(manager.fetchLogsForToday().map(\.amount) == [400])
            #expect(manager.currentWater == 400)
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 400)
        }
    }

    // MARK: The rollover no longer destroys data

    /// The behavioural change the log model buys: yesterday stays on disk as history, and today
    /// is empty because nothing was logged today — not because anything was zeroed.
    @Test func theRolloverKeepsYesterdaysLogsAsHistory() throws {
        var clock = utc(2026, 8, 27, 12)
        try withTempStore(now: { clock }) { manager, defaults in
            manager.addLog(amount: 750)
            #expect(manager.currentWater == 750)

            clock = utc(2026, 8, 28, 9)
            manager.refresh()

            #expect(manager.currentWater == 0, "today starts empty")
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 0)
            #expect(manager.fetchLogsForToday().isEmpty)

            // …but the serving itself is still there.
            #expect(manager.allLogs().count == 1)
            #expect(manager.allLogs().first?.amount == 750)
        }
    }

    // MARK: The doorbell

    @Test func loggingRingsTheWidgetDoorbellExactlyOnce() throws {
        var reloads = 0
        try withTempStore(onReload: { reloads += 1 }) { manager, _ in
            manager.addLog(amount: 250)
            #expect(reloads == 1)

            manager.addLog(amount: 0)
            #expect(reloads == 1, "a rejected serving changes nothing and must not ring")
        }
    }

    // MARK: The seed migration

    /// A user upgrading from the UserDefaults-only build has a total but no logs. Losing it on
    /// launch would look exactly like data loss, which is the same reason the App Group migration
    /// exists (rule `25-shared-storage`).
    @Test func anUpgradingUsersTotalIsSeededAsASingleLog() throws {
        let name = "test.waterbuddy.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let container = try ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        // The state the old build would have left behind.
        defaults.set(1_150, forKey: DataManager.Key.currentWater)
        defaults.set(20_260_828, forKey: DataManager.Key.lastActiveDay)

        let manager = makeManager(defaults: defaults, container: container, now: { utc(2026, 8, 28, 12) })

        #expect(manager.fetchLogsForToday().map(\.amount) == [1_150])
        #expect(manager.currentWater == 1_150)
    }

    @Test func theSeedDoesNotRunTwice() throws {
        let name = "test.waterbuddy.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let container = try ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        defaults.set(1_150, forKey: DataManager.Key.currentWater)
        defaults.set(20_260_828, forKey: DataManager.Key.lastActiveDay)

        _ = makeManager(defaults: defaults, container: container, now: { utc(2026, 8, 28, 12) })
        let second = makeManager(defaults: defaults, container: container, now: { utc(2026, 8, 28, 12) })

        #expect(second.fetchLogsForToday().count == 1, "a second launch must not double the water")
        #expect(second.currentWater == 1_150)
    }

    /// Reproduces a failure first seen in the UI suite: with servings already on disk from an
    /// earlier day, the next tap showed **0** instead of the serving just logged.
    @Test func loggingAfterARolloverCountsOnlyTheNewDay() throws {
        var clock = utc(2026, 8, 27, 12)
        try withTempStore(now: { clock }) { manager, defaults in
            manager.addLog(amount: 750)
            #expect(manager.currentWater == 750)

            clock = utc(2026, 8, 28, 9)
            manager.addLog(amount: 250)

            #expect(manager.currentWater == 250, "the new day starts from the new serving")
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 250)
            #expect(manager.allLogs().count == 2, "yesterday is history, not deleted")
        }
    }

    /// The same shape, but the rollover lands via `refresh()` before the tap rather than inside it.
    @Test func aRolloverThenALogDoesNotStrandTheTotalAtZero() throws {
        var clock = utc(2026, 8, 27, 12)
        try withTempStore(now: { clock }) { manager, _ in
            manager.addLog(amount: 750)

            clock = utc(2026, 8, 28, 9)
            manager.refresh()
            #expect(manager.currentWater == 0)

            manager.addLog(amount: 250)
            #expect(manager.currentWater == 250)
        }
    }

    // MARK: The published rows

    @Test func todaysLogsPublishesTheServingsNewestFirst() throws {
        try withTempStore(now: { utc(2026, 8, 28, 9) }) { manager, _ in
            manager.addLog(amount: 100, at: utc(2026, 8, 28, 7))
            manager.addLog(amount: 300, at: utc(2026, 8, 28, 9))
            manager.addLog(amount: 200, at: utc(2026, 8, 28, 8))

            #expect(manager.todaysLogs.map(\.amount) == [300, 200, 100])
            // The published rows and the fetch are the same rows, or a view and a test would be
            // reading two different answers to one question.
            #expect(manager.todaysLogs.map(\.amount) == manager.fetchLogsForToday().map(\.amount))
        }
    }

    @Test func todaysLogsExcludesOtherDays() throws {
        try withTempStore(now: { utc(2026, 8, 28) }) { manager, _ in
            manager.addLog(amount: 250, at: utc(2026, 8, 28, 10))
            manager.addLog(amount: 400, at: utc(2026, 8, 27, 23))

            #expect(manager.todaysLogs.map(\.amount) == [250])
            #expect(manager.allLogs().count == 2)
        }
    }

    @Test func addingALogInvalidatesObserversOfTodaysLogs() throws {
        try withTempStore { manager, _ in
            let counter = Counter()
            withObservationTracking { _ = manager.todaysLogs } onChange: { counter.count += 1 }
            manager.addLog(amount: 250)

            #expect(counter.count == 1, "a history list bound to todaysLogs would never redraw")
        }
    }

    @Test func deletingALogInvalidatesObserversOfTodaysLogs() throws {
        try withTempStore { manager, _ in
            manager.addLog(amount: 250)
            let target = try #require(manager.todaysLogs.first)

            let counter = Counter()
            withObservationTracking { _ = manager.todaysLogs } onChange: { counter.count += 1 }
            manager.deleteLog(target)

            #expect(counter.count == 1)
            #expect(manager.todaysLogs.isEmpty)
        }
    }

    /// The reason ``DataManager/todaysLogs`` deliberately carries **no** equality guard, where
    /// `currentWater` and `dailyGoal` both do.
    ///
    /// `WaterLog` is a `@Model` class, so its `Hashable` conformance is by `persistentModelID` —
    /// the array after an amount edit compares *equal* to the array before it. A guard of the kind
    /// the other two properties carry would swallow exactly this change, and a row the user just
    /// corrected would go on showing the old figure.
    @Test func editingALogInvalidatesObserversOfTodaysLogs() throws {
        try withTempStore { manager, _ in
            manager.addLog(amount: 250)
            let target = try #require(manager.todaysLogs.first)
            let before = manager.todaysLogs

            let counter = Counter()
            withObservationTracking { _ = manager.todaysLogs } onChange: { counter.count += 1 }
            manager.updateLog(target, newAmount: 400)

            #expect(before == manager.todaysLogs, "identity-equal across an edit — that is the trap")
            #expect(counter.count == 1, "an equality guard here would swallow the edit")
            #expect(manager.todaysLogs.first?.amount == 400)
        }
    }

    /// Pins the `republishTodaysLogs()` in ``DataManager/refresh()``.
    ///
    /// Two processes hold their own instance over one store — the app, and `AddWaterIntent` in the
    /// widget extension. An instance that has not looked since the other wrote holds stale rows, so
    /// a history list would contradict the figure printed above it until it re-reads.
    ///
    /// `refresh()` is `loadFromStore()` → `resetIfNeeded()` → `republishTodaysLogs()` →
    /// `republishHistory()` → `rescheduleRemindersNow()`. It does **not** call `recomputeToday()`,
    /// and that is the ruling rather than an omission: `republishTodaysLogs()`' own DocC records the
    /// re-derive as *tried and **rejected***, because a cross-process fetch can succeed while
    /// returning rows that do not yet include the extension's write, and re-summing those would
    /// overwrite the other process's serving with a smaller figure. So the **rows** asserted below
    /// come from the republish, and the **total** comes from `loadFromStore()` picking the cache
    /// back up — two different mechanisms, neither of them a re-derive.
    ///
    /// An earlier edition of this comment said the test pinned the re-derive. It never did: the test
    /// was green for a different reason than it gave, and a DocC comment describing a design this
    /// codebase deliberately rejected is worse than no comment, because DocC outranks the rule files
    /// here (`docs/AI_CONTEXT.md` known issue #11).
    @Test func refreshRepublishesLogsWrittenByAnotherInstance() throws {
        try withSharedTempStore { defaults, container in
            // Two instances over one container — the shape this product actually has, where the
            // app and `AddWaterIntent` in the extension each hold their own.
            let app = makeManager(defaults: defaults, container: container)
            let widget = makeManager(defaults: defaults, container: container)

            widget.addLog(amount: 250)
            #expect(app.todaysLogs.isEmpty, "the other instance has not looked yet")

            app.refresh()

            #expect(app.todaysLogs.map(\.amount) == [250])
            #expect(app.currentWater == 250, "the rows and the total have to agree after a refresh")
        }
    }

    @Test func aRolloverEmptiesTodaysLogsButKeepsHistory() throws {
        var clock = utc(2026, 8, 27, 12)
        try withTempStore(now: { clock }) { manager, _ in
            manager.addLog(amount: 750)
            #expect(manager.todaysLogs.count == 1)

            clock = utc(2026, 8, 28, 9)
            manager.refresh()

            #expect(manager.todaysLogs.isEmpty, "today starts empty")
            #expect(manager.allLogs().count == 1, "yesterday is history, not deleted")
        }
    }

    // MARK: The fixture itself

    /// The fixture's own tripwire: proves ``withTempStore(now:onReload:onReschedule:_:)`` injects
    /// the reminder seam rather than letting it default.
    ///
    /// `DataManager.init` ends in `rescheduleRemindersNow()`, and the production default is
    /// ``DataManager/requestReminderReschedule(_:)`` — which builds a real
    /// `UNUserNotificationCenter` and reconciles against it. So a fixture that omits the argument
    /// makes **merely constructing a manager** remove real pending requests filed under
    /// ``ReminderPlan/identifierPrefix``, which rule `85-testing` forbids outright.
    ///
    /// Nothing else can catch that. A test may not read the source tree (it hangs the gate under
    /// TCC — `tasks/lessons.md`) and may not construct a real centre to inspect it. Watching the
    /// seam fire is the only evidence available from inside the process, so this test *is* the
    /// guard: delete the argument from the factory and the counter stays at zero.
    @Test func theStoreFixtureRoutesTheReminderPlanToTheInjectedSeam() throws {
        var plans = 0
        try withTempStore(onReschedule: { _ in plans += 1 }) { manager, _ in
            manager.addLog(amount: 250)
        }

        #expect(plans > 0, "the fixture is reaching a real UNUserNotificationCenter")
    }
}
