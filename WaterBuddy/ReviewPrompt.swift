//
//  ReviewPrompt.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 15/10/26.
//

import Foundation

/// The app's side of asking iOS for a rating: whether this run may ask at all, how long Home waits,
/// and the version a request is recorded under
/// (`docs/superpowers/specs/2026-10-15-rating-prompt-design.md` §3.6).
///
/// **Whether to ask is not decided here.** That is ``DataManager/claimReviewRequest(version:)``'s,
/// so the decision and its record are one call. Nor is `StoreKit` imported here: only
/// `HomeView.swift` imports it (rule `70-privacy`). App-only — no exception set lists this file.
enum ReviewPrompt {

    /// A DEBUG build's opt-in. Followed by a value, as `-WaterBuddyFreshStart` is: a `-key`
    /// argument takes the next one as its value.
    static let launchArgument = "-WaterBuddyReviewPrompt"

    /// Whether a run launched with `arguments` may ask for a rating.
    ///
    /// **A DEBUG build asks only when launched with ``launchArgument``.** StoreKit shows the request
    /// every time in development, and the UI suite pours on a simulator whose streak may already be
    /// three: a crossing there would meet a system alert. Off, Home never claims, so a DEBUG run
    /// without the argument writes nothing and shows nothing (rule `85-testing`). A Release build
    /// always may; TestFlight shows nothing whatever the app asks.
    static func isEnabled(arguments: [String]) -> Bool {
        #if DEBUG
        arguments.contains(launchArgument)
        #else
        true
        #endif
    }

    /// ``isEnabled(arguments:)`` for this process, read when asked: a process's arguments do not
    /// change while it runs, and reading them costs nothing worth keeping.
    static var isEnabledHere: Bool {
        isEnabled(arguments: ProcessInfo.processInfo.arguments)
    }

    /// How long Home waits after the pour that reached the goal: until the confetti has landed and
    /// gone — the overlay keeps its burst for ``Confetti/duration`` and 0.4 s more — so the request
    /// meets a screen at rest, as Apple's sample waits on its completed scene.
    static var pause: Duration {
        .seconds(Confetti.duration + 0.4)
    }

    /// The version a request is recorded under: the bundle's `CFBundleShortVersionString`, or `""`
    /// when it has none, which ``DataManager/mayRequestReview(reachedToday:streak:askedVersion:version:)``
    /// never asks in. A version is not copy, so reading `Bundle.main` here is outside the strings
    /// rule (rule `70-privacy`, *Localization*).
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
}
