//
//  NotificationManagerTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import Testing
import UserNotifications
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

/// A stand-in for the notification centre.
///
/// `UNUserNotificationCenter` cannot be faked by subclassing — its `init` is `NS_UNAVAILABLE`, so a
/// subclass compiles and then cannot be constructed — and `UNNotificationSettings` cannot be built
/// either. That is why ``ReminderScheduler`` is a struct of closures rather than a protocol: the
/// seam is the only thing a test can stand behind.
private final class SchedulerSpy {
    var pending: [String] = []
    var added: [String] = []
    var removedPending: [String] = []
    var removedDelivered: [String] = []
    var pendingReads = 0
    var status: UNAuthorizationStatus = .authorized
    /// Identifiers whose `add` should fail, and with what.
    var failures: [String: Error] = [:]

    func scheduler() -> ReminderScheduler {
        ReminderScheduler(
            pendingIdentifiers: { [self] in
                pendingReads += 1
                return pending
            },
            add: { [self] request in
                if let error = failures[request.identifier] { throw error }
                added.append(request.identifier)
                pending.append(request.identifier)
            },
            removePending: { [self] ids in
                removedPending.append(contentsOf: ids)
                pending.removeAll { ids.contains($0) }
            },
            removeDelivered: { [self] ids in removedDelivered.append(contentsOf: ids) },
            authorizationStatus: { [self] in status },
            requestAuthorization: { true }
        )
    }
}

private func plan(now: Date = utc(2026, 8, 28, 12), water: Int = 0, horizonDays: Int = 1) -> [ReminderPlan.Slot] {
    ReminderPlan.slots(
        enabled: true,
        currentWater: water,
        dailyGoal: 2_000,
        now: now,
        calendar: utcDay,
        horizonDays: horizonDays
    )
}

// MARK: - Tests

/// Applying a plan to the notification centre.
///
/// Not `@MainActor`: ``NotificationManager/reconcile(_:calendar:strings:using:)`` has to be callable from
/// `AddWaterIntent.perform()` in the widget extension, which is the whole reason it is `async` and
/// awaits its adds.
struct NotificationManagerTests {

    @Test func reconcileSchedulesEveryPlannedSlot() async {
        let spy = SchedulerSpy()
        let slots = plan()

        let outcome = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.added.sorted() == slots.map(\.identifier).sorted())
        #expect(outcome.added.sorted() == slots.map(\.identifier).sorted())
        #expect(outcome.failed.isEmpty)
    }

    /// The property that makes it safe to call from `refresh()` on every foreground.
    @Test func reconcileIsIdempotent() async {
        let spy = SchedulerSpy()
        let slots = plan()

        _ = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())
        spy.added.removeAll()
        let second = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.added.isEmpty, "a second run with an unchanged plan must schedule nothing")
        #expect(second.added.isEmpty)
        #expect(spy.removedPending.isEmpty)
    }

    @Test func reconcileRemovesSlotsThatHaveDroppedOutOfThePlan() async {
        let spy = SchedulerSpy()
        _ = await NotificationManager.reconcile(plan(now: utc(2026, 8, 28, 12)), calendar: utcDay, strings: .main, using: spy.scheduler())
        spy.added.removeAll()

        // Two hours later the 13:00 slot is in the past and must come off.
        let dropped = "\(ReminderPlan.identifierPrefix)20260828.13"
        _ = await NotificationManager.reconcile(plan(now: utc(2026, 8, 28, 14)), calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.removedPending.contains(dropped))
        #expect(!spy.pending.contains(dropped))
    }

    /// A delivered banner lives in a **separate** list from the pending one. Clearing only pending
    /// leaves a nag sitting in Notification Center after the user has already drunk.
    @Test func reconcileAlsoClearsDeliveredNotificationsForDroppedSlots() async {
        let spy = SchedulerSpy()
        _ = await NotificationManager.reconcile(plan(now: utc(2026, 8, 28, 12)), calendar: utcDay, strings: .main, using: spy.scheduler())

        let dropped = "\(ReminderPlan.identifierPrefix)20260828.13"
        _ = await NotificationManager.reconcile(plan(now: utc(2026, 8, 28, 14)), calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.removedDelivered.contains(dropped))
    }

    /// From the widget process `removeAllPendingNotificationRequests()` would clear the **app's**
    /// entire set — the centre an extension resolves is the containing app's, not its own.
    @Test func reconcileNeverTouchesRequestsItDoesNotOwn() async {
        let spy = SchedulerSpy()
        spy.pending = ["com.someone.else.request", "\(ReminderPlan.identifierPrefix)19990101.09"]

        _ = await NotificationManager.reconcile(plan(), calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.pending.contains("com.someone.else.request"), "a foreign request was removed")
        #expect(spy.removedPending == ["\(ReminderPlan.identifierPrefix)19990101.09"])
    }

    @Test func anEmptyPlanRemovesEverythingOfOurs() async {
        let spy = SchedulerSpy()
        _ = await NotificationManager.reconcile(plan(), calendar: utcDay, strings: .main, using: spy.scheduler())
        let ours = spy.pending

        _ = await NotificationManager.reconcile([], calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.removedPending.sorted() == ours.sorted())
        #expect(spy.pending.isEmpty)
    }

    /// `removePendingNotificationRequests(withIdentifiers:)` has no completion handler and no async
    /// form, yet Apple documents it as executing asynchronously on another thread. A widget process
    /// torn down straight after `perform()` returns can lose it. When a reconcile only removes,
    /// it therefore ends on an awaited read, which forces a round trip the removal is ordered
    /// behind.
    @Test func aRemoveOnlyReconcileEndsOnAnAwaitedRoundTrip() async {
        let spy = SchedulerSpy()
        _ = await NotificationManager.reconcile(plan(), calendar: utcDay, strings: .main, using: spy.scheduler())
        let readsAfterFirst = spy.pendingReads

        _ = await NotificationManager.reconcile([], calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(spy.pendingReads >= readsAfterFirst + 2, "a remove-only pass must await a read behind it")
    }

    // MARK: Failure

    @Test func aDeniedAuthorizationIsReportedRatherThanSwallowed() async {
        let spy = SchedulerSpy()
        let slots = plan()
        let first = slots[0].identifier
        spy.failures[first] = NSError(
            domain: UNErrorDomain,
            code: Int(UNError.Code.notificationsNotAllowed.rawValue)
        )

        let outcome = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(outcome.deniedAuthorization)
        #expect(outcome.failed.contains(first))
    }

    /// One bad request must not abandon the rest of the day.
    @Test func oneFailedAddDoesNotStopTheRemainingSlots() async {
        let spy = SchedulerSpy()
        let slots = plan()
        spy.failures[slots[0].identifier] = NSError(domain: UNErrorDomain, code: 1_000)

        let outcome = await NotificationManager.reconcile(slots, calendar: utcDay, strings: .main, using: spy.scheduler())

        #expect(outcome.failed == [slots[0].identifier])
        #expect(outcome.added.count == slots.count - 1)
    }

    // MARK: Content

    /// Rule `70-privacy`: a delivered banner renders on a locked screen, outside the App Group
    /// boundary. The copy names no total, no goal and no serving.
    @Test func theReminderCopyCarriesNoUserValues() {
        let content = NotificationManager.reminderContent(in: .main)

        let text = content.title + " " + content.body
        let carriesAFigure = text.contains { $0.isNumber }
        #expect(!carriesAFigure, "reminder copy must not carry a figure: \(text)")
        #expect(content.interruptionLevel == .active, ".timeSensitive would need an entitlement")
    }
}
