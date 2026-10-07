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
            phoneDayEnd: Date(timeIntervalSince1970: 89_300),
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
            composedAt: .now, phoneDayStart: .now, phoneDayEnd: .now, acked: []
        )
        let data = try JSONEncoder().encode(mirror)
        let decoded = try JSONDecoder().decode(WristMirror.self, from: data)
        #expect(decoded.languageCode == nil)
    }

    /// A mirror written before `phoneDayEnd` existed — persisted in the watch's own suite across an
    /// update, or sent by a phone that updated after its watch — must still decode, with the field
    /// absent rather than the whole value lost. That is the reason the field is optional: a decode
    /// failure here puts an upgrading watch back on its never-synced screen until the phone next
    /// publishes (spec §17).
    @Test
    func aMirrorFromBeforeThisChangeStillDecodes() throws {
        // Hand-written in the shape the previous build encoded: every field except `phoneDayEnd`.
        // `languageCode` is missing too, which is how a `nil` one is encoded.
        let legacy = Data("""
            {"schemaVersion":1,"currentWater":500,"dailyGoal":2000,"servings":[150,250,500],
             "isGoalSet":true,"composedAt":3000,"phoneDayStart":2900,"acked":[]}
            """.utf8)
        let decoded = try JSONDecoder().decode(WristMirror.self, from: legacy)
        #expect(decoded.phoneDayEnd == nil)
        #expect(decoded.currentWater == 500)
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
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
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
                reloadWidgets: { reloadCount += 1 }, rescheduleReminders: { _ in },
                publishWrist: { _ in }
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

    /// C1: a failed read of the full history must **decline the whole batch**, never collapse to
    /// "no existing rows" — that collapse is exactly what let a re-sent pour insert a permanent
    /// duplicate the moment the store degrades (rule `20-state`, `fetch(_:)`'s own DocC).
    ///
    /// Forces a genuine SwiftData fetch failure by corrupting the on-disk store with same-size
    /// random bytes *after* the container is already open and the manager already holds a
    /// long-lived `ModelContext` on it — the only technique of three tried that actually makes
    /// `try context.fetch(...)` throw. Truncating to zero bytes makes SQLite treat the file as a
    /// fresh, valid, empty database (no error); revoking read permission on an already-open file
    /// descriptor does not retroactively fail a read through that descriptor. Only overwriting the
    /// file with garbage of its *original* size reliably corrupts the SQLite header in a way both
    /// a fresh and an existing long-lived context detect.
    ///
    /// **This does not isolate C1 from C2.** Corrupting the SwiftData store fails `fetch(nil)`
    /// *and*, were the function to proceed past that guard, would fail the later `save()` too — so
    /// this pins the combined "the store cannot be read or written" behaviour, not C1's specific
    /// guard alone; disabling only C1's decline here would still return `folded == 0` via C2's
    /// separate `saveAndRecompute()` guard catching the same corruption downstream. The ledger-decode
    /// half of C1 has no such confound, since `readAppliedLedger()` reads `UserDefaults`, a
    /// completely different store from the one this test corrupts — see
    /// `anUndecodableLedgerDeclinesTheWholeBatch` immediately below for the test that actually
    /// isolates C1.
    @Test
    func aFailedExistingLogsReadDeclinesTheWholeBatchRatherThanTreatingEverythingAsNew() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let storeURL = dir.appendingPathComponent("corrupt.store")
        defer { try? FileManager.default.removeItem(at: dir) }

        let schema = Schema([WaterLog.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: storeURL))

        try withTempDefaults { defaults in
            let manager = DataManager(
                defaults: defaults, modelContainer: container, calendar: Self.utc,
                now: { Date(timeIntervalSince1970: 1_000) },
                reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
            )
            manager.addLog(amount: 100, at: Date(timeIntervalSince1970: 1_000))
            #expect(manager.currentWater == 100, "the store must be healthy before it is corrupted")

            // Corrupt the file the manager's own long-lived `ModelContext` is already open on.
            let size = try FileManager.default.attributesOfItem(atPath: storeURL.path)[.size] as? Int ?? 4_096
            try Data((0..<size).map { _ in UInt8.random(in: 0...255) }).write(to: storeURL)
            for suffix in ["-wal", "-shm"] {
                let path = storeURL.path + suffix
                if FileManager.default.fileExists(atPath: path) {
                    try? FileManager.default.removeItem(atPath: path)
                }
            }

            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            let folded = manager.ingest([pour])
            #expect(folded == 0, "an unreadable store must decline the batch, never treat it as empty")
            #expect(manager.currentWater == 100, "a failed read must leave the total exactly as it stood")
        }
    }

    /// C1's other half: an **undecodable** ledger (present but corrupt data under `Key.wristApplied`)
    /// must also decline the whole batch, never collapse to "empty ledger". This is the isolated
    /// counterpart to the test above — the SwiftData store here stays perfectly healthy, so a
    /// failure of this test can only mean the ledger-decode guard itself regressed, not C2's
    /// downstream save guard catching an unrelated corruption.
    @Test
    func anUndecodableLedgerDeclinesTheWholeBatch() {
        withTempDefaults { defaults in
            defaults.set(Data([0xDE, 0xAD, 0xBE, 0xEF]), forKey: DataManager.Key.wristApplied)
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            #expect(manager.ingest([pour]) == 0, "an undecodable ledger must decline, never read as empty")
            #expect(manager.currentWater == 0)
            #expect(manager.allLogs().isEmpty, "nothing may be inserted against a ledger that could not be read")
        }
    }

    /// C2: the applied ledger may only be written **after** a successful save, never before — a
    /// crash or a save failure between the two previously marked ids permanently applied with no
    /// `WaterLog` row behind them, so every future resend of the same ids was blocked by the
    /// ledger with nothing for `existingIds` to find either: the user's watch-authored water lost
    /// silently and irrecoverably.
    ///
    /// `ModelConfiguration(schema:url:allowsSave:)`'s `allowsSave: false` is the seam that forces
    /// `modelContext.save()` to throw — reads still succeed, isolating this from C1's read
    /// failure. It has to be file-backed, not `isStoredInMemoryOnly`: SwiftData opens a read-only
    /// configuration by attaching an *existing* store, and an in-memory store combined with
    /// `allowsSave: false` fails at container construction (`SwiftDataError.loadIssueModelContainer`
    /// — verified by hand) rather than at `save()`. Seed the file with a normal, writable container
    /// first, then reopen the same URL read-only for the manager under test.
    @Test
    func aFailedSaveDoesNotUpdateTheAppliedLedgerOrReportThePourAsFolded() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let storeURL = dir.appendingPathComponent("readonly.store")
        defer { try? FileManager.default.removeItem(at: dir) }

        let schema = Schema([WaterLog.self])
        let seedContainer = try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: storeURL))
        try ModelContext(seedContainer).save() // materialise the file even with zero rows

        try withTempDefaults { defaults in
            let container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, url: storeURL, allowsSave: false)
            )
            let manager = DataManager(
                defaults: defaults, modelContainer: container, calendar: Self.utc,
                now: { Date(timeIntervalSince1970: 1_000) },
                reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
            )
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            let folded = manager.ingest([pour])
            #expect(folded == 0, "a failed save must not be reported as an applied pour")

            let day = DataManager.dayOrdinal(for: pour.at, in: Self.utc)
            let ledger = DataManager.readAppliedLedger(from: defaults)
            #expect(
                ledger?[day]?.contains(pour.id) != true,
                "the ledger must not mark an unsaved pour as applied — a resend once the store recovers must still fold it"
            )
        }
    }

    /// A7 (final review): `readAppliedLedger`/`writeAppliedLedger` insert a folded pour under **its
    /// own day**, then the retention trim filters by `$0.key >= cutoff` where `cutoff` is derived
    /// from `now()`. A pour whose own day already precedes the 90-day cutoff — a watch that was
    /// offline a long time, or a system-daemon-held `transferUserInfo` delivered late — was
    /// previously inserted and then immediately trimmed by the **same write**, leaving it protected
    /// only by the full-history existence check: exactly what a user's `deleteLog` removes,
    /// reopening the resurrection hole the ledger exists to close.
    @Test
    func aPourOlderThanTheRetentionWindowStillGetsItsLedgerEntryOnTheWriteThatFoldsIt() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000_000_000)
            let oldPourDate = Self.utc.date(byAdding: .day, value: -100, to: now)!
            let manager = makeManager(defaults, now: { now })

            let pour = WristPour(id: UUID(), amount: 250, at: oldPourDate)
            let folded = manager.ingest([pour])
            #expect(folded == 1, "a pour older than the retention window is still a genuinely new pour and must fold")

            let day = DataManager.dayOrdinal(for: oldPourDate, in: Self.utc)
            let ledger = DataManager.readAppliedLedger(from: defaults)
            #expect(
                ledger?[day]?.contains(pour.id) == true,
                "the write that folds an old pour must not trim its own ledger entry in the same pass"
            )
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

    // MARK: - The phone's total, and when it stops counting (spec §17)

    /// A mirror holding `currentWater` for the phone's day `[phoneDayStart, phoneDayEnd)`. Only the
    /// two ends and the total matter to the plan; everything else is filler.
    private static func mirror(currentWater: Int = 1_800, phoneDayStart: Date, phoneDayEnd: Date?) -> WristMirror {
        WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: currentWater, dailyGoal: 2_000,
            servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
            composedAt: phoneDayStart, phoneDayStart: phoneDayStart, phoneDayEnd: phoneDayEnd, acked: []
        )
    }

    /// The phone's total belongs to the phone's day and to nothing after it. Counting it regardless
    /// is what left yesterday's water on the wrist every morning until something woke the phone. The
    /// end is exclusive — the same half-open day `fetchLogsForToday()` reads on the phone — and the
    /// watch's own pours keep counting once the phone's figure has stopped.
    @Test
    func thePhonesTotalCountsUntilThePhonesDayEnds() {
        let mirror = Self.mirror(
            phoneDayStart: Date(timeIntervalSince1970: 1_767_225_600), // 2026-01-01 00:00 UTC
            phoneDayEnd: Date(timeIntervalSince1970: 1_767_312_000)    // 2026-01-02 00:00 UTC
        )
        let lastSecond = Date(timeIntervalSince1970: 1_767_311_999)
        let end = Date(timeIntervalSince1970: 1_767_312_000)
        let newDaysPour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_767_312_060)) // 00:01

        #expect(WristPlan.todaysTotal(mirror: mirror, outbox: [], now: lastSecond, calendar: Self.utc) == 1_800)
        #expect(WristPlan.todaysTotal(mirror: mirror, outbox: [], now: end, calendar: Self.utc) == 0,
                "the instant the phone's day ends already belongs to the next one")
        #expect(WristPlan.todaysTotal(mirror: mirror, outbox: [newDaysPour], now: Date(timeIntervalSince1970: 1_767_312_120), calendar: Self.utc) == 250,
                "the watch's own pour still counts once the phone's total has stopped")
    }

    /// §5's guarantee, pinned on its own: a watch whose day turned first must never zero a phone
    /// whose day is still running. The phone keeps New York time (UTC−5) and the watch UTC, so for
    /// five hours the watch is on 2 January while the phone is still on the 1st. Comparing the
    /// watch's own calendar day — what `isMirrorStale` does — would drop the phone's total for all
    /// five of those hours.
    @Test
    func aWatchAheadOfThePhoneKeepsThePhonesTotalUntilThePhonesDayEnds() {
        let mirror = Self.mirror(
            phoneDayStart: Date(timeIntervalSince1970: 1_767_243_600), // 2026-01-01 00:00 EST
            phoneDayEnd: Date(timeIntervalSince1970: 1_767_330_000)    // 2026-01-02 00:00 EST
        )
        let watchsNewDay = Date(timeIntervalSince1970: 1_767_315_600) // 2026-01-02 01:00 UTC, 20:00 EST on the 1st

        #expect(WristPlan.todaysTotal(mirror: mirror, outbox: [], now: watchsNewDay, calendar: Self.utc) == 1_800,
                "never a confident zero while the phone's own day is still running")
        #expect(WristPlan.todaysTotal(mirror: mirror, outbox: [], now: Date(timeIntervalSince1970: 1_767_330_000), calendar: Self.utc) == 0)
    }

    /// A mirror from a phone build that predates `phoneDayEnd` carries none. The watch then assumes
    /// the phone shares its time zone and ends the phone's day at the watch's own next midnight after
    /// `phoneDayStart` — the real one, which on this New York day is 25 hours on, not 24
    /// (rule `30-rollover`: never add 86,400).
    @Test
    func aMirrorWithNoDayEndFallsBackToTheWatchsOwnMidnight() {
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = TimeZone(identifier: "America/New_York")!
        let mirror = Self.mirror(phoneDayStart: Date(timeIntervalSince1970: 1_793_505_600), phoneDayEnd: nil) // 2026-11-01 00:00 EDT

        #expect(WristPlan.todaysTotal(mirror: mirror, outbox: [], now: Date(timeIntervalSince1970: 1_793_595_599), calendar: newYork) == 1_800,
                "23:59:59 EST, in the 25th hour of the day the clocks fell back")
        #expect(WristPlan.todaysTotal(mirror: mirror, outbox: [], now: Date(timeIntervalSince1970: 1_793_595_600), calendar: newYork) == 0) // 2026-11-02 00:00 EST
    }

    // MARK: - When the complication has to turn over by itself

    /// One shared midnight is one turnover, not two timeline entries at the same instant.
    @Test
    func theTimelineTurnsOnceWhenTheDevicesShareAZone() {
        let mirror = Self.mirror(
            phoneDayStart: Date(timeIntervalSince1970: 1_767_225_600), // 2026-01-01 00:00 UTC
            phoneDayEnd: Date(timeIntervalSince1970: 1_767_312_000)    // 2026-01-02 00:00 UTC
        )
        let boundaries = WristPlan.dayBoundaries(after: Date(timeIntervalSince1970: 1_767_279_600), mirror: mirror, calendar: Self.utc) // 15:00 UTC

        #expect(boundaries == [Date(timeIntervalSince1970: 1_767_312_000)])
    }

    /// Under skew the two days end at different instants, and each changes what the face shows: the
    /// phone's total stops at one, the watch's own pours re-bucket at the other. Here the phone keeps
    /// Tokyo time, so its day ends **first** — the order a list built as "the watch's midnight, then
    /// the phone's end" would get backwards.
    @Test
    func theTimelineTurnsAtBothBoundariesInOrderWhenTheZonesDisagree() {
        let mirror = Self.mirror(
            phoneDayStart: Date(timeIntervalSince1970: 1_767_193_200), // 2026-01-01 00:00 JST
            phoneDayEnd: Date(timeIntervalSince1970: 1_767_279_600)    // 2026-01-02 00:00 JST
        )
        let boundaries = WristPlan.dayBoundaries(after: Date(timeIntervalSince1970: 1_767_261_600), mirror: mirror, calendar: Self.utc) // 10:00 UTC

        #expect(boundaries == [
            Date(timeIntervalSince1970: 1_767_279_600), // the phone's day ends, 15:00 UTC
            Date(timeIntervalSince1970: 1_767_312_000), // the watch's own midnight
        ])
    }

    /// A phone day that has already ended changes nothing further, and with no mirror at all only the
    /// watch's own pours can move — either way, the watch's own midnight is all that is left.
    @Test
    func withNoPhoneDayStillRunningOnlyTheWatchsMidnightIsScheduled() {
        let now = Date(timeIntervalSince1970: 1_767_279_600) // 2026-01-01 15:00 UTC
        let ended = Self.mirror(
            phoneDayStart: Date(timeIntervalSince1970: 1_767_139_200), // 2025-12-31 00:00 UTC
            phoneDayEnd: Date(timeIntervalSince1970: 1_767_225_600)    // 2026-01-01 00:00 UTC
        )

        #expect(WristPlan.dayBoundaries(after: now, mirror: ended, calendar: Self.utc) == [Date(timeIntervalSince1970: 1_767_312_000)])
        #expect(WristPlan.dayBoundaries(after: now, mirror: nil, calendar: Self.utc) == [Date(timeIntervalSince1970: 1_767_312_000)])
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

    private static let utc = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "UTC")!; return c }()

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
            // C3: the truncation must drop the ids the watch retired long ago (yesterday's), never
            // the ones still sitting in its outbox (today's). Today's 256 ids alone already fill
            // the cap, so a correct newest-first sort keeps every one of them and none of
            // yesterday's; an ascending sort instead keeps all 10 of yesterday's and drops 10 of
            // today's, and the count alone cannot tell the two apart.
            #expect(Set(mirror.acked) == Set(todaysIds), "the cap must keep the newest day's ids, not the oldest")
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

    /// On a 25-hour day the phone's day ends at the next real midnight — not 24 hours after it began,
    /// which here would close the day an hour early and take the phone's total off the wrist at
    /// 23:00. New York, 1 November 2026: the clocks fall back at 02:00.
    @Test
    func aMirrorNamesTheMomentThePhonesDayEnds() {
        withTempDefaults { defaults in
            var newYork = Calendar(identifier: .gregorian)
            newYork.timeZone = TimeZone(identifier: "America/New_York")!
            let noon = Date(timeIntervalSince1970: 1_793_552_400) // 2026-11-01 12:00 EST

            let mirror = DataManager.composeWristMirror(from: defaults, calendar: newYork, now: noon)
            #expect(mirror.phoneDayEnd == Date(timeIntervalSince1970: 1_793_595_600)) // 2026-11-02 00:00 EST
        }
    }

    /// A mirror's total has to belong to the day the mirror names. A cache still holding yesterday's
    /// total — this process has not run the phone's own rollover yet — is sent as zero, exactly as
    /// `DataManager.snapshot` draws it on the phone's widget. Sent as-is, it would sit on the wrist
    /// all day under today's `phoneDayStart`, where no comparison of days could catch it.
    @Test
    func aMirrorNeverCarriesYesterdaysCachedTotalIntoToday() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_791_190_800) // 2026-10-05 09:00 UTC
            defaults.set(1_800, forKey: DataManager.Key.currentWater)

            defaults.set(20_261_004, forKey: DataManager.Key.lastActiveDay)
            let stale = DataManager.composeWristMirror(from: defaults, calendar: Self.utc, now: now)
            #expect(stale.currentWater == 0, "stamped yesterday, so it is yesterday's water")

            defaults.set(20_261_005, forKey: DataManager.Key.lastActiveDay)
            let fresh = DataManager.composeWristMirror(from: defaults, calendar: Self.utc, now: now)
            #expect(fresh.currentWater == 1_800, "stamped today, the same figure is today's and goes as it is")
        }
    }
}

