//
//  AddWaterIntent.swift
//  WaterBuddyWidget
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import AppIntents
import WidgetKit

/// Logs a serving of water without opening the app.
///
/// This is what the widget's button runs, and it is also a Shortcuts action in its own right, so
/// "log 250 ml" works from an automation, a Back Tap, or Siri.
///
/// It is compiled into the widget extension only. The app has no need of it — its own button
/// already holds the `DataManager` — and a second copy in the app binary would register the same
/// action twice in Shortcuts.
struct AddWaterIntent: AppIntent {

    // `let`, not `var`: a `static var` on a `Sendable` type is nonisolated global mutable state,
    // which is an error in the Swift 6 language mode.
    static let title: LocalizedStringResource = "Log Water"

    static let description = IntentDescription(
        "Adds a serving of water to today's total in WaterBuddy.",
        categoryName: "Hydration"
    )

    /// The widget stays put and the total updates in place — opening the app would throw away
    /// the whole point of an interactive widget.
    static let openAppWhenRun = false

    /// Millilitres to log.
    ///
    /// `@Parameter` is a macro and its arguments have to be compile-time constants, so they cannot
    /// spell `DataManager.defaultServing` or `DataManager.maximumDailyIntake`, and they especially
    /// cannot spell a value the user edits at runtime. The literals here are only what Shortcuts
    /// pre-fills and validates against when a person builds an automation by hand;
    /// ``DataManager/addWater(amount:)`` does the real clamping regardless of what any caller asks.
    ///
    /// **The widget's button no longer goes through ``init()``.** It builds
    /// ``init(amount:)`` with `entry.snapshot.serving`, so the amount it logs is the middle vessel
    /// the user chose and matches the figure drawn on the button's own face. `init()` survives as
    /// the `AppIntent` requirement — the path Shortcuts uses to construct the action before
    /// decoding a parameter over the top of it — and its `defaultServing` is the value a Shortcuts
    /// user sees pre-filled, which is the right default for a caller that has expressed no
    /// preference.
    @Parameter(title: "Amount", description: "Millilitres of water to log.", default: 250, inclusiveRange: (1, 100_000))
    var amount: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$amount) ml of water")
    }

    init() {
        amount = DataManager.defaultServing
        Self.activateWristLinkIfNeeded()
    }

    init(amount: Int) {
        self.amount = amount
        Self.activateWristLinkIfNeeded()
    }

    /// Without this, `perform()`'s call to ``DataManager/addWater(amount:)`` — through
    /// `currentWater`'s setter — reaches `publishWrist(defaults)`, whose production default is
    /// `DataManager.requestWristPublish(from:)`. That calls `WCSession.default.updateApplicationContext`,
    /// which throws `sessionNotActivated` in this process: nothing in the widget extension has ever
    /// called `WCSession.default.activate()`, unlike the app, whose own `init()`
    /// (`WaterBuddyApp.swift`) does exactly this before its first mutation is possible. The throw
    /// lands in `requestWristPublish`'s own `#if DEBUG`-only catch, so today it fails **silently** —
    /// water logged from the Home Screen widget never reaches the watch, with no signal anywhere.
    ///
    /// Called from **both** initialisers rather than once in `perform()`: the widget's own button
    /// constructs `AddWaterIntent(amount:)` while the widget's view tree is built — which happens on
    /// every timeline render, well before any tap — so activating here, rather than at the top of
    /// `perform()`, gives `WCSession`'s asynchronous activation the most possible time to complete
    /// before a user actually taps and `perform()` tries to publish. `init()` is covered too, for
    /// the Shortcuts/Siri/Back Tap path, which never goes through `init(amount:)` at all.
    /// `WristLink.activate()` tolerates being called repeatedly, so there is no cost to calling it
    /// from a process that may run this intent many times without ever being relaunched.
    #if canImport(WatchConnectivity)
    private static func activateWristLinkIfNeeded() {
        WristLink.live.activate()
    }
    #else
    private static func activateWristLinkIfNeeded() {}
    #endif

    /// `@MainActor` on the implementation of a `nonisolated` protocol requirement is legal and
    /// warning-free in both the Swift 5 and Swift 6 language modes — verified by compiling it
    /// under `-swift-version 5` and `-swift-version 6`. It is what lets the body touch
    /// ``DataManager/shared`` directly instead of hopping by hand.
    @MainActor
    func perform() async throws -> some IntentResult {
        // `addWater` re-reads the shared store before it adds, which is what makes this safe from
        // an extension process whose `DataManager` may have been built hours ago — see the note
        // on ``DataManager/addWater(amount:)``.
        DataManager.shared.addWater(amount: amount)

        // WidgetKit reloads after an interactive intent on its own, but only the timeline it
        // owns, and only if it decides something changed. Asking explicitly also covers the two
        // cases where nothing did: this intent run from Shortcuts rather than from the widget,
        // and a total already pinned at `maximumDailyIntake`, where `currentWater`'s setter
        // returns early and never rings the doorbell.
        WidgetCenter.shared.reloadAllTimelines()

        // Reminders are rescheduled here, by hand and **awaited**, rather than through
        // `DataManager`'s injected hook — and that is not the "call the side effect again to make
        // sure" that rule `20-state` forbids. It is the only place the work can happen at all.
        //
        // A widget extension is guaranteed to live exactly as long as the awaited work inside
        // `perform()`. The model's production hook spawns a detached `Task`, which in this process
        // would be torn down before it reached the system, so that hook returns immediately when
        // `isAppExtension` — leaving this as the one path that can hold the process open.
        //
        // The centre reached from here is the **containing app's**: an `.appex` has no notification
        // identity of its own, so `UNUserNotificationCenter.current()` resolves through
        // `LSPlugInKitProxy.containingBundle` and these requests join the same pending set the app
        // manages. Which is why `reconcile` only ever removes identifiers under
        // `ReminderPlan.identifierPrefix` — clearing everything here would clear the app's set.
        //
        // If the sandbox ever refuses the call outright, this degrades rather than breaks: the app
        // reconciles again in `DataManager.refresh()` on its next foreground.
        await NotificationManager.reconcile(
            DataManager.shared.currentReminderSlots(),
            calendar: .waterBuddyDay,
            // `perform()` is `@MainActor`, so the model is reachable here — and it has to be, or a
            // reminder filed from the widget would arrive in the device language while every other
            // one arrived in the chosen one.
            strings: DataManager.shared.language.bundle,
            using: ReminderScheduler.live()
        )

        return .result()
    }
}
