//
//  WristGlassTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

/// The watch's half of `theAvailabilityFlagMatchesTheRunningSystem`: the flag the glass modifier
/// passes has to be the truth about the system it runs on, and on the watch that is always yes — its
/// floor is watchOS 26.0, where Apple's glass begins (spec 2026-10-20 §3.3).
///
/// Not `@MainActor`, like the phone's glass suites: the answer is a value (rule `43-concurrency`).
struct WristGlassTests {

    @Test func theWatchDrawsAppleGlass() {
        let floor = OperatingSystemVersion(majorVersion: 26, minorVersion: 0, patchVersion: 0)
        #expect(ProcessInfo.processInfo.isOperatingSystemAtLeast(floor),
                "this runtime is below the watch's own floor — the run proves nothing")
        #expect(LiquidGlass.systemGlassAvailable)
    }
}
