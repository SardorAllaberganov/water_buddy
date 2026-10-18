//
//  TodaysWaterTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 18/10/26.
//

import AppIntents
import Foundation
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

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// Every test gets its own suite, named once: `UserDefaults` caches domains in-process and `@Test`
/// functions run in parallel (rule `85-testing`).
private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
    let name = "test.waterbuddy.todayswater.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults)
}

/// A clock a test can move between mutations.
private final class MovableClock: @unchecked Sendable {
    var now: Date
    init(_ now: Date) { self.now = now }
}

// MARK: - What the snapshot says is left

/// ``WaterSnapshot/remaining`` and ``WaterSnapshot/hasReachedGoal`` — the arithmetic Siri's answer
/// reads (spec 2026-10-18-todays-water §3.5).
///
/// Not `@MainActor`, like `WaterSnapshotTests`: Siri's answer is built off the main actor, and so is
/// the widget's read.
///
/// **`async`, with each value read into a local before it is checked — that is what makes it a
/// canary** for the two properties' isolation (rule `43-concurrency`, as amended). With `nonisolated`
/// taken off `remaining`, a synchronous test drew no warning from this target, and neither did a read
/// inside `#expect`, whose closures swallow it; a plain read in an `async` test warned (known issue
/// #147). Do not fold the locals back into the `#expect`s.
struct TodaysWaterSnapshotTests {

    @Test(arguments: [
        (water: 0, goal: 2_500, left: 2_500, met: false),
        (water: 1_450, goal: 2_500, left: 1_050, met: false),
        (water: 2_500, goal: 2_500, left: 0, met: true),
        (water: 2_600, goal: 2_500, left: 0, met: true),
    ])
    func theSnapshotSaysWhatIsLeftAndWhetherTheGoalIsMet(
        water: Int, goal: Int, left: Int, met: Bool
    ) async {
        let snapshot = WaterSnapshot(currentWater: water, dailyGoal: goal)
        let remaining = snapshot.remaining
        let reached = snapshot.hasReachedGoal
        #expect(remaining == left)
        #expect(reached == met)
    }
}

// MARK: - The snapshot and the manager agree

/// The snapshot's two properties are twins of ``DataManager/remaining`` and
/// ``DataManager/hasReachedGoal``, as `progress` and `percentage` are; this keeps the pairs in step
/// (rule `20-state`, as amended).
@MainActor
struct TodaysWaterAgreementTests {

    @Test func theSnapshotAgreesWithTheManager() throws {
        try withTempDefaults { defaults in
            let clock = MovableClock(utc(2026, 10, 18, 9))
            let container = try ModelContainer(
                for: WaterLog.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            let manager = DataManager(
                defaults: defaults,
                modelContainer: container,
                calendar: utcDay,
                now: { clock.now },
                reloadWidgets: {},
                rescheduleReminders: { _ in },
                publishWrist: { _ in }
            )
            manager.saveDailyGoal(ml: 2_000)

            let agree = {
                let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: clock.now)
                #expect(snapshot.currentWater == manager.currentWater)
                #expect(snapshot.remaining == manager.remaining)
                #expect(snapshot.hasReachedGoal == manager.hasReachedGoal)
            }

            agree()                                   // nothing logged
            _ = manager.addLog(amount: 1_500)
            agree()                                   // under the goal
            _ = manager.addLog(amount: 500)
            agree()                                   // exactly at it
            _ = manager.addLog(amount: 300)
            agree()                                   // over it
        }
    }
}

// MARK: - What Siri says

/// One language's `.lproj` inside the app, or `nil` if it did not ship.
private func lproj(_ language: String) -> Bundle? {
    Bundle.main.url(forResource: language, withExtension: "lproj").flatMap(Bundle.init(url:))
}

/// What no translation could be, so a missing key is told apart from one translated to itself.
private let missingKey = "\u{0}__missing__\u{0}"

