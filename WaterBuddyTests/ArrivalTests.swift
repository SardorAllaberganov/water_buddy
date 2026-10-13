//
//  ArrivalTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 11/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

/// How a screen's content settles when its tab is shown, as numbers. Not `@MainActor`: `Arrival`
/// is `nonisolated` on purpose (rule `43-concurrency`).
struct ArrivalTests {

    @Test func theFirstSectionDoesNotWait() {
        #expect(Arrival.delay(order: 0) == 0)
    }

    @Test func eachSectionFollowsTheOneAboveIt() {
        #expect(Arrival.delay(order: 1) > Arrival.delay(order: 0))
        #expect(Arrival.delay(order: 2) > Arrival.delay(order: 1))
    }

    /// A screen of many sections must not keep its last one waiting a second: past a few the
    /// delay stops growing, and the whole arrival is over in well under a second. No screen has
    /// more than four today — a day's servings all arrive as one — so this is the ceiling for
    /// the screen that does.
    @Test func aLongScreenIsNotKeptWaiting() {
        #expect(Arrival.delay(order: 500) == Arrival.longestDelay)
        #expect(Arrival.longestDelay + Arrival.duration <= 0.7)
    }

    @Test func anOrderBelowZeroIsTheFirst() {
        #expect(Arrival.delay(order: -3) == 0)
    }

    /// Enough to be seen as settling, never enough to be a slide across the screen.
    @Test func theRiseIsAFewPoints() {
        #expect(Arrival.rise > 0 && Arrival.rise <= 16)
    }

    /// **A section that has not arrived is never at exactly no opacity.** At exactly zero SwiftUI
    /// drops a view from hit-testing and from the accessibility tree, and on a screen that was kept
    /// while its tab was away the tree did not take it back: after a return every day in History's
    /// week card was drawn, answered a finger, and was reported as impossible to press
    /// (`testAScreenAnswersATapWhenItIsShownAgain`). A page is rebuilt each time it is shown now,
    /// and the floor stays. Under one part in 255 it is drawn as nothing all the same.
    @Test func aSectionThatHasNotArrivedIsNeverAtExactlyNothing() {
        #expect(Arrival.hiddenOpacity > 0)
        #expect(Arrival.hiddenOpacity < 1.0 / 255)
    }

    // MARK: When a section settles in, and when it is simply there

    /// **A page that slides in is whole from its first frame.** For one build its sections
    /// faded in as it travelled: the first was at half strength when the page had covered two
    /// thirds of the way, so what crossed the screen was mostly a header over an empty page —
    /// and a slide is only seen as one if the thing sliding is there to see.
    @Test func aPageThatSlidInIsWholeFromItsFirstFrame() {
        #expect(Arrival.opacity(arrived: false, settles: false) == 1)
        #expect(Arrival.lift(arrived: false, settles: false, reduceMotion: false) == 0)
    }

    /// The page the app opens on has nothing to slide in from. Its sections wait hidden, a
    /// little low, and settle in.
    @Test func aSectionOfTheOpeningPageWaitsHiddenAndLow() {
        #expect(Arrival.opacity(arrived: false, settles: true) == Arrival.hiddenOpacity)
        #expect(Arrival.lift(arrived: false, settles: true, reduceMotion: false) == Arrival.rise)
    }

    @Test func aSectionThatHasArrivedIsInPlace() {
        #expect(Arrival.opacity(arrived: true, settles: true) == 1)
        #expect(Arrival.lift(arrived: true, settles: true, reduceMotion: false) == 0)
    }

    /// Under Reduce Motion a section of the opening page fades in where it stands.
    @Test func underReduceMotionASectionFadesAndDoesNotRise() {
        #expect(Arrival.opacity(arrived: false, settles: true) == Arrival.hiddenOpacity)
        #expect(Arrival.lift(arrived: false, settles: true, reduceMotion: true) == 0)
    }
}
