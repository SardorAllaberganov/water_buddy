//
//  HistoryView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftData
import SwiftUI

/// Today's servings, as a list the user can correct.
///
/// ``WaterLog`` has been the source of truth since the SwiftData move and nothing displayed it:
/// `DataManager`'s CRUD was reachable only through `removeWater`, which shrinks servings
/// newest-first with no way to see or choose which one. This is the surface for that — swipe a row
/// to delete it, tap it to fix the amount.
///
/// **It reads ``DataManager/todaysLogs``, never the store.** `fetchLogsForToday()` would return the
/// same rows and register no observation dependency, so the list would go stale the moment anything
/// changed; a SwiftData `@Query` would be the SwiftUI-shaped answer and is the boundary rule
/// `10-architecture` exists to hold. The published array is the only reading of the log a view is
/// allowed, and it is republished by `recomputeToday()` on every mutation *and* by `refresh()` —
/// which is what makes a widget tap taken while the app was backgrounded show up here.
///
/// App-only. The widget has no list and no editor; only ``Aurora``'s colours are shared.
struct HistoryView: View {

    /// The range the serving editor offers, which is intentionally *narrower* than what the store
    /// accepts — the same split ``GoalSetupView/goalRange`` draws, for the same reason.
    ///
    /// `DataManager` rejects only a non-positive serving, because that is a floor against a corrupt
    /// store rather than a menu: 1 ml and 100,000 ml are both legal to save and absurd to offer.
    /// These two numbers are the offer, and they live here — on the only screen that asks — because
    /// the widget has no editor and nothing in the extension needs to agree about them.
    ///
    /// The seams that *are* load-bearing — that ``DataManager/defaultServing`` sits inside this
    /// range and lands on a step, and that neither end is rewritten by `updateLog` — are pinned by
    /// `HistoryServingTests`, because nothing in the compiler notices when one of them moves.
    static let servingRange = 50...1_000

    /// The slider's increment. 50 ml is a mouthful — fine enough to correct a mis-tap, coarse
    /// enough that a drag lands on a round number.
    static let servingStep = 50

    /// The bounds the editor's slider actually offers for a serving of `amount`.
    ///
    /// ``servingRange`` is the menu, but it cannot be the whole story. The seed migration inserts a
    /// **single** log carrying a whole day's cached total (rule `25-shared-storage`), which is
    /// routinely larger than any serving a person pours. A fixed slider could not represent one,
    /// and clamping the initial value into range would silently show a different figure from the
    /// row the user just tapped — so the bounds widen to contain whatever is being edited instead.
    ///
    /// `max(1, amount)` keeps the range well-formed even for a value the store should never hold,
    /// so a corrupt row opens an editor rather than trapping on an invalid `ClosedRange`.
    static func sliderBounds(forAmount amount: Int) -> ClosedRange<Int> {
        min(servingRange.lowerBound, max(1, amount))...max(servingRange.upperBound, amount)
    }

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings

    /// The serving being corrected. Presentation state, which is the only kind a view owns
    /// (rule `50-views`) — the servings themselves live on the model.
    @State private var editing: WaterLog?

    var body: some View {
        ZStack {
            AuroraBackground()

            VStack(spacing: 20) {
                header

                // Drawn only once there is a past to show. A fresh install would otherwise open on
                // seven empty bars, which reads as a broken chart rather than as a new account —
                // and this is the one screen guaranteed to render its empty state for every new
                // user. Note the condition is `history`, not `todaysLogs`: the morning after a
                // rollover, today is empty and the week is exactly what the user wants to see.
                if hasSomethingToShow {
                    HistoryCard()
                }

                if manager.todaysLogs.isEmpty {
                    emptyState
                    Spacer(minLength: 0)
                } else {
                    servings
                }
            }
            .padding(.top, 24)
        }
        // No `.preferredColorScheme` and no `.presentationDragIndicator` here any more: this is a
        // tab, not a sheet. There is nothing to drag down, and the dark-appearance preference is
        // declared once on `RootTabView`, which owns the hosting controller both tabs share.
        // Another process may have logged while this one was away, and the day may have turned.
        // `refresh()` re-derives the rows as well as the total, so both arrive together.
        .onAppear { manager.refresh() }
        .sheet(item: $editing) { log in
            EditServingSheet(log: log)
        }
    }

