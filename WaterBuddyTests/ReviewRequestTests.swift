//
//  ReviewRequestTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 15/10/26.
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

/// A Gregorian/UTC day, so a run cannot flake on a machine sitting near local midnight.
private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// Noon on the day every fixture here calls today.
private let today = utc(2026, 10, 15)

/// A manager on its own UUID-named suite and in-memory store, every side effect off, its clock
/// pinned to ``today`` and its goal at 1,000 (rule `85-testing`).
@MainActor
private func withManager(_ body: (DataManager, UserDefaults) throws -> Void) rethrows {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        // Never the default: that resolves the live App Group store (rule `85-testing`).
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        calendar: utcDay,
        now: { today },
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    manager.saveDailyGoal(ml: 1_000)
    try body(manager, defaults)
}

/// The goal reached on each of the `days` days before today, then `todayAmount` today.
@MainActor
private func pour(goalDays days: Int, today todayAmount: Int, into manager: DataManager) {
    for back in stride(from: days, through: 1, by: -1) {
        manager.addLog(amount: 1_000, at: utcDay.date(byAdding: .day, value: -back, to: today)!)
    }
    if todayAmount > 0 { manager.addLog(amount: todayAmount) }
}

// MARK: - The decision and its record

/// Whether the app may ask iOS for a rating, and the record that it did
/// (`docs/superpowers/specs/2026-10-15-rating-prompt-design.md`, roadmap 1.2.5).
@MainActor
struct ReviewRequestTests {

    /// D1: the third goal day in a row asks; the second does not.
    @Test func theRequestWaitsForTheThirdGoalDayInARow() {
        #expect(DataManager.reviewStreak == 3)
        #expect(!DataManager.mayRequestReview(reachedToday: true, streak: 2, askedVersion: nil, version: "1.2"))
        #expect(DataManager.mayRequestReview(reachedToday: true, streak: 3, askedVersion: nil, version: "1.2"))
        #expect(DataManager.mayRequestReview(reachedToday: true, streak: 40, askedVersion: nil, version: "1.2"))
    }

    /// A run of three can end yesterday while today is still short. The request belongs to the day
    /// that completed the run.
    @Test func aRunThatEndedYesterdayIsNotAskedAbout() {
        #expect(!DataManager.mayRequestReview(reachedToday: false, streak: 3, askedVersion: nil, version: "1.2"))
    }

    /// D2: once per version, as Apple's own sample asks.
    @Test func aVersionAlreadyAskedInIsNotAskedAgain() {
        #expect(!DataManager.mayRequestReview(reachedToday: true, streak: 3, askedVersion: "1.2", version: "1.2"))
        #expect(DataManager.mayRequestReview(reachedToday: true, streak: 3, askedVersion: "1.1", version: "1.2"))
    }

    /// An empty version could never be told from the next one, so it is never asked in.
    @Test func anUnknownVersionIsNeverAskedIn() {
        #expect(!DataManager.mayRequestReview(reachedToday: true, streak: 3, askedVersion: nil, version: ""))
    }

    /// The claim records before it answers, and answers once per version.
    @Test func aClaimOnTheThirdGoalDayRecordsTheVersionBeforeAnswering() throws {
        try withManager { manager, defaults in
            pour(goalDays: 2, today: 1_000, into: manager)
            try #require(manager.streak == 3, "the fixture did not make a three-day run")
            try #require(manager.hasReachedGoal)

            #expect(manager.claimReviewRequest(version: "1.2"))
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) as? String == "1.2")

            #expect(!manager.claimReviewRequest(version: "1.2"), "asked twice in one version")
            #expect(manager.claimReviewRequest(version: "1.3"), "a new version was not asked")
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) as? String == "1.3")
        }
    }

    /// The second goal day in a row is refused, and a refusal writes nothing.
    @Test func aClaimOnTheSecondGoalDayWritesNothing() throws {
        try withManager { manager, defaults in
            pour(goalDays: 1, today: 1_000, into: manager)
            try #require(manager.streak == 2, "the fixture did not make a two-day run")

            #expect(!manager.claimReviewRequest(version: "1.2"))
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) == nil)
        }
    }

    /// Three goal days ending yesterday, today short: refused, nothing written.
    @Test func aClaimWithTodayShortWritesNothing() throws {
        try withManager { manager, defaults in
            pour(goalDays: 3, today: 500, into: manager)
            try #require(manager.streak == 3, "three goal days ending yesterday did not count as a run of three")
            try #require(!manager.hasReachedGoal)

            #expect(!manager.claimReviewRequest(version: "1.2"))
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) == nil)
        }
    }

    /// Plan P1. `string(forKey:)` would hand back a stored number `1.2` as `"1.2"` and call version
    /// 1.2 asked; the key is read with `object(forKey:) as? String`, so anything but a string is
    /// absent.
    @Test func aStoredNumberCountsAsNeverAsked() {
        withManager { manager, defaults in
            defaults.set(1.2, forKey: DataManager.Key.reviewRequestedVersion)
            pour(goalDays: 2, today: 1_000, into: manager)

            #expect(manager.claimReviewRequest(version: "1.2"))
            #expect(defaults.object(forKey: DataManager.Key.reviewRequestedVersion) as? String == "1.2")
        }
    }
}

// MARK: - The app's side

/// When the app may ask at all, how long Home waits, and which version it records.
@MainActor
struct ReviewPromptTests {

    /// D4. The test host is a DEBUG build, so this holds the DEBUG branch. The Release branch,
    /// which always answers `true`, is not compiled by the gate (spec §6).
    @Test func aDebugBuildAsksOnlyWhenLaunchedToAsk() {
        #expect(ReviewPrompt.launchArgument == "-WaterBuddyReviewPrompt")
        #if DEBUG
        #expect(!ReviewPrompt.isEnabled(arguments: []))
        #expect(!ReviewPrompt.isEnabled(arguments: ["-WaterBuddyFreshStart", "YES"]))
        #expect(ReviewPrompt.isEnabled(arguments: ["-WaterBuddyReviewPrompt", "YES"]))
        #endif
    }

    /// The gate's own runs launch without the argument, so nothing in them can meet the request.
    @Test func theTestRunItselfIsNotLaunchedToAsk() {
        #if DEBUG
        #expect(!ReviewPrompt.isEnabledHere)
        #endif
    }

    /// The request meets a screen at rest: the confetti has landed first.
    @Test func theRequestWaitsForTheConfettiToLand() {
        #expect(ReviewPrompt.pause > .seconds(Confetti.duration))
    }

    /// The version is the bundle's own, and the app has one.
    @Test func theVersionIsTheBundlesOwn() {
        #expect(!ReviewPrompt.version.isEmpty)
        #expect(ReviewPrompt.version == Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }
}
