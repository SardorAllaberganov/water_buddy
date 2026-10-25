//
//  WelcomeTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import Foundation
import SwiftData
import Testing
import UserNotifications
@testable import WaterBuddy

// MARK: - Fixtures

/// A UUID-named throwaway suite, removed when `body` returns — never the App Group's, never
/// `.standard`'s (rule `85-testing`).
@MainActor
private func withWelcomeSuite(_ body: (UserDefaults) async throws -> Void) async rethrows {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    try await body(defaults)
}

/// A manager on `defaults` and an in-memory store, its calendar and clock pinned, every side effect
/// a no-op. `rescheduleReminders` above all: its production default builds a real
/// `UNUserNotificationCenter`, and `init` reschedules (rule `85-testing`).
@MainActor
private func welcomeManager(_ defaults: UserDefaults) -> DataManager {
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = TimeZone(identifier: "UTC")!
    return DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        calendar: utc,
        // 2026-10-14, 12:00 UTC.
        now: { Date(timeIntervalSince1970: 1_791_979_200) },
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
}

/// What a refused request can throw.
private struct RequestFailed: Error {}

/// A notification centre that is only the two closures permission uses, and counts them.
///
/// The other four never run here; they are inert so a stray call files nothing anywhere. Never a
/// real centre: `UNUserNotificationCenter` cannot be faked, which is why `ReminderScheduler` is a
/// struct of closures (`NotificationManagerTests`' `SchedulerSpy` says the same).
@MainActor
private final class PermissionSpy {

    var status: UNAuthorizationStatus
    var answer: Result<Bool, RequestFailed>

    /// Run as the request is made, before it is answered — where a test looks at the model.
    var onRequest: () -> Void = {}

    private(set) var statusReads = 0
    private(set) var requests = 0

    init(status: UNAuthorizationStatus, answer: Result<Bool, RequestFailed> = .success(true)) {
        self.status = status
        self.answer = answer
    }

    func scheduler() -> ReminderScheduler {
        ReminderScheduler(
            pending: { [] },
            add: { _ in },
            removePending: { _ in },
            removeDelivered: { _ in },
            setCategories: { _ in },
            authorizationStatus: { [self] in
                statusReads += 1
                return status
            },
            requestAuthorization: { [self] in
                requests += 1
                onRequest()
                return try answer.get()
            }
        )
    }
}

// MARK: - Permission

/// Asking for reminders and re-reading what iOS says — one implementation for Settings' switch and
/// the welcome's *Turn on reminders* (spec 2026-10-14 §6).
@MainActor
struct ReminderPermissionTests {

    @Test func aGrantIsStored() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .success(true))

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(spy.requests == 1)
            #expect(manager.remindersEnabled)
        }
    }

    @Test func aRefusalIsStoredAsOff() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .success(false))

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(spy.requests == 1)
            #expect(manager.remindersEnabled == false, "a refusal stored as on is a switch that lies")
        }
    }

    @Test func aRequestThatFailsIsStoredAsOff() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .failure(RequestFailed()))

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(manager.remindersEnabled == false)
        }
    }

    @Test func aPhoneAlreadyAllowedIsNotAskedAgain() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .authorized)

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(spy.requests == 0, "iOS asks once; a second request shows nothing and answers the old answer")
            #expect(manager.remindersEnabled)
        }
    }

    @Test func aPhoneThatRefusedIsNotAskedAndStaysOff() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .denied)

            await ReminderPermission.enable(on: manager, using: spy.scheduler())

            #expect(spy.requests == 0)
            #expect(manager.remindersEnabled == false)
        }
    }

    /// Withdrawn in iOS Settings while the app was away (#100(d)).
    @Test func aReReadTurnsRemindersOffWhenTheyAreRefused() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            manager.remindersEnabled = true
            let spy = PermissionSpy(status: .denied)

            let status = await ReminderPermission.reconcile(manager, using: spy.scheduler())

            #expect(status == .denied)
            #expect(manager.remindersEnabled == false)
            #expect(spy.requests == 0, "a re-read never asks")
        }
    }

    @Test(arguments: [UNAuthorizationStatus.authorized, .notDetermined, .provisional, .ephemeral])
    func aReReadLeavesTheSwitchAloneOtherwise(status: UNAuthorizationStatus) async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            manager.remindersEnabled = true
            let spy = PermissionSpy(status: status)

            let read = await ReminderPermission.reconcile(manager, using: spy.scheduler())

            #expect(read == status, "Settings draws its refused state from what this returns")
            #expect(manager.remindersEnabled)
            #expect(spy.requests == 0)
        }
    }
}

// MARK: - The steps

/// The welcome's steps as a value (spec 2026-10-14 §§5–6). Not `@MainActor`: ``WelcomeStep`` sits at
/// file scope, `nonisolated`, as ``AppTab`` does, and this suite is the canary that keeps it there
/// (rule `43-concurrency`).
struct WelcomeStepTests {

