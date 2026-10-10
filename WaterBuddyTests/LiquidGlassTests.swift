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
/// time". On iOS 26 and later an interactive pane is that glass; these numbers are what the
/// hand-made stack does instead, below iOS 26 and wherever a pane cannot sample its backdrop.
/// `PressStyle` already recoiled the *frame*; nothing made the *material* respond.
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

/// The **flat** half of the design system: what a pane draws when it cannot sample a backdrop —
/// a WidgetKit widget, or (after this suite) a watchOS target, which has no
/// `Color(.secondarySystemBackground)` at all.
struct LiquidGlassBaseTests {

    /// `.material`'s Reduce-Transparency fill must equal `.archived`'s — not merely "some
    /// colour". If a future edit reintroduces a system-material colour here, this is the test
    /// that catches it before the watch target stops compiling again.
    @Test
    func materialAndArchivedAgreeUnderReduceTransparency() {
        #expect(LiquidGlass.Base.material(.thin).opaqueFill == LiquidGlass.Base.archived.opaqueFill)
    }

    /// `.flat`'s own opaque fill is returned verbatim, never substituted.
    @Test
    func flatReturnsItsOwnOpaqueFillUnchanged() {
        let fill = Color(red: 0.5, green: 0.1, blue: 0.9)
        let base = LiquidGlass.Base.flat(translucent: .clear, opaque: fill)
        #expect(base.opaqueFill == fill)
    }
}

/// The **routing** half of the design system: which pane a `liquidGlass(…)` call draws
/// (spec `2026-10-09-premium-redesign-design.md` §3.2).
///
/// Not `@MainActor`, like the two suites above — and here that is also the point being proved: the
/// choice is made without building a view.
struct LiquidGlassRoutingTests {

    /// Built per use: `Base` carries a `Material` and is not `Sendable`, so it may not sit in a
    /// `static let` (rule `43-concurrency`).
    private var material: LiquidGlass.Base { .material(.ultraThinMaterial) }

    /// Reduce Transparency wins over everything, on every OS and for every base. The SDK does not
    /// say what Apple's glass does under that setting, so this system keeps its own answer.
    @Test(arguments: [true, false])
    func reduceTransparencyAlwaysDrawsTheOpaquePane(systemGlassAvailable: Bool) {
        #expect(LiquidGlass.rendering(base: material, reduceTransparency: true, systemGlassAvailable: systemGlassAvailable) == .opaque)
        #expect(LiquidGlass.rendering(base: .archived, reduceTransparency: true, systemGlassAvailable: systemGlassAvailable) == .opaque)
    }

    /// The widget's base. It exists because a widget cannot sample a backdrop, and Apple's glass
    /// samples one — so it never reaches Apple's glass, whatever the OS.
    @Test(arguments: [true, false])
    func aFlatBaseIsAlwaysHandMade(systemGlassAvailable: Bool) {
        #expect(LiquidGlass.rendering(base: .archived, reduceTransparency: false, systemGlassAvailable: systemGlassAvailable) == .handMade)
    }

    @Test func aMaterialBaseDrawsApplesGlassWhereTheSystemHasIt() {
        #expect(LiquidGlass.rendering(base: material, reduceTransparency: false, systemGlassAvailable: true) == .system)
    }

    /// iOS 17 to 25, and for now the watch: exactly the stack every pane drew before this existed.
    @Test func aMaterialBaseFallsBackToTheHandMadeStackWhereItHasNot() {
        #expect(LiquidGlass.rendering(base: material, reduceTransparency: false, systemGlassAvailable: false) == .handMade)
    }

    /// The flag the modifier passes has to be the truth about the system this suite is running on.
    /// Run on iOS 26.5 it must be `true`; run on iOS 18.6 it must be `false`.
    @Test func theAvailabilityFlagMatchesTheRunningSystem() {
        let isTwentySixOrLater = ProcessInfo.processInfo.isOperatingSystemAtLeast(
            OperatingSystemVersion(majorVersion: 26, minorVersion: 0, patchVersion: 0)
        )
        #expect(LiquidGlass.systemGlassAvailable == isTwentySixOrLater)
    }

