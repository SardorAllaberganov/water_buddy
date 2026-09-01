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

    /// Regression for the retention cutoff: `dayOrdinal` encodes a date as
    /// `year*10_000 + month*100 + day`, and subtracting a plain day count from that encoded value
    /// is not "N calendar days ago" — it borrows across the month/day radix as though a month were
    /// 100 days long. With `now` pinned to Sept 1 2026 (ordinal `20260901`), the old
    /// `dayOrdinal(now) - 90` formula produced cutoff `20260811` ("Aug 11 2026") — 69 days later
    /// than the real 90-days-ago date, June 3 2026 (ordinal `20260603`). Anything dated between
    /// those two — real calendar days well inside the documented 90-day window — was wrongly
    /// trimmed off the ledger by the old formula, silently shortening retention to about three
    /// weeks.
    ///
    /// July 1 2026 (ordinal `20260701`) is exactly such a date: only 62 real days before `now`
    /// (inside the true window), but below the old buggy cutoff (so the old formula discarded its
    /// ledger entry) and at or above the real one (so the fix must keep it). Deleting the row and
    /// forcing a second `writeAppliedLedger` (via an unrelated fold) is what makes the trim actually
    /// run — this is the same delete-then-resend shape `aDeletedPourStillOnTheLedgerIsNotResurrected`
    /// covers, but for a ledger entry old enough for retention trimming to matter.
    ///
    /// Under the old formula this test fails exactly here: the July entry is trimmed the moment it
    /// is first written, so the resend below finds no ledger entry and no existing row, and
    /// re-inserts the deleted pour — `resend` comes back `1`, not `0`, and the log count comes back
    /// `2`, not `1`.
    @Test
    func aLedgerEntryWithinNinetyRealDaysSurvivesTrimmingAcrossAMonthBoundary() {
        withTempDefaults { defaults in
            let now = { Self.utc.date(from: DateComponents(year: 2026, month: 9, day: 1, hour: 12))! }
            let manager = makeManager(defaults, now: now)

            let sixtyTwoDaysAgo = Self.utc.date(from: DateComponents(year: 2026, month: 7, day: 1, hour: 12))!
            let oldPour = WristPour(id: UUID(), amount: 200, at: sixtyTwoDaysAgo)
            _ = manager.ingest([oldPour])

            // Simulate a swipe-to-delete: the row is gone, so only the ledger entry stands between
            // a resend and a resurrection.
            let loggedRow = manager.allLogs().first { $0.id == oldPour.id }!
            manager.deleteLog(loggedRow)

            // A second, unrelated fold — the only thing that makes `ingest` call
            // `writeAppliedLedger` again, which is where the trimming bug bites.
            let freshPour = WristPour(id: UUID(), amount: 50, at: now())
            let folded = manager.ingest([freshPour])
            #expect(folded == 1)

            let resend = manager.ingest([oldPour])
            #expect(resend == 0, "a ledger entry inside the real 90-day window must survive trimming")
            #expect(manager.allLogs().count == 1, "the deleted pour must not have been resurrected")
        }
    }
}

/// Pure day-bucketing, `ReminderPlan`'s twin — no `UserNotifications`, no `WatchConnectivity`, no
/// `DataManager`. A compile-time canary in the same spirit as `ReminderPlanTests`: if a future edit
/// makes this suite need `@MainActor` or a store, something has leaked into the wrong layer.
struct WristPlanTests {

    private static let utc = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "UTC")!; return c }()

    @Test
    func sumsOnlyTodaysPours() {
        let now = Date(timeIntervalSince1970: 1_756_800_000) // an arbitrary fixed instant
        let today = WristPour(id: UUID(), amount: 250, at: now)
        let yesterday = WristPour(id: UUID(), amount: 500, at: now.addingTimeInterval(-86_400))
        let total = WristPlan.todaysTotal(from: [today, yesterday], now: now, calendar: Self.utc)
        #expect(total == 250)
    }

    @Test
    func emptyOutboxSumsToZero() {
        let total = WristPlan.todaysTotal(from: [], now: .now, calendar: Self.utc)
        #expect(total == 0)
    }

    /// A pour stamped just before midnight and one just after both count on their own day, never
    /// the other's — this is the seam a naive "within the last 24 hours" filter would get wrong.
    @Test
    func aPourAtTheDayBoundaryCountsOnItsOwnDay() {
        // 2026-01-02 00:00:00 UTC
        let midnight = Date(timeIntervalSince1970: 1_767_312_000)
        let justBefore = WristPour(id: UUID(), amount: 100, at: midnight.addingTimeInterval(-1))
        let justAfter = WristPour(id: UUID(), amount: 200, at: midnight)
        let total = WristPlan.todaysTotal(from: [justBefore, justAfter], now: midnight, calendar: Self.utc)
        #expect(total == 200)
    }
}