    /// Whether any day in the published window carries water.
    ///
    /// A presentation decision — whether to draw a card — rather than arithmetic the model
    /// publishes, which is the line rule `50-views` draws. Nothing is summed here.
    private var hasSomethingToShow: Bool {
        manager.history.contains { $0.total > 0 }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Today", bundle: strings)
                    .font(.title2.weight(.bold))

                // Both figures come off the model. The list adds up to this number, and a `body`
                // that computed it for itself is how the two start disagreeing
                // (rule `10-architecture`).
                Text(String(format: strings.localizedString(forKey: "%1$d of %2$d ml", value: nil, table: nil), manager.currentWater, manager.dailyGoal))
                    .font(.footnote.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.75))
                    .contentTransition(.numericText(value: Double(manager.currentWater)))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
            // One heading, not two stops.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today", bundle: strings))
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d of %2$d millilitres", value: nil, table: nil), manager.currentWater, manager.dailyGoal))

            // No settings gear here any more. It lived in this header while Settings was a
            // sheet, and it became the bar's third tab: one screen of preferences reached through
            // *another* screen's header is a route a user finds once and then hunts for. Two
            // routes to one destination is what the tab bar replaced, not something it joins —
            // `testSettingsIsReachableFromHomeAsATab` asserts exactly one control is labelled
            // Settings.
            Spacer(minLength: 12)
        }
        .padding(.horizontal, 28)
        .animation(.smooth(duration: 0.5), value: manager.currentWater)
    }

    // MARK: - The servings

    private var servings: some View {
        List {
            ForEach(manager.todaysLogs, id: \.id) { log in
                ServingRow(log: log) { editing = log }
                    // The pane is the row. A `List`'s own background and separators would draw a
                    // second surface behind glass that is already lit (rule `60-design-system`).
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 28, bottom: 5, trailing: 28))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        // The model deletes the row *and* recomputes the total; the doorbell is
                        // rung by the setter, not from here (rule `20-state`).
                        Button(role: .destructive) {
                            manager.deleteLog(log)
                        } label: {
                            // The closure form, because `Label(_:systemImage:)` has no bundle
                            // parameter and this string has to follow the chosen language like
                            // every other one.
                            Label {
                                Text("Delete", bundle: strings)
                            } icon: {
                                Image(systemName: "trash")
                            }
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        // Scoped to the value that actually changed — never a bare `withAnimation` around a model
        // mutation. Identity, not amount: an edit redraws its own row and must not slide the list.
        .animation(.smooth(duration: 0.35), value: manager.todaysLogs.map(\.id))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "drop")
                .font(.system(size: 38, weight: .light))
                .foregroundStyle(.white.opacity(0.7))
                .accessibilityHidden(true)

            Text("Nothing logged yet today", bundle: strings)
                .font(.callout.weight(.semibold))

            // Names no amount. It used to read "Tap + … to log \(DataManager.defaultServing) ml",
            // spelled from the constant so it could not drift — but the Home tab now offers three
            // vessels, and naming one of them is a different kind of drift: copy that is accurate
            // about the constant and wrong about the product.
            Text("Pick a vessel on the Home tab to log your first serving.", bundle: strings)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .padding(.vertical, 34)
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity)
        // `.frosted`, not `.sheer`: this pane carries a sentence, and the density scale exists
        // because tint and blur compete (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, 28)
        .padding(.top, 40)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - The week

