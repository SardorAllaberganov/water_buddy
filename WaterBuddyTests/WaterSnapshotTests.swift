//
//  WaterSnapshotTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
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

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// Same rule as `DataManagerTests`: every test gets its own suite, and names are never reused,
/// because `UserDefaults` caches domains in-process and `@Test` functions run in parallel.
private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
    let name = "test.waterbuddy.snapshot.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults)
}

/// Everything WaterBuddy has ever written into a suite, so a test can prove nothing moved.
private func waterBuddyKeys(in defaults: UserDefaults) -> [String: String] {
    // `Key.all`, never a list re-typed here. This function spent two releases enumerating six of
    // the seven keys — it omitted `remindersEnabled` — so both tripwires below were one key blind
    // while their own DocC claimed they covered "everything WaterBuddy has ever written into a
    // suite". `theTripwireHelperEnumeratesEveryStoredKey` now pins the two together.
    DataManager.Key.all.reduce(into: [:]) { result, key in
        result[key] = defaults.object(forKey: key).map { String(describing: $0) } ?? "<nil>"
    }
}

/// Seeds a suite the way the app would have left it, without building a `DataManager` — which is
/// `@MainActor` and would drag these tests onto the main actor for no reason. The point of
/// ``DataManager/snapshot(defaults:calendar:now:)`` is that a widget never needs one.
private func seed(_ defaults: UserDefaults, water: Int?, goal: Int?, day: Int?) {
    if let water { defaults.set(water, forKey: DataManager.Key.currentWater) }
    if let goal { defaults.set(goal, forKey: DataManager.Key.dailyGoal) }
    if let day { defaults.set(day, forKey: DataManager.Key.lastActiveDay) }
}

// MARK: - Tests

/// The widget's read path. Deliberately *not* `@MainActor`: if any of this ever needed the main
/// actor it could not run in a timeline provider, and these tests would stop compiling — which is
/// the warning we want.
struct WaterSnapshotTests {

    // MARK: Reading what the app wrote

    @Test func reportsWhatTheAppWroteToday() {
        withTempDefaults { defaults in
            seed(defaults, water: 750, goal: 2_500, day: 20_260_828)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(snapshot.currentWater == 750)
            #expect(snapshot.dailyGoal == 2_500)
        }
    }

    @Test func fallsBackToTheDefaultGoalWhenTheSuiteIsEmpty() {
        withTempDefaults { defaults in
            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(snapshot.currentWater == 0)
            #expect(snapshot.dailyGoal == DataManager.defaultDailyGoal)
            #expect(snapshot.progress == 0)
        }
    }

    /// A `0` goal written by an older build would make the first sip read as 100% — and, worse,
    /// divide by zero.
    @Test func aCorruptZeroGoalFallsBackToTheDefault() {
        withTempDefaults { defaults in
            seed(defaults, water: 500, goal: 0, day: 20_260_828)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(snapshot.dailyGoal == DataManager.defaultDailyGoal)
            #expect(snapshot.progress == 0.25)
            #expect(snapshot.progress.isFinite)
        }
    }

    @Test func clampsATotalCorruptedBeyondTheMaximum() {
        withTempDefaults { defaults in
            seed(defaults, water: .max, goal: 2_000, day: 20_260_828)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(snapshot.currentWater == DataManager.maximumDailyIntake)
        }
    }

    // MARK: Rollover

    @Test func reportsZeroWhenTheStoredDayIsYesterday() {
        withTempDefaults { defaults in
            seed(defaults, water: 750, goal: 2_000, day: 20_260_827)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(snapshot.currentWater == 0, "the widget would still be showing yesterday's water")
            #expect(snapshot.dailyGoal == 2_000, "the goal is not today's business")
        }
    }

    @Test func reportsTheStoredTotalWithinTheSameDay() {
        withTempDefaults { defaults in
            seed(defaults, water: 750, goal: 2_000, day: 20_260_828)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28, 23, 59))

