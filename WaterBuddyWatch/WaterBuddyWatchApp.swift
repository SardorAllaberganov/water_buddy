//
//  WaterBuddyWatchApp.swift
//  WaterBuddyWatch
//

import SwiftUI

@main
struct WaterBuddyWatchApp: App {
    init() {
        WristLink.live.activate()
    }

    var body: some Scene {
        WindowGroup {
            WristView()
        }
    }
}
