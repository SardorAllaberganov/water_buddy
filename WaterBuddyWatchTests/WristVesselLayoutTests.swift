//
//  WristVesselLayoutTests.swift
//  WaterBuddyWatchTests
//

import Foundation
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

    /// The call-site bug this pins: `WristView` drew the vessel inside a `.frame(height: 140)` but
    /// sized it with `diameter(fitting:reserving:)` and `reserving: 0`, which reduces that formula to
    /// `max(60, width)` — a ~185pt circle in a 140pt box on a 46mm watch, overflowing into the pour
    /// rows below. Height is the binding constraint on this screen, and the old signature could not
    /// express it. Every real watch width/height pair must fit **both** dimensions.
    @Test(arguments: [
        (CGFloat(184), CGFloat(140)),   // 46mm
        (CGFloat(176), CGFloat(140)),   // 45mm
        (CGFloat(162), CGFloat(140)),   // 42mm
        (CGFloat(155), CGFloat(140)),   // 41mm
        (CGFloat(198), CGFloat(140)),   // 49mm Ultra
    ])
    func theVesselFitsInsideBothItsWidthAndItsHeight(size: (width: CGFloat, height: CGFloat)) {
        let diameter = WristVessel.diameter(fitting: size.width, within: size.height)
        #expect(diameter <= size.width, "a vessel wider than its row clips horizontally")
        #expect(diameter <= size.height, "a vessel taller than its frame overflows into the pour rows")
        #expect(diameter >= 60, "the 60pt floor still holds")
    }

    @Test
    func theHeightConstraintWinsWhenItIsTheTighterOne() {
        // 46mm: 184pt wide, 140pt tall — height is what must bind.
        #expect(WristVessel.diameter(fitting: 184, within: 140) == 140)
    }
}