/// A resource resolved as Siri resolves it: its own locale chooses the table, the plural form and
/// the grouping (spec 2026-10-18-todays-water §3.4).
private func said(_ resource: LocalizedStringResource, in language: String) -> String {
    var resource = resource
    resource.locale = Locale(identifier: language)
    return String(localized: resource)
}

/// Siri's answer for a total against a goal, in `language`.
private func answer(_ water: Int, of goal: Int, in language: String = "en") -> String {
    said(TodaysWaterIntent.answer(for: WaterSnapshot(currentWater: water, dailyGoal: goal)), in: language)
}

/// Russian and Uzbek group with a no-break space (U+00A0, measured by the plan's probe).
private let nbsp = "\u{00A0}"

/// ``TodaysWaterIntent/answer(for:)`` — the whole of what Siri says, a pure function of the snapshot,
/// resolved in each shipped language (spec §3.2, §3.3).
///
/// Not `@MainActor`: the answer is built in a `nonisolated static`, and this suite calls it from no
/// actor. It is **not** a proven canary for that keyword, whatever rule `43-concurrency` says: with
/// `nonisolated` taken off `answer(for:)`, no call from this target warned — synchronous, `async`, or
/// read into a local — so what keeps the keyword is its DocC and review (known issue #147).
struct TodaysWaterAnswerTests {

    /// Every line, the title and the description are in every shipped language's table — proven
    /// before any resolved line is read, so a missing table cannot pass as English.
    @Test func everyLineIsTranslatedInEveryLanguage() throws {
        let keys = [
            "%1$lld millilitres so far today — %2$lld millilitres to go.",
            "%1$lld millilitres so far today — you've reached your goal.",
            "Nothing logged yet today — %1$lld millilitres to go.",
            "Today's Water",
            "Tells you how much water you've had today in WaterBuddy, and how much is left.",
        ]
        for language in ["en", "ru", "uz"] {
            let bundle = try #require(lproj(language), "the app ships no \(language) localization")
            for key in keys {
                let value = bundle.localizedString(forKey: key, value: missingKey, table: nil)
                #expect(value != missingKey, "\(language) has no translation of \(key)")
            }
        }
    }

    @Test func nothingLoggedSaysWhatIsLeftOfTheWholeGoal() {
        #expect(answer(0, of: 2_000) == "Nothing logged yet today — 2,000 millilitres to go.")
        #expect(answer(0, of: 1) == "Nothing logged yet today — 1 millilitre to go.")
    }

    @Test func underTheGoalSaysTheTotalAndWhatIsLeft() {
        #expect(answer(1_450, of: 2_500) == "1,450 millilitres so far today — 1,050 millilitres to go.")
    }

    @Test func atOrOverTheGoalSaysItIsReached() {
        #expect(answer(2_500, of: 2_500) == "2,500 millilitres so far today — you've reached your goal.")
        #expect(answer(2_600, of: 2_500) == "2,600 millilitres so far today — you've reached your goal.")
    }

    @Test func theAnswerReadsInRussian() {
        #expect(answer(0, of: 2_000, in: "ru") == "Сегодня ещё ничего не записано — осталось 2\(nbsp)000 миллилитров.")
        #expect(answer(1_450, of: 2_500, in: "ru") == "Сегодня уже 1\(nbsp)450 миллилитров — осталось 1\(nbsp)050 миллилитров.")
        #expect(answer(2_600, of: 2_500, in: "ru") == "Сегодня уже 2\(nbsp)600 миллилитров — цель достигнута.")
    }

    @Test func theAnswerReadsInUzbek() {
        #expect(answer(0, of: 2_000, in: "uz") == "Bugun hali hech narsa qayd etilmagan — 2\(nbsp)000 millilitr qoldi.")
        #expect(answer(1_450, of: 2_500, in: "uz") == "Bugun 1\(nbsp)450 millilitr — 1\(nbsp)050 millilitr qoldi.")
        #expect(answer(2_600, of: 2_500, in: "uz") == "Bugun 2\(nbsp)600 millilitr — maqsadga erishildi.")
    }

