//
//  DataManagerTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import Observation
import SwiftData
import SwiftUI
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private func gregorian(in timeZone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}

/// A Gregorian/UTC day, so a rollover test cannot flake on a machine sitting near local
/// midnight or in the middle of a DST transition.
private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// swift-testing runs `@Test` functions in parallel inside one process, so a shared suite
/// would let one test's water show up in another's assertions. Every test gets its own
/// freshly named suite, and names are never reused — `UserDefaults` caches domains in-process.
@MainActor
private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults)
}

@MainActor
private func makeManager(
    _ defaults: UserDefaults,
    calendar: Calendar = utcDay,
    onReload: @escaping () -> Void = {},
    onReschedule: @escaping ([ReminderPlan.Slot]) -> Void = { _ in },
    now: @escaping () -> Date
) -> DataManager {
    DataManager(
        defaults: defaults,
        // A fresh in-memory store per manager, for exactly the reason each one gets a
        // UUID-named `UserDefaults` suite: `@Test` functions run in parallel in one process.
        //
        // This is not optional. `DataManager.sharedModelContainer` resolves the *real* App Group
        // store, so omitting it here would point every test in this file at live data and let
        // them see one another's rows (rule `85-testing`).
        modelContainer: inMemoryContainer(),
        calendar: calendar,
        now: now,
        reloadWidgets: onReload,
        rescheduleReminders: onReschedule
    )
}

/// A throwaway SwiftData store that never touches disk.
private func inMemoryContainer() -> ModelContainer {
    try! ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
}

/// `withObservationTracking`'s `onChange` is `@Sendable`, so the tally needs a reference box.
private final class Counter: @unchecked Sendable {
    var count = 0
}

// MARK: - Tests

@MainActor
struct DataManagerTests {

    // MARK: Defaults

