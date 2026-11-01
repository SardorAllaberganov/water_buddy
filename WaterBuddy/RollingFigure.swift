//
//  RollingFigure.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import SwiftUI

/// A hero figure that rolls once, from `start` to `final`, as its data draws (spec `2026-11-01-premium-look-design.md`, M2).
///
/// Both ends are finished strings, each made by the caller's own formatter, so a figure in any language rolls between two
/// figures in that language. **Never read for VoiceOver:** the element around it speaks the real value from its first frame,
/// and a picture rendered for sharing passes `rolled: true`.
struct RollingFigure: View {

    let start: String
    let final: String
    let rolled: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// What is drawn. Rolling is travel, so under Reduce Motion the figure stands final (rule `65-accessibility`).
    nonisolated static func shown(start: String, final: String, rolled: Bool, reduceMotion: Bool) -> String {
        rolled || reduceMotion ? final : start
    }

    var body: some View {
        Text(verbatim: Self.shown(start: start, final: final, rolled: rolled, reduceMotion: reduceMotion))
            .contentTransition(.numericText())
            .animation(Motion.roll, value: rolled)
    }
}
