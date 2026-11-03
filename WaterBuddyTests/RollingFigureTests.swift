//
//  RollingFigureTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import SwiftUI
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

/// How wide a rolling figure is, rendered. `@MainActor`, as `ImageRenderer` is; the canary above stays off it.
@MainActor
struct RollingFigureLayoutTests {

    private func width(of view: some View) throws -> CGFloat {
        let renderer = ImageRenderer(content: view.font(.title3.weight(.bold)).fontDesign(.rounded).monospacedDigit())
        renderer.scale = 1
        return try #require(renderer.uiImage, "nothing was rendered").size.width
    }

    /// **A figure is as wide at its start as at its value, and wide enough for both.** A tile measured once never flips
    /// from a row to a column, and a start wider than its value — *0 days* rolling to *1 day*, where the noun's plural is
    /// longer — is never cut (the final review). Laid out at the value's width alone, the start drew *0 d…*.
    @Test func aFigureHoldsTheWiderOfItsTwoEnds() throws {
        let start = try width(of: RollingFigure(start: "0 days", final: "1 day", rolled: false))
        let end = try width(of: RollingFigure(start: "0 days", final: "1 day", rolled: true))
        #expect(start == end)
        #expect(end >= (try width(of: Text(verbatim: "0 days"))))
    }
}
