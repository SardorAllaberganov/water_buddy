//
//  ScrollDepth.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 12/10/26.
//

import SwiftUI

/// How far a section has receded as it crosses the edge of its scroll view.
///
/// A card that scrolls off a screen is cut by the screen's edge, flat, as if the list were a
/// sheet of paper sliding under a ruler. With this it draws back from the edge as it goes —
/// smaller, by how little of it is left — so the list reads as having depth under the header
/// and the bar.
///
/// **It shrinks and does not fade.** It did both for an hour. A fade is a loss of contrast on
/// text that is still on screen: a card with a third of itself past the top was drawn at about
/// five sixths of its strength while two thirds of it were still being read, and *Measured
/// against your current goal*, 5.49:1 at rest, read about 3.8:1 in a frame of it — under the
/// 4.5:1 floor (rule `65-accessibility`), at any scrolled position the list happened to rest
/// in. A section a few percent smaller has lost no contrast at all.
///
/// **A section that shows all of itself it can is untouched** (`aSectionAtRestIsWhole`,
/// `aCardTallerThanTheScreenIsWholeWhileItFillsIt`).
///
/// **The phase is worked out here, and not asked of SwiftUI.** `scrollTransition` is the API
/// for this, and it was used first. Inside a `List` it never reported a row as being at rest:
/// every row of History stood shrunk and at half strength. So a section is told what span of
/// the screen its scroll view shows (``EnvironmentValues/scrollDepthSpan``), reads where it
/// stands itself, and the arithmetic between the two is ``phase(of:within:)`` — which a test
/// can hold.
///
/// A value at file scope and `nonisolated`: `ScrollDepthTests` reads it off the main actor, and
/// so does the closure SwiftUI runs it from (rule `43-concurrency`).
nonisolated enum ScrollDepth {

    /// The scale of a section that has wholly left.
    static let smallest: Double = 0.92

    /// A span from `top` to `foot`, or `nil` for two numbers that are not one: a bound that is
    /// not finite, or a foot above its top.
    ///
    /// Both come off a view's frame while the screen is being laid out, and a `ClosedRange`
    /// built from a NaN or from bounds the wrong way round traps. This codebase has no traps
    /// (rule `75-diagnostics`); where there is no span, nothing recedes.
    static func span(from top: CGFloat, to foot: CGFloat) -> ClosedRange<CGFloat>? {
        guard top.isFinite, foot.isFinite, top <= foot else { return nil }
        return top...foot
    }

    /// How far out a section standing at `section` — its top and its foot — is from a scroll
    /// view that shows `shown`, both in the screen's own points: `0` while it shows all of
    /// itself it can, down to `-1` as it leaves by the top, up to `1` as it leaves by the foot.
    ///
    /// **Counted by what is left, not by what has crossed**: the share of the section that
    /// *could* be showing — its own height, or the screen's if it is taller — that is not. For
    /// a section shorter than the screen the two are the same thing. For one taller they are
    /// not: counted by what had crossed, a card that filled the screen from top to foot was
    /// never whole, and jumped as its top passed the edge
    /// (`nothingJumpsAsATallCardsTopCrossesTheEdge`).
    static func phase(of section: ClosedRange<CGFloat>, within shown: ClosedRange<CGFloat>) -> Double {
        let leavesByTop = section.lowerBound < shown.lowerBound
        let leavesByFoot = section.upperBound > shown.upperBound
        guard leavesByTop || leavesByFoot else { return 0 }

        let height = max(section.upperBound - section.lowerBound, 1)
        let room = max(min(height, shown.upperBound - shown.lowerBound), 1)
        let showing = max(min(section.upperBound, shown.upperBound) - max(section.lowerBound, shown.lowerBound), 0)
        let gone = Double(min(max(1 - showing / room, 0), 1))

        return leavesByTop ? -gone : gone
    }

    /// The scale at `phase`.
    static func scale(at phase: Double) -> Double {
        1 - (1 - smallest) * min(abs(phase), 1)
    }

    /// What a section shrinks toward at `phase`: the edge of itself that is still on screen, so
    /// it is seen to draw back from the edge it is crossing.
    static func anchor(at phase: Double) -> UnitPoint {
        if phase < 0 { return .bottom }
        if phase > 0 { return .top }
        return .center
    }
}

private struct ScrollDepthSpanKey: EnvironmentKey {
    static let defaultValue: ClosedRange<CGFloat>? = nil
}

extension EnvironmentValues {

    /// What span of the screen the enclosing scroll view shows, top to foot, in the screen's own
    /// points. `nil` where no screen has said, and then nothing recedes.
    var scrollDepthSpan: ClosedRange<CGFloat>? {
        get { self[ScrollDepthSpanKey.self] }
        set { self[ScrollDepthSpanKey.self] = newValue }
    }
}

private struct ScrollDepthModifier: ViewModifier {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scrollDepthSpan) private var span

    func body(content: Content) -> some View {
        // Read here and captured: the closure below is run off the view's own update, and can
        // take a value but not ask the environment.
        //
        // Under Reduce Motion there is nothing to hand it: the effect is a section moving, and
        // a section is then simply cut by the edge, as it always was (rule `65-accessibility`).
        let shown = reduceMotion ? nil : span

        content
            // A visual effect, so a section that recedes takes the room it always took and the
            // list under it does not move. It follows the finger and has no duration of its own.
            .visualEffect { section, proxy in
                let frame = proxy.frame(in: .global)
                let phase: Double
                if let shown, let standing = ScrollDepth.span(from: frame.minY, to: frame.maxY) {
                    phase = ScrollDepth.phase(of: standing, within: shown)
                } else {
                    phase = 0
                }

                return section.scaleEffect(ScrollDepth.scale(at: phase), anchor: ScrollDepth.anchor(at: phase))
            }
    }
}

extension View {

    /// Lets this section recede as it scrolls past the top or the foot of its scroll view
    /// (``ScrollDepth``). For a section of a screen that scrolls; a section at rest is
    /// untouched, and so is every section of a screen that has not said what it shows.
    func scrollDepth() -> some View {
        modifier(ScrollDepthModifier())
    }

    /// Marks this scroll view as one whose sections recede, and tells them what it shows.
    func scrollDepthContainer() -> some View {
        modifier(ScrollDepthContainer())
    }
}

/// Reads what a scroll view shows and hands it to the sections inside.
///
/// From the top of the scroll view's own frame — the safe area's, under the status bar — to the
/// foot of the screen, past the safe area's: a row scrolled under the tab bar is still seen
/// through its glass, and is only cut where the screen ends.
private struct ScrollDepthContainer: ViewModifier {

    @State private var span: ClosedRange<CGFloat>?

    func body(content: Content) -> some View {
        content
            .environment(\.scrollDepthSpan, span)
            .onGeometryChange(for: ClosedRange<CGFloat>?.self) { proxy in
                let frame = proxy.frame(in: .global)
                return ScrollDepth.span(from: frame.minY, to: frame.maxY + proxy.safeAreaInsets.bottom)
            } action: { shown in
                span = shown
            }
    }
}