    @Test func defaultGoalIs2000WhenTheSuiteIsEmpty() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            #expect(manager.dailyGoal == 2000)
        }
    }

    @Test func defaultCurrentWaterIsZeroWhenTheSuiteIsEmpty() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            #expect(manager.currentWater == 0)
            #expect(manager.progress == 0)
        }
    }

    /// **Every key the product actually writes is on ``DataManager/Key/all``.**
    ///
    /// The roster is what both widget read-path tripwires — `readingLeavesTheStoreUntouched` and
    /// `readingAnEmptySuiteDoesNotCreateKeys` — enumerate, so a key missing from it is a key those
    /// two are structurally blind to.
    ///
    /// `theTripwireHelperEnumeratesEveryStoredKey` was supposed to be this guarantee and is not.
    /// Its helper *is* `Key.all.reduce(…)` (`WaterSnapshotTests.swift:40-43`), so its assertion
    /// reduces to `Set(Key.all) == Set(Key.all)` and **cannot fail for any content of the roster**
    /// — declare a key, use it in production, forget the roster, and both sides shrink together
    /// while the test stays green. Its own DocC claims it "fails the moment the two disagree";
    /// they cannot disagree.
    ///
    /// This test asks the opposite question, and asks it of the **suite** rather than the roster:
    /// drive the real writers, read back every `sardor.WaterBuddy.` key that actually landed, and
    /// require the roster to contain it. It fails when a new key reaches the store without joining
    /// `Key.all`, which is the failure the roster exists to prevent.
    ///
    /// Lives here rather than beside the helper because it must construct a `DataManager`, and
    /// `WaterSnapshotTests` is deliberately not `@MainActor` (rule `85-testing`).
    @Test func everyKeyTheProductWritesIsOnTheRoster() throws {
        try withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28, 12) }

            // Every public mutator that persists, plus the one-shot migration — which is
            // `nonisolated static` and takes both suites, so it is drivable without going
            // anywhere near the real group (rule `85-testing`).
            manager.saveDailyGoal(ml: 2_500)          // dailyGoal, isGoalSet
            manager.servings = [200, 300, 600]        // servings
            manager.language = .russian                    // language
            manager.remindersEnabled = true           // remindersEnabled
            manager.addLog(amount: 250)               // currentWater
            _ = manager.resetIfNeeded()               // lastActiveDay

            let sourceName = "test.waterbuddy.\(UUID().uuidString)"
            let source = try #require(UserDefaults(suiteName: sourceName))
            defer {
                source.removePersistentDomain(forName: sourceName)
                UserDefaults.standard.removeSuite(named: sourceName)
            }
            DataManager.migrateIfNeeded(from: source, into: defaults)   // didMigrateFromStandard

            let live = defaults.dictionaryRepresentation().keys
                .filter { $0.hasPrefix("sardor.WaterBuddy.") }
            let unrostered = Set(live).subtracting(DataManager.Key.all).sorted()

            #expect(
                unrostered.isEmpty,
                "these reached the suite without joining Key.all, so both read-path tripwires are blind to them — \(unrostered)"
            )
            // Guards the guard: if the writers above stopped writing, the subtraction above would
            // be vacuously empty and this test would pass while proving nothing.
            #expect(live.count >= 7, "only \(live.count) keys landed — the writers above are not exercising the store")
        }
    }

    /// A widget process reads the plist directly, so the goal must exist on disk — not only
    /// in this instance's memory."""
    @Test func initMaterialisesTheDefaultGoalIntoTheSuite() {
        withTempDefaults { defaults in
            _ = makeManager(defaults) { utc(2026, 8, 28) }
            #expect(defaults.object(forKey: DataManager.Key.dailyGoal) as? Int == 2000)
        }
    }

    // MARK: Adding and removing

    @Test func addWaterAccumulatesAndWritesThrough() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.addWater(amount: 250)
            manager.addWater(amount: 250)

            #expect(manager.currentWater == 500)
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 500)
        }
    }

    @Test func addWaterIgnoresZeroAndNegativeAmounts() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.addWater(amount: 500)
            manager.addWater(amount: 0)
            manager.addWater(amount: -500)

            #expect(manager.currentWater == 500)
        }
    }

    @Test func addWaterSaturatesInsteadOfTrapping() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.addWater(amount: .max)
            manager.addWater(amount: .max)

            #expect(manager.currentWater == DataManager.maximumDailyIntake)
        }
    }

    @Test func removeWaterSubtractsAndFloorsAtZero() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.addWater(amount: 500)
            manager.removeWater(amount: 200)
            #expect(manager.currentWater == 300)

            manager.removeWater(amount: 9_999)
            #expect(manager.currentWater == 0)
        }
    }

    // MARK: Progress

    @Test(arguments: zip([0, 500, 2000, 3000], [0.0, 0.25, 1.0, 1.0]))
    func progressMath(water: Int, expected: Double) {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.addWater(amount: water)

            #expect(manager.progress == expected)
        }
    }

    @Test func progressUnclampedExceedsOneOnOverachievement() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.addWater(amount: 3000)

            #expect(manager.progressUnclamped == 1.5)
            #expect(manager.progress == 1.0)
        }
    }

    /// A `0` goal written by an older build (or `integer(forKey:)` on a missing key) must not
    /// divide by zero or make the first sip read as 100%.
    @Test func aCorruptZeroGoalFallsBackToTheDefault() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            defaults.set(0, forKey: DataManager.Key.dailyGoal)   // behind the setter's back
            manager.refresh()
            manager.addWater(amount: 500)

            #expect(manager.dailyGoal == 2000)
            #expect(manager.progress == 0.25)
            #expect(manager.progress.isFinite)
        }
    }

    // MARK: Goal

    @Test func dailyGoalRejectsNonPositiveValues() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.dailyGoal = 0
            #expect(manager.dailyGoal == 1)

            manager.dailyGoal = -100
            #expect(manager.dailyGoal == 1)
        }
    }

    @Test func settingDailyGoalPersistsToTheSuite() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.dailyGoal = 3000

            #expect(defaults.integer(forKey: DataManager.Key.dailyGoal) == 3000)
        }
    }

    // MARK: Daily rollover

    @Test func resetsWhenTheStoredDayIsYesterday() {
        withTempDefaults { defaults in
            let yesterday = makeManager(defaults) { utc(2026, 8, 27, 9) }
            yesterday.addWater(amount: 750)
            #expect(yesterday.currentWater == 750)

            let today = makeManager(defaults) { utc(2026, 8, 28, 9) }
            #expect(today.currentWater == 0)
        }
    }

    @Test func doesNotResetWithinTheSameDay() {
        withTempDefaults { defaults in
            let morning = makeManager(defaults) { utc(2026, 8, 28, 9) }
            morning.addWater(amount: 750)

            let evening = makeManager(defaults) { utc(2026, 8, 28, 23) }
            #expect(evening.currentWater == 750)
        }
    }

    @Test func dailyGoalSurvivesTheDailyReset() {
        withTempDefaults { defaults in
            let dayOne = makeManager(defaults) { utc(2026, 8, 27) }
            dayOne.dailyGoal = 3000
            dayOne.addWater(amount: 900)

            let dayTwo = makeManager(defaults) { utc(2026, 8, 28) }
            #expect(dayTwo.currentWater == 0)
            #expect(dayTwo.dailyGoal == 3000)
        }
    }

    /// The app left open past midnight: the next tap must start a new day, not top up
    /// yesterday's total.
    @Test func rollsOverMidSessionOnAddWater() {
        withTempDefaults { defaults in
            var clock = utc(2026, 8, 28, 23)
            let manager = makeManager(defaults) { clock }
            manager.addWater(amount: 500)

            clock = utc(2026, 8, 29, 1)
            manager.addWater(amount: 250)

            #expect(manager.currentWater == 250)
        }
    }

    @Test func rollsOverOnRefresh() {
        withTempDefaults { defaults in
            var clock = utc(2026, 8, 28, 23)
            let manager = makeManager(defaults) { clock }
            manager.addWater(amount: 500)

            clock = utc(2026, 8, 29, 1)
            manager.refresh()

            #expect(manager.currentWater == 0)
        }
    }

    @Test func resetIfNeededReportsRolloverAndIsIdempotent() {
        withTempDefaults { defaults in
            var clock = utc(2026, 8, 28, 9)
            let manager = makeManager(defaults) { clock }
            manager.addWater(amount: 500)

            #expect(manager.resetIfNeeded() == false)
            #expect(manager.currentWater == 500)

            clock = utc(2026, 8, 29, 9)
            #expect(manager.resetIfNeeded() == true)
            #expect(manager.resetIfNeeded() == false)
            #expect(manager.currentWater == 0)
        }
    }

    @Test func resetDailyProgressZeroesMidDayWithoutTouchingTheGoal() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28, 10) }
            manager.dailyGoal = 3000
            manager.addWater(amount: 750)

            manager.resetDailyProgress()

            #expect(manager.currentWater == 0)
            #expect(manager.dailyGoal == 3000)
        }
    }

    /// Upgrading from a build that never stamped a day must not look like a reset.
    @Test func aMissingDayMarkerAdoptsTodayWithoutResetting() {
        withTempDefaults { defaults in
            defaults.set(400, forKey: DataManager.Key.currentWater)

            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            #expect(manager.currentWater == 400)
            #expect(defaults.object(forKey: DataManager.Key.lastActiveDay) != nil)
        }
    }

    // MARK: Cross-process behaviour

    /// Stands in for a widget intent writing while the app was backgrounded.
    @Test func refreshPicksUpAnExternalWrite() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.addWater(amount: 100)

            defaults.set(900, forKey: DataManager.Key.currentWater)
            manager.refresh()

            #expect(manager.currentWater == 900)
        }
    }

    /// Stands in for a widget process reading what the app wrote.
    @Test func aSecondInstanceOverTheSameSuiteSeesPersistedValues() {
        withTempDefaults { defaults in
            let app = makeManager(defaults) { utc(2026, 8, 28) }
            app.dailyGoal = 2500
            app.addWater(amount: 600)

            let widget = makeManager(defaults) { utc(2026, 8, 28) }
            #expect(widget.currentWater == 600)
            #expect(widget.dailyGoal == 2500)
        }
    }

    @Test func mutationsRingTheWidgetDoorbellAndNoOpRefreshesDoNot() {
        withTempDefaults { defaults in
            var reloads = 0
            let manager = makeManager(defaults, onReload: { reloads += 1 }) { utc(2026, 8, 28) }

            manager.addWater(amount: 250)
            #expect(reloads == 1)

            manager.refresh()
            #expect(reloads == 1)
        }
    }

    // MARK: Calendar edge cases

    /// 00:30 EDT to 23:59 EST on the 25-hour fall-back day spans 24h29m. Interval maths
    /// against 86,400 seconds would call that a new day; a calendar comparison does not.
    @Test func theDayBoundaryHoldsAcrossADstTransition() {
        let newYork = gregorian(in: "America/New_York")

        let justAfterMidnight = newYork.date(
            from: DateComponents(year: 2025, month: 11, day: 2, hour: 0, minute: 30)
        )!
        let justBeforeMidnight = newYork.date(
            from: DateComponents(year: 2025, month: 11, day: 2, hour: 23, minute: 59)
        )!
        #expect(justBeforeMidnight.timeIntervalSince(justAfterMidnight) > 86_400)

        withTempDefaults { defaults in
            var clock = justAfterMidnight
            let manager = makeManager(defaults, calendar: newYork) { clock }
            manager.addWater(amount: 500)

            clock = justBeforeMidnight
            manager.addWater(amount: 250)

            #expect(manager.currentWater == 750)
        }
    }

    /// Flying an hour west must not destroy the day's water — the user's local date never
    /// changed. Storing the marker as an *instant* rather than a day ordinal used to re-read
    /// yesterday's local midnight as the day before, and silently wipe the total.
    @Test func travellingWestwardDoesNotWipeTheDay() {
        let paris = gregorian(in: "Europe/Paris")
        let london = gregorian(in: "Europe/London")
        let instant = paris.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 14))!

        withTempDefaults { defaults in
            let inParis = makeManager(defaults, calendar: paris) { instant }
            inParis.addWater(amount: 750)

            // The very same instant — 13:00 BST, still 28 August. Only the zone changed.
            let inLondon = makeManager(defaults, calendar: london) { instant }

            #expect(inLondon.currentWater == 750)
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 750)
        }
    }

    /// Flying far enough east that the local date genuinely advances *should* start a new day.
    @Test func travellingEastwardAcrossTheDateStartsANewDay() {
        let losAngeles = gregorian(in: "America/Los_Angeles")
        let tokyo = gregorian(in: "Asia/Tokyo")
        let logged = losAngeles.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 10))!
        let landed = logged.addingTimeInterval(4 * 60 * 60)   // 29 August in Tokyo

        withTempDefaults { defaults in
            let inLosAngeles = makeManager(defaults, calendar: losAngeles) { logged }
            inLosAngeles.addWater(amount: 750)

            let inTokyo = makeManager(defaults, calendar: tokyo) { landed }

            #expect(inTokyo.currentWater == 0)
        }
    }

    // MARK: SwiftUI observation

    // These are the reason `currentWater`/`dailyGoal` are hand-written computed properties over
    // `access(keyPath:)`/`withMutation(keyPath:)`. A plain computed property reading UserDefaults
    // would register nothing with the ObservationRegistrar: every assertion above would still
    // pass while the UI silently never redrew.

    @Test func addWaterInvalidatesObserversOfCurrentWater() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            let counter = Counter()
            withObservationTracking { _ = manager.currentWater } onChange: { counter.count += 1 }
            manager.addWater(amount: 250)

            #expect(counter.count == 1, "SwiftUI would never redraw after addWater")
        }
    }

    @Test func progressIsTrackedTransitivelyThroughCurrentWater() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            let counter = Counter()
            withObservationTracking { _ = manager.progress } onChange: { counter.count += 1 }
            manager.addWater(amount: 250)

            #expect(counter.count == 1, "a ProgressView bound to progress would never animate")
        }
    }

    @Test func progressIsTrackedTransitivelyThroughDailyGoal() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            let counter = Counter()
            withObservationTracking { _ = manager.progress } onChange: { counter.count += 1 }
            manager.dailyGoal = 3000

            #expect(counter.count == 1)
        }
    }

    @Test func noOpWritesAndRefreshesDoNotInvalidate() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.addWater(amount: 250)

            let counter = Counter()
            withObservationTracking { _ = manager.currentWater } onChange: { counter.count += 1 }
            manager.currentWater = 250   // same value
            manager.refresh()            // re-reads the same values

            #expect(counter.count == 0, "the view tree would churn on every foreground")
        }
    }

    @Test func theDailyResetInvalidatesObservers() {
        withTempDefaults { defaults in
            var clock = utc(2026, 8, 28)
            let manager = makeManager(defaults) { clock }
            manager.addWater(amount: 500)

            let counter = Counter()
            withObservationTracking { _ = manager.currentWater } onChange: { counter.count += 1 }
            clock = utc(2026, 8, 30)
            manager.refresh()

            #expect(counter.count == 1)
            #expect(manager.currentWater == 0)
        }
    }
}

