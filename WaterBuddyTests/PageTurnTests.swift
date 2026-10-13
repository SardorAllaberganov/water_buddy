//
//  PageTurnTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 12/10/26.
//

import SwiftUI
import Testing
@testable import WaterBuddy

/// Which pages are on screen during a change of tab, and where each stands. Not `@MainActor`:
/// ``PageTurn`` is a plain value, `nonisolated` on purpose (rule `43-concurrency`).
///
/// The pages sit side by side in the bar's order, so a tab to the right comes in from the right.
/// The view only draws what this says; the direction, the count and the order are decided here,
/// where a test can reach them.
struct PageTurnTests {

    private let width: CGFloat = 402

    @Test func theAppOpensOnOnePage() {
        let turn = PageTurn()

        #expect(turn.shown == AppTab.opening)
        #expect(turn.leaving == nil)
        #expect(turn.mounted == [AppTab.opening])
        #expect(turn.offset(of: AppTab.opening, across: width, slides: true) == 0)
    }

    /// No turn has been made when the app opens, and each one is counted. The count is what a
    /// slide's end is matched against, and what tells the first page — which settles in — from
    /// every page after it, which slides in whole.
    @Test func everyTurnIsCounted() {
        var turn = PageTurn()
        #expect(turn.turns == 0)

        turn.turn(to: .history)
        #expect(turn.turns == 1)

        turn.turn(to: .history)
        #expect(turn.turns == 1, "the tab already shown is not a turn")

        turn.turn(to: .home)
        #expect(turn.turns == 2)
    }

    @Test func aTabToTheRightComesInFromTheRight() {
        var turn = PageTurn()
        turn.turn(to: .history)

        #expect(turn.shown == .history)
        #expect(turn.leaving == .home)
        #expect(turn.travel == 1)
        #expect(turn.entry(across: width, slides: true) == width, "it starts a screen to the right")
        #expect(turn.offset(of: .history, across: width, slides: true) == 0, "and ends in place")
    }

    @Test func aTabToTheLeftComesInFromTheLeft() {
        var turn = PageTurn()
        turn.turn(to: .settings)
        turn.settle(turn.turns)
        turn.turn(to: .home)

        #expect(turn.leaving == .settings)
        #expect(turn.travel == -1)
        #expect(turn.entry(across: width, slides: true) == -width)
    }

    /// The two move together: the one leaving ends exactly as far out as the one arriving
    /// began, on the other side. Short of that, a strip of the old page stays on screen.
    @Test func thePageLeavingEndsAWholeWidthAway() {
        var right = PageTurn()
        right.turn(to: .history)
        #expect(right.offset(of: .home, across: width, slides: true) == -width)

        var left = PageTurn()
        left.turn(to: .settings)
        left.settle(left.turns)
        left.turn(to: .history)
        #expect(left.offset(of: .settings, across: width, slides: true) == width)
    }

    /// A tap on the tab already shown is not a turn: nothing leaves, nothing moves.
    @Test func theTabAlreadyShownTurnsNothing() {
        var turn = PageTurn()
        turn.turn(to: .history)
        turn.settle(turn.turns)
        let before = turn

        turn.turn(to: .history)

        #expect(turn == before)
    }

    /// A second tap before the first slide has ended. The page that was leaving is dropped and
    /// the one that was shown leaves in its turn: never three screens alive at once.
    @Test func twoPagesAtMostAreMounted() {
        var turn = PageTurn()
        turn.turn(to: .history)
        turn.turn(to: .settings)

        #expect(turn.shown == .settings)
        #expect(turn.leaving == .history)
        #expect(turn.mounted == [.history, .settings])
    }

    @Test func aTurnThatHasEndedMountsOnePage() {
        var turn = PageTurn()
        turn.turn(to: .history)
        turn.settle(turn.turns)

        #expect(turn.leaving == nil)
        #expect(turn.mounted == [.history])
    }

    /// The first slide's animation ends while the second is half way. Its end is reported for
    /// the turn that started it — and the page that turn brought in is now the one leaving,
    /// which must stay until its own slide is over.
    @Test func anOlderTurnsEndDoesNotEndANewerTurn() {
        var turn = PageTurn()
        turn.turn(to: .history)
        let first = turn.turns
        turn.turn(to: .settings)

        turn.settle(first)

        #expect(turn.leaving == .history)
        #expect(turn.mounted == [.history, .settings])
    }

    /// There and back and there again, inside one slide. The page shown at the end is the page
    /// the first turn brought in — so a check on *which page* is shown would take the first
    /// slide's end for the third's, and the page leaving would vanish part of the way out. The
    /// end is matched to the turn, not to the tab.
    @Test func aTurnBackAndForthInsideOneSlideIsNotEndedByTheFirst() {
        var turn = PageTurn()
        turn.turn(to: .history)
        let first = turn.turns
        turn.turn(to: .home)
        turn.turn(to: .history)

        turn.settle(first)

        #expect(turn.shown == .history)
        #expect(turn.leaving == .home, "the first slide's end removed the page the third is still moving")

        turn.settle(turn.turns)
        #expect(turn.leaving == nil)
    }

    /// Whichever way the turn went, the pages are listed as the bar lists them. The order is
    /// the views' identity order; one that flipped with the direction would rebuild both.
    @Test func thePagesAreMountedInTheBarsOrder() {
        var turn = PageTurn()
        turn.turn(to: .settings)
        #expect(turn.mounted == [.home, .settings])

        turn.settle(turn.turns)
        turn.turn(to: .home)
        #expect(turn.mounted == [.home, .settings])
    }

    /// Under Reduce Motion the page cross-fades: both stand in place, and the one leaving is
    /// the one that fades.
    @Test func underReduceMotionNothingTravels() {
        var turn = PageTurn()
        turn.turn(to: .history)

        #expect(turn.entry(across: width, slides: false) == 0)
        #expect(turn.offset(of: .home, across: width, slides: false) == 0)
        #expect(turn.offset(of: .history, across: width, slides: false) == 0)
        #expect(turn.opacity(of: .home, slides: false) == 0)
        #expect(turn.opacity(of: .history, slides: false) == 1)
    }

    /// When the pages slide, neither fades: the old one is seen all the way out.
    @Test func aPageThatSlidesDoesNotFade() {
        var turn = PageTurn()
        turn.turn(to: .history)

        #expect(turn.opacity(of: .home, slides: true) == 1)
        #expect(turn.opacity(of: .history, slides: true) == 1)
    }
}
