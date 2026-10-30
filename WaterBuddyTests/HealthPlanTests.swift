//
//  HealthPlanTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func at(_ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
}

private func serving(_ amount: Int = 250, at instant: Date = at(10, 29)) -> HealthPlan.Serving {
    HealthPlan.Serving(id: UUID(), amount: amount, at: instant)
}

private func sample(
    of serving: HealthPlan.Serving?, amount: Int? = nil, at instant: Date? = nil, version: Int = 1
) -> HealthPlan.Sample {
    HealthPlan.Sample(
        object: UUID(), serving: serving?.id, amount: amount ?? serving?.amount ?? 250,
        at: instant ?? serving?.at ?? at(10, 29), version: version
    )
}

/// Not `@MainActor`, on purpose: a compile-time canary that `HealthPlan` stayed `nonisolated` (rule
/// `43-concurrency`).
struct HealthPlanTests {

    @Test func aServingHealthHasNotSeenIsSavedAtTheFirstVersion() {
        let glass = serving()
        #expect(HealthPlan.changes(servings: [glass], samples: [], within: nil, deletable: [])
                == HealthPlan.Changes(saves: [HealthPlan.Save(serving: glass, version: 1)], deletions: []))
    }

    @Test func aServingHealthAlreadyHasIsLeftAlone() {
        let glass = serving()
        #expect(HealthPlan.changes(servings: [glass], samples: [sample(of: glass, version: 4)], within: nil, deletable: []).isEmpty)
    }

    @Test func aCorrectedAmountIsSavedOneVersionAboveTheSample() {
        let glass = serving(300)
        let changes = HealthPlan.changes(servings: [glass], samples: [sample(of: glass, amount: 250, version: 3)], within: nil, deletable: [])
        #expect(changes == HealthPlan.Changes(saves: [HealthPlan.Save(serving: glass, version: 4)], deletions: []))
    }

    @Test func aMovedServingIsSavedOneVersionAboveTheSample() {
        let glass = serving(at: at(10, 29, 9, 30))
        let changes = HealthPlan.changes(servings: [glass], samples: [sample(of: glass, at: at(10, 29, 12))], within: nil, deletable: [])
        #expect(changes.saves == [HealthPlan.Save(serving: glass, version: 2)])
        #expect(changes.deletions.isEmpty, "a move is a replacement, not a deletion")
    }

    /// Review Focus 1: an instant read back a hair different must not be written again on every pass.
    @Test func anInstantThatComesBackAHairDifferentIsNotWrittenAgain() {
        let glass = serving()
        let drifted = sample(of: glass, at: glass.at.addingTimeInterval(0.000_2))
        #expect(HealthPlan.changes(servings: [glass], samples: [drifted], within: nil, deletable: []).isEmpty)
    }

    @Test func aSampleWhoseServingIsGoneIsDeleted() {
        let gone = sample(of: serving())
        // Its serving was seen in the log, and is gone from it now.
        let seen = Set([gone.serving].compactMap { $0 })
        #expect(HealthPlan.changes(servings: [], samples: [gone], within: nil, deletable: seen).deletions == [gone.object])
    }

    @Test func aSecondSampleOfOneServingIsDeletedAndTheHighestVersionKept() {
        let glass = serving()
        let older = sample(of: glass, version: 1)
        let newer = sample(of: glass, version: 2)
        let changes = HealthPlan.changes(servings: [glass], samples: [newer, older], within: nil, deletable: [])
        #expect(changes.deletions == [older.object])
        #expect(changes.saves.isEmpty)
    }

    /// Review Focus 4: a sample WaterBuddy did not write is never WaterBuddy's to delete.
    @Test func aSampleWithoutASyncIdentifierIsLeftAlone() {
        #expect(HealthPlan.changes(servings: [], samples: [sample(of: nil)], within: nil, deletable: []).isEmpty)
    }

    @Test func outsideTheIntervalNothingIsSavedOrDeleted() {
        let week = DateInterval(start: at(10, 23, 0), end: at(10, 30, 0))
        let unseen = serving(at: at(10, 1))
        let orphan = sample(of: serving(at: at(10, 2)))
        // Deletable, so the interval alone keeps it.
        let seen = Set([orphan.serving].compactMap { $0 })
        #expect(HealthPlan.changes(servings: [unseen], samples: [orphan], within: week, deletable: seen).isEmpty)
    }

    /// Half-open, as every day bound in the product: the interval's first instant is in, its end is out.
    @Test func theIntervalIncludesItsStartAndExcludesItsEnd() {
        let week = DateInterval(start: at(10, 23, 0), end: at(10, 30, 0))
        let first = serving(at: week.start)
        let past = serving(at: week.end)
        #expect(HealthPlan.changes(servings: [first, past], samples: [], within: week, deletable: []).saves
                == [HealthPlan.Save(serving: first, version: 1)])
    }

    @Test func theRecentScopeReachesBackItsDaysToTomorrowsMidnight() throws {
        let interval = try #require(HealthPlan.Scope.recent.interval(endingAt: at(10, 29, 15), calendar: utcDay))
        #expect(interval.end == at(10, 30, 0))
        #expect(utcDay.dateComponents([.day], from: interval.start, to: at(10, 29, 0)).day == HealthPlan.recentDays - 1)
        #expect(utcDay.component(.hour, from: interval.start) == 0)
    }

    /// Days, not 86,400-second steps: the interval starts at a midnight even across a DST change (rule
    /// `30-rollover`).
    @Test func theRecentScopeCountsDaysAcrossADaylightSavingChange() throws {
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = TimeZone(identifier: "America/New_York")!
        newYork.locale = Locale(identifier: "en_US_POSIX")
        let afterTheChange = newYork.date(from: DateComponents(year: 2026, month: 11, day: 2, hour: 12))!

        let interval = try #require(HealthPlan.Scope.recent.interval(endingAt: afterTheChange, calendar: newYork))
        #expect(newYork.component(.hour, from: interval.start) == 0)
        #expect(newYork.dateComponents([.day], from: interval.start, to: newYork.startOfDay(for: afterTheChange)).day
                == HealthPlan.recentDays - 1)
    }

    @Test func theWholeHistoryHasNoBound() {
        #expect(HealthPlan.Scope.all.interval(endingAt: at(10, 29), calendar: utcDay) == nil)
    }

    // MARK: What this log can have orphaned

    /// The final review's Critical: an earlier install's sample, or another iPhone's, has a serving this log
    /// never held — its id was never seen — and is never this log's to delete. Only a serving the log was
    /// seen to hold, and holds no more, takes its sample with it.
    @Test func anOrphanThisLogNeverHeldIsLeftAlone() {
        let deleted = serving()
        let mine = sample(of: deleted)
        let anotherPhones = sample(of: serving())
        #expect(HealthPlan.changes(servings: [], samples: [mine, anotherPhones], within: nil, deletable: [deleted.id]).deletions
                == [mine.object])
    }

    /// An empty log — a new install, or a store that fell back to an empty one — has seen nothing, so it
    /// deletes no orphan; a second sample of a serving the log holds goes whatever was seen.
    @Test func aLogThatHasSeenNothingDeletesNoOrphan() {
        let glass = serving()
        let older = sample(of: glass, version: 1)
        let newer = sample(of: glass, version: 2)
        let orphan = sample(of: serving())
        #expect(HealthPlan.changes(servings: [glass], samples: [newer, older, orphan], within: nil, deletable: []).deletions
                == [older.object])
    }

    @Test func aPassAskedForWhileAnotherWaitsTakesTheWiderReach() {
        #expect(HealthPlan.Scope.recent.widened(by: .all) == .all)
        #expect(HealthPlan.Scope.all.widened(by: .recent) == .all)
        #expect(HealthPlan.Scope.recent.widened(by: .recent) == .recent)
    }
}
