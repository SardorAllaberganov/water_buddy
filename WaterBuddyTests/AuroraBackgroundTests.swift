//
//  AuroraBackgroundTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import Foundation
import SwiftUI
import Testing
@testable import WaterBuddy

// MARK: - Tests

/// The backdrop's **lights**, in the same sense as ``AppTabTests`` and ``HomeServingTests``: what a
/// view offers, pinned where the compiler cannot notice one of them moving.
///
/// Deliberately **not** `@MainActor`. ``AuroraBackground/lights`` is `nonisolated` for the reason
/// `HomeView.servings` is — a `View` is `@MainActor`, so a static declared inside one inherits that
/// isolation and `@Test(arguments:)` evaluates its arguments off the main actor, which cost three
/// *"error in the Swift 6 language mode"* warnings the last time it was missed (rule `43-concurrency`).
struct AuroraLightTests {

    /// **The resting frame is the design that shipped.**
    ///
    /// This is the whole safety net under the animation. Reduce Motion draws the lights at rest and
    /// nothing else, so if these four numbers drift, a user who turns motion off silently gets a
    /// different product — and no rendered check would catch it, because the animated build would
    /// still look right.
    @Test func theRestingLightsAreTheOnesTheStaticBackdropDrew() {
        let resting = AuroraBackground.lights.map { ($0.size, $0.rest.x, $0.rest.y, $0.opacity) }

        #expect(resting.count == 3)
        #expect(resting[0] == (340, -130, -240, 0.75))
        #expect(resting[1] == (320, 150, 250, 0.70))
        #expect(resting[2] == (210, 140, -140, 0.38))
    }

    /// Colour is `Aurora`'s to own (rule `60-design-system`). A light that introduced its own would
    /// be a second palette, and the widget — which re-expresses these same three lights
    /// proportionally in `WidgetAurora` — could no longer match it.
    @Test(arguments: AuroraBackground.lights)
    func everyLightIsPaintedFromTheAuroraPalette(light: AuroraBackground.Light) {
        let palette: Set<Color> = [Aurora.blue, Aurora.magenta, Aurora.cyan]

        #expect(palette.contains(light.color), "a colour literal outside Aurora")
        #expect(palette.contains(light.alternate), "a colour literal outside Aurora")
    }

    /// The point of the feature: each light travels *between two* palette colours, so what moves
    /// across the backdrop is hue and not merely a shape.
    @Test(arguments: AuroraBackground.lights)
    func everyLightActuallyChangesColour(light: AuroraBackground.Light) {
        #expect(light.color != light.alternate,
                "a light that fades to itself is an animation nobody can see")
    }

    /// **No two periods are equal, and none divides another.**
    ///
    /// Shared or harmonic periods make the three lights re-sync on a visible beat, which reads as a
    /// pulse rather than as weather. It is the same reason `WaterSurface` interferes two waves at
    /// different frequencies instead of scaling one: what sells the effect is that it never quite
    /// repeats.
    @Test func noTwoLightsShareOrDivideAPeriod() {
        let periods = AuroraBackground.lights.map(\.period)

        #expect(Set(periods).count == periods.count, "two lights breathing in lockstep")

        for (i, a) in periods.enumerated() {
            for (j, b) in periods.enumerated() where i != j {
                let ratio = max(a, b) / min(a, b)
                #expect(abs(ratio - ratio.rounded()) > 0.05,
                        "\(a)s and \(b)s are near-harmonic, so the backdrop beats")
            }
        }
    }

    /// Glass needs something behind it: a perfectly smooth gradient gives the material nothing to
    /// blur and the panes disappear (rule `60-design-system`). A light that wandered far enough to
    /// leave its own footprint would take that texture with it, so the drift stays inside the
    /// radius.
    @Test(arguments: AuroraBackground.lights)
    func noLightDriftsOffItsOwnFootprint(light: AuroraBackground.Light) {
        let travel = max(abs(light.drift.width), abs(light.drift.height))

        #expect(travel > 0, "a light that does not move is not animated")
        #expect(travel < light.size / 2,
                "this light wanders further than its own radius, so the glass loses its texture")
    }

    /// Slow enough to read as weather rather than as a screensaver. Anything under ~10s starts to
    /// register as motion in peripheral vision while someone is reading the vessel.
    @Test(arguments: AuroraBackground.lights)
    func everyLightMovesSlowly(light: AuroraBackground.Light) {
        #expect(light.period >= 12, "fast enough to be distracting behind body text")
        #expect(light.period <= 60, "so slow the backdrop reads as static anyway")
    }
}