/// The last ``DataManager/historyWindow`` days as bars, with the average and the best day.
///
/// **Hand-rolled rather than drawn with Swift Charts, and that is a design-system decision rather
/// than a dependency one.** Charts is an Apple SDK framework and would be legal under rule
/// `95-dependencies` — every target keeps `packageProductDependencies` empty and it would enter as
/// an import line like any other. Two things rule it out here. Its axis chrome draws system greys
/// and `Color.secondary` onto a `Material` over the aurora, whose composite contrast nobody has
/// measured — exactly how the tab bar shipped a 4.34:1 caption against a 4.5:1 floor. And this
/// codebase enforces its palette by asserting over *values* (`everyPieceIsPaintedFromTheAurora‑
/// Palette`); a `BarMark`'s `foregroundStyle` is not readable as one, so that enforcement would
/// simply disappear.
///
/// Every bar shares one fill. Goal-met is carried by height against the reference line, never by
/// colour — rule `65-accessibility` forbids a tint being the only carrier of state, and a second
/// hue here would be a second unmeasured contrast figure for no gain.
private struct HistoryCard: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings

    /// A real magnitude, never a unitless `1` that is then multiplied — `UIFontMetrics` rounds to
    /// the nearest third of a point, which would quantise twelve Dynamic Type categories into
    /// three (rule `65-accessibility`). Capped at the use site: this is a decorative dimension, and
    /// an uncapped one would push the serving list off the screen at the accessibility sizes.
    @ScaledMetric(relativeTo: .footnote) private var scaledBarHeight: CGFloat = 84

    private var barHeight: CGFloat { min(scaledBarHeight, 118) }

    private let barSpacing: CGFloat = 6

    /// The tallest thing the chart must fit — the goal, or an overachieving day, whichever is
    /// larger, so a day above the goal is drawn above the line rather than clipped to it.
    private var scale: Int {
        max(manager.dailyGoal, DaySummary.best(of: manager.history), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(format: strings.localizedString(forKey: "Last %1$d days", value: nil, table: nil), DataManager.historyWindow))
                .font(.callout.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            bars
            weekdays
            figures

            // The honest disclosure of a real limitation: `dailyGoal` is one scalar overwritten in
            // place, so nothing in either store records what the goal *was* on a past day. Every
            // bar is therefore measured against the goal as it stands right now, and moving the
            // goal in Settings re-judges the whole week. Said out loud rather than hidden.
            Text("Measured against your current goal", bundle: strings)
                .font(.caption2)
                // 0.70, not the 0.55 this was drafted at. **Measured, not derived**: the pane is a
                // `Material` over a moving aurora, so its composite cannot be computed from a
                // token — it was sampled off a render at sRGB (0.214, 0.283, 0.398) at the card's
                // foot, where the backdrop is lightest. White at 0.55 measured **4.06:1** against
                // a 4.5:1 small-text floor, a real rule `65-accessibility` failure that looked
                // perfectly legible. 0.70 measures 5.49:1. Figures in `docs/DESIGN.md`.
                .foregroundStyle(.white.opacity(0.70))
                // No line limit, and `fixedSize` so it claims the height it needs. The card is not
                // in a `ScrollView` — the `List` beneath it is the only scroller — so the `VStack`
                // gets vertically compressed and `Text` gives up lines rather than pushing back.
                // With `.lineLimit(2)` this still read "Measured against your cur…" at
                // `AccessibilityXXXL`; a disclosure that is itself truncated discloses nothing.
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
        // The same density/elevation pair as this screen's empty state — sibling panes on one
        // screen share one (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, 28)
        // One stop, not fifteen. Every child here is a plain `Text` or a shape — there is no
        // control inside, which is what makes `.ignore` correct rather than a duplicate stop
        // (rule `65-accessibility`).
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(String(format: strings.localizedString(forKey: "Last %1$d days", value: nil, table: nil), DataManager.historyWindow)))
        .accessibilityValue(String(format: strings.localizedString(forKey: "Average %1$d millilitres. Best %2$d millilitres.", value: nil, table: nil), DaySummary.average(of: manager.history), DaySummary.best(of: manager.history)))
    }

    // MARK: Bars

    private var bars: some View {
        HStack(alignment: .bottom, spacing: barSpacing) {
            ForEach(manager.history, id: \.dayOrdinal) { day in
                bar(for: day)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: barHeight)
        .overlay(alignment: .bottom) { goalLine }
        // Once per change, not perpetual, so it is deliberately **not** gated on Reduce Motion —
        // that setting is aimed at sustained motion, and the resting frame here is the design
        // (rule `65-accessibility`).
        .animation(.smooth(duration: 0.45), value: manager.history)
    }

    private func bar(for day: DaySummary) -> some View {
        let fraction = min(Double(day.total) / Double(scale), 1)

        return ZStack(alignment: .bottom) {
            Capsule()
                .fill(.white.opacity(0.12))

            // Solid `Aurora.cyan`, **not** a `Aurora.blue` → `Aurora.cyan` gradient, and the
            // reason is a measurement rather than taste. Pure `Aurora.blue` composites to
            // **2.72:1** against this pane — under the 3:1 non-text floor — so the foot of every
            // bar failed, and a nearly-empty day is drawn almost entirely in that end. Sampling a
            // *rendered* bar gave a reassuring 3.33:1, but that is the average of the whole
            // gradient, not its endpoint: the figure was real and measured the wrong thing.
            // `Aurora.cyan` alone measures 5.22:1. A 6–90pt bar loses nothing by being one colour.
            Capsule()
                .fill(Aurora.cyan)
                // A day with nothing logged still draws a sliver, so the bar reads as an empty day
                // rather than as a missing one. The series is zero-filled for the same reason.
                .frame(height: max(barHeight * fraction, day.total > 0 ? 6 : 2))
        }
    }

    private var goalLine: some View {
        Rectangle()
            .fill(.white.opacity(0.45))
            .frame(height: 1)
            .offset(y: -barHeight * min(Double(manager.dailyGoal) / Double(scale), 1))
    }

    private var weekdays: some View {
        HStack(spacing: barSpacing) {
            ForEach(manager.history, id: \.dayOrdinal) { day in
                // Formatted from the environment locale, which the app injects from the in-app
                // language picker alongside `\.strings` — never `Locale.current`, or a Russian
                // user who chose English would still read Russian weekdays (rule `70-privacy`).
                Text(day.date, format: .dateTime.weekday(.narrow))
                    // A **ratio** of the bar it annotates, never its own text style. The bar is
                    // capped and a text style is not, so the two cross over at the accessibility
                    // sizes and the label overtakes the figure — this codebase has shipped that
                    // inversion once already (rule `65-accessibility`).
                    .font(.system(size: barHeight * 0.14, weight: .medium))
                    // 0.72 measures 5.70:1 on the sampled pane. 0.60 lands on **exactly** 4.50:1 —
                    // the floor itself, with no margin for the aurora drifting a shade lighter
                    // under it, which it does continuously.
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// Average and best, side by side while they fit and stacked when they do not.
    ///
    /// Two strings rather than one, and a `ViewThatFits` rather than a wrap. As a single
    /// `"Average %1$d ml · Best %2$d ml"` it truncated outright at `AccessibilityXXXL` — the two
    /// figures the card exists to show, cut off — and once allowed to wrap it broke after the
    /// separator, leaving a line beginning "· Best 8050 ml". Letting the row become a column is
    /// the shape rule `65-accessibility` asks for when scaled content overflows, and two keys also
    /// give a translator two independent phrases instead of one word order.
    private var figures: some View {
        let average = String(format: strings.localizedString(forKey: "Average %1$d ml", value: nil, table: nil), DaySummary.average(of: manager.history))
        let best = String(format: strings.localizedString(forKey: "Best %1$d ml", value: nil, table: nil), DaySummary.best(of: manager.history))

        return ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) {
                Text(average)
                Text(verbatim: "·")
                Text(best)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(average)
                Text(best)
            }
        }
        .font(.footnote.weight(.medium))
        .monospacedDigit()
        .foregroundStyle(.white.opacity(0.75))
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    }
}

// MARK: - A serving

/// One logged serving: a frosted capsule carrying the amount and the time it landed.
///
/// Private because it has exactly one consumer. `AuroraBackground` and `PressStyle` earned their
/// own files only when a second screen wanted them.
private struct ServingRow: View {

    @Environment(\.strings) private var strings

    let log: WaterLog
    let edit: () -> Void

    var body: some View {
        Button(action: edit) {
            HStack(spacing: 14) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Aurora.cyan)
                    .accessibilityHidden(true)

                Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), log.amount))
                    .font(.body.weight(.semibold))
                    .monospacedDigit()

                Spacer(minLength: 8)

                // Rendered through the phone's own 12/24-hour setting rather than a fixed pattern:
                // "14:32" on a 24-hour device, "2:32 PM" on a 12-hour one. Forcing HH:mm would
                // override a preference the user actually chose.
                Text(log.timestamp, format: .dateTime.hour().minute())
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.75))
            }
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            // WidgetKit's 44pt floor is a widget rule, but a list row is a control here too, and a
            // `minHeight` lets it grow with Dynamic Type instead of clipping.
            .frame(minHeight: 56)
            .liquidGlass(in: Capsule(), density: .frosted, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
        // One serving, one stop. The swipe action reaches VoiceOver on its own, as a rotor action.
        //
        // The label goes on the **button**, not on an `.accessibilityElement(children: .ignore)`
        // wrapper around it. That is the idiom the vessel and this screen's own header use, and it
        // is wrong here: those wrap plain `Text`, while this wraps a *control*, which VoiceOver
        // surfaces regardless. The wrapper became a second element above it and every serving was
        // announced twice — "250 millilitres, 21:22", then "250 ml, 21:22, button". Only the real
        // accessibility tree shows that; no unit test in this project can see one.
        .accessibilityLabel(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), log.amount))
        .accessibilityValue(log.timestamp.formatted(date: .omitted, time: .shortened))
        .accessibilityHint(Text("Edits this serving", bundle: strings))
    }
}