            #expect(snapshot.currentWater == 750)
        }
    }

    /// The trap in mirroring `resetIfNeeded()`: its *missing* marker branch adopts today and
    /// returns `false`. Reporting zero here instead would blank the widget for everyone upgrading
    /// from a build that never stamped a day.
    @Test func aMissingDayMarkerReportsTheStoredTotal() {
        withTempDefaults { defaults in
            seed(defaults, water: 400, goal: nil, day: nil)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(snapshot.currentWater == 400)
        }
    }

    /// The same instant, re-read an hour west. The user's local date never changed, so their
    /// water must not vanish — the widget has to agree with the app about this, or a phone that
    /// lands in London shows one number in the app and another on the Home Screen.
    @Test func travellingWestwardDoesNotBlankTheWidget() {
        withTempDefaults { defaults in
            let paris = gregorian(in: "Europe/Paris")
            let london = gregorian(in: "Europe/London")
            let instant = paris.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 14))!

            seed(defaults, water: 750, goal: 2_000, day: 20_260_828)

            #expect(DataManager.snapshot(defaults: defaults, calendar: paris, now: instant).currentWater == 750)
            #expect(DataManager.snapshot(defaults: defaults, calendar: london, now: instant).currentWater == 750)
        }
    }

    @Test func travellingEastwardAcrossTheDateReportsANewDay() {
        withTempDefaults { defaults in
            let losAngeles = gregorian(in: "America/Los_Angeles")
            let tokyo = gregorian(in: "Asia/Tokyo")
            let logged = losAngeles.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 10))!
            let landed = logged.addingTimeInterval(4 * 60 * 60)

            seed(defaults, water: 750, goal: 2_000, day: 20_260_828)

            #expect(DataManager.snapshot(defaults: defaults, calendar: tokyo, now: landed).currentWater == 0)
        }
    }

    // MARK: The widget must not write

    /// The whole reason this API exists. A widget process that constructed a `DataManager` would
    /// materialise the goal, stamp the day, possibly zero the total, and ring the widget doorbell
    /// from inside a timeline render.
    @Test func readingLeavesTheStoreUntouched() {
        withTempDefaults { defaults in
            seed(defaults, water: 750, goal: 2_500, day: 20_260_827)   // deliberately yesterday
            let before = waterBuddyKeys(in: defaults)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(snapshot.currentWater == 0, "the rollover is applied to the value…")
            #expect(waterBuddyKeys(in: defaults) == before, "…but never written back")
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 750)
        }
    }

    @Test func readingAnEmptySuiteDoesNotCreateKeys() {
        withTempDefaults { defaults in
            let before = waterBuddyKeys(in: defaults)

            _ = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(waterBuddyKeys(in: defaults) == before)
        }
    }

    // MARK: The tripwire's own coverage

    /// The two tripwires below are only as wide as ``waterBuddyKeys(in:)``, and that helper is a
    /// hand-written list. It enumerated **six** of the seven keys for two releases — `remindersEnabled`
    /// was missing — so `readingLeavesTheStoreUntouched` and `readingAnEmptySuiteDoesNotCreateKeys`
    /// were quietly blind to a whole key while reading as though they covered everything. Rule
    /// `30-rollover` names this failure directly: the helper "enumerates keys explicitly and will
    /// not notice a new one on its own".
    ///
    /// `DataManager.Key.all` is what closes **half** of it. The list now lives beside the
    /// declarations it mirrors rather than in a test file, so both tripwires widen automatically
    /// when the roster grows — that part is real, and it is what the roster bought.
    ///
    /// **This assertion, however, is a tautology, and its previous edition said otherwise.** It
    /// claimed to "fail the moment the two disagree". They cannot disagree: ``waterBuddyKeys(in:)``
    /// *is* `Key.all.reduce(…)` (`:40-43`), so this reduces to `Set(Key.all) == Set(Key.all)` and
    /// holds for every possible content of the roster. Declare a key, use it in production, forget
    /// `Key.all`, and both sides shrink together while this stays green.
    ///
    /// It is kept because it does pin one real thing — that the helper is *exactly* the roster and
    /// no wider, so nobody re-introduces the hand-written list this replaced. The guarantee it used
    /// to claim lives in `DataManagerTests.everyKeyTheProductWritesIsOnTheRoster`, which drives the
    /// product's real writers and reads the **suite** back rather than the roster. That test was
    /// watched failing, with `servings` removed from `Key.all`, while *this* one passed.
    @Test func theTripwireHelperEnumeratesEveryStoredKey() {
        withTempDefaults { defaults in
            #expect(Set(waterBuddyKeys(in: defaults).keys) == Set(DataManager.Key.all),
                    "the tripwires are exactly as wide as this helper, and no wider")
        }
    }

    // MARK: The midnight entry

    /// `getTimeline` emits a second, midnight-dated entry with a zeroed total, which is how the
    /// widget rolls over unattended. It used to build that entry with the two-argument memberwise
    /// initialiser — `WaterSnapshot(currentWater: 0, dailyGoal: current.dailyGoal)` — and
    /// ``WaterSnapshot/language`` carries a default of `.system`, so **every field not named was
    /// silently reset at local midnight**. A user who chose Russian in the app watched the widget
    /// revert to the device language overnight, and nothing brought it back until something else
    /// reloaded the timeline. Rule `70-privacy` is explicit that the widget takes its language from
    /// `entry.snapshot.language` and never from the device.
    ///
    /// ``WaterSnapshot/rolledOver()`` exists so that entry cannot be built by enumeration. It
    /// copies `self` and zeroes one field, which makes it structurally impossible for a field added
    /// later to be forgotten — the reason this is a method on the value rather than a second
    /// initialiser call at the widget's call site.
    @Test func theMidnightEntryKeepsEveryFieldButTheTotal() {
        let evening = WaterSnapshot(currentWater: 1_750, dailyGoal: 3_000, language: .russian)

        let midnight = evening.rolledOver()

        #expect(midnight.currentWater == 0, "the day turned")
        #expect(midnight.dailyGoal == 3_000, "the goal did not")
        #expect(midnight.language == .russian, "and neither did the language the user chose")
    }

    /// The whole value, not a field list: anything a future author adds to ``WaterSnapshot`` is
    /// carried by this assertion without anybody remembering to extend it.
    @Test func rollingOverChangesNothingExceptTheTotal() {
        var evening = WaterSnapshot(currentWater: 1_750, dailyGoal: 3_000, language: .uzbek)
        let midnight = evening.rolledOver()

        evening.currentWater = 0
        #expect(midnight == evening, "rolledOver() differs from its receiver in currentWater alone")
    }

    // MARK: Arithmetic the widget draws with

    @Test(arguments: zip([0, 500, 2_000, 3_000], [0.0, 0.25, 1.0, 1.0]))
    func progressMatchesTheApp(water: Int, expected: Double) {
        let snapshot = WaterSnapshot(currentWater: water, dailyGoal: 2_000)
        #expect(snapshot.progress == expected)
    }

    @Test func progressUnclampedExceedsOneOnOverachievement() {
        let snapshot = WaterSnapshot(currentWater: 3_000, dailyGoal: 2_000)

        #expect(snapshot.progressUnclamped == 1.5)
        #expect(snapshot.progress == 1.0)
    }

    /// The readout announces 150%, not 100% — the same rounding `HomeView` uses, so the two
    /// surfaces never disagree by a percentage point.
    ///
    /// 1,150 of 2,000 is the interesting one: 0.575 has no exact binary form, and the nearest
    /// double times 100 is 57.49999999999999, so it rounds *down* to 57. Both surfaces show 57
    /// because both round the same expression — which is the property under test. Anything that
    /// "tidied" one of them to `water * 100 / goal` would silently make them disagree.
    @Test(arguments: zip([0, 1, 500, 1_150, 3_000], [0, 0, 25, 57, 150]))
    func percentageRoundsLikeTheApp(water: Int, expected: Int) {
        #expect(WaterSnapshot(currentWater: water, dailyGoal: 2_000).percentage == expected)
    }

    @Test func aZeroGoalCannotDivideByZero() {
        let snapshot = WaterSnapshot(currentWater: 500, dailyGoal: 0)

        #expect(snapshot.progress == 0)
        #expect(snapshot.progressUnclamped == 0)
        #expect(snapshot.percentage == 0)
    }

    // MARK: Scheduling the day's turn

    @Test func theNextBoundaryIsTheComingLocalMidnight() {
        let evening = utc(2026, 8, 28, 23, 30)
        let boundary = DataManager.nextDayBoundary(after: evening, calendar: utcDay)

        #expect(boundary == utc(2026, 8, 29, 0, 0))
        #expect(boundary > evening)
    }

    @Test func theNextBoundaryFromJustAfterMidnightIsTomorrow() {
        let justAfter = utc(2026, 8, 28, 0, 1)
        #expect(DataManager.nextDayBoundary(after: justAfter, calendar: utcDay) == utc(2026, 8, 29, 0, 0))
    }

    /// The boundary the widget schedules and the ordinal the snapshot compares have to be the same
    /// event, or the widget wakes at the wrong minute and redraws the same number.
    @Test func theSnapshotFlipsExactlyAtTheScheduledBoundary() {
        withTempDefaults { defaults in
            let now = utc(2026, 8, 28, 21, 0)
            seed(defaults, water: 900, goal: 2_000, day: 20_260_828)

            let boundary = DataManager.nextDayBoundary(after: now, calendar: utcDay)
            let aMomentBefore = boundary.addingTimeInterval(-1)

            #expect(DataManager.snapshot(defaults: defaults, calendar: utcDay, now: aMomentBefore).currentWater == 900)
            #expect(DataManager.snapshot(defaults: defaults, calendar: utcDay, now: boundary).currentWater == 0)
        }
    }

    /// 2 November 2025 in New York is 25 hours long. Starting *inside* that day is what makes this
    /// a real test: the boundary is 24.5 hours away, so `date + 86,400` would land at 23:30 on the
    /// 2nd — still the same date, scheduling a reset half an hour before the day it is meant to
    /// reset actually ends. Only a calendar computation gets it right.
    @Test func theBoundaryHoldsAcrossADstTransition() {
        let newYork = gregorian(in: "America/New_York")
        let insideTheLongDay = newYork.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 0, minute: 30))!

        let boundary = DataManager.nextDayBoundary(after: insideTheLongDay, calendar: newYork)
        let naive = insideTheLongDay.addingTimeInterval(86_400)

        #expect(boundary == newYork.date(from: DateComponents(year: 2025, month: 11, day: 3, hour: 0))!)
        #expect(boundary.timeIntervalSince(insideTheLongDay) == 24.5 * 60 * 60)
        #expect(newYork.dateComponents([.day], from: naive).day == 2, "the naive form has not left the day yet")
        #expect(naive < boundary)
    }

    // MARK: The one-shot migration into the App Group

    /// Enabling App Groups must not look like data loss to someone upgrading from a build that
    /// only ever wrote `UserDefaults.standard`.
    @Test func migrationCarriesEveryValueIntoAnEmptyGroup() {
        withTempDefaults { old in
            withTempDefaults { group in
                seed(old, water: 1_500, goal: 3_000, day: 20_260_828)

                DataManager.migrateIfNeeded(from: old, into: group)

                #expect(group.integer(forKey: DataManager.Key.currentWater) == 1_500)
                #expect(group.integer(forKey: DataManager.Key.dailyGoal) == 3_000)
                #expect(group.integer(forKey: DataManager.Key.lastActiveDay) == 20_260_828)
            }
        }
    }

    @Test func migrationRunsOnlyOnce() {
        withTempDefaults { old in
            withTempDefaults { group in
                seed(old, water: 1_500, goal: 3_000, day: 20_260_828)
                DataManager.migrateIfNeeded(from: old, into: group)

                // The user logs more water, then something asks to migrate again.
                group.set(1_750, forKey: DataManager.Key.currentWater)
                seed(old, water: 9_999, goal: nil, day: nil)
                DataManager.migrateIfNeeded(from: old, into: group)

                #expect(group.integer(forKey: DataManager.Key.currentWater) == 1_750)
            }
        }
    }

    /// The key case, and the one that has a widget in it. A tap on the widget before the app has
    /// been opened even once after the update writes `currentWater` into the group and nothing
    /// else. A whole-set probe on one key would then either strand every old value or overwrite
    /// the tap; migrating key by key keeps both.
    @Test func migrationFillsTheGapsAroundAValueAlreadyInTheGroup() {
        withTempDefaults { old in
            withTempDefaults { group in
                seed(old, water: 1_500, goal: 3_000, day: 20_260_828)
                group.set(250, forKey: DataManager.Key.currentWater)   // the widget got there first

                DataManager.migrateIfNeeded(from: old, into: group)

                #expect(group.integer(forKey: DataManager.Key.currentWater) == 250, "the deliberate tap survives")
                #expect(group.integer(forKey: DataManager.Key.dailyGoal) == 3_000, "and the old goal is not stranded")
                #expect(group.integer(forKey: DataManager.Key.lastActiveDay) == 20_260_828)
            }
        }
    }

    @Test func migrationFromAnEmptySourceWritesNothingButTheFlag() {
        withTempDefaults { old in
            withTempDefaults { group in
                DataManager.migrateIfNeeded(from: old, into: group)

                #expect(group.object(forKey: DataManager.Key.currentWater) == nil)
                #expect(group.object(forKey: DataManager.Key.dailyGoal) == nil)
                #expect(group.bool(forKey: DataManager.Key.didMigrateFromStandard))
            }
        }
    }

    // MARK: The two front doors log the same amount

    /// What has to hold has moved twice. It was "the two front doors spell the same constant";
    /// then, when the quick-add row replaced the single `+`, "the app's row still contains the
    /// widget's serving". Now the vessels are editable and neither is right: the widget's amount is
    /// whatever the user set the **middle slot** to, and the two doors agree by reading one key
    /// rather than by compiling one literal.
    ///
    /// So this asserts the read, at an edited value — a re-introduced constant on either side would
    /// fail it. `HomeView`'s half is pinned by `theRowsMiddleVesselIsTheOneTheWidgetLogs`, which
    /// can build a `DataManager` because it is `@MainActor` and this suite deliberately is not.
    @Test func theWidgetsServingIsTheAppsMiddleVessel() {
        withTempDefaults { defaults in
            defaults.set([200, 330, 750], forKey: DataManager.Key.servings)
            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(snapshot.serving == 330)
            #expect(snapshot.serving == HomeView.servings(amounts: [200, 330, 750])[1].amount,
                    "one value, read by both front doors")
        }
    }

    @Test func theDefaultServingIsStillTheMiddleOfTheDefaultTriple() {
        #expect(DataManager.defaultServing == 250)
        #expect(DataManager.defaultServings[1] == DataManager.defaultServing)
    }
}

