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
struct PremiumRim: ViewModifier {

    /// The canvas's 1.5 pt.
    static let width: CGFloat = 1.5

    func body(content: Content) -> some View {
        content.overlay {
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
    }
}

extension View {

    /// Marks a pane as Premium's — only the Settings card carries it (rule `60-design-system`).
    func premiumRim() -> some View {
        modifier(PremiumRim())
    }
}
