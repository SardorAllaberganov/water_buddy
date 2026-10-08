//
//  LogServingIntent.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 07/10/26.
//

import AppIntents

/// Logs the user's Glass — the serving the widget's button adds — from Siri, Spotlight or the
/// Shortcuts app, without opening the app.
///
/// **App-only, and a different action from `AddWaterIntent`.** A Siri phrase needs its intent in the
/// target of its `AppShortcutsProvider`, and Siri runs an app-target intent by launching the app in
/// the background — the one process that can also reach the watch (known issue #53).
/// `AddWaterIntent` stays the widget extension's own: it logs whatever amount its caller decoded,
/// which is why it may not re-read the serving at run time (rule `40-widget`). This intent takes no
/// amount at all, so reading the Glass when it runs is its whole job.
///
/// **What Siri may say is fixed.** The reply is ``reply`` — no amount, no total, no digit — because it
/// is spoken aloud and shown on a locked iPhone, the public surface rule `70-privacy` holds the
/// reminders to. `theSiriReplyCarriesNoUserValues` pins it in every shipped language.
///
/// Design: `docs/superpowers/specs/2026-10-07-siri-phrase-design.md`.
struct LogServingIntent: AppIntent {

    // `let`, not `var`, as on `AddWaterIntent`: a `static var` on a `Sendable` type is nonisolated
    // global mutable state.
    static let title: LocalizedStringResource = "Log a Glass"

    static let description = IntentDescription(
        "Adds your Glass to today's total in WaterBuddy.",
        categoryName: "Hydration"
    )

    /// Siri, Spotlight and the Shortcuts app run it where they stand; opening the app would undo the
    /// point of logging by voice.
    static let openAppWhenRun = false

    /// The default, written out so the choice is visible where it is made: logging water on a locked
    /// iPhone is harmless, and the reply says nothing.
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    /// Siri's whole reply. A static rather than an inline literal, so the privacy test reads the key
    /// this intent actually speaks.
    static let reply: LocalizedStringResource = "Water logged."

    /// What `perform()` does between its two waits: log the Glass once, on the day it is now.
    ///
    /// A function of a manager and a suite rather than an inline call on ``DataManager/shared``, so
    /// the one part of this intent a test can run is tested (`LogTheGlassTests`) — no simulator here
    /// can run `perform()` itself, because the App Intents daemon refuses an ad-hoc-signed build.
    ///
    /// The Glass is read when Siri runs, not when anything was built, so one edited a minute ago
    /// counts; ``DataManager/addWater(amount:)`` re-reads the store and rolls the day over before it
    /// adds, so an instance built yesterday logs into today.
    @MainActor
    static func logTheGlass(into manager: DataManager, from defaults: UserDefaults) {
        manager.addWater(amount: DataManager.usualServing(in: defaults))
    }

    /// `@MainActor` on a `nonisolated` requirement, as on `AddWaterIntent`, so the body reaches
    /// ``DataManager/shared`` directly.
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // The watch link first: this launch started activating it in `WaterBuddyApp.init()`, and a
        // publish before it is up is dropped.
        await WristLink.waitUntilActivated()

        Self.logTheGlass(into: .shared, from: DataManager.sharedDefaults)

        // The re-plan `addWater` queued must reach the notification centre before the system can
        // suspend this background launch (rule `80-notifications`).
        await DataManager.remindersSettled()

        return .result(dialog: IntentDialog(Self.reply))
    }
}
