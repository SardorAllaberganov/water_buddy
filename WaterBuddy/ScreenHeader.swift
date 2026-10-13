//
//  ScreenHeader.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 11/10/26.
//

import SwiftUI

/// The numbers every tab's screen shares.
///
/// At file scope and `nonisolated`, so `ScreenMetricsTests` reads them off the main actor (rule
/// `43-concurrency`). They are here, beside the header they place, because the header is the
/// thing that has to land in one spot on three screens: each screen used to carry its own, and
/// *Today* stood 4 pt further left and 1.3 pt lower on Home than on History.
nonisolated enum ScreenMetrics {

    /// The side margin. History's week card budgets its day buttons inside it and the row's own
    /// inset (`HistoryView.daySlot(across:count:)`): exactly 44 pt each on the narrowest supported
    /// iPhone, on the floor (`sevenDaysClearTheTapFloorOnTheNarrowestPhone`).
    static let margin: CGFloat = 24

    /// From the top of the safe area to the top of the title's line.
    static let topInset: CGFloat = 16

    /// The least the title's line may be, and the height its accessory is laid out at whatever
    /// it draws. The accessory is a chip on one screen, a button on another and absent on a
    /// third, and each grows with the text at its own rate: a line that took its height from
    /// them stood the title at three heights.
    static let titleLine: CGFloat = 44

    /// The width of one of `count` equal slots across a screen `width` wide, inside the margin. Not
    /// the week card's day slot, which also stands in by the row's inset
    /// (`HistoryView.daySlot(across:count:)`).
    static func slot(of count: Int, across width: CGFloat) -> CGFloat {
        (width - 2 * margin) / CGFloat(max(count, 1))
    }
}

/// The header every tab opens with: the title, a line under it, and whatever shares the title's
/// line.
///
/// **The title comes first.** Home drew its date above the title and History its total below, so
/// one word had two places. A line under the title is the one arrangement both can share without
/// either carrying an empty line.
///
/// The screen supplies the three parts and what they say to VoiceOver — Home's and History's
/// are one heading with a value of its own, Settings' a heading alone (rule
/// `65-accessibility`). The header owns only what must be the same everywhere: the sizes, the
/// line's height, the halo for text on the aurora.
struct ScreenHeader<Title: View, Detail: View, Accessory: View>: View {

    @ViewBuilder var title: Title
    @ViewBuilder var detail: Detail
    @ViewBuilder var accessory: Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 12) {
                title
                    .font(.largeTitle.weight(.bold))
                    // First call on the line's width, and rigid in height: it may shrink for a
                    // long word at a large text size, and for nothing else
                    // (`testTheTitleKeepsItsSizeBesideTheStreak`).
                    .layoutPriority(1)
                    .fixedSize(horizontal: false, vertical: true)
                    // On the texts and not on the stack: an accessory is a pane, and a shadow on
                    // the stack would be cast by it as well.
                    .legibleOnBackdrop()

                Spacer(minLength: 0)

                // Laid out at the line's floor and drawn at its own size, centred on the line.
                // History's `+` is 53 pt at the third text size above the ordinary one, where
                // the title's line is 48: given its own height it made the line 53, and the
                // title, centred in that, stood 2.7 pt lower than on a screen with no accessory
                // (`testTheTitleHoldsItsPlaceWhereItsAccessoryIsTaller`). There it reaches that
                // far past the line each way, into the inset above and beside the line below.
                accessory
                    .frame(height: ScreenMetrics.titleLine)
            }
            .frame(minHeight: ScreenMetrics.titleLine)
            // Rigid, and not only floored. A frame with a least height still reports less than
            // its content when it is offered less, and a stack offers its least flexible child
            // an even share first: in Home's column the line was offered 38 pt, reported its
            // 44 pt floor around a 48 pt title, and the title stood 2 pt above its own line —
            // on Home alone, because a list's row and a scroll view offer a header what it
            // asks for.
            .fixedSize(horizontal: false, vertical: true)

            detail
                .font(.headline)
                .legibleOnBackdrop()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(.white)
    }
}
