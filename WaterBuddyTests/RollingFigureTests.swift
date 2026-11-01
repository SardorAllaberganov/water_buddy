//
//  RollingFigureTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import Testing
@testable import WaterBuddy

/// What a rolling figure draws. Not `@MainActor`: the value is `nonisolated` on purpose (rule `43-concurrency`).
struct RollingFigureTests {

    @Test func aFigureStartsAtItsStartAndEndsAtItsValue() {
        #expect(RollingFigure.shown(start: "0/30", final: "23/30", rolled: false, reduceMotion: false) == "0/30")
        #expect(RollingFigure.shown(start: "0/30", final: "23/30", rolled: true, reduceMotion: false) == "23/30")
    }

    /// Rolling is travel, and that setting turns travel off: the figure stands final from the first frame.
    @Test func underReduceMotionAFigureStandsFinal() {
        #expect(RollingFigure.shown(start: "0/30", final: "23/30", rolled: false, reduceMotion: true) == "23/30")
    }
}
