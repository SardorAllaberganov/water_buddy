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

/// One theme's sky: five colours (spec `2026-11-22-set-c-design.md` §3.4). Aurora's is deep blue into purple, with
/// soft colour pushed off-centre. The blobs are not decoration: a perfectly smooth gradient gives the material
/// nothing to blur, and the glass disappears.
///
/// The colour is shared with the widget and the watch; the shape of the light is not. `AuroraBackground` in the
/// app blurs three circles at absolute offsets sized for a phone screen, which means nothing in a 158pt widget —
/// see `WidgetAurora` for the same three lights re-expressed proportionally.
///
/// **A value, one per theme.** `top` is the sky's head and the ink on white — the primary surface's label, the
/// selection discs' letters — and Apple's glass's tint and the phone's scrim; `bottom` its foot; `first` and
/// `second` the two broad lights, the confetti and the rim; `accent` the third light and every mark, switch and
/// accent line. A view draws the environment's `aurora`, never a palette by name — except water, which is
/// ``classic``'s in every theme (D6). Every value measured on a theme's renders is a function of the theme, beside
/// Aurora's number (rule `60-design-system`).
nonisolated struct Aurora: Equatable, Sendable {
    let top: Color
    let bottom: Color
    let first: Color
    let second: Color
    let accent: Color

    var gradient: LinearGradient {
        LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
    }

    /// The palette the app always drew — Aurora's — and the water's in every theme (D6).
    static let classic = Aurora(
        top: Color(red: 0.04, green: 0.13, blue: 0.52), bottom: Color(red: 0.36, green: 0.10, blue: 0.62),
        first: Color(red: 0.00, green: 0.55, blue: 1.00), second: Color(red: 0.78, green: 0.25, blue: 0.98),
        accent: Color(red: 0.00, green: 0.85, blue: 0.85)
    )
    /// The board's starting values (§3.4), confirmed on renders with the owner; derived values per theme are
    /// measured (D7), never read off these by eye.
    static let lagoon = Aurora(
        top: Color(red: 0.01, green: 0.15, blue: 0.26), bottom: Color(red: 0.00, green: 0.27, blue: 0.33),
        first: Color(red: 0.00, green: 0.60, blue: 0.78), second: Color(red: 0.05, green: 0.58, blue: 0.50),
        accent: Color(red: 0.25, green: 0.88, blue: 0.75)
    )
    static let dusk = Aurora(
        top: Color(red: 0.17, green: 0.04, blue: 0.20), bottom: Color(red: 0.42, green: 0.09, blue: 0.22),
        first: Color(red: 0.95, green: 0.38, blue: 0.22), second: Color(red: 0.90, green: 0.22, blue: 0.50),
        accent: Color(red: 1.00, green: 0.74, blue: 0.30)
    )
    static let midnight = Aurora(
        top: Color(red: 0.04, green: 0.05, blue: 0.09), bottom: Color(red: 0.11, green: 0.12, blue: 0.18),
        first: Color(red: 0.28, green: 0.38, blue: 0.62), second: Color(red: 0.42, green: 0.40, blue: 0.55),
        accent: Color(red: 0.40, green: 0.82, blue: 1.00)
    )
    static let bloom = Aurora(
        top: Color(red: 0.20, green: 0.03, blue: 0.18), bottom: Color(red: 0.36, green: 0.06, blue: 0.34),
        first: Color(red: 0.92, green: 0.30, blue: 0.62), second: Color(red: 0.62, green: 0.30, blue: 0.96),
        accent: Color(red: 1.00, green: 0.66, blue: 0.78)
    )
}

extension AppTheme {
    /// The theme's palette. `palette`, not `aurora`: an instance member may not share the case's name.
    nonisolated var palette: Aurora {
        switch self {
        case .aurora: .classic
        case .lagoon: .lagoon
        case .dusk: .dusk
        case .midnight: .midnight
        case .bloom: .bloom
        }
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .aurora
}

extension EnvironmentValues {
    /// The theme a root injected beside `\.strings` and `\.locale`: the stored one in the app, the snapshot's in a
    /// widget, the mirror's on the watch (rule `50-views`).
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }

    /// The palette every view draws. Read-only: inject ``theme``.
    var aurora: Aurora { theme.palette }
}

/// The seven icons a vessel may wear — the standard three's and four more — in the order the editor offers
/// them (spec `2026-11-22-set-c-design.md` D13).
///
/// **Stored by code**, the raw value, never by symbol name: a symbol Apple renames changes one `case` here and
/// no stored library. Every symbol exists on iOS 17 and watchOS 26 — read from SF Symbols' own availability
/// table; `cup.and.heat.waves.fill` needs iOS 18 and is left out. `VesselGlyphTests` proves each resolves,
/// because an unknown symbol draws nothing at all. Here, beside `vesselSlots`, because the widget's snapshot
/// and the watch read it and this file is in all three exception sets (rule `15-project`).
nonisolated enum VesselGlyph: String, CaseIterable, Codable, Sendable {
    case cup, glass, bottle, wineGlass, takeaway, flask, drop

    /// The SF Symbol drawn for it.
    var symbol: String {
        switch self {
        case .cup: "cup.and.saucer.fill"
        case .glass: "mug.fill"
        case .bottle: "waterbottle.fill"
        case .wineGlass: "wineglass.fill"
        case .takeaway: "takeoutbag.and.cup.and.straw.fill"
        case .flask: "flask.fill"
        case .drop: "drop.fill"
        }
    }

    /// What VoiceOver calls the icon in the vessel editor — the icon, not a vessel's name.
    var spokenKey: String {
        switch self {
        case .cup: "Cup"
        case .glass: "Mug"
        case .bottle: "Bottle"
        case .wineGlass: "Wine glass"
        case .takeaway: "Takeaway cup"
        case .flask: "Flask"
        case .drop: "Drop"
        }
    }

    /// The translated name a standard vessel wears: only the standard three's glyphs have one. A user's vessel
    /// always carries the name they typed.
    var standardNameKey: String? {
        switch self {
        case .cup: "Cup"
        case .glass: "Glass"
        case .bottle: "Bottle"
        case .wineGlass, .takeaway, .flask, .drop: nil
        }
    }

    /// The standard three's glyphs, in their own places: Cup, Glass, Bottle.
    static let standardThree: [VesselGlyph] = [.cup, .glass, .bottle]
}

/// The three quick-add vessels' presentation — names and SF Symbols, smallest first: Cup, Glass,
/// Bottle. The **amounts** live on `DataManager.servings` (state); this is presentation, and lives
/// here — a shared design-token file, not `DataManager.swift` — because `HomeView`, which used to
/// own it, is app-only and unreachable from the watch (`WristView`, Task 15, is the second
/// consumer). Order is load-bearing the same way `DataManager.servings`' order is: index 1 is the
/// vessel the widget's own button draws and logs.
///
/// **Since set C, the standard three's presentation alone**, built from ``VesselGlyph``: what Home, the watch and
/// the one-tap doors draw while no library was ever made (spec `2026-11-22-set-c-design.md` §3.6).
nonisolated let vesselSlots: [(nameKey: String, symbol: String)] = VesselGlyph.standardThree.map {
    (nameKey: $0.standardNameKey ?? "", symbol: $0.symbol)
}

// MARK: - Preview

#Preview("Water") {
    ZStack {
        Aurora.classic.gradient.ignoresSafeArea()

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
