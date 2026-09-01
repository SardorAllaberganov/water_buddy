//
//  WristSyncTests.swift
//  WaterBuddyTests
//

import Foundation
import Testing
@testable import WaterBuddy

/// The wire protocol's own round-trip. Not `@MainActor` — these are plain `Codable` values with no
/// actor isolation, and keeping the suite off the main actor is the same canary
/// `LiquidGlassInteractionTests` already is (rule `43-concurrency`).
struct WristWireTests {

    @Test
    func aWristPourRoundTripsThroughJSON() throws {
        let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
        let data = try JSONEncoder().encode(pour)
        let decoded = try JSONDecoder().decode(WristPour.self, from: data)
        #expect(decoded == pour)
    }

    @Test
    func aWristBatchRoundTripsThroughJSON() throws {
        let batch = WristBatch(
            schemaVersion: WristBatch.currentSchemaVersion,
            batchId: UUID(),
            chunkIndex: 0,
            chunkCount: 1,
            pours: [WristPour(id: UUID(), amount: 150, at: Date(timeIntervalSince1970: 2_000))]
        )
        let data = try JSONEncoder().encode(batch)
        let decoded = try JSONDecoder().decode(WristBatch.self, from: data)
        #expect(decoded == batch)
    }

    @Test
    func aWristMirrorRoundTripsThroughJSON() throws {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion,
            currentWater: 500,
            dailyGoal: 2_000,
            servings: [150, 250, 500],
            languageCode: "ru",
            isGoalSet: true,
            composedAt: Date(timeIntervalSince1970: 3_000),
            phoneDayStart: Date(timeIntervalSince1970: 2_900),
            acked: [UUID(), UUID()]
        )
        let data = try JSONEncoder().encode(mirror)
        let decoded = try JSONDecoder().decode(WristMirror.self, from: data)
        #expect(decoded == mirror)
    }

    /// `languageCode == nil` means "follow the device" (rule `70-privacy`'s "absence carries
    /// meaning") — it must round-trip as `nil`, not coerce into a sentinel string.
    @Test
    func aNilLanguageCodeRoundTripsAsNil() throws {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: 2_000,
            servings: [150, 250, 500], languageCode: nil, isGoalSet: false,
            composedAt: .now, phoneDayStart: .now, acked: []
        )
        let data = try JSONEncoder().encode(mirror)
        let decoded = try JSONDecoder().decode(WristMirror.self, from: data)
        #expect(decoded.languageCode == nil)
    }
}
