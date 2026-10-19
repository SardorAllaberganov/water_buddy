//
//  WeekWidget.swift
//  WaterBuddyWidget
//
//  Created by Sardor Allaberganov on 19/10/26.
//

import SwiftUI
import WidgetKit

// MARK: - Widget

/// The last seven days against the goal, on the Home Screen — History's week card at widget size
/// (spec 2026-10-19-the-widget-stage §3.5).
///
/// **The Hydration widget's provider**, never a second one: the two draw one snapshot, turn over at
/// one midnight and reload together (rule `40-widget`). The week reaches this process as
/// ``WaterSnapshot/weekTotals`` — the cache `DataManager` rewrites wherever it recomputes today's
/// total — because the widget may never open SwiftData.
///
/// **No button.** A tap opens History, which shows the same week in full (``WidgetLink/history``).
struct WeekWidget: Widget {

    /// Permanent once shipped: iOS identifies every placed widget by its kind.
    static let kind = "WaterBuddyWeek"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HydrationProvider()) { entry in
            WeekView(entry: entry)
        }
        // Static literals naming no figure, as the Hydration widget's are: the gallery renders them
        // before any entry exists, and WidgetKit traps on a formatted one (rule `40-widget`).
        .configurationDisplayName("Week")
        .description("Your last seven days against your goal.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Entry view

/// Injects the snapshot's language, draws the card and sets the link.
///
/// It reads no string itself, for ``HydrationView``'s reason: the bundle this injects reaches only
/// the views below it.
struct WeekView: View {

    let entry: HydrationEntry

    var body: some View {
        WeekCard(
            week: entry.snapshot.week(endingOn: entry.date, calendar: .waterBuddyDay),
            goal: entry.snapshot.dailyGoal
        )
        // A widget cannot scroll or reflow, so past the first accessibility size the type holds still
        // rather than eating the bars (rule `65-accessibility`). **Here, above the card, and not in
        // its body:** a view's own `@ScaledMetric` reads the environment from above the view, so a cap
        // inside `WeekCard.body` capped nothing — every font there is a ratio of `titleSize` — and at
        // AX5 the title pressed the bars to slivers (the final review; rendered before and after).
        // The medium Hydration column still carries that shape (`docs/AI_CONTEXT.md` #76).
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .widgetCard()
        .padding(HydrationView.cardInset)
        .widgetURL(WidgetLink.history)
        .containerBackground(for: .widget) { WidgetAurora() }
        .environment(\.colorScheme, .dark)
        .environment(\.strings, entry.snapshot.language.bundle)
        .environment(\.locale, entry.snapshot.language.locale)
    }
}

// MARK: - The card

/// History's week card at widget size: the title, the days met, seven bars on their tracks against a
/// dashed goal line, and the narrow weekday letters.
///
/// **History's values, measured again here.** Cyan for a met day and white for the rest, white 0.10
/// tracks, the goal line 1.5 pt at white 0.62 — each pair measured on this widget's own rendered
/// pane (`docs/DESIGN.md`), because History's figures were read on History's panes (rule
/// `60-design-system`). A met day also stands at or above the line, so colour is never its only sign
/// (rule `65-accessibility`). The scale is the goal or the best day, whichever is larger, so a day
/// over the goal stands above the line rather than being clipped to it.
///
/// **One element for VoiceOver**: *Last 7 days*, valued with the sentence History's card speaks. The
/// bars, the letters and the figure draw nothing into the tree.
private struct WeekCard: View {

    /// Oldest first, today last — or `nil` when no week is cached yet.
    let week: [DaySummary]?
    let goal: Int

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// The title's size at default Dynamic Type — a real magnitude, never a unitless `1`
    /// (rule `40-widget`). The figure and the letters are ratios of it. Capped at `.accessibility1` by
    /// `WeekView`, above this view, where the cap reaches it.
    @ScaledMetric(relativeTo: .callout) private var titleSize: CGFloat = 15

    /// Room between two days' tracks.
    private let barInset: CGFloat = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            header

            if let week {
                days(week)
            } else {
                Text("Open WaterBuddy to see your week.", bundle: strings)
                    .font(.system(size: titleSize * 0.9, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.88))
                    // Two lines before a word is cut: it says what the widget needs.
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .foregroundStyle(.white)
        // The cap on the type is `WeekView`'s, above this view — see there.
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(spoken)
    }

    private var title: String {
        strings.localized("Last %1$d days", DataManager.historyWindow, locale: locale)
    }

    /// History's card's sentence, or the empty state's line.
    private var spoken: String {
        guard let week else {
            return strings.localizedString(forKey: "Open WaterBuddy to see your week.", value: nil, table: nil)
        }
        return strings.localized(
            "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.",
            DaySummary.average(of: week),
            DaySummary.best(of: week),
            DaySummary.daysMet(in: week, goal: goal),
            week.count,
            locale: locale
        )
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: titleSize, weight: .semibold, design: .rounded))

            Spacer(minLength: 8)

            if let week {
                // The figure over its label, as History draws its three.
                VStack(alignment: .trailing, spacing: 0) {
                    Text(strings.figure("%1$@ of %2$@", DaySummary.daysMet(in: week, goal: goal), week.count, locale: locale))
                        .font(.system(size: titleSize, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text("Goal met", bundle: strings)
                        .font(.system(size: titleSize * 0.7, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }

    private func days(_ week: [DaySummary]) -> some View {
        let scale = max(goal, DaySummary.best(of: week), 1)
        let goalFraction = min(Double(goal) / Double(scale), 1)

        return VStack(spacing: 4) {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(week, id: \.dayOrdinal) { day in
                            bar(for: day, scale: scale, height: proxy.size.height)
                                .padding(.horizontal, barInset)
                        }
                    }

                    // One line across all seven at the goal's height, from the first track's edge to
                    // the last's.
                    GoalRule()
                        .stroke(.white.opacity(0.62), style: StrokeStyle(lineWidth: 1.5, dash: [4.5, 3]))
                        .frame(height: 1.5)
                        .padding(.horizontal, barInset)
                        .offset(y: -proxy.size.height * goalFraction + 0.75)
                }
            }

            HStack(spacing: 0) {
                ForEach(week, id: \.dayOrdinal) { day in
                    // From the environment's locale, which the root injects from the snapshot —
                    // never the device's (rule `70-privacy`). Today's is heavier, the mark History
                    // gives its shown day, without the ring: nothing here is selected.
                    Text(day.date, format: .dateTime.weekday(.narrow))
                        .font(.system(size: titleSize * 0.75, weight: day.dayOrdinal == week.last?.dayOrdinal ? .heavy : .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func bar(for day: DaySummary, scale: Int, height: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous)
        let met = day.reached(goal)
        let fraction = min(Double(day.total) / Double(scale), 1)

        return ZStack(alignment: .bottom) {
            shape
                .fill(.white.opacity(0.10))

            shape
                .fill(met ? Aurora.cyan : Color.white)
                // A day with nothing logged still draws a sliver, so it reads as an empty day rather
                // than a missing one — History's rule.
                .frame(height: max(height * fraction, day.total > 0 ? 4 : 2))
                // On a tinted Home Screen a met day takes iOS's accent; it still stands at the line.
                .widgetAccentable(met)
        }
        .frame(maxWidth: .infinity)
    }
}

/// A horizontal rule through the middle of its frame — the week's dashed goal line.
private struct GoalRule: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

// MARK: - Preview

#Preview("Week", as: .systemMedium) {
    WeekWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: .sample(at: .now))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
}
