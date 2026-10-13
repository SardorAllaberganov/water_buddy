//
//  Motion.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 12/10/26.
//

import SwiftUI

/// The curves the app moves on, each named for what moves.
///
/// Motion written from here on names one of these and does not spell a curve of its own. The
/// first build of the page change took its numbers one screen at a time — a 10 pt rise here,
/// 0.3 s there — and the owner, holding it on a phone, saw no animation at all: each was
/// defensible alone and together they were nothing. One list is where "how much does this app
/// move" is decided and can be read.
///
/// **Not every curve in the app is here yet.** Sixteen older call sites still write
/// `.smooth(duration:)` themselves, at five lengths from 0.28 to 0.5 s, and were left as they
/// were: renaming them is a change to every screen with nothing to see for it.
///
/// **Three kinds of motion, and the kind picks the curve.**
/// - A *state that changes* — a figure, a colour, a line of text — `settle`. No overshoot: a
///   number that bounced past its value would have shown a wrong number.
/// - A *thing that arrives* — a capsule, a chip, a marker, a tick — `land`. It passes its place
///   a little and comes back, which is what tells the eye something has been put down.
/// - A *page* — `page`, and under Reduce Motion `pageFade`, which carries nothing across the
///   screen (rule `65-accessibility`).
///
/// The press is not here. Its spring is written in `PressStyle` and `LiquidGlassModifier` and
/// held identical in the two (rule `60-design-system`); it answers a finger, and these do not.
///
/// The numbers are plain `Double`s beside the curves built from them, so `MotionTests` holds
/// them without an `Animation` to take apart. `nonisolated`, and at file scope, so that suite
/// reads them off the main actor (rule `43-concurrency`).
nonisolated enum Motion {

    // MARK: A page

    /// How long a page takes to change. Long enough to see both pages move; short enough that
    /// the second tap of a quick pair is not kept waiting.
    static let pageDuration: Double = 0.45

    /// How long the cross-fade that replaces the slide under Reduce Motion takes.
    static let fadeDuration: Double = 0.25

    /// A page changing: both pages travel a screen's width together.
    static var page: Animation { .smooth(duration: pageDuration) }

    /// A page changing under Reduce Motion: nothing travels.
    static var pageFade: Animation { .smooth(duration: fadeDuration) }

    // MARK: A state

    /// How long a change of state takes. The commonest of the lengths this app's older
    /// `.smooth` call sites write for themselves.
    static let settleDuration: Double = 0.3

    /// A state changing.
    static var settle: Animation { .smooth(duration: settleDuration) }

    // MARK: An arrival

    /// The response and damping of ``land``. Damped under 1, so it overshoots; not far under,
    /// so it does so once (`whatLandsPassesItsPlaceAndDoesNotRing`).
    static let landResponse: Double = 0.5
    static let landDamping: Double = 0.68

    /// Something arriving.
    static var land: Animation { .spring(response: landResponse, dampingFraction: landDamping) }

    /// The same spring as a value, for the one place that needs it as a keyframe and not as an
    /// animation: the vessel's swell.
    static var landSpring: Spring { Spring(response: landResponse, dampingRatio: landDamping) }

    // MARK: Water

    /// The response and damping of ``water``: slower and a little looser than ``land``. A level
    /// is a mass, not a control.
    static let waterResponse: Double = 0.8
    static let waterDamping: Double = 0.62

    /// The level in the vessel rising or falling.
    static var water: Animation { .spring(response: waterResponse, dampingFraction: waterDamping) }

    /// How long a drop takes from the disc that was pressed to the vessel. Shorter than
    /// ``water``'s response, so the level is still on its way up when the drop arrives
    /// (`aDropIsQuickerThanTheLevel`).
    static let dropDuration: Double = 0.42

    /// A drop on its way to the vessel. Eased in and not out: it is falling when it arrives.
    static var drop: Animation { .easeIn(duration: dropDuration) }
}
