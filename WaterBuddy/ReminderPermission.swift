//
//  ReminderPermission.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import UserNotifications

/// Asking iOS for reminders, and re-reading what it says.
///
/// **Two taps ask, and both run ``enable(on:using:)``**: Settings' switch turning on, and *Turn on
/// reminders* on the welcome's last step — the moment the user has just asked for reminders, and no
/// other (rule `70-privacy`). It asks only when iOS has not been asked yet. For any other status it
/// stores what iOS already says, because iOS asks once and a second request shows nothing.
///
/// **A refusal is stored as off.** A switch that reads "on" while every reminder is silently
/// dropped is worse than no switch at all — so a refusal, or a request that fails, leaves
/// ``DataManager/remindersEnabled`` `false` rather than storing an intent iOS will never honour.
///
/// **And the answer is re-read, because it can be withdrawn.** iOS Settings can turn notifications
/// off while this app is in the background. ``reconcile(_:using:)`` notices, and clears the flag
/// through the model's own setter, which clears the schedule still filed. It runs whenever the app
/// comes forward and whenever Settings is shown, so Home stops promising a *Next reminder* that
/// cannot fire (known issue #100(d)).
///
/// It decides nothing about *when* to remind — that is ``ReminderPlan``'s — and it takes the
/// scheduler as a parameter, built by the caller inside the task that uses it
/// (rule `80-notifications`).
@MainActor
enum ReminderPermission {

    /// Asks if iOS has not been asked, and stores the answer; stores what iOS says otherwise.
    static func enable(on manager: DataManager, using scheduler: ReminderScheduler) async {
        let status = await scheduler.authorizationStatus()

        if status == .notDetermined {
            let granted = (try? await scheduler.requestAuthorization()) ?? false
            manager.remindersEnabled = granted
        } else {
            manager.remindersEnabled = status != .denied
        }
    }

    /// Reads what iOS says, turns reminders off if it refuses them, and returns what it read. Never
    /// asks.
    @discardableResult
    static func reconcile(_ manager: DataManager, using scheduler: ReminderScheduler) async -> UNAuthorizationStatus {
        let status = await scheduler.authorizationStatus()

        if status == .denied, manager.remindersEnabled {
            manager.remindersEnabled = false
        }

        return status
    }
}
