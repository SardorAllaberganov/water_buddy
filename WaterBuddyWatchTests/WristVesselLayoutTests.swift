//
//  WristVesselLayoutTests.swift
//  WaterBuddyWatchTests
//

import Testing
@testable import WaterBuddyWatch

struct WristVesselLayoutTests {
    @Test
    func theVesselNeverExceedsTheAvailableWidth() {
        let diameter = WristVessel.diameter(fitting: 180, reserving: 60)
        #expect(diameter <= 180)
        #expect(diameter > 0)
    }

    @Test
    func reservingMoreSpaceShrinksTheVessel() {
        let generous = WristVessel.diameter(fitting: 180, reserving: 40)
        let tight = WristVessel.diameter(fitting: 180, reserving: 100)
        #expect(tight < generous)
    }
}
