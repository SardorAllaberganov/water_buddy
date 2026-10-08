//
//  ServingSeamTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 30/08/26.
//

import Foundation
import Observation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private func gregorian(in timeZone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}

private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
    let name = "test.waterbuddy.servings.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults)
}

private final class Counter: @unchecked Sendable {
    var count = 0
}

/// Every argument passed explicitly, diffed against `DataManager.init` by hand.
///
/// Grafted from `DataManagerTests.makeManager`. Every fixture in this target now passes all six —
/// the six sites that omitted `rescheduleReminders:` and reached a real `UNUserNotificationCenter`
/// were closed in the change that retired `docs/AI_CONTEXT.md` known issue #6, and the two files
/// that held them each carry a test that fails if the argument goes missing again.
@MainActor
private func makeManager(
    _ defaults: UserDefaults,
    onReload: @escaping () -> Void = {},
    now: @escaping () -> Date = { utc(2026, 8, 30) }
) -> DataManager {
    DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        calendar: utcDay,
        now: now,
        reloadWidgets: onReload,
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
}

// MARK: - Resolution

/// The read path for the three editable vessels.
///
/// **Deliberately not `@MainActor`.** `resolveServings(in:)` is `nonisolated static` and takes its
/// `UserDefaults` as a parameter, exactly like `resolveLanguage(in:)` — because the *widget* has to
/// reach it from a timeline provider that carries no isolation. If it ever grew a dependency on
/// instance state this suite would stop compiling, which is the warning wanted (rule `43-concurrency`).
///
/// Note the resolver is `nonisolated static` and **not** `private`, unlike `resolveDailyGoal` and
/// `resolveIsGoalSet`. Those two are unreachable from any test even under `@testable import`;
/// `resolveLanguage` is the precedent that can be tested, and this follows it.
struct ServingResolutionTests {

    @Test func anEmptySuiteResolvesToTheDefaultVessels() {
        withTempDefaults { defaults in
            #expect(DataManager.resolveServings(in: defaults) == DataManager.defaultServings)
            #expect(DataManager.defaultServings == [150, 250, 500])
            #expect(DataManager.defaultServings[1] == DataManager.defaultServing,
                    "the middle vessel is the one the widget draws and logs")
        }
    }

    @Test func aStoredTripleComesBackInTheOrderItWasWritten() {
        withTempDefaults { defaults in
            defaults.set([200, 330, 750], forKey: DataManager.Key.servings)

            #expect(DataManager.resolveServings(in: defaults) == [200, 330, 750],
                    "never sorted — sorting would move which vessel the widget follows")
        }
    }

    /// A short array casts to `[Int]` perfectly happily, so arity has to be checked by hand. This
    /// is the case a cast-only resolver would wave through, and it would then index [1] out of
    /// bounds or silently draw the wrong vessel.
    @Test func aTripleOfTheWrongLengthFallsBackWholesale() {
        for stored in [[250], [150, 250], [150, 250, 500, 750], [Int]()] {
            withTempDefaults { defaults in
                defaults.set(stored, forKey: DataManager.Key.servings)
                #expect(DataManager.resolveServings(in: defaults) == DataManager.defaultServings)
            }
        }
    }

    @Test func aNonIntegerElementFallsBackWholesale() {
        withTempDefaults { defaults in
            defaults.set([150, "not a number", 500], forKey: DataManager.Key.servings)
            #expect(DataManager.resolveServings(in: defaults) == DataManager.defaultServings)
        }
    }

    /// **The whole triple falls back, not the offending element.** This is deliberately *unlike*
    /// `resolveDailyGoal`, which rejects below its floor but clamps above its ceiling — an
    /// asymmetry that is fine for one scalar and wrong for a set. Repairing one element of a
    /// corrupt triple produces a row nobody authored: Cup 500, Glass 250, Bottle 500 is not a
    /// state any writer can reach, and it is worse than the honest defaults.
    @Test func anOutOfRangeElementFallsBackWholesale() {
        for stored in [[0, 250, 500], [150, -1, 500], [150, 250, DataManager.maximumDailyIntake + 1]] {
            withTempDefaults { defaults in
                defaults.set(stored, forKey: DataManager.Key.servings)
                #expect(DataManager.resolveServings(in: defaults) == DataManager.defaultServings,
                        "one bad element discards the triple rather than being repaired in place")
            }
        }
    }

    /// The read path may not create a key, which is what `readingAnEmptySuiteDoesNotCreateKeys`
    /// asserts for the snapshot as a whole. Pinned here too, because this resolver is the newest
    /// thing that could break it.
    @Test func resolvingAnAbsentKeyWritesNothing() {
        withTempDefaults { defaults in
            _ = DataManager.resolveServings(in: defaults)
            #expect(defaults.object(forKey: DataManager.Key.servings) == nil)
        }
    }

    // MARK: What the widget reads

    @Test func theSnapshotCarriesTheMiddleVessel() {
        withTempDefaults { defaults in
            defaults.set([200, 330, 750], forKey: DataManager.Key.servings)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 30))

            #expect(snapshot.serving == 330,
                    "the widget's button and its face both draw this, so it is the middle vessel or nothing")
        }
    }

    @Test func theSnapshotFallsBackToTheDefaultServingWhenNothingIsStored() {
        withTempDefaults { defaults in
            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 30))
            #expect(snapshot.serving == DataManager.defaultServing)
        }
    }

    /// The midnight entry carries the serving across, for the same reason it carries the language.
    @Test func theServingSurvivesTheMidnightEntry() {
        let evening = WaterSnapshot(currentWater: 900, dailyGoal: 2_000, language: .russian, serving: 330)
        #expect(evening.rolledOver().serving == 330)
    }

    // MARK: The slot the one-tap doors log

    /// **The slot every one-tap door logs is named once.** ``DataManager/usualServing(in:)`` reads it,
    /// and the Control Center control draws its glyph — a tile with no figure, which could never show
    /// that its glyph and its amount had come from two different slots.
    @Test func theUsualServingIsReadFromTheUsualSlot() {
        withTempDefaults { defaults in
            defaults.set([200, 330, 750], forKey: DataManager.Key.servings)
            #expect(DataManager.usualServing(in: defaults) == [200, 330, 750][DataManager.usualSlot])
        }
    }

    /// The Glass by name, so moving the one-tap doors to another vessel is a decision this test makes
    /// visible rather than an index somebody edited.
    @Test func theUsualSlotIsTheGlass() {
        #expect(vesselSlots[DataManager.usualSlot].nameKey == "Glass")
    }
}