// MARK: - Reminders

/// The seam only: that `DataManager` computes a plan and hands it out at the right moments.
/// What the plan *contains* is `ReminderPlanTests`, and what happens to it is
/// `NotificationManagerTests` — neither of which needs a `DataManager` at all.
@MainActor
struct ReminderSeamTests {

    // MARK: The stored flag

    @Test func remindersAreOffUntilTheUserAsks() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            #expect(manager.remindersEnabled == false)
            #expect(
                defaults.object(forKey: DataManager.Key.remindersEnabled) == nil,
                "an untouched install must not materialise the flag"
            )
        }
    }

    @Test func enablingRemindersWritesThroughToTheSharedSuite() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            manager.remindersEnabled = true

            #expect(manager.remindersEnabled)
            #expect(defaults.bool(forKey: DataManager.Key.remindersEnabled))
        }
    }

    @Test func enablingRemindersInvalidatesObservers() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            let counter = Counter()
            withObservationTracking { _ = manager.remindersEnabled } onChange: { counter.count += 1 }
            manager.remindersEnabled = true

            #expect(counter.count == 1, "the settings toggle would never redraw")
        }
    }

    @Test func settingTheSameValueTwiceDoesNotChurn() {
        withTempDefaults { defaults in
            var plans = 0
            let manager = makeManager(defaults, onReschedule: { _ in plans += 1 }) { utc(2026, 8, 28) }
            manager.remindersEnabled = true
            let after = plans

            manager.remindersEnabled = true

            #expect(plans == after, "a no-op write must not re-plan the day")
        }
    }

    // MARK: The seam fires

    @Test func togglingRemindersRePlansImmediately() {
        withTempDefaults { defaults in
            var latest: [ReminderPlan.Slot] = []
            let manager = makeManager(defaults, onReschedule: { latest = $0 }) { utc(2026, 8, 28, 12) }

            manager.remindersEnabled = true
            #expect(!latest.isEmpty, "turning reminders on must schedule something")

            manager.remindersEnabled = false
            #expect(latest.isEmpty, "turning reminders off must clear the plan")
        }
    }

    @Test func loggingWaterRePlansTheDay() {
        withTempDefaults { defaults in
            var plans = 0
            let manager = makeManager(defaults, onReschedule: { _ in plans += 1 }) { utc(2026, 8, 28, 12) }
            manager.remindersEnabled = true
            let after = plans

            manager.addWater(amount: 250)

            #expect(plans > after, "a serving must reschedule — that is the whole feature")
        }
    }

    /// Reaching the goal is the one case where the plan goes *empty* rather than shifting.
    @Test func reachingTheGoalEmptiesTodaysPlan() {
        withTempDefaults { defaults in
            var latest: [ReminderPlan.Slot] = []
            let manager = makeManager(defaults, onReschedule: { latest = $0 }) { utc(2026, 8, 28, 12) }
            manager.remindersEnabled = true

            manager.addWater(amount: manager.dailyGoal)

            #expect(latest.allSatisfy { $0.dayOrdinal != 20_260_828 }, "today must fall silent")
            #expect(!latest.isEmpty, "tomorrow must still be planned")
        }
    }

    /// `applyDailyReset` bypasses the `currentWater` setter and rings the widget doorbell by hand,
    /// so a hook hung only on the setter would miss midnight — the one schedule change that
    /// happens with nobody tapping.
    @Test func theDailyRolloverRePlans() {
        withTempDefaults { defaults in
            var clock = utc(2026, 8, 28, 12)
            var plans = 0
            let manager = makeManager(defaults, onReschedule: { _ in plans += 1 }) { clock }
            manager.remindersEnabled = true
            manager.addWater(amount: 2_000)
            let after = plans

            clock = utc(2026, 8, 29, 8)
            manager.refresh()

            #expect(plans > after, "the rollover must re-arm the new day")
        }
    }

    @Test func refreshRePlansSoAWidgetTapIsReconciledOnTheNextForeground() {
        withTempDefaults { defaults in
            var plans = 0
            let manager = makeManager(defaults, onReschedule: { _ in plans += 1 }) { utc(2026, 8, 28, 12) }
            manager.remindersEnabled = true
            let after = plans

            manager.refresh()

            #expect(plans > after)
        }
    }

    @Test func aDisabledManagerStillHandsOutAnEmptyPlanRatherThanSkippingTheCall() {
        withTempDefaults { defaults in
            var calls = 0
            var latest: [ReminderPlan.Slot] = [ReminderPlan.Slot(dayOrdinal: 1, hour: 9, fireDate: .distantPast)]
            let manager = makeManager(defaults, onReschedule: { calls += 1; latest = $0 }) { utc(2026, 8, 28, 12) }

            manager.addWater(amount: 250)

            #expect(calls > 0, "the call must still happen, or a stale schedule would survive being switched off")
            #expect(latest.isEmpty)
        }
    }

    // MARK: The goal is half of "goal reached"

    // `ReminderPlan` silences today once `currentWater >= dailyGoal`, so the plan depends on the
    // goal exactly as much as it depends on the water. While `saveDailyGoal(ml:)` ran once per
    // install — before any water existed — nothing could observe that. A goal the user can edit
    // from Settings makes it reachable, and these three are what keep the seam wired.

    @Test func raisingTheGoalPastAMetTotalRePlansToday() {
        withTempDefaults { defaults in
            var latest: [ReminderPlan.Slot] = []
            let manager = makeManager(defaults, onReschedule: { latest = $0 }) { utc(2026, 8, 28, 12) }
            manager.remindersEnabled = true
            manager.saveDailyGoal(ml: 1_500)
            manager.addWater(amount: 1_500)

            #expect(latest.allSatisfy { $0.dayOrdinal != 20_260_828 },
                    "1,500 of 1,500 is done, so today is silent")

            manager.saveDailyGoal(ml: 2_500)

            #expect(latest.contains { $0.dayOrdinal == 20_260_828 },
                    "raising the goal un-meets it — the rest of today has to come back")
        }
    }

    @Test func loweringTheGoalBelowTheTotalSilencesToday() {
        withTempDefaults { defaults in
            var latest: [ReminderPlan.Slot] = []
            let manager = makeManager(defaults, onReschedule: { latest = $0 }) { utc(2026, 8, 28, 12) }
            manager.remindersEnabled = true
            manager.saveDailyGoal(ml: 3_000)
            manager.addWater(amount: 1_500)

            #expect(latest.contains { $0.dayOrdinal == 20_260_828 }, "1,500 of 3,000 is not done")

            manager.saveDailyGoal(ml: 1_500)

            #expect(latest.allSatisfy { $0.dayOrdinal != 20_260_828 },
                    "the goal is met now — nagging for water already drunk is the bug this prevents")
            #expect(!latest.isEmpty, "tomorrow starts at zero and must still be planned")
        }
    }

    @Test func savingTheSameGoalTwiceDoesNotRePlan() {
        withTempDefaults { defaults in
            var plans = 0
            let manager = makeManager(defaults, onReschedule: { _ in plans += 1 }) { utc(2026, 8, 28, 12) }
            manager.remindersEnabled = true
            manager.saveDailyGoal(ml: 2_500)
            let after = plans

            manager.saveDailyGoal(ml: 2_500)

            #expect(plans == after,
                    "the setter's equality guard has to cover the re-plan exactly as it covers the doorbell")
        }
    }
}

