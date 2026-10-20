//
//  WristVessel.swift
//  WaterBuddyWatch
//
//  The glass vessel, watch-sized. Reproduces `HomeView.swift`'s private `WaterVessel`
//  composition — glass circle, water, a readability scrim, the percentage readout — from the
//  shared primitives, since that type is app-only and cannot be imported here.
//

import SwiftUI

/// The vessel draws today's water and the percentage, and describes itself to VoiceOver as one
/// element: the label *Today's hydration* and the phone vessel's own sentence as its value.
///
/// **A display since stage 7, not a control.** For a time the circle was the pour button, and the
/// label, the value and a hint lived on that `Button` in ``WristView`` — rule `65-accessibility`
/// forbids an `.accessibilityElement(children: .ignore)` wrapper around a control. The pour row took
/// the action back (spec 2026-10-20 §3.4), so the element and its two strings came home here.
struct WristVessel: View {
    let face: WristPlan.Face
    let diameter: CGFloat

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    var body: some View {
        ZStack {
            WaterSurface(level: face.progress, phase: 0, amplitude: diameter * 0.02)
                .clipShape(Circle())
                .padding(6)
            WaterReadabilityScrim(diameter: diameter, intensity: Self.scrimIntensity(at: face.progress))
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                // `HomeView`'s own spelling: formatted against the injected locale, and not a
                // `%lld` key the build would extract for nobody to translate.
                Text(face.percentage, format: .number)
                    .font(.system(size: diameter * Self.figureShare, weight: .bold, design: .rounded))
                Text("%")
                    .font(.system(size: Self.signSize(diameter: diameter), weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        // One element again, now that it is no control (rule `65-accessibility`): the label and the
        // value the pour button used to carry for it.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(face.spokenFigures(in: strings, locale: locale))
    }

    /// The percentage and its sign as shares of the diameter — the canvas's 32 and 14 pt in its 100 pt
    /// vessel. A ratio, never a text style: the vessel is a capped container (rule `65-accessibility`).
    nonisolated static let figureShare: CGFloat = 0.32
    nonisolated static let signShare: CGFloat = 0.14

    /// The canvas's own "%" — 14pt bold, the smallest size at which bold text is large text.
    nonisolated static let signFloor: CGFloat = 14

    /// The "%" at ``signShare`` of the diameter, never under ``signFloor``, and bold — so it stays
    /// large text, held to 3:1 over the water, on every watch.
    ///
    /// **The owner's ruling, 2026-10-20.** At the share alone the sign was 11pt in the 46mm watch's
    /// 77pt vessel and 8pt at the 60pt floor: small text, held to 4.5:1, and over a full vessel it
    /// read 3.99:1 there and 4.00:1 on the 40mm. The widget's two readout shadows reached 4.34. At the
    /// canvas's 14pt bold it is large text again, as it was in the 164pt vessel before stage 7, and
    /// reads 3.54:1 at its worst.
    nonisolated static func signSize(diameter: CGFloat) -> CGFloat {
        max(signFloor, diameter * signShare)
    }

    /// The call-site-correct sizing: a circle has one dimension, so it is clamped against both the
    /// width and the height it is offered.
    ///
    /// The 60pt floor: below it the percentage readout and its scrim stop being legible at all, so a
    /// vessel that small is worse than a clipped one.
    nonisolated static func diameter(fitting availableWidth: CGFloat, within availableHeight: CGFloat) -> CGFloat {
        max(60, min(availableWidth, availableHeight))
    }

    /// The level by which the readability scrim is back at full strength: 32%.
    ///
    /// Derived, not chosen. Since stage 7 the vessel's lowest readout is the percentage — the
    /// millilitre line moved out of the water and under the vessel (#44) — and water first reaches its
    /// ink at `(0.36·D − 6) / (D − 12)`: the water's well is inset 6pt, its wave peaks `0.02·D` above
    /// the mean surface, and the figure's ink ends `0.12·D` below the centre — measured off
    /// `ImageRenderer` renders of the empty vessel at 60, 77, 80, 100 and 123pt (0.106 to 0.115)
    /// rather than taken from a font metric, and rounded up, so the figure is assumed lower than it
    /// is. That is 0.325 at the 60pt floor and about 0.34 on real watches; the least, rounded down, is
    /// full before any water can be behind the figure on every size. `WristViewLogicTests` works the
    /// same formula out by hand, and holds the ramp below it too.
    nonisolated static let scrimFullStrengthLevel = 0.32

    /// How much of ``WaterReadabilityScrim`` to lay down: none for an empty vessel, rising with the
    /// water to full strength at ``scrimFullStrengthLevel``, and full from there on.
    ///
    /// The scrim's own DocC is the ruling: somewhere small, where an empty vessel is most of what you
    /// see, a full scrim at 0% "only turns the vessel into a black hole". This one did, at full
    /// strength — every watch's first screen of the day, and the shipped App Store image (known
    /// issue #35). Below the threshold only glass is ever behind the figure, which is large, bold
    /// text held to 3:1.
    ///
    /// **Not the phone widget's `min(1, level * 1.6)`.** That ramp is calibrated to the widget's own
    /// readout and is full only at 62.5%; here water reaches the figure at about a third, where the
    /// widget's ramp would stand at a half. Each small canvas calibrates its ramp to where its own
    /// text sits. The millilitre line's 4.5:1 figures over water (#44) no longer apply: the line is
    /// no longer over water.
    ///
    /// `nonisolated static` and free of view state, so `WristViewLogicTests` can pin it.
    nonisolated static func scrimIntensity(at level: Double) -> Double {
        min(1, max(0, level / scrimFullStrengthLevel))
    }
}

#Preview {
    WristVessel(face: .sample, diameter: 100)
        .background(WristAurora())
}
