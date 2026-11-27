//
//  LiveWaterPlanTests.swift
//  WaterBuddyTests
//

import Foundation
import Testing
@testable import WaterBuddy

/// Each pass's one decision (spec `2026-11-27-live-activity-design.md` §4), from plain values: the switch, what iOS
/// allows, whether the app is in the foreground, the activity running and the content wanted.
///
/// **Not `@MainActor`, on purpose:** a compile-time canary for rule `43-concurrency`. `LiveWaterPlan` is `nonisolated`
/// and imports Foundation alone, so this suite reads it from no actor at all.
struct LiveWaterPlanTests {

    private let today = LiveWaterAttributes.ContentState(
        currentWater: 750, dailyGoal: 2_000, serving: 250, servingGlyph: "mug.fill", languageCode: nil, themeCode: nil
    )

    /// The day's end, as the owner hands it over: any fixed instant will do here.
    private let midnight = Date(timeIntervalSince1970: 1_795_000_000)

    private func step(
        enabled: Bool = true, allowed: Bool = true, inForeground: Bool = true, running: LiveWaterPlan.Running? = nil
    ) -> LiveWaterPlan.Step {
        LiveWaterPlan.step(
            enabled: enabled, allowed: allowed, inForeground: inForeground,
            running: running, wanted: today, staleDate: midnight
        )
    }

    @Test func offWithNoneRunningDoesNothing() {
        #expect(step(enabled: false) == .nothing)
    }

    @Test func offEndsTheOneRunningAtOnce() {
        #expect(step(enabled: false, running: .init(content: today, staleDate: midnight)) == .end)
    }

    @Test func iOSSayingNoEndsTheOneRunningEvenWithTheSwitchOn() {
        #expect(step(allowed: false, running: .init(content: today, staleDate: midnight)) == .end)
        #expect(step(allowed: false) == .nothing, "and starts none")
    }

    @Test func onInTheForegroundWithNoneRunningStartsOne() {
        #expect(step() == .start)
    }

    /// iOS refuses a start from the background, so the plan never asks for one there: Siri, a reminder's button and
    /// a watch pour update what is running and wait for the app to come forward for the rest.
    @Test func onInTheBackgroundWithNoneRunningStartsNone() {
        #expect(step(inForeground: false) == .nothing)
    }

    @Test func onWithOneRunningUpdatesItWhenItsContentDiffers() {
        var before = today
        before.currentWater = 500
        #expect(step(running: .init(content: before, staleDate: midnight)) == .update)
        #expect(step(inForeground: false, running: .init(content: before, staleDate: midnight)) == .update,
                "a background run may update what it may not start")
    }

    @Test func onWithOneRunningUpdatesItWhenItsStaleDateDiffers() {
        #expect(step(running: .init(content: today, staleDate: midnight.addingTimeInterval(-3_600))) == .update)
        #expect(step(running: .init(content: today, staleDate: nil)) == .update, "a stale date it never had")
    }

    @Test func onWithOneRunningAndNothingNewDoesNothing() {
        #expect(step(running: .init(content: today, staleDate: midnight)) == .nothing)
        #expect(step(inForeground: false, running: .init(content: today, staleDate: midnight)) == .nothing)
    }
}
