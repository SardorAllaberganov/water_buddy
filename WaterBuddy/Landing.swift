//
//  Landing.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import SwiftUI

/// How a sheet's content arrives: **the sheet slides in whole, and what is inside moves once it has landed.**
///
/// A sheet is a page that slides in, and ``Arrival``'s DocC records what happens when a page's content moves during its
/// slide: the owner saw a header over sections still fading in. So nothing here starts until ``wait`` has passed.
///
/// It rises further than ``Arrival/rise``, which holds a tab's page to a few points. A sheet has come up from the foot of the
/// screen on the user's tap, so a part may travel, and under about 20 pt nobody sees it travel (`tasks/lessons.md`,
/// 2026-10-12).
///
/// It does not read ``EnvironmentValues/pageSettlesIn``. A sheet inherits that `false` from a page that was turned to.
///
/// A value at file scope and `nonisolated`, so `LandingTests` reads it off the main actor (rule `43-concurrency`).
nonisolated enum Landing {

    /// How long a sheet is given to land.
    static let wait: Duration = .milliseconds(350)

    /// How far a part rises, in points.
    static let rise: CGFloat = 28

    /// How long each part waits for the one above it.
    static let stagger: Double = 0.07

    /// The longest any part waits, however far down the sheet it is.
    static let longestDelay: Double = 0.42

    /// How long the part at `order` waits once the sheet has landed.
    static func delay(order: Int) -> Double {
        min(Double(max(order, 0)) * stagger, longestDelay)
    }

    /// Waits for the sheet to land: `false` if it was gone first, so nothing is set on a sheet that has left (rule
    /// `43-concurrency`).
    static func waitForLanding() async -> Bool {
        do { try await Task.sleep(for: wait) } catch { return false }
        return !Task.isCancelled
    }

    /// What a part is drawn at. Never exactly zero (``Arrival/hiddenOpacity``).
    static func opacity(landed: Bool) -> Double {
        landed ? 1 : Arrival.hiddenOpacity
    }

    /// How far below its place a part is drawn. Under Reduce Motion it fades in where it stands.
    static func lift(landed: Bool, reduceMotion: Bool) -> CGFloat {
        landed || reduceMotion ? 0 : rise
    }
}

private struct LandingModifier: ViewModifier {

    let landed: Bool
    let order: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(Landing.opacity(landed: landed))
            .offset(y: Landing.lift(landed: landed, reduceMotion: reduceMotion))
            // Scoped to the flag (rule `50-views`). There is no way out to animate: a sheet leaves whole.
            .animation(landed ? Motion.land.delay(Landing.delay(order: order)) : nil, value: landed)
    }
}

private struct LandingTracker: ViewModifier {

    @Binding var landed: Bool

    func body(content: Content) -> some View {
        content
            .task {
                if await Landing.waitForLanding() { landed = true }
            }
    }
}

extension View {

    /// Draws this view as arriving with its sheet: hidden until `landed`, then risen and faded in, `order` parts after the
    /// first. The sheet owns the flag and keeps it with ``tracksLanding(_:)``.
    func lands(_ landed: Bool, order: Int) -> some View {
        modifier(LandingModifier(landed: landed, order: order))
    }

    /// Keeps a sheet's landing flag: set ``Landing/wait`` after the sheet is built.
    func tracksLanding(_ landed: Binding<Bool>) -> some View {
        modifier(LandingTracker(landed: landed))
    }
}
