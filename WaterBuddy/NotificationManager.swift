//
//  NotificationManager.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import UserNotifications

// MARK: - The seam

/// The notification centre, as injectable closures.
///
/// A struct of closures rather than a protocol, and that is forced rather than preferred:
/// `UNUserNotificationCenter.init` is `NS_UNAVAILABLE`, so a subclass compiles and then **cannot be
/// constructed**; and `UNNotificationSettings` cannot be built either, so no seam may traffic in
/// one — which is why ``authorizationStatus`` returns the bare `UNAuthorizationStatus` enum.
///
/// It is also the shape this codebase already uses for exactly this kind of thing:
/// `DataManager.init`'s `reloadWidgets: @escaping () -> Void = DataManager.requestWidgetReload` is
/// a side effect on a system singleton, injected, defaulted, and counted in tests by a spy.
///
/// ## Three details that are Swift 6 requirements, not taste
///
/// 1. ``live()`` is a **`func`, not a `let`**. A `static let` of a non-`Sendable` struct is
///    nonisolated global mutable state, which is an error in the Swift 6 language mode
///    (rule `43-concurrency`). Keeping it a function also keeps the closures non-`@Sendable`, so a
///    test can spy with a plain `var` and needs no reference box.
/// 2. Each live closure calls `UNUserNotificationCenter.current()` **inside its own body**. The
///    centre is not `Sendable` and must never be captured — the same treatment
///    `DataManager.requestWidgetReload` gives `WidgetCenter.shared`.
/// 3. ``removePending`` is not `async` **because it cannot be**. See ``NotificationManager``.
struct ReminderScheduler {

    var pendingIdentifiers: () async -> [String]
    var add: (UNNotificationRequest) async throws -> Void
    var removePending: ([String]) -> Void
    var removeDelivered: ([String]) -> Void
    var authorizationStatus: () async -> UNAuthorizationStatus
    var requestAuthorization: () async throws -> Bool

    static func live() -> ReminderScheduler {
        ReminderScheduler(
            pendingIdentifiers: {
                await UNUserNotificationCenter.current().pendingNotificationRequests().map(\.identifier)
            },
            add: { request in
                try await UNUserNotificationCenter.current().add(request)
            },
            removePending: { identifiers in
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            },
            removeDelivered: { identifiers in
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
            },
            authorizationStatus: {
                await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            },
            requestAuthorization: {
                // No `.badge`: a badge would put the user's hydration state on the Home Screen
                // permanently, which is a rule `70-privacy` decision of its own, and it would need
                // a writer this product does not have.
                try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            }
        )
    }
}

/// What a reconcile actually did. Returned rather than logged, because rule `75-diagnostics` says
/// to prefer a test over a log — and because the caller is the only thing that can react.
struct ReconcileOutcome: Equatable, Sendable {
    var added: [String] = []
    var removed: [String] = []
    var failed: [String] = []
    /// The one failure with a recovery: the user has to be told, and the toggle has to stop lying.
    var deniedAuthorization = false
}

// MARK: - Applying a plan

/// Makes the pending notification set equal a ``ReminderPlan``.
///
/// It decides nothing. ``ReminderPlan`` already chose the slots; this only files and unfiles them,
/// which is what keeps every rule about *when* to remind testable without a device.
///
/// ## Why this is `async`, and why the ordering matters
///
/// The two halves of a reschedule are not equally durable, and the asymmetry is in the SDK:
///
/// - `add(_:)` has an `async throws` form, so the caller can hold on until the system has taken the
///   request and can see `UNErrorCodeNotificationsNotAllowed` come back.
/// - `removePendingNotificationRequests(withIdentifiers:)` has **no completion handler and no async
///   form**, yet Apple documents it as "execut[ing] asynchronously … on a secondary thread". It is
///   an unobservable side effect.
///
/// That matters because of who calls this. `AddWaterIntent` runs in the **widget extension**, whose
/// only guaranteed lifetime is the span of awaited work inside `perform()`; a removal issued as the
/// process is torn down can simply be lost. So a pass that *only* removes ends on an awaited read —
/// the requests are processed serially, so a round trip that returns is a round trip the removal is
/// already behind. `aRemoveOnlyReconcileEndsOnAnAwaitedRoundTrip` pins it.
///
/// ## Delivered notifications are a separate list
///
/// Dropping a slot from the pending set does nothing to a banner already sitting in Notification
/// Center. Clearing only the pending half leaves the user nagged for water they have already drunk,
/// so both are cleared together.
enum NotificationManager {

