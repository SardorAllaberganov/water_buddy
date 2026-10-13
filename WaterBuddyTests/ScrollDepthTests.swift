//
//  ScrollDepthTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 12/10/26.
//

import SwiftUI
import Testing
@testable import WaterBuddy

/// How far a section has receded as it crosses the edge of its scroll view, as arithmetic. Not
/// `@MainActor`: ``ScrollDepth`` is `nonisolated` on purpose (rule `43-concurrency`), and it is
/// called from a closure SwiftUI runs wherever it likes.
///
/// The phase is ``ScrollDepth/phase(of:within:)``'s own: `0` for a section that shows all of
/// itself it can, down to `-1` as it leaves by the top and up to `1` as it leaves by the foot.
struct ScrollDepthTests {

    // MARK: What a phase does to a section

    /// A section that is on screen is untouched.
    @Test func aSectionAtRestIsWhole() {
        #expect(ScrollDepth.scale(at: 0) == 1)
    }

    @Test func aSectionAtTheEdgeIsAtItsFloor() {
        #expect(ScrollDepth.scale(at: 1) == ScrollDepth.smallest)
    }

    /// It recedes; it does not collapse. Much smaller and a card reads as shrinking away from
    /// the finger that is moving it.
    @Test func theFloorIsARecedingAndNotADisappearance() {
        #expect(ScrollDepth.smallest >= 0.9 && ScrollDepth.smallest < 1)
    }

    @Test func theTopAndTheFootAreTreatedAlike() {
        #expect(ScrollDepth.scale(at: -0.5) == ScrollDepth.scale(at: 0.5))
        #expect(ScrollDepth.scale(at: -1) == ScrollDepth.scale(at: 1))
    }

    /// Part of the way out is part of the way down, in step with the finger.
    @Test func aSectionHalfWayOutIsHalfWayToItsFloor() {
        #expect(ScrollDepth.scale(at: 0.5) == 1 - (1 - ScrollDepth.smallest) / 2)
    }

    @Test func aPhaseBeyondTheEdgeGoesNoFurther() {
        #expect(ScrollDepth.scale(at: 3) == ScrollDepth.smallest)
        #expect(ScrollDepth.scale(at: -7) == ScrollDepth.smallest)
    }

    /// A section draws back from the edge it is crossing: it shrinks toward the edge of itself
    /// that is still on screen, and at rest toward its middle, where it makes no difference.
    @Test func aSectionHoldsOnToTheEdgeThatIsStillOnScreen() {
        #expect(ScrollDepth.anchor(at: -0.4) == .bottom)
        #expect(ScrollDepth.anchor(at: 0.4) == .top)
        #expect(ScrollDepth.anchor(at: 0) == .center)
    }

    // MARK: How far out a section is

    /// What the scroll view shows, top to foot, in the screen's own points.
    private let shown: ClosedRange<CGFloat> = 60...874

    /// **The one that matters.** SwiftUI's own `scrollTransition` was used for this first, and
    /// inside a `List` it never reported a row as being at rest: every row of History stood at
    /// 0.94 of its size and half strength, on a screen whose every line had been measured whole.
    /// So the phase is worked out here from where a section stands, and a section wholly inside
    /// what the scroll view shows is at exactly nothing.
    @Test func aSectionInsideWhatIsShownHasNotMovedAtAll() {
        #expect(ScrollDepth.phase(of: 60...200, within: shown) == 0)
        #expect(ScrollDepth.phase(of: 400...500, within: shown) == 0)
        #expect(ScrollDepth.phase(of: 800...874, within: shown) == 0)
    }

    @Test func aSectionHalfWayOutByTheTopIsHalfWayGone() {
        #expect(ScrollDepth.phase(of: 10...110, within: shown) == -0.5)
    }

    @Test func aSectionHalfWayOutByTheFootIsHalfWayGone() {
        #expect(ScrollDepth.phase(of: 824...924, within: shown) == 0.5)
    }

    @Test func aSectionWhollyOutIsWhollyGoneAndNoFurther() {
        #expect(ScrollDepth.phase(of: -300...(-100), within: shown) == -1)
        #expect(ScrollDepth.phase(of: 900...1_100, within: shown) == 1)
    }

    /// A section with no height — a row that draws nothing — is never a division by zero.
    @Test func aSectionOfNoHeightIsNotADivisionByZero() {
        #expect(ScrollDepth.phase(of: 20...20, within: shown).isFinite)
        #expect(ScrollDepth.phase(of: 400...400, within: shown).isFinite)
    }

    /// A card taller than the screen can never be wholly inside it. It is whole all the same
    /// for as long as it fills the screen: what counts is how much of what *could* be showing
    /// is. Counted by how much had crossed, such a card was never whole — top-aligned it stood
    /// at nine parts in ten — and it jumped as its top passed the edge.
    @Test func aCardTallerThanTheScreenIsWholeWhileItFillsIt() {
        #expect(ScrollDepth.phase(of: 60...1_060, within: shown) == 0)
        #expect(ScrollDepth.phase(of: 0...1_000, within: shown) == 0)
        #expect(ScrollDepth.phase(of: -300...900, within: shown) == 0)
    }

    /// And once its foot has come up into the screen it is leaving by the top, like any other.
    @Test func aTallCardRecedesOnceItNoLongerFillsTheScreen() {
        let phase = ScrollDepth.phase(of: -533...467, within: shown)

        // 407 of the 814 points the screen shows are still filled: half.
        #expect(phase == -0.5)
    }

    /// One point of scrolling is never a jump. The old arithmetic went from 0.186 to nothing
    /// as a tall card's top crossed the edge.
    @Test func nothingJumpsAsATallCardsTopCrossesTheEdge() {
        let before = ScrollDepth.phase(of: 60...1_060, within: shown)
        let after = ScrollDepth.phase(of: 59...1_059, within: shown)

        #expect(abs(before - after) < 0.01)
    }

    // MARK: A span read off live geometry

    /// A `ClosedRange` traps on bounds that are not numbers or are the wrong way round, and
    /// these come from a view's frame while it is being laid out. Whatever is not a span is no
    /// span, and then nothing recedes.
    @Test func aSpanOfNonsenseIsNoSpan() {
        #expect(ScrollDepth.span(from: 5, to: 10) == 5...10)
        #expect(ScrollDepth.span(from: 7, to: 7) == 7...7)
        #expect(ScrollDepth.span(from: .nan, to: 10) == nil)
        #expect(ScrollDepth.span(from: 5, to: .infinity) == nil)
        #expect(ScrollDepth.span(from: 10, to: 5) == nil)
    }
}