/// When a mirror tells the watch something the last one did not — the one test the phone uses to
/// decide a complication push and the watch uses to decide a reload
/// (`docs/superpowers/specs/2026-10-07-complication-current-design.md` §4.6). Not `@MainActor`, for
/// `WristWireTests`' reason: a mirror is a plain value with no isolation.
struct WristMirrorNewsTests {

    private static let ackedId = UUID(uuidString: "6A0B6C8E-2F55-4E27-9C3B-6F1E0B7D1A20")!

    /// Every field a literal, so a test that changes one can name exactly which.
    private static func mirror(
        schemaVersion: Int = WristMirror.currentSchemaVersion,
        currentWater: Int = 500,
        dailyGoal: Int = 2_000,
        servings: [Int] = [150, 250, 500],
        languageCode: String? = nil,
        isGoalSet: Bool = true,
        composedAt: Date = Date(timeIntervalSince1970: 1_000),
        phoneDayStart: Date = Date(timeIntervalSince1970: 0),
        phoneDayEnd: Date? = Date(timeIntervalSince1970: 86_400),
        acked: [UUID] = [WristMirrorNewsTests.ackedId]
    ) -> WristMirror {
        WristMirror(
            schemaVersion: schemaVersion, currentWater: currentWater, dailyGoal: dailyGoal,
            servings: servings, languageCode: languageCode, isGoalSet: isGoalSet, composedAt: composedAt,
            phoneDayStart: phoneDayStart, phoneDayEnd: phoneDayEnd, acked: acked
        )
    }

