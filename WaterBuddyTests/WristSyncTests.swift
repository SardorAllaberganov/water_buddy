//
//  WristSyncTests.swift
//  WaterBuddyTests
//

import Foundation
import SwiftData
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

/// `ingest(_:)`'s conjunction guard — the mechanism spec §4 built specifically because either half
/// alone leaves a real hole: without the applied ledger, an ordinary delete un-does itself when the
/// watch re-sends; without a full-history existence check, a resend past the ledger's own horizon
/// double-counts a serving forever.
@MainActor
struct WristIngestTests {

    private static let utc = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "UTC")!; return c }()

    private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
        let name = "test.waterbuddy.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name); UserDefaults.standard.removeSuite(named: name) }
        return try body(defaults)
    }

    private func inMemoryContainer() -> ModelContainer {
        try! ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    private func makeManager(_ defaults: UserDefaults, now: @escaping () -> Date) -> DataManager {
        DataManager(
            defaults: defaults, modelContainer: inMemoryContainer(), calendar: Self.utc, now: now,
            reloadWidgets: {}, rescheduleReminders: { _ in }
        )
    }

    @Test
    func aFreshPourIsFolded() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            let folded = manager.ingest([pour])
            #expect(folded == 1)
            #expect(manager.currentWater == 250)
        }
    }

    @Test
    func aResentPourAlreadyOnTheLedgerIsANoOp() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            _ = manager.ingest([pour])
            let secondPass = manager.ingest([pour])
            #expect(secondPass == 0)
            #expect(manager.currentWater == 250, "a resend must not double the total")
        }
    }

    /// The half `applied` alone cannot cover: the row was deleted, so it's no longer in `allLogs()`,
    /// but it's still on the ledger — must stay a no-op, or a delete undoes itself the moment the
    /// watch's outbox retries.
    @Test
    func aDeletedPourStillOnTheLedgerIsNotResurrected() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            _ = manager.ingest([pour])
            let log = manager.allLogs().first { $0.id == pour.id }!
            manager.deleteLog(log)
            #expect(manager.currentWater == 0)

            let resend = manager.ingest([pour])
            #expect(resend == 0, "the ledger must block the resend even though the row is gone")
            #expect(manager.currentWater == 0)
        }
    }

    /// The half `existing` alone cannot cover: past the ledger's own day-bucket, a resend must
    /// still not duplicate a row that is still there.
    @Test
    func aPourStillPresentButOffTheLedgerIsNotDuplicated() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            // Insert directly, bypassing ingest, so nothing is on the applied ledger for it —
            // simulates a row that predates this feature, or whose ledger entry aged out.
            manager.addLog(amount: 250, at: Date(timeIntervalSince1970: 1_000))
            let existing = manager.allLogs().first!
            #expect(existing.amount == 250)

            let pour = WristPour(id: existing.id, amount: 250, at: Date(timeIntervalSince1970: 1_000))
            let folded = manager.ingest([pour])
            #expect(folded == 0, "existing must catch this even with no ledger entry")
            #expect(manager.allLogs().count == 1)
        }
    }

    @Test
    func anOutOfRangeAmountIsRejected() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let zero = WristPour(id: UUID(), amount: 0, at: Date(timeIntervalSince1970: 1_000))
            let negative = WristPour(id: UUID(), amount: -5, at: Date(timeIntervalSince1970: 1_000))
            let tooLarge = WristPour(id: UUID(), amount: DataManager.maximumDailyIntake + 1, at: Date(timeIntervalSince1970: 1_000))
            #expect(manager.ingest([zero, negative, tooLarge]) == 0)
        }
    }

    @Test
    func ingestingNothingNewRingsNoDoorbell() {
        withTempDefaults { defaults in
            var reloadCount = 0
            let manager = DataManager(
                defaults: defaults, modelContainer: inMemoryContainer(), calendar: Self.utc,
                now: { Date(timeIntervalSince1970: 1_000) },
                reloadWidgets: { reloadCount += 1 }, rescheduleReminders: { _ in }
            )
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            _ = manager.ingest([pour])
            let countAfterFirst = reloadCount
            _ = manager.ingest([pour])
            #expect(reloadCount == countAfterFirst, "a fully-applied batch must not write, and must not reload widgets")
        }
    }
}
