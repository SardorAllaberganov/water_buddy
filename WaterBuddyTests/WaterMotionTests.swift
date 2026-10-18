//
//  WaterMotionTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 18/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

/// The water moves after a pour and then rests (spec `2026-10-18-the-waters-cost-design.md`).
///
/// Deliberately not `@MainActor`: `WaterMotion` is a pure value a view reads, and this suite is the
/// canary that it stays one (rule `43-concurrency`).
struct WaterMotionTests {

    private static let pour = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// Off at the speed the water always travelled — so a pour on a moving surface does not jerk it.
    @Test func theWaterSetsOffAtItsOwnSpeed() {
        let start = WaterMotion.phase(at: Self.pour, since: Self.pour, base: 0)
        let soon = WaterMotion.phase(at: Self.pour.addingTimeInterval(0.001), since: Self.pour, base: 0)
        #expect(abs((soon - start) / 0.001 - WaterMotion.speed) < 0.001)
        #expect(WaterMotion.remaining(at: Self.pour.addingTimeInterval(2), since: Self.pour) == WaterMotion.settling - 2)
    }

    /// Slowing all the way, and never backwards: a surface that stopped dead would read as a stall.
    @Test func theWaterSlowsToAStandstill() {
        let end = Self.pour.addingTimeInterval(WaterMotion.settling)
        let last = WaterMotion.phase(at: end, since: Self.pour, base: 0)
        let justBefore = WaterMotion.phase(at: end.addingTimeInterval(-0.001), since: Self.pour, base: 0)
        #expect((last - justBefore) / 0.001 < 0.01)

        let samples = (0...50).map {
            WaterMotion.phase(at: Self.pour.addingTimeInterval(Double($0) * 0.1), since: Self.pour, base: 0)
        }
        #expect(zip(samples, samples.dropFirst()).allSatisfy { $0 <= $1 })
        #expect(zip(samples, samples.dropFirst()).dropFirst().allSatisfy { pair in
            let (a, b) = pair
            return b - a <= samples[1] - samples[0] + 1e-12
        })
    }

    @Test func theWaterStandsStillOnceItHasSettled() {
        let settled = WaterMotion.phase(at: Self.pour.addingTimeInterval(WaterMotion.settling), since: Self.pour, base: 0.4)
        let later = WaterMotion.phase(at: Self.pour.addingTimeInterval(3_600), since: Self.pour, base: 0.4)
        #expect(settled == later)
        #expect(WaterMotion.remaining(at: Self.pour.addingTimeInterval(WaterMotion.settling), since: Self.pour) == 0)
        #expect(WaterMotion.remaining(at: Self.pour.addingTimeInterval(3_600), since: Self.pour) == 0)
    }

    /// Mid-movement and at rest: the surface carries on from where it stood, never jumping.
    @Test(arguments: [2.0, 30.0])
    func aNewPourCarriesOnFromWhereTheWaterStood(gap: TimeInterval) {
        let base = 0.4
        let next = Self.pour.addingTimeInterval(gap)
        let stood = WaterMotion.phase(at: next, since: Self.pour, base: base)

        let carried = WaterMotion.base(after: base, from: Self.pour, to: next)
        #expect(WaterMotion.phase(at: next, since: next, base: carried) == stood)
        // And from there it moves as any pour's water does.
        let onward = WaterMotion.phase(at: next.addingTimeInterval(1), since: next, base: carried) - carried
        #expect(abs(onward - WaterMotion.phase(at: Self.pour.addingTimeInterval(1), since: Self.pour, base: 0)) < 1e-9)
    }

    /// The first pour of a launch comes after `Date.distantPast`, `HomeView`'s starting value.
    @Test func theFirstPourCarriesOnFromTheRestingSurface() {
        let resting = WaterMotion.phase(at: Self.pour, since: .distantPast, base: 0)
        let carried = WaterMotion.base(after: 0, from: .distantPast, to: Self.pour)
        #expect(WaterMotion.phase(at: Self.pour, since: Self.pour, base: carried) == resting)
        #expect(resting.isFinite)
    }

    /// The owner's ruling of 2026-10-18, on a measurement: settling in 2.5 s rather than 5 cut a
    /// pour's cost by about a quarter, and the slosh is down to 5 % of its height by 2 s anyway.
    @Test func theWaterSettlesInTwoAndAHalfSeconds() {
        #expect(WaterMotion.settling == 2.5)
    }

    @Test func aPourStillAheadOfTheClockMovesNothing() {
        #expect(WaterMotion.phase(at: Self.pour.addingTimeInterval(-3), since: Self.pour, base: 0.4) == 0.4)
        #expect(WaterMotion.remaining(at: Self.pour.addingTimeInterval(-3), since: Self.pour) == 0)
    }
}
