//
//  LiveWaterContentTests.swift
//  WaterBuddyTests
//

import Foundation
import Testing
@testable import WaterBuddy

/// The Live Activity's content (spec `2026-11-27-live-activity-design.md` §3): built from a `WaterSnapshot`, so the
/// activity and the widgets cannot round differently; drawn back as one; and small.
///
/// **Not `@MainActor`, on purpose:** a compile-time canary for rule `43-concurrency`, as `LiveWaterPlanTests` is.
struct LiveWaterContentTests {

    private let snapshot = WaterSnapshot(
        currentWater: 1_300, dailyGoal: 2_000, language: .russian, serving: 330,
        weekTotals: [20_261_126: 1_800], servingGlyph: "waterbottle.fill", theme: .lagoon
    )

    @Test func theContentCarriesTheSnapshotsFigures() {
        let content = LiveWaterAttributes.ContentState(snapshot: snapshot)

        #expect(content.currentWater == 1_300)
        #expect(content.dailyGoal == 2_000)
        #expect(content.serving == 330)
        #expect(content.servingGlyph == "waterbottle.fill")
        #expect(content.languageCode == "ru")
        #expect(content.themeCode == "lagoon")
    }

    /// The activity draws no week, so only the week is lost on the way back.
    @Test func itDrawsBackTheSnapshotItWasMadeFromButTheWeek() {
        let drawn = LiveWaterAttributes.ContentState(snapshot: snapshot).snapshot(stale: false)

        var expected = snapshot
        expected.weekTotals = nil
        #expect(drawn == expected)
        #expect(drawn.percentage == 65, "one rounding, WaterSnapshot's")
    }

    @Test func followDeviceAndAuroraTravelAsTheirAbsence() {
        let content = LiveWaterAttributes.ContentState(snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))

        #expect(content.languageCode == nil)
        #expect(content.themeCode == nil)
        let drawn = content.snapshot(stale: false)
        #expect(drawn.language == .system)
        #expect(drawn.theme == .aurora)
    }

    @Test func aCodeThisBuildDoesNotKnowReadsAsTheDefault() {
        let content = LiveWaterAttributes.ContentState(
            currentWater: 100, dailyGoal: 2_000, serving: 250, servingGlyph: "mug.fill",
            languageCode: "xx", themeCode: "sunset"
        )

        let drawn = content.snapshot(stale: false)
        #expect(drawn.language == .system)
        #expect(drawn.theme == .aurora)
    }

    /// Past its stale date — the day's end — the activity draws what the widgets' midnight entry draws.
    @Test func pastItsStaleDateItDrawsTheNewDayEmpty() {
        let content = LiveWaterAttributes.ContentState(snapshot: snapshot)

        let stale = content.snapshot(stale: true)
        #expect(stale == content.snapshot(stale: false).rolledOver())
        #expect(stale.currentWater == 0)
        #expect(stale.dailyGoal == 2_000, "the goal is kept")
        #expect(stale.language == .russian, "and so is the language")
    }

    @Test func itRoundTripsAndStaysFarUnderActivityKitsFourKilobytes() throws {
        let content = LiveWaterAttributes.ContentState(snapshot: snapshot)

        let data = try JSONEncoder().encode(content)
        #expect(try JSONDecoder().decode(LiveWaterAttributes.ContentState.self, from: data) == content)
        #expect(data.count < 1_024, "the content is \(data.count) bytes")
        #expect(try JSONEncoder().encode(LiveWaterAttributes()).count < 64, "the attributes hold nothing")
    }
}