// MARK: - The editor

/// Corrects one serving's amount.
///
/// Deliberately the same lockup as `GoalSetupView`'s goal card — one glass pane, a hero readout
/// with a ratio-sized unit, an `Aurora.cyan` slider — because every pane in this product is lit by
/// the same light, and a second layout for "pick a number in millilitres" would be a second one.
private struct EditServingSheet: View {

    let log: WaterLog

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.dismiss) private var dismiss

    /// The amount under the finger, as an `Int` for the same reason every other volume here is
    /// one. The `Double` a `Slider` demands lives only inside ``sliderValue``.
    @State private var amount: Int

    /// Bumped when the correction is committed, so the haptic fires on the tap rather than on any
    /// later change to the model.
    @State private var commits = 0

    @ScaledMetric(relativeTo: .largeTitle) private var readoutSize: CGFloat = 52

    init(log: WaterLog) {
        self.log = log
        _amount = State(initialValue: log.amount)
    }

    private var bounds: ClosedRange<Int> { HistoryView.sliderBounds(forAmount: log.amount) }

    var body: some View {
        ZStack {
            AuroraBackground()

            // Same shape as the setup screen: centred at every ordinary size, scrolling only once
            // the type genuinely outgrows the sheet.
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 26) {
                        Spacer(minLength: 8)
                        title
                        card
                        actions
                        Spacer(minLength: 8)
                    }
                    .padding(.horizontal, 28)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sensoryFeedback(Haptics.pour, trigger: commits)
    }

    private var title: some View {
        VStack(spacing: 6) {
            Text("Edit serving", bundle: strings)
                .font(.title2.weight(.bold))

            Text(String(format: strings.localizedString(forKey: "Logged at %1$@", value: nil, table: nil),
                 log.timestamp.formatted(.dateTime.hour().minute())))
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.75))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
    }

    private var card: some View {
        VStack(spacing: 24) {
            readout

            Slider(
                value: sliderValue,
                in: Double(bounds.lowerBound)...Double(bounds.upperBound),
                step: Double(HistoryView.servingStep)
            )
            .tint(Aurora.cyan)
            // A `Slider`'s stock VoiceOver value is a percentage of its range, which here would
            // announce "21%" for 250 ml — a number that appears nowhere in the product.
            .accessibilityLabel(Text("Serving amount", bundle: strings))
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), amount))
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .liquidGlass(density: .frosted, elevation: .floating)
    }

    private var readout: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(amount, format: .number)
                // Bounded so the largest accessibility sizes cannot push the figure through the
                // edges of the card containing it.
                .font(.system(size: min(readoutSize, 72), weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(amount)))

            // Sized as a ratio of the figure it annotates, never with its own text style: a fixed
            // style and a scaled hero cross over at the accessibility sizes and the unit ends up
            // larger than the number.
            Text("ml", bundle: strings)
                .font(.system(size: min(readoutSize, 72) * 0.36, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 2)
        .animation(.smooth(duration: 0.35), value: amount)
        .accessibilityHidden(true)
    }

    private var actions: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Text("Cancel", bundle: strings)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())

            Button {
                // One call. The model clamps, skips a write that changes nothing, recomputes the
                // total from the logs and rings the widget doorbell exactly once — none of which
                // is this view's business to repeat (rule `20-state`).
                manager.updateLog(log, newAmount: amount)
                commits += 1
                dismiss()
            } label: {
                Text("Save", bundle: strings)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    .liquidGlass(in: Capsule(), density: .frosted, elevation: .raised, interactive: true)
                    // The same lit-by-the-backdrop glow *Get Started* carries, at the same two
                    // radii — a tight hot core the eye reads as the source, and a bloom to carry
                    // it off the edge. Static, so it owes no Reduce Motion path.
                    .shadow(color: Aurora.cyan.opacity(0.55), radius: 12)
                    .shadow(color: Aurora.cyan.opacity(0.38), radius: 28)
            }
            .buttonStyle(PressStyle())
        }
    }

    /// Bridges the `Int` this view holds to the `BinaryFloatingPoint` a `Slider` requires.
    ///
    /// The `step` already snaps the value; `rounded()` is what stops floating-point dust from
    /// turning 250 into 249.9999999, which truncation would then read as 249.
    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(amount) },
            set: { amount = Int($0.rounded()) }
        )
    }
}