// MARK: - The published vessels

@MainActor
struct ServingSeamTests {

    @Test func theVesselsDefaultToTheStandardThreeOnAFreshInstall() {
        withTempDefaults { defaults in
            #expect(makeManager(defaults).servings == [150, 250, 500])
        }
    }

    @Test func savingVesselsPublishesThemAndWritesThemThrough() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)

            manager.servings = [200, 330, 750]

            #expect(manager.servings == [200, 330, 750])
            #expect(defaults.array(forKey: DataManager.Key.servings) as? [Int] == [200, 330, 750],
                    "the widget reads the suite, not the instance")
        }
    }

    @Test func eachVesselIsClampedIndependentlyOnTheWayIn() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)

            manager.servings = [0, 330, DataManager.maximumDailyIntake + 5_000]

            #expect(manager.servings == [1, 330, DataManager.maximumDailyIntake],
                    "a floor against corruption, applied per vessel — the resolver rejects, the setter clamps")
        }
    }

    /// A triple of the wrong length is not a partial edit to merge — it is a caller bug, and
    /// merging it would invent amounts. Rejected outright, like a non-positive serving.
    @Test func aTripleOfTheWrongLengthIsIgnored() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)
            manager.servings = [200, 330]

            #expect(manager.servings == [150, 250, 500], "the previous triple stands")
        }
    }

    @Test func savingTheSameVesselsDoesNotChurnObservers() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)
            manager.servings = [200, 330, 750]

            let counter = Counter()
            withObservationTracking { _ = manager.servings } onChange: { counter.count += 1 }
            manager.servings = [200, 330, 750]

            #expect(counter.count == 0)
        }
    }

    @Test func changingAVesselRingsTheWidgetDoorbell() {
        withTempDefaults { defaults in
            let reloads = Counter()
            let manager = makeManager(defaults, onReload: { reloads.count += 1 })
            let before = reloads.count

            manager.servings = [200, 330, 750]

            #expect(reloads.count == before + 1,
                    "the amount is baked into the widget's archive at render, so nothing else refreshes its face")
        }
    }

    /// Two vessels may hold the same amount. The editor deliberately does not enforce ascent or
    /// distinctness: making Cup push Glass would silently change what the *widget* logs, which is
    /// the bug-found-only-by-arithmetic the old constant existed to prevent. `Serving.id` is the
    /// slot, not the amount, so a duplicate is drawn as two rows rather than collapsing one away.
    @Test func twoVesselsMayHoldTheSameAmount() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)
            manager.servings = [250, 250, 500]

            #expect(manager.servings == [250, 250, 500])
            #expect(HomeView.servings(amounts: manager.servings).map(\.id).count == 3)
            #expect(Set(HomeView.servings(amounts: manager.servings).map(\.id)).count == 3,
                    "three distinct identities even when two amounts match")
        }
    }

    @Test func theQuickAddRowDrawsTheStoredAmounts() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults)
            manager.servings = [200, 330, 750]

            #expect(HomeView.servings(amounts: manager.servings).map(\.amount) == [200, 330, 750])
            #expect(HomeView.servings(amounts: manager.servings).map(\.symbol)
                    == ["cup.and.saucer.fill", "mug.fill", "waterbottle.fill"],
                    "the glyphs and names stay on the view; only the amounts come off the model")
        }
    }

    /// A second instance over the same suite — the app and the widget extension — sees the edit.
    @Test func aSecondInstanceReadsTheEditedVessels() {
        withTempDefaults { defaults in
            makeManager(defaults).servings = [200, 330, 750]

            #expect(makeManager(defaults).servings == [200, 330, 750])
        }
    }
}
