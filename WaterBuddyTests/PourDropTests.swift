//
//  PourDropTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 12/10/26.
//

import SwiftUI
import Testing
@testable import WaterBuddy

/// The path a drop takes from the disc that was pressed to the vessel, as arithmetic. Not
/// `@MainActor`: ``PourArc`` is `nonisolated` on purpose (rule `43-concurrency`).
///
/// What a drop looks like on the way is the view's and is watched on a recording. Where it is
/// at each moment is decided here, so a drop that started beside its disc or stopped short of
/// the vessel would fail a test and not wait for someone to notice.
struct PourArcTests {

    /// A side disc and the vessel above it, as Home lays them out on a 402 pt phone.
    private let disc = CGPoint(x: 96, y: 706)
    private let vessel = CGPoint(x: 201, y: 372)

    @Test func aDropStartsAtTheDisc() {
        #expect(PourArc.point(at: 0, from: disc, to: vessel) == disc)
    }

    @Test func aDropEndsInTheVessel() {
        #expect(PourArc.point(at: 1, from: disc, to: vessel) == vessel)
    }

    /// Thrown, not slid: half way it is above the straight line between the two, by half the
    /// lift — which is where a curve with one control point that far above the middle stands.
    @Test func aDropRisesAboveTheLineBetween() {
        let middle = PourArc.point(at: 0.5, from: disc, to: vessel)

        #expect(PourArc.lift > 0)
        #expect(middle.x == (disc.x + vessel.x) / 2)
        #expect(middle.y == (disc.y + vessel.y) / 2 - PourArc.lift / 2)
    }

    /// An animation may ask for a little before the start or a little past the end. The drop is
    /// held at the disc and at the vessel, and never drawn beyond either.
    @Test func progressOutsideTheJourneyIsHeldAtItsEnds() {
        #expect(PourArc.point(at: -0.4, from: disc, to: vessel) == disc)
        #expect(PourArc.point(at: 1.6, from: disc, to: vessel) == vessel)
    }

    /// It leaves whole and is taken in as it lands: full size and full strength for most of the
    /// way, gone at the end. A drop that faded from the start would be a smear, and one still
    /// whole at the end would sit on the vessel's readout.
    @Test func aDropIsWholeOnTheWayAndGoneWhenItLands() {
        #expect(PourArc.presence(at: 0) == 1)
        #expect(PourArc.presence(at: 0.5) == 1)
        #expect(PourArc.presence(at: 1) == 0)
        #expect(PourArc.presence(at: 0.9) > 0 && PourArc.presence(at: 0.9) < 1)
    }

    /// The Glass stands straight under the vessel. Its drop goes straight up: the lift is
    /// upward, and nothing in the arc pushes a drop sideways that has nowhere sideways to go.
    @Test func aDropFromStraightBelowGoesStraightUp() {
        let glass = CGPoint(x: 201, y: 690)

        for progress in [0.25, 0.5, 0.75] {
            #expect(PourArc.point(at: progress, from: glass, to: vessel).x == 201)
        }
    }
}
