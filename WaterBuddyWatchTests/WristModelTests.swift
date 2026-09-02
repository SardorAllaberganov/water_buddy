//
//  WristModelTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

@MainActor
struct WristModelTests {

    private static let utc = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "UTC")!; return c }()

    private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
        let name = "test.waterbuddywatch.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name); UserDefaults.standard.removeSuite(named: name) }
        return try body(defaults)
    }

    private func makeModel(_ defaults: UserDefaults, now: @escaping () -> Date, sent: @escaping ([WristPour]) -> Void = { _ in }) -> WristModel {
        WristModel(defaults: defaults, calendar: Self.utc, now: now, send: sent)
    }

    @Test
    func withNoMirrorYetTotalIsJustTheOutbox() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { now })
            model.pour(amount: 250)
            #expect(model.todaysTotal == 250)
        }
    }

    @Test
    func pouringAppendsToTheOutboxAndCallsSend() {
        withTempDefaults { defaults in
            var sent: [WristPour] = []
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) }, sent: { sent.append(contentsOf: $0) })
            model.pour(amount: 150)
            #expect(sent.map(\.amount) == [150])
        }
    }

    /// I5: a pour must hand the transport the **whole current outbox**, not just the newest pour —
    /// or a dropped/stranded pour is lost silently, and the multi-chunk path
    /// (`WristLink.chunk(_:batchId:)`, >64 pours) never actually exercises in production. Sending
    /// only `[pour]` each time would leave every earlier un-acked pour permanently un-resent,
    /// because nothing else in this design ever retries on its own.
    @Test
    func pouringASecondTimeResendsTheWholeOutboxNotJustTheNewestPour() {
        withTempDefaults { defaults in
            var sent: [[WristPour]] = []
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) }, sent: { sent.append($0) })
            model.pour(amount: 150)
            model.pour(amount: 250)
            #expect(sent.last?.map(\.amount) == [150, 250], "the second send must carry the first, still-unacked pour along with the new one")
        }
    }

    @Test
    func applyingAMirrorRetiresAckedPoursFromTheOutbox() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { now })
            model.pour(amount: 250)
            let pouredId = model.pendingOutbox.first!.id

            model.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 250, dailyGoal: 2_000,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: now, phoneDayStart: Self.utc.startOfDay(for: now), acked: [pouredId]
            ))

            #expect(model.pendingOutbox.isEmpty)
            #expect(model.todaysTotal == 250, "the mirror's own total now carries it, not the outbox")
        }
    }

    @Test
    func anUnackedPourStaysInTheOutboxAcrossAMirrorUpdate() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { now })
            model.pour(amount: 150) // never acked below

            model.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 500, dailyGoal: 2_000,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: now, phoneDayStart: Self.utc.startOfDay(for: now), acked: []
            ))

            #expect(model.pendingOutbox.count == 1)
            #expect(model.todaysTotal == 650, "mirror's 500 plus the still-unacked 150")
        }
    }

    @Test
    func isMirrorStaleWhenThePhonesDayDisagreesWithTheWatchsOwnDay() {
        withTempDefaults { defaults in
            let today = Date(timeIntervalSince1970: 1_000)
            let yesterday = today.addingTimeInterval(-90_000)
            let model = makeModel(defaults, now: { today })
            model.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 1_800, dailyGoal: 2_000,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: yesterday, phoneDayStart: Self.utc.startOfDay(for: yesterday), acked: []
            ))
            #expect(model.isMirrorStale == true)
            #expect(model.todaysTotal == 1_800, "never a confident zero — the number is still shown")
        }
    }

    @Test
    func stateSurvivesReconstruction() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let first = makeModel(defaults, now: { now })
            first.pour(amount: 250)

            let second = makeModel(defaults, now: { now })
            #expect(second.pendingOutbox.map(\.amount) == [250], "the outbox is persisted, not just in-memory")
        }
    }

    // MARK: - Standalone operation before the first sync

    /// The watch draws a real screen before it has ever heard from the phone, so it needs a goal to
    /// draw against. `DataManager.defaultDailyGoal` is the same figure the phone itself materialises
    /// for a fresh install, so the two agree the moment a mirror does arrive.
    @Test
    func withNoMirrorTheGoalFallsBackToTheSharedDefault() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            #expect(model.mirror == nil)
            #expect(model.displayGoal == DataManager.defaultDailyGoal)
        }
    }

    @Test
    func aMirrorsOwnGoalWinsOverTheDefault() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: 3_500,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: Date(timeIntervalSince1970: 1_000),
                phoneDayStart: Self.utc.startOfDay(for: Date(timeIntervalSince1970: 1_000)), acked: []
            ))
            #expect(model.displayGoal == 3_500)
        }
    }

    /// The deadlock this breaks: the only watch-side action that makes the phone publish is a pour,
    /// and the pour rows used to sit behind a gate that required a mirror to open. A pour authored
    /// before any sync must be recorded and survive, so it can ride along the moment the phone appears.
    @Test
    func aPourAuthoredBeforeAnySyncIsRecordedAndPersisted() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { now })
            #expect(model.mirror == nil, "precondition: never synced")

            model.pour(amount: 250)

            #expect(model.todaysTotal == 250)
            #expect(model.displayGoal == DataManager.defaultDailyGoal)
            #expect(makeModel(defaults, now: { now }).pendingOutbox.map(\.amount) == [250])
        }
    }
}