// MARK: - One sky

/// Where a light is on its journey, as a function of one clock every backdrop reads.
///
/// More than one ``AuroraBackground`` is on screen in a session — the tabs' own, the first-run
/// screen's, the serving sheet's — and each used to start its lights when it was first shown.
/// When every tab's screen stood its own and was kept alive, the three ran out of step and the
/// backdrop changed at every change of tab: read in the screens' side margins, three of four
/// cuts moved it by 12.5 to 16.3 levels where four seconds of drift moves it by 3.1 to 5.5
/// (`docs/DESIGN.md`, *One sky*).
///
/// Not `@MainActor`: the animation is asked for its value wherever SwiftUI likes, so everything
/// it reads is `nonisolated` (rule `43-concurrency`).
struct AuroraDriftTests {

    /// A light rests at the start, stands at its far point one period on, and is back a period
    /// after that — the journey `easeInOut(duration:).repeatForever(autoreverses:)` drew.
    @Test func aLightGoesThereAndBackInTwoPeriods() {
        #expect(abs(AuroraDrift.progress(at: 0, period: 16)) < 1e-6)
        #expect(abs(AuroraDrift.progress(at: 16, period: 16) - 1) < 1e-6)
        #expect(abs(AuroraDrift.progress(at: 32, period: 16)) < 1e-6)
        #expect(abs(AuroraDrift.progress(at: 48, period: 16) - 1) < 1e-6)
    }

    /// Slow away from each end and halfway at the middle of a leg: the curve the lights have
    /// always travelled on.
    @Test func theJourneyEasesInAndOut() {
        #expect(abs(AuroraDrift.progress(at: 8, period: 16) - 0.5) < 0.001)
        #expect(AuroraDrift.progress(at: 2, period: 16) < 2.0 / 16)
        #expect(AuroraDrift.progress(at: 14, period: 16) > 14.0 / 16)
    }

    /// The way back is the way out, run backwards — a light never jumps at its far point.
    @Test func theWayBackMirrorsTheWayOut() {
        for step in stride(from: 0.0, through: 16, by: 0.5) {
            let out = AuroraDrift.progress(at: 16 - step, period: 16)
            let back = AuroraDrift.progress(at: 16 + step, period: 16)
            #expect(abs(out - back) < 1e-9, "the two legs part \(step) s from the far point")
        }
    }

    /// **Where a light stands is the clock's to say, and nothing else's.** The animation is
    /// handed the clock and the distance to cover; it is not asked how long it has been running
    /// itself, which is what differed between a screen shown at launch and one shown a minute
    /// later.
    @Test func whereALightStandsIsTheClocksToSay() {
        let drift = AuroraDrift(period: 22.5)

        #expect(drift.displacement(of: 100.0, clock: 0) == 0)
        #expect(abs(drift.displacement(of: 100.0, clock: 22.5) - 100) < 1e-4)
        #expect(drift.displacement(of: 100.0, clock: 75) == 100 * AuroraDrift.progress(at: 75, period: 22.5))
    }

    /// The clock starts when the first backdrop is drawn and never runs backwards, so the app
    /// still opens on the resting frame — the design that shipped.
    @Test func theClockStartsAtNothingAndNeverRunsBackwards() {
        #expect(abs(AuroraClock.elapsed(uptime: AuroraClock.epoch + 5) - 5) < 1e-6)
        #expect(AuroraClock.elapsed(uptime: AuroraClock.epoch) == 0)
        #expect(AuroraClock.elapsed(uptime: AuroraClock.epoch - 30) == 0)
    }

    /// A clock before its start, or a period that is not one, leaves a light at rest — never a
    /// division by zero drawn as a light at infinity.
    @Test func aBrokenClockLeavesTheLightAtRest() {
        #expect(AuroraDrift.progress(at: -5, period: 16) == 0)
        #expect(AuroraDrift.progress(at: 10, period: 0) == 0)
        #expect(AuroraDrift.progress(at: .nan, period: 16) == 0)
    }
}
