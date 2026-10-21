//
//  PremiumSet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation

/// The sets Premium sells — one case per set, added by the item that builds it (`docs/ROADMAP.md`
/// §5, *Sold as sets*: *understand*, *coached*, *theirs*, *export*).
///
/// **No case in 1.4.1, on purpose.** ``PaywallView/isOffered(arguments:)`` offers the paywall in a
/// Release build only while this has a case, so the first set to land turns the paywall on with it
/// and nothing waits to be remembered. App Review asks an app to say what a subscription buys before
/// asking for it (spec §3.5); with no case there is nothing to say. The paywall's section that lists
/// the sets is written by the first set, with its first row (plan P6).
///
/// `nonisolated`, so the switch counts it from off the main actor (rule `43-concurrency`).
nonisolated enum PremiumSet: CaseIterable, Sendable {}
