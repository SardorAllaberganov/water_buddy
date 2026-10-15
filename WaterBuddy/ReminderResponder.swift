//
//  ReminderResponder.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 15/10/26.
//

import UserNotifications

/// Answers a press of a reminder's *Log a Glass* — the notification centre's delegate. App-only.
///
/// **Main-actor, the opposite of `WristLink`.** `WCSession` calls its delegate on "a non-main serial
/// queue", so `WristLink` stays off the main actor and posts. Everything a press does here is main-actor
/// work — `DataManager.shared` lives there — so the `async` form of
/// `userNotificationCenter(_:didReceive:)` is a main-actor method: under this target's approachable
/// concurrency the conformance is inferred main-actor-isolated and compiles with no diagnostic, and
/// whichever queue the centre calls on, the thunk the system calls hops to the main actor, awaits the
/// body, then completes — so everything a press needs is awaited before iOS is told it is done and may
/// suspend the launch. (Apple's DTS says the centre calls its delegate on the main thread; nothing here
/// rests on it.) Never `@preconcurrency` on the conformance (it warns, "has no effect"), and never a
/// `nonisolated` `didReceive`, which completes off the main thread (rule `43-concurrency`).
///
/// **Installed in `WaterBuddyApp.init()`**, which runs before the app finishes launching — the moment
/// iOS requires a delegate by, to hand over the response that launched it. The centre holds its
/// delegate weakly, so ``shared`` keeps this one for the life of the process.
///
/// **No `willPresent`.** Implementing it would start showing reminders while the app is open — a
/// change nobody asked for.
///
/// Design: `docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md` §3.6.
@MainActor
final class ReminderResponder: NSObject, UNUserNotificationCenterDelegate {

    private static let shared = ReminderResponder()

    /// Makes this the centre's delegate. Once per launch, from `WaterBuddyApp.init()`.
    static func install() {
        UNUserNotificationCenter.current().delegate = shared
    }

    /// Whether a response is a press of the reminder's button. Everything else — in practice a tap on
    /// the reminder itself, which opens the app as it always did — logs nothing.
    ///
    /// `nonisolated` so a suite that is not on the main actor can ask it.
    nonisolated static func logsTheGlass(for actionIdentifier: String) -> Bool {
        actionIdentifier == NotificationManager.logTheGlassActionIdentifier
    }

    /// Logs the Glass read **now** — one edited after the reminder was filed logs its new amount — and
    /// returns only once the watch link and the reminder queue have been waited for: returning is the
    /// completion, after which iOS may suspend the launch.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard Self.logsTheGlass(for: response.actionIdentifier) else { return }
        await LogServingIntent.logTheGlassInTheBackground()
    }
}
