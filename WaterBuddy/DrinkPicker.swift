//
//  DrinkPicker.swift
//  WaterBuddy
//

import SwiftUI

/// The five drinks as capsules — Home's row, above its vessels, and the serving sheet's, above the amount (spec
/// `2026-11-27-other-drinks-design.md` §5, §6). Its own file because two screens draw it (rule `50-views`).
/// App-only: no widget or watch draws a drink (R4).
///
/// **By name, with no glyphs** (D3): iOS has no symbol for milk, and the cup, mug and takeaway glyphs already
/// name vessels. The chosen drink takes `LiquidGlass.Selection`'s fill and rim, as any selected slot does, and
/// lands on it as the sheet's vessel shortcuts do (rule `60-design-system`).
///
/// **On Home each capsule is a glass pane**, sheer — the density for short labels — and interactive, over the
/// aurora, the five in one glass container, on one row. **In the sheet they are drawn inside its glass card**,
/// as the shortcuts beside them are — glass is never laid on glass — on as few lines as fit.
///
/// **The five fit one row of Home on the narrowest supported iPhone at the default text size, in every
/// language** (`theFiveDrinksFitHomeOnTheNarrowestPhoneInEveryLanguage`). The walk found the first row, at 12 pt
/// inside each capsule and 8 between them, 337 pt wide in English against the 327 a 375-pt iPhone leaves Home,
/// and running past the sheet's card on every iPhone narrower than a Plus (2026-11-27): hence the 10 and the 6.
struct DrinkPicker: View {

    /// The drink the row marks as chosen.
    let selection: Drink

    /// Whether each capsule is a glass pane of its own (Home) or drawn inside one (the sheet).
    let glass: Bool

    /// One call per tap; what it does is the screen's.
    let choose: (Drink) -> Void

    @Environment(\.strings) private var strings

    /// A capsule's type at the default text size, scaled with the text (rule `65-accessibility`) and capped
    /// where it is used.
    nonisolated static let typeSize: CGFloat = 15

    /// The room either side of a name, inside its capsule.
    nonisolated static let capsuleInset: CGFloat = 10

    /// A capsule is never narrower than a tap target, however short its name — Spanish's *Té*.
    nonisolated static let capsuleMinimumWidth: CGFloat = 44

    /// Between two capsules, across and, in the sheet, down.
    nonisolated static let spacing: CGFloat = 6

    @ScaledMetric(relativeTo: .subheadline) private var scaledType: CGFloat = DrinkPicker.typeSize

    private var typeSize: CGFloat { min(scaledType, 30) }

