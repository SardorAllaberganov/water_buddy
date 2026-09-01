//
//  WristPlanCompileTests.swift
//  WaterBuddyWatchTests
//
//  The canary that this target can actually reach the shared files at all — if the exception set
//  in `project.pbxproj` (Task 9) or this target's own `fileSystemSynchronizedGroups` regresses,
//  this is the first thing that stops compiling, before any real behavioural test gets the chance
//  to fail for the wrong reason.
//

import Testing
@testable import WaterBuddyWatch

struct WristPlanCompileTests {
    @Test
    func wristPlanIsReachableFromTheWatchTestTarget() {
        let total = WristPlan.todaysTotal(from: [], now: .now, calendar: .waterBuddyDay)
        #expect(total == 0)
    }
}
