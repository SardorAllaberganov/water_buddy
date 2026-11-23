//
//  AuroraPaletteTests.swift
//  WaterBuddyTests
//

import SwiftUI
import Testing
import UIKit
@testable import WaterBuddy

private func rgb(_ color: Color) -> (r: Double, g: Double, b: Double) {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
    return (Double(r), Double(g), Double(b))
}

private func luminance(_ c: (r: Double, g: Double, b: Double)) -> Double {
    func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b)
}

private func contrast(_ a: (r: Double, g: Double, b: Double), _ b: (r: Double, g: Double, b: Double)) -> Double {
    let (la, lb) = (luminance(a), luminance(b))
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
}

/// The five palettes (spec `2026-11-22-set-c-design.md` §3.4) — the figures arithmetic can hold without a render.
/// **Deliberately not `@MainActor`** (rule `43-concurrency`).
struct AuroraPaletteTests {

    /// Aurora is the palette the app always drew — to the last digit.
    @Test func auroraIsTheClassicPaletteUnchanged() {
        #expect(AppTheme.aurora.palette == .classic)
        let palette = Aurora.classic
        let classic = [palette.top, palette.bottom, palette.first, palette.second, palette.accent].map(rgb)
        let today: [(Double, Double, Double)] = [(0.04, 0.13, 0.52), (0.36, 0.10, 0.62), (0.00, 0.55, 1.00), (0.78, 0.25, 0.98), (0.00, 0.85, 0.85)]
        for (got, want) in zip(classic, today) {
            #expect(abs(got.r - want.0) < 0.001 && abs(got.g - want.1) < 0.001 && abs(got.b - want.2) < 0.001)
        }
    }

    @Test func everyThemeHasItsOwnPalette() {
        #expect(Set(AppTheme.allCases.map { "\($0.palette)" }).count == AppTheme.allCases.count)
    }

    /// §3.4's envelope: no sky's head is lighter than Aurora's, so no theme's tinted glass starts lighter.
    @Test(arguments: AppTheme.allCases)
    func noSkyIsLighterThanAurorasAtItsHead(_ theme: AppTheme) {
        #expect(luminance(rgb(theme.palette.top)) <= luminance(rgb(Aurora.classic.top)) + 0.000_1)
    }

    /// The accent is text in places (the busiest hour, an insight's first line): on its own sky it clears 4.5 by
    /// arithmetic. Only the render says what it reads on glass (D7).
    @Test(arguments: AppTheme.allCases)
    func theAccentClearsTheTextFloorOnItsOwnSky(_ theme: AppTheme) {
        #expect(contrast(rgb(theme.palette.accent), rgb(theme.palette.top)) >= 4.5)
    }

    /// The third light is the accent, in every theme (§3.4).
    @Test(arguments: AppTheme.allCases)
    func theThirdLightIsTheAccent(_ theme: AppTheme) {
        #expect(AuroraBackground.lights(in: theme.palette)[2].color == theme.palette.accent)
    }
}
