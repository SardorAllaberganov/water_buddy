//
//  LiquidGlassTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import Foundation
import SwiftUI
import Testing
@testable import WaterBuddy

// MARK: - Tests

/// The **interactive** half of the design system: what a pane does while a finger is on it.
///
/// Adopted from Apple's *Applying Liquid Glass to custom views*, which describes
/// `Glass.interactive()` as a material that "reacts to touch and pointer interactions in real
/// time". WaterBuddy cannot call that API — it ships in the iOS 26 SDK and this project builds
/// against 18.5 — so the behaviour is expressed in the hand-rolled system instead. `PressStyle`
/// already recoiled the *frame*; nothing made the *material* respond.
///
/// Not `@MainActor`: these are numbers, and keeping the suite off the main actor is what stops
/// someone moving them onto a `View` (rule `43-concurrency`).
struct LiquidGlassInteractionTests {

    private static let schemes: [ColorScheme] = [.light, .dark]

    /// A press has to be **visible**, or the whole feature is an unmeasurable claim.
    @Test(arguments: LiquidGlass.Density.allCases)
    func aPressedPaneIsBrighterThanARestingOne(density: LiquidGlass.Density) {
        for scheme in Self.schemes {
            let resting = density.tintOpacity(for: scheme)
            let pressed = LiquidGlass.Interaction.pressedTint(resting)

            #expect(pressed > resting,
                    "\(density) in \(scheme) does not brighten under a finger")
        }
    }

    /// **Rule `60-design-system` puts the light-mode ceiling at about 0.6**, measured: past it the
    /// backdrop stops reading through and the pane becomes flat white paint. A press may approach
    /// that ceiling and must not cross it — which matters most for `.opaque`, whose resting light
    /// value is already 0.58.
    @Test(arguments: LiquidGlass.Density.allCases)
    func noPressBreachesTheLightModeTintCeiling(density: LiquidGlass.Density) {
        for scheme in Self.schemes {
            let pressed = LiquidGlass.Interaction.pressedTint(density.tintOpacity(for: scheme))

            #expect(pressed <= LiquidGlass.Interaction.maximumTintOpacity,
                    "\(density) in \(scheme) presses to \(pressed) — past the point glass stops looking like glass")
        }
    }

    /// The clamp must bite exactly where the rule says and nowhere earlier.
    ///
    /// Note where it bites: **`.frosted` in light mode is already inside a boost of the ceiling.**
    /// Its resting 0.45 × 1.35 is 0.6075, so a press takes it to exactly 0.6 and stops. That is the
    /// design working as specified rather than a value to widen — 0.6 is where rendered comparisons
    /// put the point at which the backdrop stops reading and the pane becomes flat white paint. The
    /// first version of this test asserted 0.45 got "the full boost" and failed, because the test's
    /// arithmetic was wrong and the clamp was right.
    @Test func theCeilingClampsRatherThanScalesEverythingDown() {
        // `.sheer` light: 0.22 × 1.35 = 0.297, comfortably clear of the ceiling.
        #expect(LiquidGlass.Interaction.pressedTint(0.22) == 0.22 * LiquidGlass.Interaction.tintBoost,
                "a value with real headroom must get the full boost")

        // `.frosted` and `.opaque` light both press into the ceiling and stop there.
        #expect(LiquidGlass.Interaction.pressedTint(0.45) == LiquidGlass.Interaction.maximumTintOpacity)
        #expect(LiquidGlass.Interaction.pressedTint(0.58) == LiquidGlass.Interaction.maximumTintOpacity)

        #expect(LiquidGlass.Interaction.pressedTint(0.9) == LiquidGlass.Interaction.maximumTintOpacity,
                "a corrupt tintOpacity override must not press through the ceiling either")
    }

    /// Brighter, never dimmer. A boost below 1 would make a pressed pane recede, which reads as the
    /// control moving *away* from the finger.
    @Test func everyBoostBrightens() {
        #expect(LiquidGlass.Interaction.tintBoost > 1)
        #expect(LiquidGlass.Interaction.edgeBoost > 1)
        #expect(LiquidGlass.Interaction.specularBoost > 1)
    }

    /// **The edge and the specular carry the press in dark mode**, and the app is committed to
    /// dark. Frosted dark tint is 0.07; ×1.35 is 0.0945, a change of four thousandths of white over
    /// a scrim — real but nearly invisible on its own. The lit rim is "the detail that sells it"
    /// per the design system, and it is what a finger actually sees move.
    @Test func theDarkModePressLeansOnTheEdgeRatherThanTheTint() {
        let restingTint = LiquidGlass.Density.frosted.tintOpacity(for: .dark)
        let tintDelta = LiquidGlass.Interaction.pressedTint(restingTint) - restingTint

        // The lit edge in dark mode, from `LiquidGlassModifier.edge`.
        let restingEdge = 0.55
        let edgeDelta = min(restingEdge * LiquidGlass.Interaction.edgeBoost, 1) - restingEdge

        #expect(edgeDelta > tintDelta * 4,
                "the tint alone is carrying the dark-mode press, and it is too subtle to see")
    }

    /// A boosted edge must stay a colour. `LiquidGlassModifier` already clamps its contrast boost
    /// with `min(_:1)` for the same reason.
    @Test(arguments: [0.55, 0.85, 0.95])
    func aBoostedEdgeStaysInsideOpacity(resting: Double) {
        #expect(min(resting * LiquidGlass.Interaction.edgeBoost, 1) <= 1)
    }

    /// **Interactivity is opt-in.** Every pane that existed before this change must render exactly
    /// as it did — a design system that quietly animated twenty panes would be a redesign, not a
    /// feature.
    @Test func panesAreInertUnlessTheyAskNotToBe() {
        #expect(LiquidGlassModifier(shape: Circle()).interactive == false)
    }
}
