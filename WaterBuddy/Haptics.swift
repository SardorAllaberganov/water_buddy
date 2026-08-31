//
//  Haptics.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import SwiftUI

/// The app's feedback ladder, in one place.
///
/// Five call sites used to spell `.impact(weight: .medium, intensity: 0.8)` by hand, which was fine
/// while every rung was the same height and became a drift hazard the moment they were not — the
/// same reason ``DataManager/defaultServing`` is a constant rather than a `250` at each front
/// door (rule `00-workspace`).
///
/// App-only. A widget cannot play a haptic: its view is an archive replayed by another process,
/// and `AddWaterIntent` runs without a window to feel (rule `40-widget`).
///
/// ## Why the pour steps the *weight* and not only the intensity
///
/// Water landing is meant to be **half again firmer** than a confirmation. `0.8 × 1.5` is `1.2`,
/// and `SensoryFeedback.impact(intensity:)` saturates at 1 — so intensity alone can deliver only
/// a quarter of the requested increase before it stops meaning anything. The rest is carried by
/// stepping `.medium` to `.heavy`, which is a genuinely different actuator envelope rather than
/// the same tap turned up.
///
/// `aPourIsHalfAgainFirmerThanAConfirmation` asserts that arithmetic, so nobody later restores
/// `1.2` and wonders why the phone feels the same.
enum Haptics {

    /// A choice confirmed — a goal saved, a switch flipped. The app's baseline.
    static let confirmIntensity: Double = 0.8

    /// Water landing. The requested 50% increase, clamped to what the API accepts.
    static let pourIntensity: Double = min(1, confirmIntensity * 1.5)

    /// The goal met — the firmest thing the app does, because it is the moment the product exists
    /// for.
    static let goalIntensity: Double = 1

    static var confirm: SensoryFeedback { .impact(weight: .medium, intensity: confirmIntensity) }

    static var pour: SensoryFeedback { .impact(weight: .heavy, intensity: pourIntensity) }

    /// Deliberately an **impact** rather than `.success`.
    ///
    /// `.success` is the semantically obvious choice and it is a light double-tick — a notification
    /// pattern, designed to be noticed rather than felt. What is wanted here is weight: the one
    /// unmistakable thump in the app. The confetti carries the "well done"; this carries the
    /// landing.
    static var goalReached: SensoryFeedback { .impact(weight: .heavy, intensity: goalIntensity) }
}
