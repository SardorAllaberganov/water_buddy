//
//  CelebrationTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import Foundation
import SwiftUI
import Testing
@testable import WaterBuddy

// MARK: - Haptics

/// The feedback ladder. Three rungs, and the distance between them is the whole point — a product
/// where every tap feels identical is one where nothing feels like an achievement.
///
/// Not `@MainActor`: these are plain numbers, and keeping the suite off the main actor is what
/// stops someone quietly moving them onto a `View` (rule `43-concurrency`).
struct HapticLadderTests {

    /// **Water landing is 50% firmer than a confirmation, and `intensity` alone cannot say that.**
    ///
    /// `0.8 × 1.5` is `1.2`, and `SensoryFeedback.impact(intensity:)` saturates at 1. So the
    /// requested increase is split: intensity goes to its ceiling and the *weight* steps up from
    /// `.medium` to `.heavy` to carry what is left. This asserts the arithmetic that made that
    /// necessary, so nobody later "fixes" `pourIntensity` back to 1.2 and wonders why nothing
    /// changed.
    @Test func aPourIsHalfAgainFirmerThanAConfirmation() {
        #expect(Haptics.pourIntensity > Haptics.confirmIntensity)
        #expect(Haptics.pourIntensity == min(1, Haptics.confirmIntensity * 1.5))
        #expect(Haptics.pourIntensity == 1, "the requested 1.2 saturates; the weight carries the rest")
    }

    @Test func everyRungIsWithinTheLegalRange() {
        for intensity in [Haptics.confirmIntensity, Haptics.pourIntensity, Haptics.goalIntensity] {
            #expect(intensity > 0 && intensity <= 1, "an impact intensity outside 0...1 is ignored")
        }
    }

    /// Reaching the goal is the firmest thing the app does. If a pour ever matched it, the moment
    /// the product exists for would feel like every other tap.
    @Test func theGoalIsTheFirmestRung() {
        #expect(Haptics.goalIntensity >= Haptics.pourIntensity)
        #expect(Haptics.goalIntensity > Haptics.confirmIntensity)
    }
}

// MARK: - Confetti

/// The burst is a **pure function of a seed**, which is what makes any of this assertable: a view
/// that reached for `Double.random(in:)` inside its `body` would produce a different burst on every
/// redraw — including the redraws SwiftUI does for its own reasons — and could not be tested at all.
struct ConfettiTests {

    @Test func aBurstHasTheExpectedNumberOfPieces() {
        #expect(Confetti.pieces(seed: 1).count == Confetti.pieceCount)
        #expect(Confetti.pieceCount >= 12, "too sparse to read as a celebration")
        #expect(Confetti.pieceCount <= 60, "a burst nobody asked to render on every goal")
    }

    /// Same seed, same burst. This is what stops the confetti reshuffling itself mid-flight every
    /// time the view is re-evaluated.
    @Test func aBurstIsDeterministic() {
        #expect(Confetti.pieces(seed: 7) == Confetti.pieces(seed: 7))
    }

    /// Different seeds, different bursts — so hitting the goal two days running does not replay a
    /// recording.
    @Test func consecutiveBurstsDiffer() {
        #expect(Confetti.pieces(seed: 1) != Confetti.pieces(seed: 2))
    }

    /// Colour is `Aurora`'s to own (rule `60-design-system`). Confetti is the most tempting place
    /// in the whole app to reach for a fistful of new literals.
    @Test(arguments: [1, 2, 3, 99])
    func everyPieceIsPaintedFromTheAuroraPalette(seed: Int) {
        let palette: Set<Color> = [Aurora.blue, Aurora.magenta, Aurora.cyan]

        for piece in Confetti.pieces(seed: seed) {
            #expect(palette.contains(piece.color), "a colour literal outside Aurora")
        }
    }

    /// A burst that all goes one way is a leak, not a celebration.
    @Test func aBurstThrowsPiecesInEveryDirection() {
        let angles = Confetti.pieces(seed: 3).map(\.angle)
        let quadrants = Set(angles.map { Int(($0 / (.pi / 2)).rounded(.down)) % 4 })

        #expect(quadrants.count == 4, "every piece left through the same side of the screen")
    }

    @Test(arguments: [1, 2, 3, 99])
    func everyPieceIsDrawableAndLands(seed: Int) {
        for piece in Confetti.pieces(seed: seed) {
            #expect(piece.distance > 0, "a piece that never leaves the origin")
            #expect(piece.size > 0)
            #expect(piece.delay >= 0 && piece.delay < Confetti.duration,
                    "a piece that starts after the burst has already faded is never seen")
        }
    }

    /// Long enough to register, short enough that it is gone before the user wants to tap again.
    @Test func theBurstIsBrief() {
        #expect(Confetti.duration > 0.5)
        #expect(Confetti.duration <= 3)
    }
}
