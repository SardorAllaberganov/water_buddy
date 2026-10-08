//
//  SiriPhraseTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 07/10/26.
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
    let name = "test.waterbuddy.siri.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults)
}

/// One language's `.lproj` inside the app, or `nil` if it did not ship.
private func lproj(_ language: String) -> Bundle? {
    Bundle.main.url(forResource: language, withExtension: "lproj").flatMap(Bundle.init(url:))
}

/// What no translation could be, so a missing key is told apart from one translated to itself.
private let missingKey = "\u{0}__missing__\u{0}"

/// A clock a test can move, so one instance can be built before midnight and used after it.
private final class MovableClock: @unchecked Sendable {
    var now: Date
    init(_ now: Date) { self.now = now }
}

/// A throwaway manager: its own suite, an in-memory store, every side effect a no-op, and the clock
/// the test hands it (rule `85-testing`). `prepare` writes the suite before the manager reads it.
@MainActor
private func withTempManager<T>(
    clock: MovableClock,
    prepare: (UserDefaults) -> Void = { _ in },
    _ body: (DataManager, UserDefaults) throws -> T
) throws -> T {
    let name = "test.waterbuddy.siri.manager.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    prepare(defaults)
    let manager = DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: { clock.now },
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    return try body(manager, defaults)
}

// MARK: - The serving Siri logs

/// ``DataManager/usualServing(in:)`` — the one definition of the serving the one-tap doors log.
///
/// Not `@MainActor`, like `WaterSnapshotTests`: the widget's timeline provider reaches it from no
/// isolation, so a main-actor member would fail to compile here first (rule `43-concurrency`).
struct UsualServingTests {

    @Test func nothingStoredLogsTheDefaultGlass() {
        withTempDefaults { defaults in
            #expect(DataManager.usualServing(in: defaults) == DataManager.defaultServing)
        }
    }

    @Test func anEditedGlassIsWhatSiriLogs() {
        withTempDefaults { defaults in
            defaults.set([200, 330, 750], forKey: DataManager.Key.servings)
            #expect(DataManager.usualServing(in: defaults) == 330)
        }
    }

    /// `resolveServings(in:)` discards the whole triple on any anomaly, so a corrupt suite logs the
    /// default Glass rather than a repaired element nobody chose.
    @Test func aMalformedTripleFallsBackToTheDefaultGlass() {
        let malformed: [[Any]] = [[330, 750], [200, 0, 750], [200, "330", 750]]
        for stored in malformed {
            withTempDefaults { defaults in
                defaults.set(stored, forKey: DataManager.Key.servings)
                #expect(DataManager.usualServing(in: defaults) == DataManager.defaultServing,
                        "stored \(String(describing: stored))")
            }
        }
    }

    /// The widget and Siri log one serving: the snapshot's `serving` is this, whatever is stored —
    /// including three equal vessels, a state the user is allowed to choose.
    @Test func theWidgetDrawsTheServingSiriLogs() {
        let stored: [[Int]?] = [nil, [200, 330, 750], [100, 100, 100], [330, 750]]
        for triple in stored {
            withTempDefaults { defaults in
                if let triple { defaults.set(triple, forKey: DataManager.Key.servings) }
                let snapshot = DataManager.snapshot(defaults: defaults, calendar: utcDay, now: utc(2026, 10, 7))
                #expect(snapshot.serving == DataManager.usualServing(in: defaults),
                        "stored \(String(describing: triple))")
            }
        }
    }
}

// MARK: - Waiting for the reminder queue

/// ``ReconcileQueue/settled()`` — what `LogServingIntent` awaits so a background launch outlives its
/// own re-plan.
///
/// Not `@MainActor`, and time-limited, for `ReconcileQueueTests`' reasons: the queue's callers are
/// `nonisolated`, and a settle that never returns should fail the gate in a minute rather than hang
/// it. The `Task.sleep`s only give work asked for later the time to overtake work asked for earlier;
/// a settle that keeps its place spends that time waiting.
@Suite(.timeLimit(.minutes(1)))
struct ReconcileQueueSettledTests {

    /// The settle waits for what was asked before it, and not for what came after: a later
    /// mutation's re-plan must not hold Siri's reply.
    @Test func aSettleWaitsForEarlierWorkButNotForLaterWork() async {
        let queue = ReconcileQueue()
        let (events, event) = AsyncStream<String>.makeStream()

        queue.enqueue {
            try? await Task.sleep(for: .milliseconds(500))
            event.yield("earlier work")
        }
        let settling = Task {
            await queue.settled()
            event.yield("settled")
        }
        // Time for the settle to take its place in line before the later work asks for one. A
        // quarter of a second, not a few milliseconds: other builds run beside the gate on this
        // machine, and a settle that started late would read as a settle that waited for later work.
        try? await Task.sleep(for: .milliseconds(250))
        queue.enqueue {
            try? await Task.sleep(for: .milliseconds(300))
            event.yield("later work")
        }

        let order = await events.prefix(3).reduce(into: [String]()) { $0.append($1) }
        await settling.value
        #expect(order == ["earlier work", "settled", "later work"])
    }