// MARK: - Preview

/// A throwaway suite **and** an in-memory store, so previewing — and editing or deleting in the
/// canvas — never reaches the real App Group. The container is the half that is easy to forget:
/// its production default resolves the live `WaterBuddy.store` (rule `50-views`).
@MainActor
private func previewManager(named name: String) -> DataManager {
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)

    return DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        reloadWidgets: {},
        // The production default builds a real `UNUserNotificationCenter`; a canvas rebuild must
        // not reconcile the user's actual reminders, and this screen can write water (rule
        // `85-testing`, `tasks/lessons.md`).
        rescheduleReminders: { _ in }
    )
}

#Preview("With servings") {
    let manager = previewManager(named: "preview.waterbuddy.history")

    // Pinned to the start of the day rather than offset from `now`, so the sample does not fall
    // out of "today" when the canvas happens to run after midnight.
    let start = Calendar.waterBuddyDay.startOfDay(for: .now)
    manager.addLog(amount: 250, at: start.addingTimeInterval(8 * 3_600))
    manager.addLog(amount: 500, at: start.addingTimeInterval(12 * 3_600 + 1_800))
    manager.addLog(amount: 250, at: start.addingTimeInterval(15 * 3_600))
    manager.addLog(amount: 150, at: start.addingTimeInterval(17 * 3_600 + 600))

    return HistoryView().environment(manager)
}

#Preview("Nothing logged") {
    HistoryView().environment(previewManager(named: "preview.waterbuddy.history.empty"))
}
