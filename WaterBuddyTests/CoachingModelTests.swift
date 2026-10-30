//
//  CoachingModelTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 30/10/26.
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

private final class Clock: @unchecked Sendable {
    var now: Date
    init(_ now: Date) { self.now = now }
}

private final class Rings {
    var reloads = 0
    var publishes = 0
    var plans: [[ReminderPlan.Slot]] = []
}

/// Every stored key's value, by name — to prove a setter wrote its own key and nothing else.
private func stored(in defaults: UserDefaults) -> [String: String] {
    DataManager.Key.all.reduce(into: [:]) { $0[$1] = defaults.object(forKey: $1).map { "\($0)" } ?? "<nil>" }
}

/// Managers over one throwaway suite and one in-memory store — the app's, and `make()` for a second
/// instance standing in for the widget extension's long-lived `DataManager.shared`. Every side effect is
/// injected (rule `85-testing`). 2026-10-10 is a Saturday.
@MainActor
private func withCoachStore<T>(
    clock: Clock,
    _ body: (DataManager, Rings, UserDefaults, () -> DataManager) throws -> T
) throws -> T {
    let name = "test.waterbuddy.coaching.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let rings = Rings()
    let make = {
        DataManager(
            defaults: defaults,
            modelContainer: container,
            calendar: utcDay,
            now: { clock.now },
            reloadWidgets: { rings.reloads += 1 },
            rescheduleReminders: { rings.plans.append($0) },
            publishWrist: { _ in rings.publishes += 1 }
        )
    }
    return try body(make(), rings, defaults, make)
}

private func hours(_ plan: [ReminderPlan.Slot]?, on day: Int = 20_261_010) -> [Int] {
    (plan ?? []).filter { $0.dayOrdinal == day }.map(\.hour)
}

// MARK: - Tests

/// Set B's two settings on the model (spec `2026-10-30-coaching-design.md` §3.4, D2, D7).
@MainActor
struct CoachingModelTests {

