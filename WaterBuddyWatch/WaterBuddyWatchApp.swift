//
//  WaterBuddyWatchApp.swift
//  WaterBuddyWatch
//

import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

@main
struct WaterBuddyWatchApp: App {
    init() {
        // Mirrors the phone's own `WaterBuddyApp.init()` (`_ = WristInbox.shared` before
        // `WristLink.live.activate()`): touching the singleton first is what registers its
        // `WristLink.didReceiveMirrorNotification` observer before any delegate callback could
        // possibly land. `WristView`'s `@State private var model = WristModel.shared` normally does
        // this instead, during window construction — but window content is never built for a
        // `.backgroundTask(.watchConnectivity)` launch (see below), so that path alone leaves a
        // window of time with an activated session and no observer listening. Doing it here too
        // closes it for the ordinary foreground launch as well, for the identical reason the phone
        // side does it unconditionally rather than only on its own background path.
        _ = WristModel.shared
        WristLink.live.activate()
    }

    var body: some Scene {
        WindowGroup {
            WristView()
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
            // evaluates `WindowGroup`'s content, so `WristView`'s `@State` initializer — the only
            // other place `WristModel.shared` gets constructed — never runs. Without this line, a
            // mirror that arrives while the app is woken only for this background task posts to
            // zero observers and is silently dropped, and the `reloadAllTimelines()` below then
            // re-renders the complication from a store `WristModel.apply(_:)` never actually wrote.
            _ = WristModel.shared
            WristLink.live.activate()
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
}