    /// The reminder itself.
    ///
    /// **Value-free on purpose.** A delivered banner renders on a locked screen, in public, and
    /// persists in Notification Center — outside the App Group boundary rule `70-privacy` draws
    /// around this product's four numbers. "You're 750 ml short of 2,000" would be more motivating
    /// and would put the user's day on a lock screen. `theReminderCopyCarriesNoUserValues` keeps it
    /// that way, by asserting the copy contains no digit at all.
    ///
    /// `.active` and not `.timeSensitive`: the latter requires the
    /// `com.apple.developer.usernotifications.time-sensitive` entitlement, and rule `70-privacy`
    /// forbids adding a capability to unblock something. The cost is real and is stated in the
    /// settings screen rather than hidden — an `.active` reminder is eligible for iOS's scheduled
    /// Notification Summary and may be delivered in a batch hours later.
    /// - Parameter bundle: the strings to compose in. Taken rather than read from `Bundle.main`
    ///   because this file compiles into **both** targets and the copy must follow the user's
    ///   chosen language in either — and because `Bundle.main` in a widget process is the `.appex`,
    ///   which resolves the *device* language, not the choice.
    nonisolated static func reminderContent(in bundle: Bundle) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = bundle.localizedString(forKey: "Time for water", value: nil, table: nil)
        content.body = bundle.localizedString(
            forKey: "A glass now keeps you on track for the day.", value: nil, table: nil
        )
        content.sound = .default
        content.interruptionLevel = .active
        return content
    }

    @discardableResult
    /// - Parameter strings: the bundle the copy is composed in. **Not defaulted**, deliberately:
    ///   a defaulted dependency has silently pointed this codebase at the wrong thing three times
    ///   (`tasks/lessons.md`), and here the wrong thing would be the device language rather than
    ///   the user's choice.
    nonisolated static func reconcile(
        _ slots: [ReminderPlan.Slot],
        calendar: Calendar,
        strings: Bundle,
        using scheduler: ReminderScheduler
    ) async -> ReconcileOutcome {
        var outcome = ReconcileOutcome()

        // Only ever this product's own reminders. Anything else in the set belongs to someone else
        // — and from the extension, "everything" would mean the app's entire set.
        let pending = await scheduler.pendingIdentifiers()
        let ours = pending.filter { $0.hasPrefix(ReminderPlan.identifierPrefix) }
        let wanted = Set(slots.map(\.identifier))

        let stale = ours.filter { !wanted.contains($0) }
        if !stale.isEmpty {
            scheduler.removePending(stale)
            scheduler.removeDelivered(stale)
            outcome.removed = stale
        }

        // An identifier already pending is already correct: a slot's fire time is a function of the
        // day and hour its identifier names, so it cannot have moved. Skipping it is what makes
        // this safe to call on every foreground.
        let alreadyPending = Set(ours)
        for slot in slots where !alreadyPending.contains(slot.identifier) {
            let request = UNNotificationRequest(
                identifier: slot.identifier,
                content: reminderContent(in: strings),
                trigger: UNCalendarNotificationTrigger(
                    // No `timeZone` on the components, deliberately. Pinning them would carry the
                    // home zone abroad and wake a traveller at 03:00; leaving it nil means 09:00
                    // wherever they are — the same reading of "the local day" the ordinal uses.
                    dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: slot.fireDate),
                    repeats: false
                )
            )

            do {
                try await scheduler.add(request)
                outcome.added.append(slot.identifier)
            } catch {
                // One rejected request must not abandon the rest of the day.
                outcome.failed.append(slot.identifier)
                let failure = error as NSError
                if failure.domain == UNErrorDomain,
                   failure.code == Int(UNError.Code.notificationsNotAllowed.rawValue) {
                    outcome.deniedAuthorization = true
                }
            }
        }

        // Nothing was awaited, but something was removed — see the type's note on why that needs a
        // round trip before this process is allowed to die.
        if outcome.added.isEmpty, !outcome.removed.isEmpty {
            _ = await scheduler.pendingIdentifiers()
        }

        return outcome
    }
}

