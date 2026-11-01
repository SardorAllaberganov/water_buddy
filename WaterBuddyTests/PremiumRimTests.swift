//
//  PremiumRimTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import Testing
@testable import WaterBuddy

/// The rim's lap of light. Not `@MainActor`, as ``Motion``'s suite is not (rule `43-concurrency`).
struct PremiumRimTests {

    /// The light must be gone at both ends: a rim at rest is the rim, and a picture rendered for sharing never carries it.
    @Test func theLightIsGoneBeforeItStartsAndWhenItEnds() {
        #expect(PremiumRim.lightOpacity(turn: 0, laps: 1) == 0)
        #expect(PremiumRim.lightOpacity(turn: 1, laps: 1) == 0)
        #expect(PremiumRim.lightOpacity(turn: 2, laps: 2) == 0)
    }

    @Test func theLightIsWholeThroughTheLap() {
        #expect(PremiumRim.lightOpacity(turn: 0.5, laps: 1) == 1)
        #expect(PremiumRim.lightOpacity(turn: 1, laps: 2) == 1)
    }

    /// A curve's overshoot, or a turn past its laps, never draws a light below nothing or above whole.
    @Test func theLightStaysInRange() {
        #expect(PremiumRim.lightOpacity(turn: -1, laps: 1) == 0)
        #expect(PremiumRim.lightOpacity(turn: 3, laps: 1) == 0)
    }

    /// Long enough to follow round the card (`tasks/lessons.md`, 2026-10-12), and a purchase is the bigger of the two.
    @Test func aLapIsSeenAndAPurchaseRunsLonger() {
        #expect(PremiumRim.lapDuration >= 1)
        #expect(PremiumRim.purchaseLaps > 1)
    }
}