// MARK: - The chosen language crosses to the widget

/// The widget draws localised strings too, so the language is part of what the provider reads.
///
/// This suite is **not** `@MainActor` on purpose (rule `85-testing`), which makes it the right
/// place for these: if reading the language ever needed the main actor, a `TimelineProvider` could
/// not do it and these tests would stop compiling.
struct WidgetLanguageTests {

    @Test func aMissingLanguageKeyReadsAsFollowTheDevice() {
        withTempDefaults { defaults in
            seed(defaults, water: 900, goal: 2_000, day: 20_260_828)

            let snapshot = DataManager.snapshot(
                defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28)
            )

            #expect(snapshot.language == .system,
                    "an untouched install must follow the device, not pin English")
        }
    }

    @Test(arguments: [AppLanguage.english, .russian, .uzbek])
    func theSnapshotCarriesTheChosenLanguage(language: AppLanguage) {
        withTempDefaults { defaults in
            seed(defaults, water: 900, goal: 2_000, day: 20_260_828)
            defaults.set(language.code, forKey: DataManager.Key.language)

            let snapshot = DataManager.snapshot(
                defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28)
            )

            #expect(snapshot.language == language,
                    "the widget would draw a different language from the app")
        }
    }

    /// Fail soft: a corrupt code must leave the widget rendering *something*.
    @Test func anUnrecognisedStoredCodeLeavesTheWidgetOnTheDeviceLanguage() {
        withTempDefaults { defaults in
            seed(defaults, water: 900, goal: 2_000, day: 20_260_828)
            defaults.set("fr", forKey: DataManager.Key.language)

            let snapshot = DataManager.snapshot(
                defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28)
            )

            #expect(snapshot.language == .system)
        }
    }

    /// The read path still writes nothing — the language must not be materialised by a widget any
    /// more than the goal or the day stamp may be (rule `25-shared-storage`).
    @Test func readingAnEmptySuiteStillCreatesNoLanguageKey() {
        withTempDefaults { defaults in
            _ = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 8, 28))

            #expect(defaults.object(forKey: DataManager.Key.language) == nil,
                    "the widget stamped a language into the group")
        }
    }
}

