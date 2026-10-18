//
//  TodaysWaterIntent.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 18/10/26.
//

import AppIntents

/// Tells the user how much water they have had today and how much is left — Siri's answer to "How
/// much water today in WaterBuddy", and a tile in Spotlight and the Shortcuts app.
///
/// **It reads what the widget draws.** ``perform()`` reads
/// ``DataManager/snapshot(defaults:calendar:now:)`` — the widget's own read, which writes no key and
/// applies the midnight rollover to its value only — so asking writes nothing, Siri and the Home
/// Screen cannot disagree, and an answer after midnight is the new day's even if the app has not run
/// since. Not ``DataManager/shared`` after `refresh()`: that re-plans reminders, and a question would
/// then have to hold the process open for them.
///
/// **What it says is the user's own figures, so only after authentication.** *Log a Glass* replies
/// with nothing; this answers with the total and what is left, so ``authenticationPolicy`` keeps it
/// from anyone the system has not authenticated (rule `70-privacy`). Never the streak (rule
/// `20-state`).
///
/// **App-only**, beside ``LogServingIntent``: a provider and its intents share a target (rule
/// `15-project`).
///
/// Design: `docs/superpowers/specs/2026-10-18-todays-water-design.md`.
struct TodaysWaterIntent: AppIntent {

    // `let`, not `var`, as on its siblings: a `static var` on a `Sendable` type is nonisolated
    // global mutable state.
    static let title: LocalizedStringResource = "Today's Water"

    static let description = IntentDescription(
        "Tells you how much water you've had today in WaterBuddy, and how much is left.",
        categoryName: "Hydration"
    )

    /// Answered where the user stands; opening the app would undo the point of asking by voice.
    static let openAppWhenRun = false

    /// The answer carries figures, so a locked iPhone asks for authentication first. Apple documents
    /// the stricter `.requiresLocalDeviceAuthentication` as unlocking the phone "even if the request
    /// originated from an already authenticated Apple Watch or remote device", so this one is inferred
    /// to accept those too; that one is for data unreadable while the phone is locked, and the answer
    /// reads none (spec §3.2). `theAnswerWaitsForAnUnlock` pins it.
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    /// Siri's whole answer, from what the widget draws: what is left of the whole goal before the
    /// first serving, the total once the goal is met, and otherwise the total and what is left.
    ///
    /// A pure function of the snapshot, so the part of this intent a test can run is the decision — no
    /// simulator here can run `perform()` (known issue #63). The line is not resolved here: the
    /// resource travels to Siri, which picks the language, the plural form and the grouping.
    ///
    /// Each key is written out rather than left to the interpolation, so the catalogue's key is
    /// positional and Russian can put its figures where its grammar wants them (rule `70-privacy`);
    /// the figures ride in the default value.
    nonisolated static func answer(for snapshot: WaterSnapshot) -> LocalizedStringResource {
        let water = snapshot.currentWater
        let left = snapshot.remaining
        if water == 0 {
            return LocalizedStringResource(
                "Nothing logged yet today — %1$lld millilitres to go.",
                defaultValue: "Nothing logged yet today — \(left) millilitres to go."
            )
        }
        if snapshot.hasReachedGoal {
            return LocalizedStringResource(
                "%1$lld millilitres so far today — you've reached your goal.",
                defaultValue: "\(water) millilitres so far today — you've reached your goal."
            )
        }
        return LocalizedStringResource(
            "%1$lld millilitres so far today — %2$lld millilitres to go.",
            defaultValue: "\(water) millilitres so far today — \(left) millilitres to go."
        )
    }

    /// `@MainActor`, as on both sibling intents, though nothing here needs it — ``answer(for:)`` and
    /// the snapshot are nonisolated — so the three conformances are spelled alike under the app
    /// target's default main-actor isolation. It awaits nothing: it writes nothing, publishes nothing
    /// and re-plans no reminder, so there is nothing to hold the process open for.
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(Self.answer(for: DataManager.snapshot())))
    }
}
