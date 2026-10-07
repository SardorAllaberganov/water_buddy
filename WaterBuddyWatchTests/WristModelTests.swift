//
//  WristModelTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Observation
import Testing
@testable import WaterBuddyWatch

/// `withObservationTracking`'s `onChange` is `@Sendable`, so the tally needs a reference box
/// (rule `85-testing`).
private final class Counter: @unchecked Sendable {
    var count = 0
}

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

    private func makeModel(
        _ defaults: UserDefaults, now: @escaping () -> Date,
        sent: @escaping ([WristPour]) -> Void = { _ in }, reloaded: @escaping () -> Void = {}
    ) -> WristModel {
        WristModel(defaults: defaults, calendar: Self.utc, now: now, send: sent, reloadComplication: reloaded)
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

    // MARK: - The language the watch draws in (spec 2026-10-06 §4.1)

    /// A mirror that differs from the ones above only in the language the phone chose.
    private static func mirror(language code: String?) -> WristMirror {
        let now = Date(timeIntervalSince1970: 1_000)
        return WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: 2_000,
            servings: [150, 250, 500], languageCode: code, isGoalSet: true,
            composedAt: now, phoneDayStart: utc.startOfDay(for: now), phoneDayEnd: endOfFirstDay,
            acked: []
        )
    }

    @Test
    func theWatchFollowsTheLanguageChosenOnThePhone() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(Self.mirror(language: "ru"))
            #expect(model.language == .russian)
        }
    }

    @Test
    func withNoMirrorTheWatchFollowsItsOwnLanguage() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            #expect(model.mirror == nil, "precondition: never synced")
            #expect(model.language == .system)
        }
    }

    /// `nil` is the phone saying *Follow device*. On the wrist that means the watch's own language,
    /// not the phone's — the two usually match, because watchOS mirrors the iPhone's language by
    /// default, but only the watch knows its own.
    @Test
    func aPhoneFollowingItsDeviceLeavesTheWatchOnItsOwn() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(Self.mirror(language: nil))
            #expect(model.language == .system)
        }
    }

    /// Review focus: whatever arrives on the wire, the watch never reaches for a bundle it doesn't
    /// have. `"system"` is a case name the phone never stores (rule `70-privacy`), `""` is what a
    /// corrupt encode would carry, and `"xx"` stands for a language a newer phone ships and this
    /// build does not.
    @Test(arguments: ["xx", "system", ""])
    func anUnrecognisedLanguageCodeFallsBackToTheWatchsOwn(code: String) {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(Self.mirror(language: code))
            #expect(model.language == .system)
        }
    }

    /// `WristRoot` re-injects the bundle only if Observation tells it the language moved. And —
    /// review focus — the switch runs both ways: a phone put back on *Follow device* hands the watch
    /// back its own language rather than leaving it on the last one it was told.
    @Test
    func aNewMirrorSwitchesTheLanguageForObservers() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            model.apply(Self.mirror(language: "ru"))

            let changes = Counter()
            withObservationTracking {
                _ = model.language
            } onChange: {
                changes.count += 1
            }
            model.apply(Self.mirror(language: "uz"))

            #expect(changes.count == 1)
            #expect(model.language == .uzbek)

            model.apply(Self.mirror(language: nil))
            #expect(model.language == .system)
        }
    }

    @Test
    func theChosenLanguageSurvivesARelaunch() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            makeModel(defaults, now: { now }).apply(Self.mirror(language: "ru"))
            let relaunched = makeModel(defaults, now: { now })
            #expect(relaunched.language == .russian,
                    "the language rides in the persisted mirror, so a relaunch keeps it")
        }
    }

    // MARK: - Keeping the face current (spec 2026-10-07)

    /// A mirror like the ones above, carrying `currentWater` and stamped `composedAt` — both inside the
    /// phone's first day, which ends at `endOfFirstDay`.
    private static func mirror(currentWater: Int, composedAt: Date) -> WristMirror {
        WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: currentWater, dailyGoal: 2_000,
            servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
            composedAt: composedAt, phoneDayStart: Date(timeIntervalSince1970: 0), phoneDayEnd: endOfFirstDay,
            acked: []
        )
    }

    /// Where the watch's clock stands in the reload tests: after every mirror they apply, as a
    /// received mirror ordinarily is.
    private static let afterward = Date(timeIntervalSince1970: 2_000)

    @Test
    func aPourReloadsTheComplication() {
        withTempDefaults { defaults in
            var reloads = 0
            let model = makeModel(defaults, now: { Self.afterward }, reloaded: { reloads += 1 })
            model.pour(amount: 250)
            #expect(reloads == 1)
        }
    }

    /// The face reads the outbox, and a refused pour never reaches it.
    @Test
    func aRefusedPourReloadsNothing() {
        withTempDefaults { defaults in
            var reloads = 0
            let model = makeModel(defaults, now: { Self.afterward }, reloaded: { reloads += 1 })
            model.pour(amount: 0)
            #expect(reloads == 0)
        }
    }

    @Test
    func aMirrorThatChangesTheTotalReloadsTheComplication() {
        withTempDefaults { defaults in
            var reloads = 0
            let model = makeModel(defaults, now: { Self.afterward }, reloaded: { reloads += 1 })
            model.apply(Self.mirror(currentWater: 500, composedAt: Date(timeIntervalSince1970: 1_000)))
            model.apply(Self.mirror(currentWater: 750, composedAt: Date(timeIntervalSince1970: 1_060)))
            #expect(reloads == 2)
        }
    }

    /// Every activation re-reads the context the watch already holds, and hands it to `apply(_:)`.
    @Test
    func theSameMirrorAppliedTwiceReloadsOnce() {
        withTempDefaults { defaults in
            var reloads = 0
            let model = makeModel(defaults, now: { Self.afterward }, reloaded: { reloads += 1 })
            let mirror = Self.mirror(currentWater: 500, composedAt: Date(timeIntervalSince1970: 1_000))
            model.apply(mirror)
            model.apply(mirror)
            #expect(reloads == 1)
        }
    }

    /// A republish of unchanged state still moves "synced at" on the screen, so it is taken. It spends
    /// none of the face's reloads, which from the background count against a daily budget.
    @Test
    func aMirrorNewOnlyInWhenItWasComposedReloadsNothing() {
        withTempDefaults { defaults in
            var reloads = 0
            let model = makeModel(defaults, now: { Self.afterward }, reloaded: { reloads += 1 })
            model.apply(Self.mirror(currentWater: 500, composedAt: Date(timeIntervalSince1970: 1_000)))
            let republished = Self.mirror(currentWater: 500, composedAt: Date(timeIntervalSince1970: 1_060))
            model.apply(republished)
            #expect(model.mirror == republished, "taken, so the caption moves")
            #expect(reloads == 1, "the first mirror's reload, and no second")
        }
    }

    /// A superseded push can land after the one that replaced it, and the context re-read at activation
    /// can lag a push. Taking either would put the face back a drink.
    @Test
    func aMirrorOlderThanTheOneHeldChangesNothing() {
        withTempDefaults { defaults in
            var reloads = 0
            let model = makeModel(defaults, now: { Self.afterward }, reloaded: { reloads += 1 })
            let newer = Self.mirror(currentWater: 750, composedAt: Date(timeIntervalSince1970: 1_060))
            model.apply(newer)
            model.apply(Self.mirror(currentWater: 500, composedAt: Date(timeIntervalSince1970: 1_000)))
            #expect(model.mirror == newer)
            #expect(reloads == 1, "the newer mirror's reload, and no second")
        }
    }

    /// The same composition can arrive by both lanes, a push and a context — and the language tests
    /// above apply three mirrors stamped alike.
    @Test
    func aMirrorComposedAtTheSameInstantIsTaken() {
        withTempDefaults { defaults in
            let model = makeModel(defaults, now: { Self.afterward })
            let instant = Date(timeIntervalSince1970: 1_000)
            model.apply(Self.mirror(currentWater: 500, composedAt: instant))
            model.apply(Self.mirror(currentWater: 750, composedAt: instant))
            #expect(model.mirror?.currentWater == 750)
        }
    }

    /// Paired devices' clocks differ a little, so a mirror can be stamped slightly ahead of the watch
    /// that receives it. That is no reason to let an older one replace it.
    @Test
    func aHeldMirrorSlightlyAheadOfTheWatchsClockStillBlocksAnOlderOne() {
        withTempDefaults { defaults in
            let watchNow = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { watchNow })
            model.apply(Self.mirror(currentWater: 750, composedAt: watchNow.addingTimeInterval(30)))
            model.apply(Self.mirror(currentWater: 500, composedAt: watchNow.addingTimeInterval(-60)))
            #expect(model.mirror?.currentWater == 750)
        }
    }

    /// A held mirror stamped an hour ahead of the watch's own clock means a clock was set back after it
    /// was composed. The phone's stamps no longer say which came last, and refusing everything older
    /// would freeze the face for as long as the clock was moved.
    @Test
    func aHeldMirrorFarAheadOfTheWatchsClockDoesNotBlockAnOlderOne() {
        withTempDefaults { defaults in
            let watchNow = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { watchNow })
            model.apply(Self.mirror(currentWater: 750, composedAt: watchNow.addingTimeInterval(3_600)))
            model.apply(Self.mirror(currentWater: 500, composedAt: watchNow))
            #expect(model.mirror?.currentWater == 500)
        }
    }
}
