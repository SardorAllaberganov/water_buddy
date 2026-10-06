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

    /// 1970-01-02 00:00 UTC — where the phone's day ends for every fixture whose `now` is 1,000 s in.
    private static let endOfFirstDay = Date(timeIntervalSince1970: 86_400)

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
                composedAt: now, phoneDayStart: Self.utc.startOfDay(for: now), phoneDayEnd: Self.endOfFirstDay,
                acked: [pouredId]
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
                composedAt: now, phoneDayStart: Self.utc.startOfDay(for: now), phoneDayEnd: Self.endOfFirstDay,
                acked: []
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
                composedAt: yesterday, phoneDayStart: Self.utc.startOfDay(for: yesterday),
                phoneDayEnd: Date(timeIntervalSince1970: -86_400), // 1969-12-31 00:00 UTC, before `today` began
                acked: []
            ))
            #expect(model.isMirrorStale == true)
            // Reversed on 2026-10-05 at the owner's ruling (spec §17). This read `todaysTotal == 1_800`,
            // "the number is still shown" — which is how a phone that slept through midnight left
            // yesterday's water on the wrist all morning. The guarantee that sentence protected — no
            // false zero while the phone's own day is still running — is now pinned by
            // `WristPlanTests.aWatchAheadOfThePhoneKeepsThePhonesTotalUntilThePhonesDayEnds`.
            #expect(model.todaysTotal == 0, "the phone's own day has ended, so its 1,800 is not today's water")
        }
    }

    /// Known issue #26's fix end to end through the model: one persisted mirror, read one second
    /// either side of the phone's day end, by two models over the same suite (the clock is fixed per
    /// model). The phone keeps UTC−5, so its day ends five hours after the watch's own midnight —
    /// the fallback a lost `phoneDayEnd` would use — and `evening` reading 1,800 is what proves the
    /// persisted day end, not the fallback, decided it.
    @Test
    func theWatchCountsThePhonesTotalUntilThePhonesDayEnds() {
        withTempDefaults { defaults in
            let phonesDayEnd = Date(timeIntervalSince1970: 104_400) // 1970-01-02 00:00 at UTC−5, 05:00 UTC
            let evening = makeModel(defaults, now: { phonesDayEnd.addingTimeInterval(-1) })
            evening.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 1_800, dailyGoal: 2_000,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: Date(timeIntervalSince1970: 50_000),
                phoneDayStart: Date(timeIntervalSince1970: 18_000), // 1970-01-01 00:00 at UTC−5
                phoneDayEnd: phonesDayEnd, acked: []
            ))
            #expect(evening.todaysTotal == 1_800)

            let morning = makeModel(defaults, now: { phonesDayEnd })
            #expect(morning.todaysTotal == 0, "the phone's day is over, so its 1,800 is yesterday's water")
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
                phoneDayStart: Self.utc.startOfDay(for: Date(timeIntervalSince1970: 1_000)),
                phoneDayEnd: Self.endOfFirstDay, acked: []
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