    /// English *one*/*other*; Russian *one*/*few*/*many*, and *остался* where the count takes *one*
    /// (1, 21), as the existing *… millilitres to go* key does. Review Focus 4.
    @Test func theNounsTakeTheirPluralForms() {
        #expect(answer(1, of: 2) == "1 millilitre so far today — 1 millilitre to go.")
        #expect(answer(1, of: 1) == "1 millilitre so far today — you've reached your goal.")
        #expect(answer(1, of: 2, in: "ru") == "Сегодня уже 1 миллилитр — остался 1 миллилитр.")
        #expect(answer(2, of: 7, in: "ru") == "Сегодня уже 2 миллилитра — осталось 5 миллилитров.")
        #expect(answer(21, of: 42, in: "ru") == "Сегодня уже 21 миллилитр — остался 21 миллилитр.")
        #expect(answer(22, of: 22, in: "ru") == "Сегодня уже 22 миллилитра — цель достигнута.")
        #expect(answer(0, of: 1, in: "ru") == "Сегодня ещё ничего не записано — остался 1 миллилитр.")
    }

    /// Review Focus 2: six digits, grouped.
    @Test func aTotalAtTheCapIsGrouped() {
        #expect(answer(100_000, of: 2_500) == "100,000 millilitres so far today — you've reached your goal.")
        #expect(answer(100_000, of: 2_500, in: "ru") == "Сегодня уже 100\(nbsp)000 миллилитров — цель достигнута.")
    }

    /// Review Focus 3: Siri in German finds no German table, so the words fall back to English, and
    /// the figures take German's grouping (the plan's probe).
    @Test func aLanguageTheAppDoesNotShipHearsEnglishWithItsOwnFigures() {
        #expect(answer(1_450, of: 2_500, in: "de") == "1.450 millilitres so far today — 1.050 millilitres to go.")
    }

    /// Review Focus 1: the cache still holds yesterday's total and the app has not run since midnight.
    /// The snapshot zeroes it in memory, so the answer is a new day's — and the suite is left as it
    /// was (rule `30-rollover`).
    @Test func aQuestionAfterMidnightHearsANewDay() {
        withTempDefaults { defaults in
            let yesterday = utc(2026, 10, 17, 20)
            defaults.set(1_450, forKey: DataManager.Key.currentWater)
            defaults.set(2_000, forKey: DataManager.Key.dailyGoal)
            defaults.set(DataManager.dayOrdinal(for: yesterday, in: utcDay), forKey: DataManager.Key.lastActiveDay)

            let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 18, 9))

            #expect(said(TodaysWaterIntent.answer(for: snapshot), in: "en")
                    == "Nothing logged yet today — 2,000 millilitres to go.")
            #expect(defaults.integer(forKey: DataManager.Key.currentWater) == 1_450)
        }
    }
}

// MARK: - The intent's contract

/// `TodaysWaterIntent`'s privacy contract (rule `70-privacy`, as amended): its answer carries figures,
/// so it waits for authentication; it never opens the app; its name is in every language.
/// `@MainActor`, as `LogServingIntentTests` is: it reads the intent's statics.
@MainActor
struct TodaysWaterIntentTests {

    @Test func theAnswerWaitsForAnUnlock() {
        #expect(TodaysWaterIntent.authenticationPolicy == .requiresAuthentication)
    }

    @Test func askingNeverOpensTheApp() {
        #expect(TodaysWaterIntent.openAppWhenRun == false)
    }

    @Test func theActionIsNamedInEveryLanguage() {
        #expect(said(TodaysWaterIntent.title, in: "en") == "Today's Water")
        #expect(said(TodaysWaterIntent.title, in: "ru") == "Вода за сегодня")
        #expect(said(TodaysWaterIntent.title, in: "uz") == "Bugungi suv")
    }

    /// *Log a Glass* and *Today's Water*: the one provider names both (spec §3.6).
    @Test func theProviderOffersBothShortcuts() {
        #expect(WaterBuddyShortcuts.appShortcuts.count == 2)
    }
}
