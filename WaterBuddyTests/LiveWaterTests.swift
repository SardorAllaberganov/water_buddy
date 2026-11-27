//
//  LiveWaterTests.swift
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

/// The tests' clock: 27 November 2026, 15:00 UTC.
private let today: () -> Date = { utc(2026, 11, 27, 15) }

/// A suite, a store and a manager of their own, torn down after — never the real App Group (rule `85-testing`).
@MainActor
private final class Bench {
    let name = "test.waterbuddy.live.\(UUID().uuidString)"
    let defaults: UserDefaults
    let container: ModelContainer
    let manager: DataManager

    init() throws {
        defaults = try #require(UserDefaults(suiteName: name))
        container = try ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        manager = DataManager(
            defaults: defaults, modelContainer: container, calendar: utcDay, now: today,
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
    }

    func tearDown() {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
}

/// ActivityKit as a recording: what iOS allows, whether the app is forward, the one activity running, and every
/// start, update and end asked of it. Rule `85-testing`'s `@unchecked Sendable` box.
nonisolated private final class FakeActivities: @unchecked Sendable {
    var allowed = true
    var foreground = true
    var running: LiveWaterPlan.Running?
    var starts: [LiveWaterAttributes.ContentState] = []
    var updates: [LiveWaterAttributes.ContentState] = []
    var ends = 0
    var staleDates: [Date] = []

    @MainActor func source() -> LiveWater.Source {
        LiveWater.Source(
            allowed: { self.allowed },
            inForeground: { self.foreground },
            running: { self.running },
            start: { content, stale in
                self.starts.append(content)
                self.staleDates.append(stale)
                self.running = LiveWaterPlan.Running(content: content, staleDate: stale)
                return true
            },
            update: { content, stale in
                self.updates.append(content)
                self.staleDates.append(stale)
                self.running = LiveWaterPlan.Running(content: content, staleDate: stale)
            },
            end: {
                self.ends += 1
                self.running = nil
            }
        )
    }
}

@MainActor
private func makeLive(on bench: Bench, _ activities: FakeActivities) -> LiveWater {
    LiveWater(manager: bench.manager, source: activities.source(), calendar: utcDay, now: today)
}

// MARK: - DataManager's switch

@MainActor
struct LiveWaterSwitchTests {

    @Test func theSwitchIsOffUntilTheUserTurnsItOn() throws {
        let bench = try Bench()
        defer { bench.tearDown() }

        #expect(!bench.manager.liveActivityEnabled)
        #expect(bench.defaults.object(forKey: DataManager.Key.liveActivity) == nil, "absent, never materialised")
    }

    @Test func theSwitchWritesItsOwnKeyAndNothingElse() throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let before = bench.defaults.dictionaryRepresentation().filter { $0.key.hasPrefix("sardor.WaterBuddy.") }

        bench.manager.liveActivityEnabled = true

        let after = bench.defaults.dictionaryRepresentation().filter { $0.key.hasPrefix("sardor.WaterBuddy.") }
        #expect(Set(after.keys).subtracting(before.keys) == [DataManager.Key.liveActivity])
        #expect(bench.defaults.object(forKey: DataManager.Key.liveActivity) as? Bool == true)
        let again = DataManager(
            defaults: bench.defaults, modelContainer: bench.container, calendar: utcDay, now: today,
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
        #expect(again.liveActivityEnabled, "a new manager reads it back")
    }
}

// MARK: - The owner

@MainActor
struct LiveWaterTests {

    @Test func turningItOnStartsOneShowingToday() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        bench.manager.addLog(amount: 500)
        let live = makeLive(on: bench, activities)

        live.enable()
        await live.settled()

        #expect(bench.manager.liveActivityEnabled)
        #expect(live.allowed)
        let started = try #require(activities.starts.first)
        #expect(activities.starts.count == 1)
        #expect(started.currentWater == 500)
        #expect(started.dailyGoal == bench.manager.dailyGoal)
        #expect(started.serving == bench.manager.servings[DataManager.usualSlot])
        #expect(activities.staleDates.last == DataManager.nextDayBoundary(after: today(), calendar: utcDay),
                "it goes stale at the day's end")
    }