    /// `.sheer` asks for the least glass. Only a pane that is not a control — the vessel, whose
    /// readout sits on its own scrim — takes Apple's clear variant for it.
    @Test func onlyAnInertSheerPaneTakesTheClearVariant() {
        #expect(LiquidGlass.systemVariant(density: .sheer, interactive: false) == .clear)
        #expect(LiquidGlass.systemVariant(density: .sheer, interactive: true) == .regular)
    }

    /// Anything that carries a label straight on the glass needs the regular variant's legibility.
    @Test(arguments: [LiquidGlass.Density.frosted, .opaque], [true, false])
    func aPaneThatCarriesTextTakesTheRegularVariant(density: LiquidGlass.Density, interactive: Bool) {
        #expect(LiquidGlass.systemVariant(density: density, interactive: interactive) == .regular)
    }

    /// Over this aurora Apple's regular glass comes out light, and most of the app's dimmed text
    /// measured under 4.5:1 on it (`docs/DESIGN.md`, *Apple's glass, measured*) — so the regular
    /// variant is darkened. The clear one is the vessel, whose readout has `WaterReadabilityScrim`
    /// and whose water has to stay the colour it is.
    @Test func onlyTheRegularVariantIsDarkened() {
        #expect(LiquidGlass.systemTintOpacity(for: .regular) > 0)
        #expect(LiquidGlass.systemTintOpacity(for: .clear) == 0)
    }

    /// A floor, and a measured one: every lighter rung was rendered and failed. At `0.44` nine
    /// pairs were under their contrast floor; at `0.48` the dimmest text sat exactly on 4.5:1 once
    /// the aurora had been followed through its swing, with nothing to spare. A lighter glass is
    /// a new measurement first (`docs/DESIGN.md`, *Apple's glass, measured*), and then this number.
    @Test func theTintIsNoLighterThanTheLightestRungThatPassed() {
        #expect(LiquidGlass.systemTintOpacity(for: .regular) >= 0.52)
    }
}

/// The **primary surface**: the one solid thing among the glass (spec §3.3).
///
/// Its fill is solid, so unlike anything on a `Material` its contrast can be derived
/// (rule `65-accessibility`) — which is why this figure is a test and the glass figures are
/// measurements in `docs/DESIGN.md`.
struct PrimarySurfaceTests {

    /// sRGB's transfer function and its inverse. The shade is composited the way the screen
    /// composites it, in encoded space, and the luminance is taken from linear components.
    private func encoded(_ linear: Double) -> Double {
        linear <= 0.0031308 ? linear * 12.92 : 1.055 * pow(linear, 1 / 2.4) - 0.055
    }

    private func linear(_ encoded: Double) -> Double {
        encoded <= 0.04045 ? encoded / 12.92 : pow((encoded + 0.055) / 1.055, 2.4)
    }

    private func luminance(_ channels: [Double]) -> Double {
        0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]
    }

    /// `Aurora.top` on the primary fill, taken at the fill's darkest point: its foot, where the
    /// shade toward `Aurora.top` is strongest. About 13:1 at the head and 10.6:1 here.
    @Test func thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade() {
        let resolved = Aurora.top.resolve(in: EnvironmentValues())
        let ink = [resolved.linearRed, resolved.linearGreen, resolved.linearBlue].map(Double.init)
        let shade = LiquidGlass.Primary.shadeOpacity

        // White leaning toward the ink by `shade`.
        let foot = ink.map { linear((1 - shade) + shade * encoded($0)) }

        let ratio = (luminance(foot) + 0.05) / (luminance(ink) + 0.05)

        #expect(ratio >= 7)
    }
}
