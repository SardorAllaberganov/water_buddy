//
//  LiveActivityGlassIntent.swift
//  WaterBuddyWidget
//

import AppIntents

/// The Live Activity's button, as the widget extension names it (rule `40-widget`, spec
/// `2026-11-27-live-activity-design.md` §4).
///
/// **The twin of the app's `LiveActivityGlassIntent`, and never run.** iOS runs a `LiveActivityIntent` in the app's
/// process, whose copy logs the Glass; this one is here so the button's view, which this extension draws, can name the
/// intent, and its `perform()` does nothing. The two keep one title, `isDiscoverable = false`,
/// `openAppWhenRun = false` and `.alwaysAllowed`.
struct LiveActivityGlassIntent: LiveActivityIntent {

    // `let`, not `var`, as on `AddWaterIntent`: a `static var` on a `Sendable` type is nonisolated global mutable state.
    static let title: LocalizedStringResource = "Log a Glass"

    static let isDiscoverable = false

    static let openAppWhenRun = false

    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    func perform() async throws -> some IntentResult {
        .result()
    }
}