    @Test func iOSSayingNoLeavesTheSwitchOffAndStartsNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        activities.allowed = false
        let live = makeLive(on: bench, activities)

        live.enable()
        await live.settled()

        #expect(!bench.manager.liveActivityEnabled)
        #expect(!live.allowed)
        #expect(activities.starts.isEmpty)
    }

    @Test func turningItOffEndsItAtOnce() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)
        live.enable()
        await live.settled()

        live.disable()
        await live.settled()

        #expect(!bench.manager.liveActivityEnabled)
        #expect(activities.ends == 1)
        #expect(activities.running == nil)
    }

    @Test func aPourUpdatesItOnce() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)
        live.enable()
        await live.settled()

        bench.manager.addLog(amount: 250)
        await live.settled()

        #expect(activities.updates.map(\.currentWater) == [250])
    }

    @Test func anUndoUpdatesIt() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)
        live.enable()
        await live.settled()

        let id = try #require(bench.manager.addLog(amount: 250))
        await live.settled()
        bench.manager.undoLog(id: id)
        await live.settled()

        #expect(activities.updates.map(\.currentWater) == [250, 0])
    }

    /// The goal, the Glass, the language and the theme: each is drawn on the activity, so each moves it once.
    @Test func everyFigureItDrawsUpdatesIt() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)
        live.enable()
        await live.settled()

        bench.manager.saveDailyGoal(ml: 2_500)
        await live.settled()
        bench.manager.servings = [200, 330, 600]
        await live.settled()
        bench.manager.language = .russian
        await live.settled()
        bench.manager.theme = .lagoon
        await live.settled()

        #expect(activities.updates.count == 4)
        let last = try #require(activities.updates.last)
        #expect(last.dailyGoal == 2_500)
        #expect(last.serving == 330)
        #expect(last.languageCode == "ru")
        #expect(last.themeCode == "lagoon")
    }

    @Test func aPassWithNothingNewUpdatesNothing() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)
        live.enable()
        await live.settled()

        await live.reconcile()
        await live.settled()

        #expect(activities.starts.count == 1)
        #expect(activities.updates.isEmpty)
    }

    /// iOS ends an activity after eight hours. A pour logged in the background — a reminder's button — may not
    /// start the next; the app coming forward does, with that pour in it.
    @Test func aBackgroundRunUpdatesButNeverStarts() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)
        live.enable()
        await live.settled()
        activities.running = nil
        activities.foreground = false

        bench.manager.addLog(amount: 250)
        await live.settled()
        #expect(activities.starts.count == 1, "the background may not start one")

        activities.foreground = true
        await live.reconcile()
        await live.settled()
        #expect(activities.starts.count == 2)
        #expect(activities.starts.last?.currentWater == 250)
    }

    @Test func iOSTurningThemOffClearsTheSwitchAndEndsIt() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)
        live.enable()
        await live.settled()

        activities.allowed = false
        await live.reconcile()
        await live.settled()

        #expect(!bench.manager.liveActivityEnabled)
        #expect(!live.allowed)
        #expect(activities.ends == 1)
    }

    @Test func whileItIsOffNothingStartsOrMoves() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)

        bench.manager.addLog(amount: 250)
        await live.settled()
        await live.reconcile()
        await live.settled()

        #expect(activities.starts.isEmpty)
        #expect(activities.updates.isEmpty)
        #expect(activities.ends == 0)
    }

    /// Siri's phrase and a reminder's *Log a Glass* return only once the activity shows the Glass, so iOS cannot
    /// suspend the launch before it does.
    @Test func theGlassLoggedInTheBackgroundReturnsOnlyOnceTheActivityShowsIt() async throws {
        let bench = try Bench()
        defer { bench.tearDown() }
        let activities = FakeActivities()
        let live = makeLive(on: bench, activities)
        live.enable()
        await live.settled()

        await LogServingIntent.logTheGlass(into: bench.manager, from: bench.defaults, settling: live)

        #expect(activities.updates.last?.currentWater == bench.manager.servings[DataManager.usualSlot])
    }
}