// MARK: - The process role

/// ``DataManager/Role`` — the four-state answer that replaced a two-state `isAppExtension`.
///
/// **Deliberately not `@MainActor`**, and that is the point rather than an oversight: `role` is
/// read from `requestReminderReschedule` and `requestWidgetReload`, both `nonisolated static`, and
/// a watchOS timeline provider must reach it too. If `Role` or `role` ever acquired main-actor
/// isolation this suite would stop compiling — the same canary rule `43-concurrency` already
/// relies on for `WaterSnapshotTests` itself.
struct ProcessRoleTests {

    /// The truth table, in full. All four questions currently answer identically for every role,
    /// and they are still four questions — see ``DataManager/role``'s DocC. Pinning the whole grid
    /// means flipping any single answer fails here rather than silently on a wrist.
    @Test func onlyThePhoneAppOwnsTheGroupsBookkeeping() {
        #expect(DataManager.Role.phoneApp.ownsSharedStorage)
        #expect(DataManager.Role.phoneApp.mayHaveLegacyStandardDefaults)
        #expect(DataManager.Role.phoneApp.drawsHistory)
        #expect(DataManager.Role.phoneApp.mayFileReminders)

        for role in [DataManager.Role.phoneExtension, .watchApp, .watchExtension] {
            #expect(!role.ownsSharedStorage, "\(role) would write on behalf of the group")
            #expect(!role.mayHaveLegacyStandardDefaults, "\(role) would burn the burn-once migration flag")
            #expect(!role.drawsHistory, "\(role) would run a seven-day roll-up it cannot draw")
            #expect(!role.mayFileReminders, "\(role) would file a duplicate ReminderPlan")
        }
    }