/// `WristInbox`'s only reference to `DataManager` is `.shared`, which cannot be swapped in a test —
/// so these tests drive `WristInbox` against a throwaway suite by constructing `DataManager.shared`
/// is not possible from a test at all (rule `85-testing` forbids reaching the real App Group). Test
/// the reassembly logic directly instead: `WristInbox.reassemble(_:)` is the pure half (sorts and
/// concatenates chunks, decides completeness) and is `nonisolated static` for exactly this reason —
/// it takes no dependency on `DataManager.shared` and so needs no fixture at all.
struct WristInboxReassemblyTests {

    private func chunk(_ batchId: UUID, _ index: Int, of count: Int, pours: [WristPour]) -> WristBatch {
        WristBatch(schemaVersion: WristBatch.currentSchemaVersion, batchId: batchId, chunkIndex: index, chunkCount: count, pours: pours)
    }

    @Test
    func aSingleChunkBatchIsCompleteImmediately() {
        let id = UUID()
        let pour = WristPour(id: UUID(), amount: 250, at: .now)
        let result = WristInbox.reassemble([chunk(id, 0, of: 1, pours: [pour])])
        #expect(result?.map(\.id) == [pour.id])
    }

    @Test
    func aPartialBatchIsNotYetComplete() {
        let id = UUID()
        let pour = WristPour(id: UUID(), amount: 250, at: .now)
        let result = WristInbox.reassemble([chunk(id, 0, of: 2, pours: [pour])])
        #expect(result == nil)
    }

    /// `transferUserInfo` promises no ordering — chunks must be sorted by `chunkIndex`, not by
    /// arrival order, before concatenation.
    @Test
    func chunksArriveOutOfOrderButReassembleInOrder() {
        let id = UUID()
        let first = WristPour(id: UUID(), amount: 150, at: .now)
        let second = WristPour(id: UUID(), amount: 250, at: .now)
        let result = WristInbox.reassemble([
            chunk(id, 1, of: 2, pours: [second]),
            chunk(id, 0, of: 2, pours: [first]),
        ])
        #expect(result?.map(\.amount) == [150, 250])
    }

    /// Chunks from a different `batchId` must never be mixed into this one's reassembly.
    @Test
    func chunksFromADifferentBatchAreIgnored() {
        let idA = UUID(); let idB = UUID()
        let pourA = WristPour(id: UUID(), amount: 150, at: .now)
        let pourB = WristPour(id: UUID(), amount: 999, at: .now)
        let result = WristInbox.reassemble([
            chunk(idA, 0, of: 1, pours: [pourA]),
            chunk(idB, 0, of: 1, pours: [pourB]),
        ])
        // Both are individually complete single-chunk batches — reassemble(_:) operates on
        // exactly one batch's accumulated chunks at a time; see Step 3's DocC for how the buffer
        // partitions by batchId before calling this.
        #expect(result?.map(\.amount) == [150])
    }

    @Test
    func anUnrecognisedSchemaVersionIsExcludedFromReassembly() {
        let id = UUID()
        let pour = WristPour(id: UUID(), amount: 250, at: .now)
        let stale = WristBatch(schemaVersion: WristBatch.currentSchemaVersion + 1, batchId: id, chunkIndex: 0, chunkCount: 1, pours: [pour])
        #expect(WristInbox.reassemble([stale]) == nil)
    }
}

/// `requestWristPublish()` composes a `WristMirror` from the shared suite. `WCSession` itself is
/// not reachable from a unit test (there is no paired watch in CI or on a bare simulator run), so
/// these tests cover the **composition**, not the transmission — the same split
/// `WristInboxReassemblyTests` draws between the pure half and the SDK-touching half.
@MainActor
struct WristPublishTests {

