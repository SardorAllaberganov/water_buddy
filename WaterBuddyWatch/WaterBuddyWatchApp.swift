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
        WristLink.live.activate()
    }

    var body: some Scene {
        WindowGroup {
            WristView()
        }
        .backgroundTask(.watchConnectivity) {
            WristLink.live.activate()
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
}
