//
//  WaterSurface.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftUI

// MARK: - Surface

/// The water itself: two sine surfaces travelling opposite ways, filled with the app's blues.
///
/// Shared by the app and the widget rather than copied, because the two are meant to read as the
/// same body of water and a copy would drift within a release. The caller supplies `phase` — the
/// app drives it from a `TimelineView` clock, a widget freezes it, because a widget's view is
/// archived once and replayed by another process with no clock to run.
struct WaterSurface: View {

    /// How full, `0...1`.
    var level: Double

    /// Where the waves are in their travel, in radians. Constant for a still surface.
    var phase: Double

    /// Peak wave height in points, before the near-empty/near-full damping in ``WaveShape``.
    var amplitude: Double

    var body: some View {
        ZStack {
            // Two waves travelling opposite ways at different rates. One wave reads as a
            // scrolling ribbon; the interference between two reads as a surface — which is as
            // true of a single frozen frame as it is of a moving one.
            WaveShape(level: level, phase: phase * 0.85, amplitude: amplitude, frequency: 1.1)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.35, green: 0.78, blue: 1.0).opacity(0.55),
                                 Color(red: 0.04, green: 0.45, blue: 0.95).opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            WaveShape(level: level, phase: -phase * 1.25 + 1.4, amplitude: amplitude * 0.7, frequency: 1.7)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.45, green: 0.86, blue: 1.0).opacity(0.9),
                                 Color(red: 0.02, green: 0.40, blue: 0.92).opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Readability scrim

/// The plate of shade that keeps the readout legible whatever the level.
///
/// The readout sits over whichever of glass or water happens to be behind it, and those are not
/// equally light: rendered at full, white on the bright cyan surface measures about 1.4:1. This
/// makes the contrast a constant, and reads as depth rather than as a plate.
struct WaterReadabilityScrim: View {

    /// The vessel's diameter, so the falloff scales with it.
    var diameter: CGFloat

    /// How much of the scrim to lay down, `0...1`.
    ///
    /// The app keeps this at 1 so the contrast is a constant whatever the level. Somewhere small,
    /// where an empty vessel is most of what you see, it is worth scaling with how much water is
    /// actually behind the numerals — at 0% there is nothing bright to hold back and a full scrim
    /// only turns the vessel into a black hole.
    var intensity: Double = 1

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.black.opacity(0.45 * intensity), .black.opacity(0.22 * intensity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter * 0.5
                )
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

// MARK: - Wave

/// A filled sine surface. `level` is the animatable one — `phase` may be supplied fresh every
/// frame by a `TimelineView`, so it must not interpolate or it would fight the clock.
struct WaveShape: Shape {

    var level: Double
    var phase: Double
    var amplitude: Double
    var frequency: Double

    var animatableData: Double {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clampedLevel = min(max(level, 0), 1)
        let surfaceY = rect.maxY - rect.height * clampedLevel

        // Flatten the surface as the vessel approaches empty or full: an almost-empty vessel has
        // nothing to slosh, and at the brim a wave would break the circle's silhouette.
        let damping = min(1, clampedLevel * 9) * min(1, (1 - clampedLevel) * 9)
        let peak = amplitude * damping

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: surfaceY))

        let step: CGFloat = 2
        var x = rect.minX
        while x < rect.maxX {
            let position = Double((x - rect.minX) / max(rect.width, 1))
            let y = surfaceY + sin(position * frequency * 2 * .pi + phase) * peak
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }

        let endY = surfaceY + sin(frequency * 2 * .pi + phase) * peak
        path.addLine(to: CGPoint(x: rect.maxX, y: endY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Backdrop

/// Deep blue into purple, with soft colour pushed off-centre. The blobs are not decoration:
/// a perfectly smooth gradient gives the material nothing to blur, and the glass disappears.
///
/// The colour is shared with the widget; the shape of the light is not. `AuroraBackground` in the
/// app blurs three circles at absolute offsets sized for a phone screen, which means nothing in a
/// 158pt widget — see `WidgetAurora` for the same three lights re-expressed proportionally.
enum Aurora {

    static let top = Color(red: 0.04, green: 0.13, blue: 0.52)
    static let bottom = Color(red: 0.36, green: 0.10, blue: 0.62)

    static let blue = Color(red: 0.00, green: 0.55, blue: 1.00)
    static let magenta = Color(red: 0.78, green: 0.25, blue: 0.98)
    static let cyan = Color(red: 0.00, green: 0.85, blue: 0.85)

    static var gradient: LinearGradient {
        LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - Preview

#Preview("Water") {
    ZStack {
        Aurora.gradient.ignoresSafeArea()

        HStack(spacing: 20) {
            ForEach([0.15, 0.5, 0.85], id: \.self) { level in
                ZStack {
                    WaterSurface(level: level, phase: 0.6, amplitude: 90 * 0.035)
                        .clipShape(Circle())
                        .padding(4)
                    WaterReadabilityScrim(diameter: 90)
                }
                .frame(width: 90, height: 90)
                .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
            }
        }
    }
    .preferredColorScheme(.dark)
}
