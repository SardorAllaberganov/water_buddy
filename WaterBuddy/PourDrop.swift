//
//  PourDrop.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 12/10/26.
//

import SwiftUI

/// The path a drop takes from the disc that was pressed to the vessel.
///
/// A pour used to be a number changing: the disc recoiled, and a moment later the level was
/// higher. Nothing went from one to the other. A drop that does is what ties the press to the
/// water — and it is thrown, not slid: a curve with one control point above the middle of the
/// straight line, so it leaves upward and falls in.
///
/// A value at file scope and `nonisolated`, so `PourArcTests` reads it off the main actor (rule
/// `43-concurrency`).
nonisolated enum PourArc {

    /// How far above the middle of the straight line the curve's control point stands. The drop
    /// itself rises half of it (`aDropRisesAboveTheLineBetween`).
    static let lift: CGFloat = 56

    /// The drop's diameter, in points, as it leaves the disc. At 16 it crossed the screen as a
    /// speck on the first recording; the journey is under half a second
    /// (``Motion/dropDuration``), and a thing that brief has to be large enough to be seen
    /// going.
    static let size: CGFloat = 22

    /// From where in the journey the drop is being taken in by the vessel.
    static let landing: Double = 0.75

    /// Where the drop is, `progress` of the way from `start` to `end`. Held at either end for a
    /// `progress` outside `0...1`, which an animation is free to ask for.
    static func point(at progress: Double, from start: CGPoint, to end: CGPoint) -> CGPoint {
        let t = min(max(progress, 0), 1)
        let control = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2 - lift)

        let leaving = (1 - t) * (1 - t)
        let turning = 2 * (1 - t) * t
        let arriving = t * t

        return CGPoint(
            x: leaving * start.x + turning * control.x + arriving * end.x,
            y: leaving * start.y + turning * control.y + arriving * end.y
        )
    }

    /// How much of the drop is there: whole until ``landing``, then taken in, and gone on
    /// arrival — so it never rests on the vessel's readout.
    static func presence(at progress: Double) -> Double {
        let t = min(max(progress, 0), 1)
        guard t > landing else { return 1 }
        return (1 - t) / (1 - landing)
    }
}

/// A place a drop goes from or to, as the screen that draws both reports them.
nonisolated enum PourPlace: Hashable, Sendable {
    /// The centre of a quick-add disc, by the vessel's slot.
    case disc(String)
    /// The centre of the vessel.
    case vessel
}

/// Where the discs and the vessel stand, gathered from wherever the layout put them.
///
/// Home's column is a `Layout` and its row may be a scroll view; neither hands a child's frame
/// to a sibling. An anchor is the one thing that crosses that, resolved by whoever draws the
/// drop into the space the drop is drawn in.
struct PourPlaces: PreferenceKey {

    static let defaultValue: [PourPlace: Anchor<CGPoint>] = [:]

    static func reduce(value: inout [PourPlace: Anchor<CGPoint>], nextValue: () -> [PourPlace: Anchor<CGPoint>]) {
        value.merge(nextValue()) { _, later in later }
    }
}

/// One drop on its way.
///
/// **Decoration, and only that.** The serving is logged at the press, not when this lands: a
/// pour that waited for an animation would be a pour a quick second tap could beat. So it takes
/// no touch, is hidden from accessibility, and is not drawn at all under Reduce Motion — the
/// screen that owns it does not make one (rule `65-accessibility`).
struct PourDrop: View {

    let start: CGPoint
    let end: CGPoint

    /// Called once, when the drop has reached the vessel.
    let landed: () -> Void

    @State private var progress: Double = 0

    var body: some View {
        Circle()
            // The palette's own water colours, lightest at the top like the surface it joins
            // (rule `60-design-system`).
            .fill(LinearGradient(colors: [Aurora.cyan, Aurora.blue], startPoint: .top, endPoint: .bottom))
            .frame(width: PourArc.size, height: PourArc.size)
            .shadow(color: Aurora.cyan.opacity(0.7), radius: 10)
            .modifier(Flight(progress: progress, start: start, end: end))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            // Scoped to the value that changed (rule `50-views`), and a transaction because the
            // end has to be known: that is when the vessel answers.
            .transaction(value: progress) { transaction in
                transaction.animation = Motion.drop
                transaction.addAnimationCompletion { landed() }
            }
            // In a task and not in `onAppear`: set as the view appears, the value has changed
            // before the first frame and there is no start to fly from.
            .task { progress = 1 }
    }
}

/// Places a drop along ``PourArc`` for a `progress` SwiftUI animates.
///
/// `Animatable`, because a position on a curve cannot be reached by interpolating two points:
/// SwiftUI would draw the straight line. It interpolates `progress` and this asks the arc.
private struct Flight: ViewModifier, Animatable {

    var progress: Double
    let start: CGPoint
    let end: CGPoint

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let presence = PourArc.presence(at: progress)

        content
            .scaleEffect(0.5 + 0.5 * presence)
            .opacity(presence)
            .position(PourArc.point(at: progress, from: start, to: end))
    }
}

extension View {

    /// Swells this view a little and lets it return, each time `landings` goes up: the vessel
    /// taking a drop.
    ///
    /// Two and a half percent, out in a tenth of a second and back over half of one on the
    /// spring everything that lands comes to rest on (``Motion/landSpring``). Larger and the
    /// vessel jumps at the readout inside it; the figure is the thing being read.
    func swells(on landings: Int) -> some View {
        keyframeAnimator(initialValue: 1.0, trigger: landings) { content, scale in
            content.scaleEffect(scale)
        } keyframes: { _ in
            CubicKeyframe(1.025, duration: 0.1)
            SpringKeyframe(1.0, duration: 0.5, spring: Motion.landSpring)
        }
    }
}