// MARK: - One reconcile at a time

/// Runs reconciles one at a time, in the order they were asked for.
///
/// ``NotificationManager/reconcile(_:calendar:strings:using:)`` makes the pending set equal *its*
/// plan, so of two that overlap, the one that finishes last is the one that stands — whichever was
/// asked for first. A mutation asks twice: the `refresh()` it starts with plans on the rows from
/// before it, `recomputeToday()` on the rows after. Started as two `Task`s, which nothing orders,
/// the older plan could read the pending set after the newer one had dropped a slot from it, and
/// file that slot again — the one reminder a drink exists to skip. Queued here, the newer plan is
/// always applied last. `anOlderPlanCannotRefileTheSlotANewerPlanDropped` pins it.
///
/// ## Why a stream, rather than a lock or an actor
///
/// The one caller, `DataManager.requestReminderReschedule`, is synchronous and `nonisolated`
/// (rule `43-concurrency`): it can neither `await` its turn nor touch main-actor state.
/// `AsyncStream.Continuation.yield` is synchronous, safe from any thread, and keeps the order it was
/// called in, so asking costs the caller nothing and the ordering needs no lock of this file's own.
/// - An **actor** can only be reached with `await`, so the hook would need a `Task` per call to
///   reach it — and two `Task`s are unordered, which is the bug again.
/// - `Mutex` needs iOS 18, and the deployment floor is 17.0.
/// - `OSAllocatedUnfairLock` would work, but needs `import os` and a lock this file then owns; the
///   stream needs neither.
/// - An `NSLock` would make this class `@unchecked Sendable`, a promise the compiler cannot check.
///
/// ## The cost, and the lifetime
///
/// An operation that never returns now holds up every one asked for after it, until the process
/// ends; as a `Task` of its own it would have stranded only itself. The one operation production
/// queues awaits nothing but the notification centre.
///
/// One worker task per queue, for as long as the queue lives. Production keeps one for the life of
/// the app process (`DataManager.reminderReconciles`). `deinit` finishes the stream: work already
/// asked for still runs, and then the worker ends rather than waiting forever on a queue nobody can
/// reach — which is what a test's queue would otherwise leave behind.
///
/// `nonisolated` stated outright: this file also compiles into the app, whose default isolation is
/// the main actor, and a queue the `nonisolated` hook could not reach would be no queue at all.
///
/// In this file rather than one of its own because `DataManager.swift` names it, and the widget
/// extension compiles `DataManager.swift`: a file of its own would have to join the widget's
/// exception set, and rule `40-widget` forbids a seventh.
nonisolated final class ReconcileQueue: Sendable {

    private let operations: AsyncStream<@Sendable () async -> Void>.Continuation

    init() {
        let (stream, operations) = AsyncStream<@Sendable () async -> Void>.makeStream()
        self.operations = operations
        // The worker. It holds the stream, never `self`, so the queue can still be released.
        Task {
            for await operation in stream {
                await operation()
            }
        }
    }

    deinit {
        operations.finish()
    }

    /// Runs `operation` once everything asked for before it has finished.
    func enqueue(_ operation: @escaping @Sendable () async -> Void) {
        operations.yield(operation)
    }
}
