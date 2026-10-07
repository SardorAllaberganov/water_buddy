//
//  WaterBuddyWatchApp.swift
//  WaterBuddyWatch
//

import SwiftUI

@main
struct WaterBuddyWatchApp: App {
    init() {
        // Mirrors the phone's own `WaterBuddyApp.init()` (`_ = WristInbox.shared` before
        // `WristLink.live.activate()`): touching the singleton first is what registers its
        // `WristLink.didReceiveMirrorNotification` observer before any delegate callback could
        // possibly land. `WristRoot`'s and `WristView`'s `@State private var model =
        // WristModel.shared` normally do this instead, during window construction — but window
        // content is never built for a `.backgroundTask(.watchConnectivity)` launch (see below),
        // so that path alone leaves a window of time with an activated session and no observer
        // listening. Doing it here too
        // closes it for the ordinary foreground launch as well, for the identical reason the phone
        // side does it unconditionally rather than only on its own background path.
        _ = WristModel.shared
        WristLink.live.activate()
    }

    var body: some Scene {
        WindowGroup {
            WristRoot()
        }
        // `@MainActor in`, explicit: `.backgroundTask`'s closure parameter is a plain
        // `@Sendable () async -> Void`, genuinely off the main actor by default — unlike
        // `WaterBuddyWatchApp.init()` above, which this project's `SWIFT_DEFAULT_ACTOR_ISOLATION =
        // MainActor` already infers as `@MainActor` for free. `WristModel.shared` is `@MainActor`
        // (`WristModel` is `@MainActor @Observable`), so touching it here needs the same explicit
        // hop `WristLink`'s own DocC now documents as this codebase's sanctioned shape for a
        // closure that starts off-main — never a silent inference, and never
        // `MainActor.assumeIsolated`, which would trap here since nothing guarantees this closure
        // runs on the main queue.
        .backgroundTask(.watchConnectivity) { @MainActor in
            // The same touch, required again here specifically: a background-task launch never
            // evaluates `WindowGroup`'s content, so the `@State` initializers in `WristRoot` and
            // `WristView` — the only other places `WristModel.shared` gets constructed — never run.
            // Without this line, a mirror that arrives while the app is woken only for this
            // background task posts to zero observers and is silently dropped.
            _ = WristModel.shared
            WristLink.live.activate()
            // The task ends when this closure returns, and nothing has been delivered yet: activation
            // is asynchronous, and delivery follows it. This used to return here, after reloading the
            // face from the store as it stood, which let the system suspend the app before the mirror
            // it was woken for ever landed. Waiting is what lets `WristModel.apply(_:)` take that
            // mirror — and it reloads the face itself, where the store is written
            // (`docs/superpowers/specs/2026-10-07-complication-current-design.md` §4.2).
            await WristLink.waitForPendingDelivery()
        }
    }
}

// MARK: - Root

/// Injects the language the watch draws in, once, above everything it draws
/// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §4.2).
///
/// A `View` rather than two modifiers on `WristView()` inside `body` above, for the reason the
/// phone's own `RootView` gives: Observation tracks reads made while a *view* body evaluates, and an
/// `App` body is not a reliable scope for it — so a mirror that changes the language would redraw
/// nothing.
///
/// **Both values, together** (rule `70-privacy`). The bundle switches the words; the locale switches
/// how the figures are grouped. One without the other draws `2,000` inside a Russian sentence.
private struct WristRoot: View {
    @State private var model = WristModel.shared

    var body: some View {
        WristView()
            .environment(\.strings, model.language.bundle)
            .environment(\.locale, model.language.locale)
    }
}
