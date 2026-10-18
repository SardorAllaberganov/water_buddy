//
//  WaterMotion.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 18/10/26.
//

import Foundation

/// How the app's water moves: for a while after a pour, then still.
///
/// **It rests, and that is the point.** Until 2026-10-18 Home's water travelled for ever on a
/// `TimelineView(.animation)` clock, and every frame rebuilt both waves under the vessel's glass:
/// 17 % of a core on an idle Home and 22 % on the welcome's first step, against 5 % and 3 % with the
/// clock stopped — Debug, on the simulator (spec `2026-10-18-the-waters-cost-design.md`). Moving the
/// waves instead of redrawing them saved too little, and made the pour itself heavier. So the clock
/// runs for ``settling`` after a pour — the slosh's own window — and stops. The owner ruled still
/// water between pours acceptable on 2026-10-18.
///
/// Each pour carries the phase on from where the surface stood, so the water never jumps when it
/// starts again; and the travel slows to its standstill rather than stopping dead, which would read
/// as a stall. A pure value with the clock as a parameter (rule `30-rollover`'s *The clock*), and
/// `nonisolated`, for the non-`@MainActor` suite that pins it (rule `43-concurrency`).
nonisolated enum WaterMotion {

    /// Seconds the water moves after a pour — and the slosh's window, so the two end together.
    ///
    /// 2.5 rather than the slosh's old 5, on the owner's ruling of 2026-10-18: moving water under
    /// glass is what a pour costs — a pour measured 1.65 s of CPU per 5 s, and 0.73 s with the
    /// motion off — and settling in half the time cut it by about a quarter. The slosh, decaying as
    /// `exp(−1.5 t)`, is at 2 % of its height by then. `theWaterSettlesInTwoAndAHalfSeconds` holds it.
    static let settling: TimeInterval = 2.5

    /// Radians a second the water sets off at: the speed the clock always drew it travelling.
    static let speed = 1.1

    /// The phase at `date`: `base`, plus the travel since `pour`, which eases from ``speed`` to a
    /// standstill over ``settling``. A pour still ahead of `date` has moved nothing.
    static func phase(at date: Date, since pour: Date, base: Double) -> Double {
        base + travelled(at: date, since: pour) * speed
    }

    /// The base a pour at `next` starts from: wherever the water stood at that moment, moving or
    /// at rest, after the pour at `previous`. So the surface carries on and never jumps.
    static func base(after base: Double, from previous: Date, to next: Date) -> Double {
        phase(at: next, since: previous, base: base)
    }

    /// Seconds of movement left at `date`, in `0 ... settling` — `0` once settled, and for a pour
    /// still ahead. What decides whether the clock runs at all.
    static func remaining(at date: Date, since pour: Date) -> TimeInterval {
        let elapsed = date.timeIntervalSince(pour)
        guard elapsed >= 0 else { return 0 }
        return max(0, settling - elapsed)
    }

    /// How far the water has travelled since `pour`, in seconds at ``speed``: `u − u²/2` of
    /// ``settling``, `u` the share of it gone — so it sets off at full speed, slows evenly, and
    /// covers half what a constant speed would before it stands.
    private static func travelled(at date: Date, since pour: Date) -> TimeInterval {
        let gone = min(max(date.timeIntervalSince(pour) / settling, 0), 1)
        return settling * (gone - gone * gone / 2)
    }
}