    var body: some View {
        if glass {
            // A Dynamic Type escape hatch, as Home's vessel row's is: past the default text size the row may
            // outgrow a narrow iPhone, and then it scrolls rather than squeezing a capsule under its 44 pt
            // floor (rule `65-accessibility`). A bare scroll view would pin the row to the leading edge.
            ViewThatFits(in: .horizontal) {
                row
                ScrollView(.horizontal) {
                    row
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
            }
        } else {
            // A card has edges a scrolling row runs past, and no drink should wait behind a scroll: in the sheet
            // the five wrap, on the lines ``lines(widths:spacing:within:)`` chooses.
            BalancedLines(spacing: Self.spacing) {
                capsules
            }
            .padding(.vertical, 2)
        }
    }

    private var row: some View {
        HStack(spacing: Self.spacing) {
            capsules
        }
        .padding(.vertical, 2)
        // Siblings a few points apart: one container, one sample of the aurora.
        .glassGroup()
    }

    private var capsules: some View {
        ForEach(Drink.allCases, id: \.self) { drink in
            capsule(drink)
        }
    }

    @ViewBuilder
    private func capsule(_ drink: Drink) -> some View {
        let isSelected = drink == selection
        let name = strings.localizedString(forKey: drink.nameKey, value: drink.nameKey, table: nil)

        if glass {
            Button {
                choose(drink)
            } label: {
                label(name, isSelected: isSelected)
                    .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(Text(verbatim: name))
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        } else {
            Button {
                choose(drink)
            } label: {
                label(name, isSelected: isSelected)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: name))
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        }
    }

    /// The name on its capsule: the whole capsule is the target, at least 44 pt high and wide (rule
    /// `65-accessibility`).
    private func label(_ name: String, isSelected: Bool) -> some View {
        // The name in bold, hidden, holds the capsule's width. The chosen drink's name is drawn bold, and without
        // it a choice would widen its capsule: Home's row would shift a point and the sheet's lines could re-flow.
        Text(verbatim: name)
            .font(font(.bold))
            .lineLimit(1)
            .fixedSize()
            .hidden()
            .overlay {
                Text(verbatim: name)
                    .font(font(isSelected ? .bold : .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, Self.capsuleInset)
            .frame(minWidth: Self.capsuleMinimumWidth, minHeight: 44)
            .background {
                Capsule()
                    .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
                    .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
                    // The mark lands on the drink that was chosen, from a little small, as the sheet's
                    // shortcuts' does.
                    .scaleEffect(isSelected ? 1 : 0.9)
                    .animation(Motion.land, value: isSelected)
            }
            .contentShape(Capsule())
    }

    private func font(_ weight: Font.Weight) -> Font {
        .system(size: typeSize, weight: weight, design: .rounded)
    }

    /// The lines the sheet's drinks stand on, as indices in the row's order: the fewest lines on which every line
    /// fits `width`; of those, the split whose widest line is narrowest — five that need two lines stand three
    /// over two, never four over a lone drink — and of equal splits, the one with more on its upper lines. A drink
    /// wider than `width` on its own still gets a line of its own, so none is ever dropped.
    nonisolated static func lines(widths: [CGFloat], spacing: CGFloat, within width: CGFloat) -> [[Int]] {
        let count = widths.count
        guard count > 0 else { return [] }
        func span(_ line: Range<Int>) -> CGFloat {
            widths[line].reduce(0, +) + spacing * CGFloat(line.count - 1)
        }
        for lineCount in 1...count {
            var best: (lines: [Range<Int>], widest: CGFloat)?
            for split in splits(of: count, into: lineCount)
            where split.allSatisfy({ $0.count == 1 || span($0) <= width }) {
                let widest = split.map(span).max() ?? 0
                if let current = best,
                   widest > current.widest || (widest == current.widest && !fuller(split, than: current.lines)) {
                    continue
                }
                best = (split, widest)
            }
            if let best { return best.lines.map { Array($0) } }
        }
        // Unreached: a drink to a line always fits.
        return widths.indices.map { [$0] }
    }

    /// Every way to cut `count` drinks, in order, into `lines` lines of at least one.
    private nonisolated static func splits(of count: Int, into lines: Int) -> [[Range<Int>]] {
        guard lines > 1 else { return [[0..<count]] }
        return (1...(count - lines + 1)).flatMap { first in
            splits(of: count - first, into: lines - 1).map { rest in
                [0..<first] + rest.map { ($0.lowerBound + first)..<($0.upperBound + first) }
            }
        }
    }

    /// Whether `split` holds more on an earlier line than `other`: the tie-break that keeps a longer line on top.
    private nonisolated static func fuller(_ split: [Range<Int>], than other: [Range<Int>]) -> Bool {
        split.map(\.count).lexicographicallyPrecedes(other.map(\.count), by: >)
    }
}

/// The sheet's five on the lines ``DrinkPicker/lines(widths:spacing:within:)`` chooses, each line centred.
private struct BalancedLines: Layout {

    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let rows = lines(of: sizes, within: proposal.width ?? .infinity)
        let widest = rows.map { span(of: $0, sizes) }.max() ?? 0
        let height = rows.map { height(of: $0, sizes) }.reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        // All the width it is offered, so its lines centre in it; the widest line where it is offered none.
        let width = proposal.width.flatMap { $0.isFinite ? $0 : nil } ?? widest
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var y = bounds.minY
        for line in lines(of: sizes, within: bounds.width) {
            let tallest = height(of: line, sizes)
            var x = bounds.midX - span(of: line, sizes) / 2
            for index in line {
                subviews[index].place(
                    at: CGPoint(x: x, y: y + (tallest - sizes[index].height) / 2),
                    proposal: ProposedViewSize(sizes[index])
                )
                x += sizes[index].width + spacing
            }
            y += tallest + spacing
        }
    }

    private func lines(of sizes: [CGSize], within width: CGFloat) -> [[Int]] {
        DrinkPicker.lines(widths: sizes.map(\.width), spacing: spacing, within: width)
    }

    private func span(of line: [Int], _ sizes: [CGSize]) -> CGFloat {
        line.map { sizes[$0].width }.reduce(0, +) + spacing * CGFloat(max(line.count - 1, 0))
    }

    private func height(of line: [Int], _ sizes: [CGSize]) -> CGFloat {
        line.map { sizes[$0].height }.max() ?? 0
    }
}
