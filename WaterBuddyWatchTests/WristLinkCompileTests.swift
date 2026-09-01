//
//  WristLinkCompileTests.swift
//  WaterBuddyWatchTests
//
//  `WristLink` is shared (it lives in `WaterBuddy/DataManager.swift`) and reaches this target
//  through the exception set Task 9 added. This test proves it actually compiles for watchOS with
//  its `#if os(watchOS)` branch live, and that `Sendable`, `NSObject` and `WCSessionDelegate`
//  conformance all hold together on this platform — the claim spec §13 records as "proven to
//  compile, not proven correct".
//

import Testing
@testable import WaterBuddyWatch

struct WristLinkCompileTests {
    @Test
    func wristLinkIsReachableAndSendableOnWatchOS() {
        let link: any Sendable = WristLink.live
        #expect(link is WristLink)
    }
}