    @Test func theStepsComeInTheOrderTheyAreWalked() {
        #expect(WelcomeStep.allCases == [.hello, .goal, .vessels, .reminders])
    }

    @Test func theFirstStepHasNoBackAndTheLastNoContinue() {
        #expect(WelcomeStep.hello.previous == nil)
        #expect(WelcomeStep.reminders.next == nil)
    }

    @Test(arguments: WelcomeStep.allCases.dropLast())
    func continueBringsTheStepAfterAndBackReturns(step: WelcomeStep) throws {
        let next = try #require(step.next)
        #expect(next.rawValue == step.rawValue + 1)
        #expect(next.previous == step)
    }

    @Test func theDotsCountFromOne() {
        #expect(WelcomeStep.allCases.map(\.number) == [1, 2, 3, 4])
    }

    /// *Continue* brings the next step in from the trailing edge, *Back* from the leading.
    @Test func theNextStepWaitsOnTheTrailingSideAndThePreviousOnTheLeading() {
        #expect(WelcomeStep.vessels.offset(shown: .goal, across: 390, slides: true) == 390)
        #expect(WelcomeStep.hello.offset(shown: .goal, across: 390, slides: true) == -390)
        #expect(WelcomeStep.goal.offset(shown: .goal, across: 390, slides: true) == 0)
    }

    @Test func aStepThatSlidesIsSeenAllTheWayOut() {
        for step in WelcomeStep.allCases {
            #expect(step.opacity(shown: .hello, slides: true) == 1)
        }
    }

    /// Under Reduce Motion nothing travels, and the change is a cross-fade (rule `65-accessibility`).
    @Test func underReduceMotionNothingTravelsAndOnlyTheShownStepIsSeen() {
        for step in WelcomeStep.allCases {
            #expect(step.offset(shown: .vessels, across: 390, slides: false) == 0)
        }
        #expect(WelcomeStep.vessels.opacity(shown: .vessels, slides: false) == 1)

        let hidden = WelcomeStep.goal.opacity(shown: .vessels, slides: false)
        #expect(hidden > 0, "a step at exactly nothing has not always been given back to a finger")
        #expect(hidden < 1.0 / 255, "a step that is not shown is drawn")
    }

    /// The bells are the plan's own hours, so the row cannot show a time the plan does not keep.
    @Test func theBellsRingAtTheReminderHours() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!

        let hours = WelcomeView.bellTimes(in: utc).map { utc.component(.hour, from: $0) }

        #expect(hours == ReminderPlan.hours)
    }
}

// MARK: - Finishing

/// The welcome's end, without a screen: the vessels, then reminders if asked, then the goal — which
/// is what closes it (spec 2026-10-14 §5).
@MainActor
struct WelcomeFinishTests {

    @Test func vesselsLeftAsTheyWereStoreNothing() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined)

            await WelcomeView.finish(goal: 2_000, amounts: manager.servings, asksForReminders: false,
                                     on: manager, using: spy.scheduler())

            #expect(defaults.object(forKey: DataManager.Key.servings) == nil,
                    "an untouched row of vessels was stored, pinning today's defaults for good")
        }
    }

    @Test func vesselsSetInTheWelcomeAreStored() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined)

            await WelcomeView.finish(goal: 2_000, amounts: [200, 300, 750], asksForReminders: false,
                                     on: manager, using: spy.scheduler())

            #expect(manager.servings == [200, 300, 750])
            #expect(defaults.array(forKey: DataManager.Key.servings) as? [Int] == [200, 300, 750])
        }
    }

    @Test func finishingSavesTheGoalAndClosesTheWelcome() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined)
            #expect(manager.isGoalSet == false)

            await WelcomeView.finish(goal: 2_500, amounts: manager.servings, asksForReminders: false,
                                     on: manager, using: spy.scheduler())

            #expect(manager.dailyGoal == 2_500)
            #expect(manager.isGoalSet, "the root would stay on the welcome")
        }
    }

    /// The order, proved: iOS's question is answered while the welcome is still on screen, and only
    /// then does the goal close it.
    @Test func remindersAreAskedForBeforeTheWelcomeCloses() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .success(true))
            var closedWhenAsked: Bool?
            spy.onRequest = { closedWhenAsked = manager.isGoalSet }

            await WelcomeView.finish(goal: 2_000, amounts: manager.servings, asksForReminders: true,
                                     on: manager, using: spy.scheduler())

            #expect(closedWhenAsked == false, "the welcome closed before iOS's question was answered")
            #expect(manager.remindersEnabled)
            #expect(manager.isGoalSet)
        }
    }

    @Test func aRefusalStillOpensTheAppWithRemindersOff() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined, answer: .success(false))

            await WelcomeView.finish(goal: 2_000, amounts: manager.servings, asksForReminders: true,
                                     on: manager, using: spy.scheduler())

            #expect(manager.remindersEnabled == false)
            #expect(manager.isGoalSet)
        }
    }

    /// *Not now* asks nothing — not even what iOS thinks.
    @Test func notNowAsksNothing() async {
        await withWelcomeSuite { defaults in
            let manager = welcomeManager(defaults)
            let spy = PermissionSpy(status: .notDetermined)

            await WelcomeView.finish(goal: 2_000, amounts: manager.servings, asksForReminders: false,
                                     on: manager, using: spy.scheduler())

            #expect(spy.statusReads == 0)
            #expect(spy.requests == 0)
            #expect(manager.remindersEnabled == false)
        }
    }
}

