//
//  LiveActivityGlassIntent.swift
//  WaterBuddy
//

import AppIntents

/// The Live Activity's button: logs the Glass, as Siri's phrase does, in the app's own process (spec
/// `2026-11-27-live-activity-design.md` R3).
///
/// **Declared twice under one name, and this is the copy iOS runs.** A `LiveActivityIntent` runs in the app's process —
/// the one that can update the activity and reach the watch. The widget extension declares the same intent so the
/// button's view can name it, and that copy's `perform()` does nothing, because it never runs. One declaration in a
/// shared file would have `DataManager.swift` call into one target's code or the other's, which rule
/// `10-architecture`'s import direction forbids. The two keep one title and the same three properties below (rule
/// `40-widget`).
///
/// **Not discoverable**: no Shortcuts action, no Siri, no Spotlight. `LogServingIntent` is the Glass's action there,
/// and `AddWaterIntent` the amount's.
struct LiveActivityGlassIntent: LiveActivityIntent {

    // `let`, not `var`, as on the two other intents: a `static var` on a `Sendable` type is nonisolated global
    // mutable state.
    static let title: LocalizedStringResource = "Log a Glass"

    static let isDiscoverable = false

    /// The activity stays where it is and shows the Glass in place.
    static let openAppWhenRun = false

    /// Logging water on a locked iPhone is harmless, and the press says nothing back (rule `70-privacy`).
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    /// What Siri's phrase and a reminder's button run: the watch link, the Glass, the activity and the reminders,
    /// each waited for before the launch may be suspended.
    @MainActor
    func perform() async throws -> some IntentResult {
        await LogServingIntent.logTheGlassInTheBackground()
        return .result()
    }
}
