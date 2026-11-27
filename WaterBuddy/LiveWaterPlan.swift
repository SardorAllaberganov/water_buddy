//
//  LiveWaterPlan.swift
//  WaterBuddy
//

import Foundation

/// What one pass does to the Live Activity (spec `2026-11-27-live-activity-design.md` §4) — `HealthPlan`'s and
/// `ReminderPlan`'s shape: a pure decision from plain values, so every answer is tested without ActivityKit
/// (`LiveWaterPlanTests`). `LiveWater` carries the answer out.
///
/// **Starting is the foreground's alone.** iOS refuses a start from the background, and with no server nothing else
/// can make one, so a background run — Siri, a reminder's *Log a Glass*, a watch pour — updates what is running and
/// leaves the rest to the app coming forward. **Ending is at once**: the switch going off, or iOS turning WaterBuddy's
/// Live Activities off, takes it off the Lock Screen there and then.
///
/// App-only and `nonisolated`, Foundation alone (rule `43-concurrency`).
nonisolated enum LiveWaterPlan {

    /// The activity iOS says is running — not one it ended, which no longer counts: its content and the stale date it
    /// was given, if any.
    struct Running: Equatable, Sendable {
        var content: LiveWaterAttributes.ContentState
        var staleDate: Date?
    }

    /// One pass's answer.
    enum Step: Equatable, Sendable {
        case start, update, end, nothing
    }

    /// The pass's answer.
    ///
    /// - Parameters:
    ///   - enabled: Settings' switch.
    ///   - allowed: Whether iOS lets WaterBuddy show Live Activities — its per-app setting, or *Don't Allow*.
    ///   - inForeground: Whether the app is in the foreground, the one place a start is allowed.
    ///   - running: The activity running, if one is.
    ///   - wanted: Today, as the activity should draw it.
    ///   - staleDate: When today ends.
    static func step(
        enabled: Bool, allowed: Bool, inForeground: Bool, running: Running?,
        wanted: LiveWaterAttributes.ContentState, staleDate: Date
    ) -> Step {
        guard enabled, allowed else {
            return running == nil ? .nothing : .end
        }
        guard let running else {
            return inForeground ? .start : .nothing
        }
        return running.content == wanted && running.staleDate == staleDate ? .nothing : .update
    }
}