// MARK: - The fresh start

#if DEBUG
/// The welcome's UI tests launch a DEBUG build with `-WaterBuddyFreshStart` (spec 2026-10-14 §9).
/// What they get must be a throwaway: absent without the argument, writing its own suite and never
/// the App Group's, and cleared at each launch (Review Focus 4). Serialized: its tests share the
/// fresh start's one fixed suite. The store capture's seed and held Premium act only beside the fresh
/// start's argument (spec `2026-10-25-store-page-design.md` §3.1, §3.2).
@MainActor
@Suite(.serialized)
struct FreshStartTests {

    /// 2026-10-25 at 2 PM on the app's own calendar: after today's last serving, on the 25th.
    private static let afternoon = Calendar.waterBuddyDay.date(
        from: DateComponents(year: 2026, month: 10, day: 25, hour: 14)
    )!

    @Test func withoutTheArgumentThereIsNoFreshStart() {
        #expect(WaterBuddyApp.freshStartManager(arguments: ["WaterBuddy"]) == nil)
    }

    @Test func aFreshStartIsAThrowawayClearedAtEachLaunch() throws {
        let arguments = ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES"]
        let suite = try #require(UserDefaults(suiteName: WaterBuddyApp.freshStartSuite))
        defer { suite.removePersistentDomain(forName: WaterBuddyApp.freshStartSuite) }

        let first = try #require(WaterBuddyApp.freshStartManager(arguments: arguments))
        #expect(first.isGoalSet == false, "a fresh start opened past the welcome")
        first.saveDailyGoal(ml: 3_000)
        #expect(suite.integer(forKey: DataManager.Key.dailyGoal) == 3_000,
                "the fresh start wrote somewhere other than its own suite")

        let second = try #require(WaterBuddyApp.freshStartManager(arguments: arguments))
        #expect(second.isGoalSet == false, "the next launch found the last one's welcome finished")
        #expect(second.dailyGoal == DataManager.defaultDailyGoal)
    }

    @Test func theStoreSampleNeedsTheFreshStart() {
        #expect(WaterBuddyApp.freshStartManager(arguments: ["WaterBuddy", WaterBuddyApp.storeSampleArgument, "YES"]) == nil)
    }

    @Test func aFreshStartAloneHoldsNoServings() throws {
        defer { UserDefaults(suiteName: WaterBuddyApp.freshStartSuite)?.removePersistentDomain(forName: WaterBuddyApp.freshStartSuite) }
        let manager = try #require(WaterBuddyApp.freshStartManager(
            arguments: ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES"], now: { Self.afternoon }
        ))
        #expect(manager.currentWater == 0)
        #expect(manager.recap(of: 20260901) == nil)
    }

    @Test func theStoreSampleLandsInTheFreshStart() throws {
        defer { UserDefaults(suiteName: WaterBuddyApp.freshStartSuite)?.removePersistentDomain(forName: WaterBuddyApp.freshStartSuite) }
        let manager = try #require(WaterBuddyApp.freshStartManager(
            arguments: ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES", WaterBuddyApp.storeSampleArgument, "YES"],
            now: { Self.afternoon }
        ))
        #expect(manager.currentWater == 1_300)
        #expect(manager.streak == 5)
        let september = try #require(manager.recap(of: 20260901), "September offers no recap")
        #expect(september.daysCounted == 30)
        #expect(manager.isGoalSet == false, "the seed finished the welcome")
    }

    @Test func theHeldPremiumNeedsTheFreshStart() {
        #expect(WaterBuddyApp.premiumSource(arguments: ["WaterBuddy", WaterBuddyApp.premiumHeldArgument, "YES"]) == nil)
        #expect(WaterBuddyApp.premiumSource(arguments: ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES"]) == nil)
    }

    @Test func theHeldPremiumReadsALifetimePurchase() async throws {
        let source = try #require(WaterBuddyApp.premiumSource(
            arguments: ["WaterBuddy", WaterBuddyApp.freshStartArgument, "YES", WaterBuddyApp.premiumHeldArgument, "YES"]
        ))
        let store = PremiumStore(source: source)
        await store.refresh()
        #expect(store.state == .known(.lifetime))
    }
}
#endif