    private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
        let name = "test.waterbuddy.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name); UserDefaults.standard.removeSuite(named: name) }
        return try body(defaults)
    }

    @Test
    func composesFromTheCurrentSuite() {
        withTempDefaults { defaults in
            defaults.set(500, forKey: DataManager.Key.currentWater)
            defaults.set(2_000, forKey: DataManager.Key.dailyGoal)
            defaults.set([150, 250, 500], forKey: DataManager.Key.servings)
            defaults.set(true, forKey: DataManager.Key.isGoalSet)

            let mirror = DataManager.composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: .now)
            #expect(mirror.currentWater == 500)
            #expect(mirror.dailyGoal == 2_000)
            #expect(mirror.servings == [150, 250, 500])
            #expect(mirror.isGoalSet == true)
            #expect(mirror.schemaVersion == WristMirror.currentSchemaVersion)
        }
    }

    @Test
    func ackedIsCappedAtTheMaximumAcrossTheWholeLedgerNotJustToday() {
        withTempDefaults { defaults in
            // Split across two days on purpose — `composeWristMirror` must flatten every retained
            // day's bucket, not just today's, or a pour whose own day has already passed would
            // never be named in `acked` and the watch could never retire it from its outbox.
            let today = DataManager.dayOrdinal(for: .now, in: .waterBuddyDay)
            let yesterday = today - 1
            let todaysIds = (0..<(WristMirror.maximumAckedIds)).map { _ in UUID() }
            let yesterdaysIds = (0..<10).map { _ in UUID() }
            let encoded = try! JSONEncoder().encode([yesterday: yesterdaysIds, today: todaysIds])
            defaults.set(encoded, forKey: DataManager.Key.wristApplied)

            let mirror = DataManager.composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: .now)
            #expect(mirror.acked.count == WristMirror.maximumAckedIds)
        }
    }

    @Test
    func aSystemLanguageComposesAsNil() {
        withTempDefaults { defaults in
            // Key.language absent == follow the device (rule `70-privacy`) — must round-trip as nil.
            let mirror = DataManager.composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: .now)
            #expect(mirror.languageCode == nil)
        }
    }
}

/// The half of `WristLink` worth testing without a paired watch: decoding the two payload shapes
/// WatchConnectivity hands a delegate — a `[String: Any]` dictionary, which `WCSession` itself is
/// never reachable to produce in a unit test.
struct WristLinkDecodingTests {

    @Test
    func decodesAWellFormedBatch() throws {
        let batch = WristBatch(schemaVersion: WristBatch.currentSchemaVersion, batchId: UUID(), chunkIndex: 0, chunkCount: 1, pours: [])
        let data = try JSONEncoder().encode(batch)
        let decoded = WristLink.decodeBatch(from: ["batch": data])
        #expect(decoded == batch)
    }

    @Test
    func rejectsUserInfoWithNoBatchKey() {
        #expect(WristLink.decodeBatch(from: [:]) == nil)
    }

    @Test
    func rejectsMalformedBatchData() {
        #expect(WristLink.decodeBatch(from: ["batch": Data([0xFF, 0x00])]) == nil)
    }

    @Test
    func decodesAWellFormedMirror() throws {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 500, dailyGoal: 2_000,
            servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
            composedAt: .now, phoneDayStart: .now, acked: []
        )
        let data = try JSONEncoder().encode(mirror)
        let decoded = WristLink.decodeMirror(from: ["mirror": data])
        #expect(decoded == mirror)
    }

    @Test
    func rejectsContextWithNoMirrorKey() {
        #expect(WristLink.decodeMirror(from: [:]) == nil)
    }
}

/// The pure half of sending: how `[WristPour]` splits into one or more `WristBatch`es. The actual
/// `WCSession.transferUserInfo` call is not reachable from a unit test — no paired watch exists in
/// this environment — so this is the half worth pinning, the same split every other WCSession-facing
/// piece in this design draws.
struct WristLinkChunkingTests {

    @Test
    func aSinglePourIsOneChunk() {
        let pours = [WristPour(id: UUID(), amount: 250, at: .now)]
        let batches = WristLink.chunk(pours, batchId: UUID())
        #expect(batches.count == 1)
        #expect(batches[0].chunkIndex == 0)
        #expect(batches[0].chunkCount == 1)
        #expect(batches[0].pours == pours)
    }

    @Test
    func moreThanTheMaximumSplitsIntoMultipleChunks() {
        let pours = (0..<(WristBatch.maximumPoursPerChunk + 10)).map { _ in WristPour(id: UUID(), amount: 100, at: .now) }
        let batches = WristLink.chunk(pours, batchId: UUID())
        #expect(batches.count == 2)
        #expect(batches[0].pours.count == WristBatch.maximumPoursPerChunk)
        #expect(batches[1].pours.count == 10)
        #expect(batches.allSatisfy { $0.chunkCount == 2 })
        #expect(batches.map(\.chunkIndex) == [0, 1])
    }

    @Test
    func everyChunkSharesTheSameBatchIdAndSchemaVersion() {
        let batchId = UUID()
        let pours = [WristPour(id: UUID(), amount: 150, at: .now)]
        let batches = WristLink.chunk(pours, batchId: batchId)
        #expect(batches.allSatisfy { $0.batchId == batchId && $0.schemaVersion == WristBatch.currentSchemaVersion })
    }

    @Test
    func emptyPoursProducesNoChunks() {
        #expect(WristLink.chunk([], batchId: UUID()).isEmpty)
    }
}
