//
//  WristColumn.swift
//  WaterBuddyWatch
//

import SwiftUI

/// The watch screen's column: the vessel, the line under it, the pour row and the sync caption, with
/// the vessel given what the line and the row leave of the visible height (spec 2026-10-20 §3.4).
///
/// A `Layout`, not a stack, for `HomeColumn`'s reason one device over (rule `50-views`): a stack
/// inside a scroll view is never offered less than its ideal height, so it cannot shrink the vessel
/// to make room for the row. Here every other child is measured at its own height, the vessel takes
/// ``diameter(available:others:range:)``, and the height still spare is split above the vessel and
/// above the row.
///
/// **The last child — the sync caption — gives way to the vessel, never the vessel to it.** It is
/// placed after the row and takes its height from what is spare, so it is on screen wherever it fits
/// beside the vessel and a turn of the crown away where it does not (spec 2026-10-20 §3.4 and §9).
/// Below the vessel's floor the column outgrows the screen and the screen scrolls — on 40 mm and
/// 42 mm, as the redesign's §9.2 allows. The height it fills is ``WristView/columnHeight(safeHeight:bottomInset:)``.
struct WristColumn: Layout {

    /// The visible height to fill.
    var height: CGFloat

    /// The diameters the vessel may take.
    var vessel: ClosedRange<CGFloat>

    /// Which child is the vessel.
    private static let vesselIndex = 0

    /// Between one child and the next. The canvas's figure.
    nonisolated static let gap: CGFloat = 6

    /// What the rest of the column leaves of the visible height, held inside `range`.
    nonisolated static func diameter(available: CGFloat, others: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(available - others, range.lowerBound), range.upperBound)
    }

    /// The vessel's diameter and the height left spare, from the children's own heights in order —
    /// the vessel's own, first, is ignored. Every child after the vessel but the last is subtracted
    /// before the vessel is sized; the last, with its gap, only from what is spare. The diameter is
    /// never wider than the column.
    nonisolated static func arrangement(
        height: CGFloat, width: CGFloat, heights: [CGFloat], range: ClosedRange<CGFloat>
    ) -> (diameter: CGFloat, spare: CGFloat) {
        let gaps = gap * CGFloat(max(0, heights.count - 1))
        let others = heights.dropFirst().reduce(0, +) + gaps
        let givesWay = heights.count > 1 ? (heights.last ?? 0) + gap : 0
        let diameter = min(diameter(available: height, others: others - givesWay, range: range), width)
        return (diameter, max(0, height - others - diameter))
    }

    private func measured(width: CGFloat, _ subviews: Subviews) -> (heights: [CGFloat], spare: CGFloat) {
        var heights = subviews.map { $0.sizeThatFits(ProposedViewSize(width: width, height: nil)).height }
        guard heights.indices.contains(Self.vesselIndex) else { return (heights, 0) }

        let arranged = Self.arrangement(height: height, width: width, heights: heights, range: vessel)
        heights[Self.vesselIndex] = arranged.diameter
        return (heights, arranged.spare)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let plan = measured(width: width, subviews)
        let gaps = Self.gap * CGFloat(max(0, subviews.count - 1))
        return CGSize(width: width, height: plan.heights.reduce(0, +) + gaps + plan.spare)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let plan = measured(width: bounds.width, subviews)
        // The row is the last child the vessel gives way to; the second half of the spare goes
        // above it, so the row and the caption sit low and the vessel high, as the canvas drew them.
        let row = subviews.count - 2
        var y = bounds.minY + plan.spare / 2

        for (index, subview) in subviews.enumerated() {
            if index > 0 { y += Self.gap }
            if index == row, index != Self.vesselIndex { y += plan.spare / 2 }
            let height = plan.heights[index]
            let width = index == Self.vesselIndex ? height : bounds.width
            subview.place(at: CGPoint(x: bounds.midX, y: y), anchor: .top,
                          proposal: ProposedViewSize(width: width, height: height))
            y += height
        }
    }
}
