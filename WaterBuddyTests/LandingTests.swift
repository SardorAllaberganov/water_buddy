//
//  LandingTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import Foundation
import Testing
@testable import WaterBuddy

/// How a sheet's content arrives, as numbers. Not `@MainActor`: ``Landing`` is `nonisolated` on purpose (rule
/// `43-concurrency`).
struct LandingTests {

    /// Under about 20 pt, motion reads as nothing (`tasks/lessons.md`, 2026-10-12): the owner, holding 10 pt on a phone, saw
    /// the screen "just appear". And a sheet travels further than a tab's page, which comes whole.
    @Test func theRiseIsFarEnoughToBeSeen() {
        #expect(Landing.rise >= 20)
        #expect(Landing.rise > Arrival.rise)
    }

    /// Long enough for the sheet to have landed, short enough that nobody sees it wait.
    @Test func itBeginsAsTheSheetLands() {
        #expect(Landing.wait >= .milliseconds(250))
        #expect(Landing.wait <= .milliseconds(500))
    }

    @Test func eachPartFollowsTheOneAboveIt() {
        #expect(Landing.delay(order: 0) == 0)
        #expect(Landing.delay(order: 1) > Landing.delay(order: 0))
        #expect(Landing.delay(order: 2) > Landing.delay(order: 1))
    }

    @Test func aLongSheetIsNotKeptWaiting() {
        #expect(Landing.delay(order: 500) == Landing.longestDelay)
        #expect(Landing.delay(order: -3) == 0)
        #expect(Landing.longestDelay + Motion.landResponse <= 1)
    }

    /// As ``Arrival/hiddenOpacity``: at exactly zero SwiftUI drops a view from the accessibility tree.
    @Test func aPartThatHasNotLandedIsNeverAtExactlyNothing() {
        #expect(Landing.opacity(landed: false) > 0)
        #expect(Landing.opacity(landed: true) == 1)
    }

    @Test func underReduceMotionAPartFadesWhereItStands() {
        #expect(Landing.lift(landed: false, reduceMotion: true) == 0)
        #expect(Landing.lift(landed: false, reduceMotion: false) == Landing.rise)
        #expect(Landing.lift(landed: true, reduceMotion: false) == 0)
    }

    /// A sheet dragged away at once sets nothing on a view that has gone.
    @Test func aSheetClosedBeforeItLandsSetsNothing() async {
        let waiting = Task { await Landing.waitForLanding() }
        waiting.cancel()
        #expect(await waiting.value == false)
    }
}
