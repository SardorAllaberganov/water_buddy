//
//  PremiumRim.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import SwiftUI

/// Premium's mark: `Aurora`'s cyan, magenta and blue stroked around a standard pane (spec
/// `2026-10-21-premium-paywall-and-monthly-design.md` §3.5, rule `60-design-system`). The one place
/// the gradient is spelled. The pane under it stays the screen's own glass — the canvas's near-opaque
/// fill is not taken — and the rim is drawn over it, outside the pane's content, so it never changes
/// what a reader sees inside.
///
/// **It runs one lap of light as it arrives** (spec `2026-11-01-premium-look-design.md`, M4), from a flag its screen owns:
/// white, a sixth of the way round, gone at both ends. Never on a loop, never under Reduce Motion, and never in a picture
/// rendered for sharing, whose `lit` stays `false`.
struct PremiumRim: ViewModifier {

    /// The canvas's 1.5 pt.
    static let width: CGFloat = 1.5

    /// How long one lap takes.
    nonisolated static let lapDuration: Double = 1.5

    /// A purchase's laps: the largest moment the app has.
    nonisolated static let purchaseLaps = 2

    /// The share of a lap the light takes to come up, and to go.
    nonisolated private static let fade: Double = 0.12

    /// How strong the light is `turn` laps round, of `laps`.
    nonisolated static func lightOpacity(turn: Double, laps: Int) -> Double {
        max(0, min(1, turn / fade, (Double(laps) - turn) / fade))
    }

    let lit: Bool
    let laps: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Aurora.cyan, Aurora.magenta, Aurora.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: Self.width
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .overlay {
                // Present at nothing while the flag is down, so what animates is a light and not a layer (rule `50-views`).
                RimLight(turn: lit && !reduceMotion ? Double(laps) : 0, laps: laps)
                    .animation(lit ? .easeInOut(duration: Self.lapDuration * Double(laps)) : nil, value: lit)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
    }
}

/// The light itself: an arc of an angular gradient, turned by `turn`, in the rim's own shape. `Animatable`, so each frame draws
/// its own angle: a gradient does not interpolate on its own.
private struct RimLight: View, Animatable {

    var turn: Double
    let laps: Int

    var animatableData: Double {
        get { turn }
        set { turn = newValue }
    }

    private static let arc = Gradient(stops: [
        .init(color: .white.opacity(0), location: 0.8),
        .init(color: .white, location: 0.94),
        .init(color: .white.opacity(0), location: 1)
    ])

    var body: some View {
        RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)
            .strokeBorder(
                AngularGradient(gradient: Self.arc, center: .center, angle: .degrees(turn * 360)),
                lineWidth: PremiumRim.width * 1.6
            )
            .opacity(PremiumRim.lightOpacity(turn: turn, laps: laps))
    }
}

extension View {

    /// Marks a pane as Premium's (rule `60-design-system` lists which). `lit`, once up, runs `laps` of light.
    func premiumRim(lit: Bool = false, laps: Int = 1) -> some View {
        modifier(PremiumRim(lit: lit, laps: laps))
    }
}