// MARK: - The chosen language

/// The language is a **preference**, like `remindersEnabled` — settable, write-through, guarded,
/// and never materialised. Unlike the reminders flag it also rings the widget doorbell, because the
/// widget draws localised strings and would otherwise keep the old language until something else
/// happened to change.
@MainActor
struct LanguageSeamTests {

    @Test func theLanguageIsAbsentUntilTheUserPicksOne() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            #expect(manager.language == .system)
            #expect(defaults.object(forKey: DataManager.Key.language) == nil,
                    "an untouched install must not materialise a language")
        }
    }

    @Test func choosingALanguageWritesThroughToTheSharedSuite() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            manager.language = .russian

            #expect(manager.language == .russian)
            #expect(defaults.string(forKey: DataManager.Key.language) == "ru",
                    "a value that never reached disk is invisible to the widget")
        }
    }

    /// Going back to *Follow device* has to **remove** the key, not store a sentinel — the absence
    /// is the state (rule `25-shared-storage`).
    @Test func returningToTheDeviceLanguageClearsTheKey() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.language = .uzbek

            manager.language = .system

            #expect(manager.language == .system)
            #expect(defaults.object(forKey: DataManager.Key.language) == nil,
                    "\"follow the device\" was stored as a value instead of as an absence")
        }
    }

    @Test func choosingALanguageRingsTheWidgetDoorbellExactlyOnce() {
        withTempDefaults { defaults in
            var reloads = 0
            let manager = makeManager(defaults, onReload: { reloads += 1 }) { utc(2026, 8, 28) }

            manager.language = .russian
            #expect(reloads == 1, "the widget would keep drawing the old language")

            manager.language = .russian
            #expect(reloads == 1, "a no-op write must not churn the widget")
        }
    }

    @Test func choosingTheSameLanguageTwiceDoesNotChurnObservers() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.language = .russian

            let counter = Counter()
            withObservationTracking { _ = manager.language } onChange: { counter.count += 1 }
            manager.language = .russian

            #expect(counter.count == 0)
        }
    }

    /// Every string in the app is resolved through the bundle this points at, so nothing redraws
    /// unless observers are invalidated.
    @Test func changingTheLanguageInvalidatesObservers() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            let counter = Counter()
            withObservationTracking { _ = manager.language } onChange: { counter.count += 1 }
            manager.language = .uzbek

            #expect(counter.count == 1, "the whole UI would keep its old strings")
        }
    }

    @Test func refreshPicksUpALanguageChosenByAnotherProcess() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            defaults.set("uz", forKey: DataManager.Key.language)

            manager.refresh()

            #expect(manager.language == .uzbek)
        }
    }

    /// Fail soft, and say so in `DEBUG` (rule `75-diagnostics`): a corrupt code leaves the app on
    /// the device language rather than blank.
    @Test func aCorruptStoredCodeReadsAsTheDeviceLanguage() {
        withTempDefaults { defaults in
            defaults.set("klingon", forKey: DataManager.Key.language)

            #expect(makeManager(defaults) { utc(2026, 8, 28) }.language == .system)
        }
    }
}