    /// When a republish of the same state is composed: a minute after the base mirror.
    private static let aMinuteLater = Date(timeIntervalSince1970: 1_060)

    @Test
    func theFirstMirrorEverSentIsNews() {
        #expect(Self.mirror().isNews(since: nil))
    }

    /// `refresh()` republishes on every foreground and every tab appearance. Counted as news, each of
    /// those would spend a complication push, and a reload on the wrist, on "synced at" alone.
    @Test
    func aMirrorDifferingOnlyInWhenItWasComposedIsNotNews() {
        #expect(!Self.mirror(composedAt: Self.aMinuteLater).isNews(since: Self.mirror()))
    }

    /// Field by field, so a re-stamp that took any one value from the wrong mirror fails here by name.
    @Test
    func aChangeToAnyOtherFieldIsNews() {
        let base = Self.mirror()
        let later = Self.aMinuteLater
        #expect(Self.mirror(schemaVersion: 2, composedAt: later).isNews(since: base), "schemaVersion")
        #expect(Self.mirror(currentWater: 750, composedAt: later).isNews(since: base), "currentWater")
        #expect(Self.mirror(dailyGoal: 2_500, composedAt: later).isNews(since: base), "dailyGoal")
        #expect(Self.mirror(servings: [150, 300, 500], composedAt: later).isNews(since: base), "servings")
        #expect(Self.mirror(languageCode: "ru", composedAt: later).isNews(since: base), "languageCode")
        #expect(Self.mirror(isGoalSet: false, composedAt: later).isNews(since: base), "isGoalSet")
        #expect(Self.mirror(composedAt: later, phoneDayStart: Date(timeIntervalSince1970: 3_600)).isNews(since: base), "phoneDayStart")
        #expect(Self.mirror(composedAt: later, phoneDayEnd: Date(timeIntervalSince1970: 90_000)).isNews(since: base), "phoneDayEnd")
        #expect(Self.mirror(composedAt: later, acked: []).isNews(since: base), "acked")
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
            composedAt: .now, phoneDayStart: .now, phoneDayEnd: .now, acked: []
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

/// Compile-time reachability check, the same honest framing `WristLinkChunkingTests`/
/// `WristLinkDecodingTests` above already use ("proven to compile, not proven correct") —
/// **not** a regression canary for `WristLink`'s `nonisolated` keyword, despite an earlier
/// version of this comment claiming otherwise. Three separate techniques were tried empirically
/// against this exact toolchain, with and without the keyword present, looking for any compiler
/// diagnostic that distinguishes the two states: an unapplied reference to `activate()`, a direct
/// synchronous call to `activate()`, and — as a control, ruling out something specific to
/// `WristLink` itself — reading a plain `static let Notification.Name` the identical shape as
/// `didReceiveBatchNotification` on a freshly-added, otherwise-unrelated `NSObject` subclass. All
/// three produced **zero** warnings and **zero** errors in every configuration, including with the
/// keyword removed. The likely cause is `SWIFT_APPROACHABLE_CONCURRENCY = YES`, set on every
/// target alongside `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, which is documented to relax
/// several categories of exactly this diagnostic — but that is inference about the compiler's
/// behaviour, not proof the underlying isolation is safe to leave unmarked. The keyword stays, on
/// the same reasoning as `Key.wristApplied`/`AppLanguage.code`/`vesselSlots`/
/// `WristModel.requestSend` and because `WCSession`'s own header is unambiguous that a delegate
/// callback lands off-main — it is simply not something this suite can currently prove will
/// regress loudly if removed. A future toolchain or build-setting change may make that provable
/// again; if so, replace this test with one that actually fails without the keyword, rather than
/// trusting this comment's account of what did not work.
struct WristLinkReachabilityTests {
    @Test
    func wristLinkIsReachableFromANonMainActorContext() {
        let name = WristLink.didReceiveBatchNotification
        #expect(name.rawValue == "sardor.WaterBuddy.wristLink.didReceiveBatch")
    }
}