    /// The bug this enum exists for, stated as an assertion.
    ///
    /// A watchOS app is a `.app`, so `Bundle.main.bundleURL.pathExtension == "appex"` is `false`
    /// and the old `!isAppExtension` guards would all *open* on the wrist. `.watchApp` must answer
    /// every question the way `.phoneExtension` does, not the way `.phoneApp` does.
    @Test func aWatchAppAnswersLikeAnExtensionAndNotLikeTheApp() {
        let watch = DataManager.Role.watchApp
        let widget = DataManager.Role.phoneExtension

        #expect(watch.ownsSharedStorage == widget.ownsSharedStorage)
        #expect(watch.mayHaveLegacyStandardDefaults == widget.mayHaveLegacyStandardDefaults)
        #expect(watch.drawsHistory == widget.drawsHistory)
        #expect(watch.mayFileReminders == widget.mayFileReminders)
    }

    /// `role` is resolved from `isAppExtension` plus the compile-time platform, never from a second
    /// runtime probe (rule `25-shared-storage`). The test host is the app, on iOS.
    @Test func theTestHostResolvesAsThePhoneApp() {
        #expect(DataManager.role == .phoneApp)
        #expect(DataManager.isAppExtension == false)
    }

    /// Every role is covered by the grid above. Fails when a fifth binary is added and this suite
    /// is not extended — the runtime half of the exhaustive `switch`es.
    @Test func everyRoleIsAccountedFor() {
        #expect(DataManager.Role.allCases.count == 4)
    }
}
