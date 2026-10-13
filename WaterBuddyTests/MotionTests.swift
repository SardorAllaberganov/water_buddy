//
//  MotionTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 12/10/26.
//

import SwiftUI
import Testing
@testable import WaterBuddy

/// The curves the app moves on, as numbers. Not `@MainActor`: ``Motion`` is `nonisolated` on
/// purpose (rule `43-concurrency`), and the suite is the canary that keeps it so.
struct MotionTests {

    /// A page that takes half a second to change is a page the user waits for. The first build of
    /// the page change went the other way — a 10 pt settle the owner did not see on a phone — so
    /// the floor is here too: a slide under a quarter of a second is a cut.
    @Test func aPageChangesInUnderHalfASecond() {
        #expect(Motion.pageDuration < 0.5)
        #expect(Motion.pageDuration >= 0.25)
    }

    /// Under Reduce Motion the page cross-fades. Nothing travels, so there is less to follow and
    /// it is done sooner.
    @Test func theFadeIsShorterThanTheSlide() {
        #expect(Motion.fadeDuration > 0)
        #expect(Motion.fadeDuration < Motion.pageDuration)
    }

    /// What lands passes its place a little and comes back: damped under 1. And it comes back
    /// once: under about 0.6 a spring is still swinging after it should have stopped.
    @Test func whatLandsPassesItsPlaceAndDoesNotRing() {
        #expect(Motion.landDamping < 1)
        #expect(Motion.landDamping >= 0.6)
        #expect(Motion.waterDamping < 1)
        #expect(Motion.waterDamping >= 0.6)
    }

    /// The press has its own spring — a response of 0.28, written in `PressStyle` and
    /// `LiquidGlassModifier` and held identical there (rule `60-design-system`); neither
    /// exposes the number, so it is written here a third time and this is where the two would
    /// be seen to have drifted. These are slower: a thing arriving is not a thing recoiling
    /// under a finger. The level's damping happens to be the press's; its response is what
    /// tells them apart.
    @Test func neitherSpringIsAsQuickAsThePresss() {
        #expect(Motion.landResponse > 0.28)
        #expect(Motion.waterResponse > Motion.landResponse)
    }

    /// The drop's journey is shorter than the level's spring: the level is still on its way up
    /// when the drop arrives, so the water is seen to answer it and not to have finished first.
    @Test func aDropIsQuickerThanTheLevel() {
        #expect(Motion.dropDuration > 0)
        #expect(Motion.dropDuration < Motion.waterResponse)
    }

    /// A state that changes is done before a page is: a figure rolling to its new value should
    /// never be the slowest thing on the screen.
    @Test func aChangeOfStateIsQuickerThanAChangeOfPage() {
        #expect(Motion.settleDuration > 0)
        #expect(Motion.settleDuration < Motion.pageDuration)
    }
}
