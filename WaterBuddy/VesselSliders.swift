//
//  VesselSliders.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import SwiftUI

/// The three quick-add vessels' rows — each one's glyph, name and amount over its slider — for
/// amounts the caller holds.
///
/// **Two screens draw them, and each keeps what is set its own way.** Settings' vessels card saves a
/// change as its slider is let go; the welcome's vessels step keeps the amounts until the welcome
/// ends. So that stays with the caller: this view moves the amounts under a finger, ticks each step,
/// and says when a finger lands and lifts (``onDrag``), and nothing else. It was the inside of
/// `SettingsView`'s `ServingsCard` until the welcome became the second screen to ask; one view is
/// what keeps the two from drifting apart (rule `50-views`).
///
/// Ascent is deliberately **not** enforced. Making an edit to Cup push Glass out of its way would
/// silently change what the widget logs; see ``DataManager/servings``.
struct VesselSliders: View {

    /// Cup, Glass, Bottle — positional and exactly three (``DataManager/servings``).
    @Binding var amounts: [Int]

    /// Told `true` as a finger lands on a slider and `false` as it lifts. Settings saves on the
    /// lift; the welcome does not listen.
    var onDrag: (Bool) -> Void = { _ in }

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// Which vessel's slider is held, by slot. Its figure is drawn a little larger meanwhile, and a
    /// step is ticked only while one is.
    @State private var held: Int?

    /// Bumped each time a drag moves a vessel by a step: the tick under the finger. A counter the
    /// slider bumps, not the amount, so an amount the caller takes from a re-read never ticks
    /// (rule `60-design-system`, *Haptics*).
    @State private var steps = 0

    /// The canvas's 26-pt glyph box, scaled with the name beside it and capped at its use site.
    @ScaledMetric(relativeTo: .body) private var glyphBox: CGFloat = 26

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(Array(vesselSlots.enumerated()), id: \.element.nameKey) { index, slot in
                vessel(at: index, slot: slot)
            }
        }
        .sensoryFeedback(Haptics.select, trigger: steps)
    }

    private func vessel(at index: Int, slot: (nameKey: String, symbol: String)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Side by side while they fit. At the accessibility text sizes on a small phone the
            // amount was cut to "150…" beside its name; there it drops under the name instead
            // (rule `65-accessibility`, *Dynamic Type*).
            //
            // **The side-by-side row is measured at its widest**, every vessel's name and the
            // largest amount the slider reaches, drawn hidden underneath: a fit decided by the
            // amount under the finger flipped the row to two lines as a drag passed 1,000, and
            // left the three rows in different shapes.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    ZStack(alignment: .leading) {
                        ForEach(vesselSlots, id: \.nameKey) { label(for: $0).hidden() }
                        label(for: slot)
                    }
                    Spacer(minLength: 8)
                    ZStack(alignment: .trailing) {
                        amountText(HistoryView.servingRange.upperBound).hidden()
                        amount(at: index, anchor: .trailing)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    label(for: slot)
                    amount(at: index, anchor: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(.white)
            // The slider below speaks the name and the value as one sentence, so this row would be
            // a duplicate stop (rule `65-accessibility`).
            .accessibilityHidden(true)

            Slider(
                value: binding(for: index),
                in: Double(HistoryView.servingRange.lowerBound)...Double(HistoryView.servingRange.upperBound),
                step: Double(HistoryView.servingStep),
                onEditingChanged: { editing in
                    held = editing ? index : nil
                    onDrag(editing)
                }
            )
            .tint(Aurora.cyan)
            // A `Slider`'s stock VoiceOver value is a percentage of its range, which would announce
            // "22%" for a 250 ml glass — a number that appears nowhere in the product.
            // Resolved through the chosen bundle rather than written as `Text(slot.nameKey,
            // bundle:)`: that initialiser takes a `LocalizedStringKey`, which must be a literal,
            // and a runtime key silently becomes the *fallback text* instead of a lookup.
            .accessibilityLabel(strings.localizedString(forKey: slot.nameKey, value: slot.nameKey, table: nil))
            .accessibilityValue(strings.localized("%1$d millilitres", amounts[index], locale: locale))
        }
    }

    /// A vessel's glyph and name.
    private func label(for slot: (nameKey: String, symbol: String)) -> some View {
        let box = min(glyphBox, 40)

        return HStack(spacing: 12) {
            Image(systemName: slot.symbol)
                .font(.system(size: box * 0.8))
                // Against its 3:1 floor the Cup's, beside the card's sheen, is the tightest:
                // 3.08 / 4.02 / 3.09:1 on iOS 27.0 / 26.5 / 18.6 (`docs/DESIGN.md`, *Settings,
                // measured*).
                .foregroundStyle(Aurora.cyan)
                // One box for all three, so the names beside them start on one line whatever
                // each glyph's own width.
                .frame(width: box, height: box)
                // The name beside it says which vessel this is; the glyph repeating it would be a
                // second stop saying the same thing.
                .accessibilityHidden(true)

            Text(verbatim: strings.localizedString(forKey: slot.nameKey, value: slot.nameKey, table: nil))
                .font(.body.weight(.medium))
        }
    }

    /// A vessel's amount, grouped as every visible volume is (rule `50-views`): a bottle of 1,000
    /// read "1000 ml" here while Home and History drew "1,000 ml".
    private func amountText(_ volume: Int) -> some View {
        Text(strings.figure("%1$@ ml", volume, locale: locale))
            .font(.body.weight(.bold))
            .fontDesign(.rounded)
            .monospacedDigit()
    }

    /// The amount under the finger, a little larger while its slider is held, as the goal's is —
    /// from the edge it is pinned to, so it grows into its row and not into the card's padding.
    private func amount(at index: Int, anchor: UnitPoint) -> some View {
        amountText(amounts[index])
            .scaleEffect(held == index ? 1.06 : 1, anchor: anchor)
            .animation(Motion.land, value: held)
    }

    /// Bridges the `Int` the caller holds to the `BinaryFloatingPoint` a `Slider` requires.
    ///
    /// `rounded()`, never truncation: the `step` already snaps the value, and rounding is what stops
    /// floating-point dust from turning 250 into 249.9999 which truncation would read as 249.
    /// A step is ticked only while a finger holds a slider: a VoiceOver adjustment takes the
    /// caller's own confirmation instead.
    private func binding(for index: Int) -> Binding<Double> {
        Binding(
            get: { Double(amounts[index]) },
            set: { value in
                let stepped = Int(value.rounded())
                guard stepped != amounts[index] else { return }
                amounts[index] = stepped
                if held != nil { steps += 1 }
            }
        )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var amounts = DataManager.defaultServings

    VesselSliders(amounts: $amounts)
        .padding(20)
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(24)
        .background { AuroraBackground() }
}