// MARK: - The custom daily goal

@MainActor
struct DailyGoalSetupTests {

    // MARK: Before setup

    @Test func aFreshInstallHasNotSetAGoalAndFallsBackTo2000() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            #expect(manager.isGoalSet == false)
            #expect(manager.dailyGoal == DataManager.defaultDailyGoal)
            #expect(manager.dailyGoal == 2000)
        }
    }

    /// `init` writes the resolved goal into the suite so a widget never reads a missing key as
    /// zero — which is exactly why "the goal key exists" cannot stand in for "the user chose it".
    @Test func theMaterialisedGoalDoesNotCountAsHavingBeenSet() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            #expect(defaults.object(forKey: DataManager.Key.dailyGoal) as? Int == 2000)
            #expect(manager.isGoalSet == false, "setup would be skipped for someone who never did it")
        }
    }

    @Test func aFreshInstallWritesNoGoalSetFlagAtAll() {
        withTempDefaults { defaults in
            _ = makeManager(defaults) { utc(2026, 8, 28) }

            #expect(defaults.object(forKey: DataManager.Key.isGoalSet) == nil,
                    "materialising `false` would destroy the upgrade inference")
        }
    }

    // MARK: Saving

    @Test func saveDailyGoalStoresTheAmountAndCompletesSetup() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.saveDailyGoal(ml: 3000)

            #expect(manager.dailyGoal == 3000)
            #expect(manager.isGoalSet)
            #expect(defaults.integer(forKey: DataManager.Key.dailyGoal) == 3000)
            #expect(defaults.bool(forKey: DataManager.Key.isGoalSet))
        }
    }

    /// Choosing 2,000 on purpose is still a choice. Treating it as "no choice" would ask this
    /// user again on every launch.
    @Test func choosingTheDefaultAmountStillCompletesSetup() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.saveDailyGoal(ml: DataManager.defaultDailyGoal)

            #expect(manager.dailyGoal == 2000)
            #expect(manager.isGoalSet)
            #expect(defaults.bool(forKey: DataManager.Key.isGoalSet))
        }
    }

    /// The second call is the one `SettingsView` makes, and it walks a path setup never did:
    /// `saveDailyGoal(ml:)` with the flag **already** true.
    ///
    /// The amount has to move and the flag has to hold still — and holding still means not
    /// invalidating either, because a spurious `isGoalSet` mutation would flip `WaterBuddyApp`'s
    /// root gate and animate the whole app back through setup for a user editing a number.
    @Test func editingTheGoalAfterSetupLeavesSetupComplete() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.saveDailyGoal(ml: 1_500)

            let counter = Counter()
            withObservationTracking { _ = manager.isGoalSet } onChange: { counter.count += 1 }
            manager.saveDailyGoal(ml: 2_500)

            #expect(manager.dailyGoal == 2_500)
            #expect(manager.isGoalSet, "a later edit must never send the user back through setup")
            #expect(defaults.integer(forKey: DataManager.Key.dailyGoal) == 2_500)
            #expect(counter.count == 0, "setup did not change, so nothing observing the flag should redraw")
        }
    }

    /// The upgrade path's flag is **inferred, never stored** — and an inference is re-derived from
    /// the goal on every read.
    ///
    /// `anExistingCustomGoalCountsAsSetEvenWithNoFlag` pins the inference itself: a stored goal that
    /// differs from ``DataManager/defaultDailyGoal`` can only have come from the user, so setup is
    /// complete even with no flag on disk. What that leaves is a state where `isGoalSet` is `true`
    /// and `Key.isGoalSet` is *absent*, and those are not the same fact — the second is what the
    /// next `resolveIsGoalSet` actually reads.
    ///
    /// So editing the goal down to exactly the default has to **persist** the flag. Skipping the
    /// write because the in-memory value is already `true` destroys the only evidence of the
    /// choice: the next read infers `2_000 != 2_000` = `false` and `RootView` cross-fades the whole
    /// app back into setup, mid-session.
    ///
    /// Unreachable until `SettingsView` gained `GoalCard`: `saveDailyGoal(ml:)` was called only
    /// from `GoalSetupView`, which is presented only while the flag is `false`, so the guard could
    /// never short-circuit.
    @Test func editingAnInferredGoalDownToTheDefaultPersistsTheFlag() {
        withTempDefaults { defaults in
            // A build from before the flag existed: a custom goal, and no flag at all.
            defaults.set(3_000, forKey: DataManager.Key.dailyGoal)

            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            #expect(manager.isGoalSet, "a non-default stored goal can only have come from the user")
            #expect(defaults.object(forKey: DataManager.Key.isGoalSet) == nil,
                    "the flag is inferred here, not stored — that is the whole premise")

            manager.saveDailyGoal(ml: DataManager.defaultDailyGoal)

            #expect(defaults.object(forKey: DataManager.Key.isGoalSet) as? Bool == true,
                    "the inference dies the moment the goal equals the default, so the flag has to reach disk")
            #expect(manager.isGoalSet)

            // Mid-session: any foreground, or either tab appearing, calls this.
            manager.refresh()
            #expect(manager.isGoalSet, "the app just cross-faded back into setup while the user watched")

            // And the next launch, which re-derives everything from the suite.
            #expect(makeManager(defaults) { utc(2026, 8, 28) }.isGoalSet,
                    "this user is sent through setup on every launch for editing their goal")
        }
    }

    @Test(arguments: zip([0, -100, 999_999], [1, 1, DataManager.maximumDailyIntake]))
    func saveDailyGoalClampsLikeTheSetter(requested: Int, expected: Int) {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.saveDailyGoal(ml: requested)

            #expect(manager.dailyGoal == expected)
            #expect(manager.progress.isFinite, "a zero goal would divide by zero")
            #expect(manager.isGoalSet)
        }
    }

    @Test func aSavedGoalSurvivesTheDailyReset() {
        withTempDefaults { defaults in
            var clock = utc(2026, 8, 28)
            let dayOne = makeManager(defaults) { clock }
            dayOne.saveDailyGoal(ml: 3500)
            dayOne.addWater(amount: 900)

            clock = utc(2026, 8, 29)
            let dayTwo = makeManager(defaults) { clock }

            #expect(dayTwo.currentWater == 0)
            #expect(dayTwo.dailyGoal == 3500)
            #expect(dayTwo.isGoalSet)
        }
    }

    @Test func aSavedGoalIsVisibleToASecondProcess() {
        withTempDefaults { defaults in
            let app = makeManager(defaults) { utc(2026, 8, 28) }
            app.saveDailyGoal(ml: 2750)

            let widget = makeManager(defaults) { utc(2026, 8, 28) }
            #expect(widget.dailyGoal == 2750)
            #expect(widget.isGoalSet)
            #expect(DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28)).dailyGoal == 2750)
        }
    }

    // MARK: Upgrading from a build that had no flag

    /// Someone who already picked 3,000 must not be sent back through setup by an update that
    /// merely introduced the flag.
    @Test func anExistingCustomGoalCountsAsSetEvenWithNoFlag() {
        withTempDefaults { defaults in
            defaults.set(3000, forKey: DataManager.Key.dailyGoal)
            defaults.set(20_260_828, forKey: DataManager.Key.lastActiveDay)

            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            #expect(manager.dailyGoal == 3000)
            #expect(manager.isGoalSet, "this user would be asked to set a goal they already set")
        }
    }

    /// The genuinely ambiguous case: a stored 2,000 could be the materialised default or a
    /// deliberate choice. Asking once is the safe reading.
    @Test func anExistingDefaultGoalWithNoFlagCountsAsUnset() {
        withTempDefaults { defaults in
            defaults.set(2000, forKey: DataManager.Key.dailyGoal)
            defaults.set(20_260_828, forKey: DataManager.Key.lastActiveDay)

            #expect(makeManager(defaults) { utc(2026, 8, 28) }.isGoalSet == false)
        }
    }

    /// An explicit `false` must win over the inference, so a user who is mid-setup with a custom
    /// goal already written is not treated as finished.
    @Test func anExplicitFlagBeatsTheInference() {
        withTempDefaults { defaults in
            defaults.set(3000, forKey: DataManager.Key.dailyGoal)
            defaults.set(false, forKey: DataManager.Key.isGoalSet)

            #expect(makeManager(defaults) { utc(2026, 8, 28) }.isGoalSet == false)
        }
    }

    // MARK: Cross-process and observation

    @Test func refreshPicksUpAGoalSetByAnotherProcess() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            #expect(manager.isGoalSet == false)

            defaults.set(2600, forKey: DataManager.Key.dailyGoal)
            defaults.set(true, forKey: DataManager.Key.isGoalSet)
            manager.refresh()

            #expect(manager.dailyGoal == 2600)
            #expect(manager.isGoalSet)
        }
    }

    /// Without this the setup screen would never dismiss: the value would be right and the view
    /// would never be told to look again.
    @Test func completingSetupInvalidatesObserversOfIsGoalSet() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            let counter = Counter()
            withObservationTracking { _ = manager.isGoalSet } onChange: { counter.count += 1 }
            manager.saveDailyGoal(ml: 3000)

            #expect(counter.count == 1, "the setup screen would never dismiss")
        }
    }

    @Test func savingTheSameGoalTwiceDoesNotChurnObservers() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults) { utc(2026, 8, 28) }
            manager.saveDailyGoal(ml: 3000)

            let counter = Counter()
            withObservationTracking { _ = manager.isGoalSet } onChange: { counter.count += 1 }
            withObservationTracking { _ = manager.dailyGoal } onChange: { counter.count += 1 }
            manager.saveDailyGoal(ml: 3000)

            #expect(counter.count == 0)
        }
    }

    @Test func savingAGoalRingsTheWidgetDoorbellExactlyOnce() {
        withTempDefaults { defaults in
            var reloads = 0
            let manager = makeManager(defaults, onReload: { reloads += 1 }) { utc(2026, 8, 28) }

            manager.saveDailyGoal(ml: 3000)
            #expect(reloads == 1, "the widget still says 'of 2,000 ml'")

            manager.saveDailyGoal(ml: 3000)
            #expect(reloads == 1)
        }
    }

    // MARK: - The offered range

    // `GoalSetupView` offers a narrower range than the store clamps to, which is the right
    // shape — 1 ml and 100,000 ml are legal to store and absurd to offer. But the two numbers
    // are declared in different files, and nothing in the compiler notices when one moves.
    // These four pin the seams between them.

    @Test func theOfferedGoalRangeContainsTheDefault() {
        #expect(GoalSetupView.goalRange.contains(DataManager.defaultDailyGoal),
                "setup opens on the default; one outside the range clamps the slider somewhere the user never chose")
    }

    @Test func theDefaultGoalLandsOnASliderStep() {
        let offset = DataManager.defaultDailyGoal - GoalSetupView.goalRange.lowerBound
        #expect(offset % GoalSetupView.goalStep == 0,
                "the slider opens on the default and can only rest on a step, so one between two steps shifts on first touch")
    }

    @Test func theOfferedRangeIsAWholeNumberOfSteps() {
        let span = GoalSetupView.goalRange.upperBound - GoalSetupView.goalRange.lowerBound
        #expect(span % GoalSetupView.goalStep == 0,
                "a trailing part-step makes the maximum unreachable by dragging")
    }

    @Test(arguments: [\.lowerBound, \.upperBound] as [KeyPath<ClosedRange<Int>, Int>])
    func bothEndsOfTheOfferedRangeSurviveTheStorageClamp(end: KeyPath<ClosedRange<Int>, Int>) {
        withTempDefaults { defaults in
            let offered = GoalSetupView.goalRange[keyPath: end]
            let manager = makeManager(defaults) { utc(2026, 8, 28) }

            manager.saveDailyGoal(ml: offered)

            #expect(manager.dailyGoal == offered,
                    "an offered goal the store rewrites is a slider that lies")
            #expect(defaults.integer(forKey: DataManager.Key.dailyGoal) == offered)
        }
    }
}