    @Test func anUntouchedSuiteFollowsTheStandardScheduleWithCoachingOff() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10))) { manager, _, defaults, _ in
            #expect(manager.reminderSchedule == .standard)
            #expect(!manager.onlyWhenBehind)
            #expect(defaults.object(forKey: DataManager.Key.reminderSchedule) == nil, "never materialised")
            #expect(defaults.object(forKey: DataManager.Key.onlyWhenBehind) == nil, "never materialised")
        }
    }

    @Test func aChosenScheduleIsStoredAndReadBack() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10))) { manager, _, defaults, make in
            let chosen = try #require(ReminderPlan.Schedule(first: 7, last: 22, every: 3, quietWeekdays: [1]))
            manager.reminderSchedule = chosen
            #expect(defaults.array(forKey: DataManager.Key.reminderSchedule) as? [Int] == chosen.stored)
            #expect(make().reminderSchedule == chosen, "a new manager reads it back")
        }
    }

    @Test func theStandardScheduleRemovesTheKey() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10))) { manager, _, defaults, _ in
            manager.reminderSchedule = try #require(ReminderPlan.Schedule(first: 7, last: 22, every: 3))
            manager.reminderSchedule = .standard
            #expect(defaults.object(forKey: DataManager.Key.reminderSchedule) == nil)
        }
    }

    @Test func aCorruptStoredScheduleReadsAsTheStandardOne() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10))) { _, _, defaults, make in
            let corrupts: [Any] = [[9, 20, 2, 0], [9, 21, 2], "9-21", 42]
            for corrupt in corrupts {
                defaults.set(corrupt, forKey: DataManager.Key.reminderSchedule)
                #expect(make().reminderSchedule == .standard, "\(corrupt) was read as a schedule")
                #expect(DataManager.resolveReminderSchedule(in: defaults) == .standard)
            }
        }
    }

    @Test func settingTheScheduleWritesItsKeyAloneAndReplans() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10))) { manager, rings, defaults, _ in
            let before = stored(in: defaults)
            let plans = rings.plans.count
            let (reloads, publishes) = (rings.reloads, rings.publishes)
            manager.reminderSchedule = try #require(ReminderPlan.Schedule(first: 7, last: 22, every: 3))

            let after = stored(in: defaults)
            #expect(Set(after.keys.filter { after[$0] != before[$0] }) == [DataManager.Key.reminderSchedule])
            #expect(rings.plans.count == plans + 1, "a schedule moves the plan")
            #expect(rings.reloads == reloads, "no widget draws it")
            #expect(rings.publishes == publishes, "the watch never hears of it")
        }
    }

    @Test func settingOnlyWhenBehindWritesItsKeyAloneAndReplans() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10))) { manager, rings, defaults, _ in
            let before = stored(in: defaults)
            let plans = rings.plans.count
            manager.onlyWhenBehind = true

            let after = stored(in: defaults)
            #expect(Set(after.keys.filter { after[$0] != before[$0] }) == [DataManager.Key.onlyWhenBehind])
            #expect(rings.plans.count == plans + 1)
            #expect(defaults.object(forKey: DataManager.Key.onlyWhenBehind) as? Bool == true)
        }
    }

    @Test func anEqualWriteNeitherWritesNorReplans() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10))) { manager, rings, _, _ in
            let plans = rings.plans.count
            manager.reminderSchedule = .standard
            manager.onlyWhenBehind = false
            #expect(rings.plans.count == plans)
        }
    }

    @Test func theFiledPlanFollowsTheStoredSchedule() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10, 12, 10))) { manager, rings, _, _ in
            manager.remindersEnabled = true
            manager.reminderSchedule = try #require(ReminderPlan.Schedule(first: 7, last: 22, every: 3))
            #expect(hours(rings.plans.last) == [13, 16, 19, 22])
            #expect(manager.nextReminder == utc(2026, 10, 10, 13))
        }
    }

    /// Review Focus 1: the extension's long-lived instance re-reads before it plans — `addWater` refreshes
    /// first, as `AddWaterIntent` does — so a widget tap files the schedule the app set after it was built.
    @Test func aWidgetTapAfterAChangeFilesTheNewSchedule() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10, 12, 10))) { app, _, _, make in
            app.remindersEnabled = true
            let widget = make()
            app.reminderSchedule = try #require(ReminderPlan.Schedule(first: 7, last: 22, every: 3))

            widget.addWater(amount: 100)

            // 13:00 is inside the hour after the 12:10 pour, so it is the drink that drops it.
            #expect(hours(widget.currentReminderSlots()) == [16, 19, 22])
        }
    }

    /// Goal 2,100: 600 is due by 11:00, 900 by 13:00.
    @Test func onlyWhenBehindMovesTheNextReminderOnOnceAShareIsDrunk() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10, 10, 10))) { manager, rings, _, _ in
            manager.saveDailyGoal(ml: 2_100)
            manager.remindersEnabled = true
            manager.addLog(amount: 700, at: utc(2026, 10, 10, 8))
            #expect(manager.nextReminder == utc(2026, 10, 10, 11))

            manager.onlyWhenBehind = true
            #expect(manager.nextReminder == utc(2026, 10, 10, 13))
            #expect(hours(rings.plans.last).first == 13)
        }
    }

    /// Review Focus 2.
    @Test func raisingTheGoalBringsBackASlotItHadCovered() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10, 10, 10))) { manager, rings, _, _ in
            manager.saveDailyGoal(ml: 2_100)
            manager.remindersEnabled = true
            manager.onlyWhenBehind = true
            manager.addLog(amount: 700, at: utc(2026, 10, 10, 8))
            #expect(!hours(rings.plans.last).contains(11))

            manager.saveDailyGoal(ml: 4_200)
            #expect(hours(rings.plans.last).first == 11, "1,200 is due by 11:00 now")
        }
    }

    /// Review Focus 3.
    @Test func deletingTheServingThatCoveredASlotBringsItBack() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10, 10, 10))) { manager, rings, _, _ in
            manager.saveDailyGoal(ml: 2_100)
            manager.remindersEnabled = true
            manager.onlyWhenBehind = true
            manager.addLog(amount: 700, at: utc(2026, 10, 10, 8))
            let serving = try #require(manager.todaysLogs.first)

            manager.deleteLog(serving)
            #expect(hours(rings.plans.last).first == 11)
        }
    }

    @Test func refreshPicksUpCoachingAnotherInstanceWrote() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10))) { app, _, _, make in
            let other = make()
            let chosen = try #require(ReminderPlan.Schedule(first: 6, last: 20, every: 2))
            app.reminderSchedule = chosen
            app.onlyWhenBehind = true

            other.refresh()
            #expect(other.reminderSchedule == chosen)
            #expect(other.onlyWhenBehind)
        }
    }

    @Test func thePaceIsThePlansOwnReading() throws {
        try withCoachStore(clock: Clock(utc(2026, 10, 10, 12, 10))) { manager, _, _, _ in
            manager.saveDailyGoal(ml: 2_100)
            #expect(manager.pace == .behind(600), "600 due by 11:00, nothing drunk")
            manager.addLog(amount: 450, at: utc(2026, 10, 10, 8))
            #expect(manager.pace == .behind(150))
            manager.addLog(amount: 150, at: utc(2026, 10, 10, 9))
            #expect(manager.pace == .onTrack)
            #expect(manager.pace == ReminderPlan.pace(water: manager.currentWater, goal: manager.dailyGoal,
                                                      schedule: manager.reminderSchedule,
                                                      now: utc(2026, 10, 10, 12, 10), calendar: utcDay))
        }
    }
}
