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
///
/// **It holds the wider of its two ends from the first frame**, leading-aligned, so a roll never changes its width: a row
/// measured once cannot flip to a column mid-roll, and a start wider than its value is never cut — *0 days* is wider than
/// *1 day*, and Russian's *0 дней* than *2 дня*. Laid out at the value's width alone, a month's tile drew *0 d…* (the final
/// review; `aFigureHoldsTheWiderOfItsTwoEnds`).
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
        ZStack(alignment: .leading) {
            Text(verbatim: start).hidden()
            Text(verbatim: final).hidden()
            Text(verbatim: Self.shown(start: start, final: final, rolled: rolled, reduceMotion: reduceMotion))
                .contentTransition(.numericText())
                .animation(Motion.roll, value: rolled)
        }
    }
}