    /// Nothing queued, nothing to wait for — measured rather than merely reached, so a settle that
    /// stalls fails here and not only at the suite's time limit.
    @Test func settlingAnIdleQueueReturnsPromptly() async {
        let queue = ReconcileQueue()
        let elapsed = await ContinuousClock().measure { await queue.settled() }
        #expect(elapsed < .seconds(1))
    }
}

// MARK: - The intent's contract

/// `LogServingIntent`'s privacy contract (rule `70-privacy`; spec 2026-10-07-siri-phrase §5): it runs
/// on a locked iPhone, it never opens the app, and its reply carries no figure in any language.
@MainActor
struct LogServingIntentTests {

    @Test func theSiriShortcutRunsOnALockedPhone() {
        #expect(LogServingIntent.authenticationPolicy == .alwaysAllowed)
    }

    @Test func theSiriShortcutNeverOpensTheApp() {
        #expect(LogServingIntent.openAppWhenRun == false)
    }

    /// Spoken aloud and shown on a locked iPhone: no total, no goal, no serving, no digit — the
    /// standard `theReminderCopyCarriesNoUserValues` holds the reminders to. Each language's bundle
    /// is proven to resolve first, or every check below would pass vacuously.
    @Test func theSiriReplyCarriesNoUserValues() throws {
        let key = LogServingIntent.reply.key
        for language in ["en", "ru", "uz"] {
            let bundle = try #require(lproj(language), "the app ships no \(language) localization")
            let reply = bundle.localizedString(forKey: key, value: missingKey, table: nil)
            #expect(reply != missingKey, "\(language) has no translation of Siri's reply")
            #expect(!reply.contains { $0.isNumber }, "the \(language) reply carries a figure: \(reply)")
        }
    }
}

// MARK: - What Siri logs

/// ``LogServingIntent/logTheGlass(into:from:)`` — the body of `perform()` between its two waits,
/// which no simulator here can run: the App Intents daemon refuses an ad-hoc-signed build. The user's
/// Glass, logged once, on the day it is now.
@MainActor
struct LogTheGlassTests {

    @Test func anEditedGlassIsLoggedOnceAtItsOwnAmount() throws {
        try withTempManager(clock: MovableClock(utc(2026, 10, 7, 9)), prepare: {
            $0.set([200, 330, 750], forKey: DataManager.Key.servings)
        }) { manager, defaults in
            LogServingIntent.logTheGlass(into: manager, from: defaults)
            #expect(manager.todaysLogs.map(\.amount) == [330])
            #expect(manager.currentWater == 330)
        }
    }

    @Test func aCorruptTripleLogsTheDefaultGlass() throws {
        try withTempManager(clock: MovableClock(utc(2026, 10, 7, 9)), prepare: {
            $0.set([200, 0, 750], forKey: DataManager.Key.servings)
        }) { manager, defaults in
            LogServingIntent.logTheGlass(into: manager, from: defaults)
            #expect(manager.todaysLogs.map(\.amount) == [DataManager.defaultServing])
        }
    }

    /// Siri reaching a suspended app at 00:05: the instance was built yesterday, and the Glass must
    /// land on the new day while yesterday's water stays yesterday's.
    @Test func aGlassLoggedAfterMidnightLandsOnTheNewDay() throws {
        let clock = MovableClock(utc(2026, 10, 6, 23, 59))
        try withTempManager(clock: clock) { manager, defaults in
            manager.addWater(amount: 500)
            #expect(manager.currentWater == 500)

            clock.now = utc(2026, 10, 7, 0, 5)
            LogServingIntent.logTheGlass(into: manager, from: defaults)

            #expect(manager.currentWater == DataManager.defaultServing)
            #expect(manager.todaysLogs.map(\.amount) == [DataManager.defaultServing])
        }
    }
}

// MARK: - The phrases

/// Siri's phrases ship in English and Russian — Siri has no Uzbek — and every one names the app,
/// without which Siri cannot tell whose shortcut it is (spec 2026-10-07-siri-phrase §3.2).
struct AppShortcutPhraseTests {

    @Test func everyPhraseNamesTheAppInEnglishAndRussian() throws {
        for language in ["en", "ru"] {
            let path = try #require(
                Bundle.main.path(forResource: "AppShortcuts", ofType: "strings", inDirectory: nil,
                                 forLocalization: language),
                "the app ships no \(language) phrase table"
            )
            let table = try #require(NSDictionary(contentsOfFile: path) as? [String: String])
            #expect(table.count == 3, "\(language) has \(table.count) phrases")
            for phrase in table.values {
                #expect(phrase.contains("${applicationName}"), "a \(language) phrase does not name the app: \(phrase)")
            }
        }
    }
}
