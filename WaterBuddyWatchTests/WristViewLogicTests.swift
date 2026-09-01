//
//  WristViewLogicTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

/// The two pure functions `WristView` reads from — resolving which servings to offer, and
/// formatting "Synced Nm ago" — pulled out so they're testable without instantiating a `View` at
/// all (rule `43-concurrency`'s "a value type a non-@MainActor suite reads is declared at file
/// scope" extended to functions for the same reason).
struct WristViewLogicTests {

    @Test
    func fallsBackToTheDefaultServingsWithNoMirrorYet() {
        let resolved = WristView.resolveServings(from: nil)
        #expect(resolved == DataManager.defaultServings)
    }

    @Test
    func usesTheMirrorsServingsWhenPresent() {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: 2_000,
            servings: [100, 200, 300], languageCode: nil, isGoalSet: true,
            composedAt: .now, phoneDayStart: .now, acked: []
        )
        #expect(WristView.resolveServings(from: mirror) == [100, 200, 300])
    }

    @Test
    func syncedJustNowReadsAsNow() {
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_030))
        #expect(text == "Synced just now")
    }

    @Test
    func syncedMinutesAgoReadsInWholeMinutes() {
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_000 + 245))
        #expect(text == "Synced 4m ago")
    }

    @Test
    func noMirrorYetReadsAsNeverSynced() {
        #expect(WristView.syncedCaption(composedAt: nil, now: .now) == "Not yet synced")
    }
}
