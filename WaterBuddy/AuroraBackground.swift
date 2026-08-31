//
//  AuroraBackground.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftUI

/// Deep blue into purple, with soft colour pushed off-centre and slowly moving. The blobs are not
/// decoration: a perfectly smooth gradient gives the material nothing to blur, and the glass
/// disappears.
///
/// Lives in its own file because all three tabs and `GoalSetupView` stand glass on it. A second
/// copy would be a second light source, which is the one thing the design system exists to
/// prevent — every pane in this product is lit by the same light.
///
/// The *shape* of that light is deliberately app-only. The widget re-expresses the same three
/// lights proportionally in `WidgetAurora`, because ±240pt means nothing on a 158pt canvas; only
/// the colours in ``Aurora`` are shared between the two processes. **The motion is not shared
/// either, and cannot be:** a widget's view is an archive replayed by another process, with no
/// clock to drive anything (rule `40-widget`).
///
/// ## The motion, and the three things that constrain it
///
/// 1. **Reduce Motion draws the resting frame, and the resting frame is the design that shipped.**
///    A perpetual animation owes a Reduce Motion path (rule `65-accessibility`), and here that
///    path is not a degraded version of the effect — it is the exact static backdrop this file
///    drew before the animation existed. ``Light/rest`` and ``Light/opacity`` are those original
///    numbers, and `theRestingLightsAreTheOnesTheStaticBackdropDrew` is what keeps them so.
/// 2. **No light drifts off its own footprint.** The blobs exist to give the material something to
///    blur; one that wandered further than its own radius would take that texture out from under
///    the glass on its way past.
/// 3. **The three periods never re-sync.** Equal or harmonic periods put the lights on a shared
///    beat, which the eye reads as a pulse rather than as weather — the same reason `WaterSurface`
///    interferes two waves at different frequencies instead of scaling one.
///
/// `repeatForever` rather than a `TimelineView`: there is nothing here to recompute per frame, so
/// handing SwiftUI two endpoints and a curve lets the render server carry the whole loop. The
/// vessel uses `TimelineView` because its wave phase genuinely is a function of the clock.
struct AuroraBackground: View {

    /// One of the three lights behind the glass.
    ///
    /// `nonisolated` and `Sendable` so ``AuroraLightTests`` can stay off the main actor — a `View`
    /// is `@MainActor` and a static declared inside one inherits that isolation, which is exactly
    /// what `HomeView.servings` cost before it was marked (rule `43-concurrency`).
    struct Light: Identifiable, Equatable, Sendable {

        /// Where the light rests. Both this and ``alternate`` come from ``Aurora`` — a colour
        /// literal here would be a second palette, and the widget could no longer match it
        /// (rule `60-design-system`).
        let color: Color

        /// Where the light travels to. The point of the feature: what crosses the backdrop is hue,
        /// not merely a shape.
        let alternate: Color

        let size: CGFloat

        /// The offset the static backdrop always drew this light at, and the frame Reduce Motion
        /// renders.
        let rest: CGPoint

        /// How far it wanders from ``rest``. Kept inside `size / 2` so the light never leaves its
        /// own footprint.
        let drift: CGSize

        /// Seconds for one there-and-back. Deliberately not a round multiple of the others.
        let period: Double

        let opacity: Double

        /// The period is unique across the three, which `noTwoLightsShareOrDivideAPeriod` asserts
        /// for its own reasons — so it doubles as a stable identity without inventing an index.
        var id: Double { period }
    }

    /// The three lights, in draw order.
    ///
    /// The periods are 16 / 22.5 / 28.5 seconds — the drift runs about **20% faster** than the
    /// 19 / 27 / 34 it shipped with, at the owner's request.
    ///
    /// Still pairwise non-harmonic, which is the property that matters and the one
    /// `noTwoLightsShareOrDivideAPeriod` protects: doubled to whole seconds they are 32 / 45 / 57,
    /// whose lowest common multiple is 27,360 — so the composition takes **3.8 hours** to
    /// approximately repeat, and never visibly beats. Speeding the lights up by a round factor
    /// would have preserved the ratios exactly and therefore the beat; these were re-chosen
    /// instead.
    nonisolated static let lights: [Light] = [
        Light(
            color: Aurora.blue, alternate: Aurora.cyan,
            size: 340, rest: CGPoint(x: -130, y: -240),
            drift: CGSize(width: 70, height: 90), period: 16, opacity: 0.75
        ),
        Light(
            color: Aurora.magenta, alternate: Aurora.blue,
            size: 320, rest: CGPoint(x: 150, y: 250),
            drift: CGSize(width: -90, height: -60), period: 22.5, opacity: 0.70
        ),
        Light(
            color: Aurora.cyan, alternate: Aurora.magenta,
            size: 210, rest: CGPoint(x: 140, y: -140),
            drift: CGSize(width: -60, height: 80), period: 28.5, opacity: 0.38
        ),
    ]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Flipped once, on appear, to send every light toward its far endpoint. The `repeatForever`
    /// curve does the rest — this is a starting pistol, not a clock.
    @State private var drifting = false

    var body: some View {
        ZStack {
            Aurora.gradient

            ForEach(Self.lights) { light in
                blob(light)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .onAppear { drifting = true }
    }

    private func blob(_ light: Light) -> some View {
        // Reduce Motion never leaves the resting frame, whatever `drifting` says.
        let moved = drifting && !reduceMotion

        return ZStack {
            // Two fills cross-fading, rather than one animated `fill`. A `Shape`'s style is not
            // itself animatable, so interpolating the colour means interpolating two opacities.
            // The blur sits on the `ZStack`, so this costs a second fill and **not** a second blur.
            Circle().fill(light.color).opacity(moved ? 0 : 1)
            Circle().fill(light.alternate).opacity(moved ? 1 : 0)
        }
        .frame(width: light.size, height: light.size)
        .blur(radius: light.size * 0.22)
        .offset(
            x: light.rest.x + (moved ? light.drift.width : 0),
            y: light.rest.y + (moved ? light.drift.height : 0)
        )
        .opacity(light.opacity)
        .animation(
            // `nil` rather than a shorter curve: Reduce Motion is aimed squarely at a loop that
            // never stops, and there is no gentler version of "forever" to offer.
            reduceMotion ? nil : .easeInOut(duration: light.period).repeatForever(autoreverses: true),
            value: moved
        )
    }
}

#Preview {
    AuroraBackground()
}
