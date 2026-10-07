//
//  HistoryView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftData
import SwiftUI

/// One day's servings — today's, unless the week card has picked another — as a list the user can
/// correct and add to.
///
/// ``WaterLog`` has been the source of truth since the SwiftData move and nothing displayed it:
/// `DataManager`'s CRUD was reachable only through `removeWater`, which shrinks servings
/// newest-first with no way to see or choose which one. This is the surface for that — swipe a row
/// to delete it, tap it to fix the amount or the time, and add a forgotten one with the `+`.
///
/// **The reach is the week the card draws.** Any of its days can be opened, and a serving added to
/// it or moved anywhere inside it. Nothing reaches further back, because nothing on screen would show
/// it: a serving dated before the window would vanish the moment it was saved
/// (`docs/superpowers/specs/2026-10-07-earlier-servings-design.md`).
///
/// **It reads ``DataManager/todaysLogs`` and ``DataManager/historyLogs``, never the store.**
/// `fetchLogsForToday()` would return the same rows and register no observation dependency, so the
/// list would go stale the moment anything changed; a SwiftData `@Query` would be the SwiftUI-shaped
/// answer and is the boundary rule `10-architecture` exists to hold. The published arrays are the
/// only reading of the log a view is allowed, and they are republished on every mutation *and* by
/// `refresh()` — which is what makes a widget tap taken while the app was backgrounded show up here.
/// Today reads `todaysLogs` and `currentWater` exactly as it always has; a past day reads its rows
/// and its bar's total, which come from one fetch.
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

    /// The day the screen shows: the selection while the window still holds it, otherwise today.
    ///
    /// A selection the window has scrolled past — the app left open across midnight — falls back to
    /// today rather than to nothing, because a list with no bar outlined above it would not say which
    /// day it is. `nonisolated` because a `View`'s statics infer its isolation, and
    /// `HistorySelectionTests` reads this off the main actor (rule `43-concurrency`).
    nonisolated static func shownDay(selected: Int?, in history: [DaySummary]) -> DaySummary? {
        history.first { $0.dayOrdinal == selected } ?? history.last
    }

    /// The selection after the day `ordinal` is picked, or a serving is saved to it: `nil` for
    /// today, so the screen goes on following midnight by itself, and the ordinal for any other day.
    nonisolated static func selection(forDay ordinal: Int, in history: [DaySummary]) -> Int? {
        ordinal == history.last?.dayOrdinal ? nil : ordinal
    }

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// The day the week card picked, as an ordinal — `nil` for today. Presentation state, which is
    /// the only kind a view owns (rule `50-views`); leaving the tab resets it to today.
    @State private var selectedDay: Int?

    /// What the serving sheet is open for. Presentation state too — the servings themselves live on
    /// the model.
    @State private var editor: ServingEditor?

    /// The `+`'s diameter, a real magnitude scaled with the header's own text (rule
    /// `65-accessibility`), bounded at its use site.
    @ScaledMetric(relativeTo: .title2) private var addButtonSize: CGFloat = 44

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
                    HistoryCard(shown: shownPastDay?.dayOrdinal ?? manager.history.last?.dayOrdinal) { ordinal in
                        selectedDay = Self.selection(forDay: ordinal, in: manager.history)
                    }
                }

                if shownLogs.isEmpty {
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
        // A selection the card can no longer show is dropped, so it cannot resurface on a later
        // serving and take the screen back to a day the user had left.
        .onChange(of: hasSomethingToShow) { _, isShowing in
            if !isShowing { selectedDay = nil }
        }
        .sheet(item: $editor) { editor in
            ServingSheet(
                editor: editor,
                range: manager.correctionRange(),
                // Index 1 is the middle vessel — the serving the widget logs, so the sheet starts
                // where the user's own "usual glass" is.
                startingAmount: manager.servings[1]
            ) { saved in
                // Follow the serving to the day it landed on. The model answers which day that is,
                // on its own calendar — a view holds none (rule `30-rollover`).
                selectedDay = Self.selection(forDay: manager.dayOrdinal(for: saved), in: manager.history)
            }
        }
    }

    /// Whether any day in the published window carries water.
    ///
    /// A presentation decision — whether to draw a card — rather than arithmetic the model
    /// publishes, which is the line rule `50-views` draws. Nothing is summed here.
    private var hasSomethingToShow: Bool {
        manager.history.contains { $0.total > 0 }
    }

    /// The day on screen when it is not today; `nil` means today, read the way it always was.
    ///
    /// The selection counts only while the card is drawn — with no card there is nothing to pick a
    /// day from, so the screen is on today.
    private var shownPastDay: DaySummary? {
        guard let day = Self.shownDay(selected: hasSomethingToShow ? selectedDay : nil, in: manager.history),
              day.dayOrdinal != manager.history.last?.dayOrdinal
        else { return nil }
        return day
    }

    /// The header's figure: today's total off the cache, as before, or a past day's bar.
    private var shownTotal: Int {
        shownPastDay?.total ?? manager.currentWater
    }

    /// The rows under the header. A past day's come from the fetch its bar was summed from, so the
    /// two cannot disagree.
    private var shownLogs: [WaterLog] {
        guard let day = shownPastDay else { return manager.todaysLogs }
        return manager.historyLogs[day.dayOrdinal] ?? []
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                dayTitle
                    .font(.title2.weight(.bold))

                // Both figures come off the model. The list adds up to this number, and a `body`
                // that computed it for itself is how the two start disagreeing
                // (rule `10-architecture`).
                Text(String(format: strings.localizedString(forKey: "%1$d of %2$d ml", value: nil, table: nil), shownTotal, manager.dailyGoal))
                    .font(.footnote.weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.75))
                    .contentTransition(.numericText(value: Double(shownTotal)))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
            // One heading, not two stops.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenDay)
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d of %2$d millilitres", value: nil, table: nil), shownTotal, manager.dailyGoal))

            // No settings gear here any more. It lived in this header while Settings was a
            // sheet, and it became the bar's third tab: one screen of preferences reached through
            // *another* screen's header is a route a user finds once and then hunts for. Two
            // routes to one destination is what the tab bar replaced, not something it joins —
            // `testSettingsIsReachableFromHomeAsATab` asserts exactly one control is labelled
            // Settings. The `+` that sits here now is the *only* route to the serving sheet.
            Spacer(minLength: 0)

            addButton
        }
        .padding(.horizontal, 28)
        .animation(.smooth(duration: 0.5), value: shownTotal)
    }

    @ViewBuilder
    private var dayTitle: some View {
        if let day = shownPastDay {
            // Formatted through the environment locale, which the app injects from the in-app
            // language picker alongside `\.strings` — never `Locale.current` (rule `70-privacy`).
            // Formatting a label is the one use `DaySummary.date` exists for.
            Text(day.date, format: .dateTime.weekday(.wide).day().month(.abbreviated))
        } else {
            Text("Today", bundle: strings)
        }
    }

    /// The header's spoken name — the month spelled out, which reads better aloud than the
    /// abbreviation drawn above it.
    private var spokenDay: Text {
        guard let day = shownPastDay else { return Text("Today", bundle: strings) }
        return Text(day.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale)))
    }

    /// Adds a serving to the day on screen.
    ///
    /// At the right of the header rather than under the list, which is where it was first sketched:
    /// a `List` scrolls a trailing button out of reach once a day holds six or seven servings, and
    /// this is the one route to the sheet (rule `50-views`). The vessels' own recipe — a `.frosted`,
    /// `.raised`, pressable circle — because it belongs to the same family of controls: the ways
    /// water enters.
    private var addButton: some View {
        let diameter = min(max(addButtonSize, 44), 56)

        return Button {
            editor = .adding(at: manager.suggestedTime(onDay: shownPastDay?.dayOrdinal))
        } label: {
            Image(systemName: "plus")
                // A ratio of the circle it sits in, never its own text style, so it cannot grow
                // through the edge (rule `65-accessibility`). 11.7:1 on the circle's glass,
                // measured off a render.
                .font(.system(size: diameter * 0.4, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: diameter, height: diameter)
                .liquidGlass(in: Circle(), density: .frosted, elevation: .raised, interactive: true)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(Text("Add a serving", bundle: strings))
    }

    // MARK: - The servings

    private var servings: some View {
        List {
            ForEach(shownLogs, id: \.id) { log in
                ServingRow(log: log) { editor = .editing(log) }
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
        .animation(.smooth(duration: 0.35), value: shownLogs.map(\.id))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "drop")
                .font(.system(size: 38, weight: .light))
                .foregroundStyle(.white.opacity(0.7))
                .accessibilityHidden(true)

            if shownPastDay == nil {
                Text("Nothing logged yet today", bundle: strings)
                    .font(.callout.weight(.semibold))

                // Names no amount. It used to read "Tap + … to log \(DataManager.defaultServing) ml",
                // spelled from the constant so it could not drift — but the Home tab now offers three
                // vessels, and naming one of them is a different kind of drift: copy that is accurate
                // about the constant and wrong about the product.
                Text("Pick a vessel on the Home tab to log your first serving.", bundle: strings)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                Text("Nothing logged that day", bundle: strings)
                    .font(.callout.weight(.semibold))

                // Points at the `+`, because on a past day there is no vessel to pick: Home pours
                // into today. Measured off a render: the title 8.0:1, this line 5.2:1.
                Text("Tap + to add a serving you forgot.", bundle: strings)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }
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

/// The last ``DataManager/historyWindow`` days as bars, with the average and the best day — and the
/// control that picks which day the list below shows.
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
///
/// **Each day is a button, and the day row alone runs the card's full width.** Seven equal slots of
/// `(375 − 2 × 28) / 7 = 45.6` pt on the narrowest supported iPhone clear the 44-pt floor rule
/// `65-accessibility` sets; inside the card's 20-pt inset they would be 39.9 pt and miss it. That is
/// the width ``DataManager/historyWindow``'s DocC budgeted, and why the title, the figures and the
/// disclosure keep their inset while the bars sit ``barInset`` in from their own slots instead.
///
/// **VoiceOver hears a summary and seven days**, no longer one element: the title carries the
/// average and the best as its value, each day is exactly one button marked selected when it is the
/// one shown, and the disclosure is read as itself. The bars, weekday letters and figures are
/// carried by those and draw nothing of their own into the tree.
private struct HistoryCard: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// The day the list below is showing — outlined here, and announced as selected.
    let shown: Int?

    /// Hands the tapped day back to the screen, which owns the selection (rule `50-views`).
    let select: (Int) -> Void

    /// A real magnitude, never a unitless `1` that is then multiplied — `UIFontMetrics` rounds to
    /// the nearest third of a point, which would quantise twelve Dynamic Type categories into
    /// three (rule `65-accessibility`). Capped at the use site: this is a decorative dimension, and
    /// an uncapped one would push the serving list off the screen at the accessibility sizes.
    @ScaledMetric(relativeTo: .footnote) private var scaledBarHeight: CGFloat = 84

    private var barHeight: CGFloat { min(scaledBarHeight, 118) }

    /// How far each bar sits in from the sides of its day's slot: 16 pt between neighbouring bars,
    /// and 8 pt from the card's edge for the outermost two.
    private let barInset: CGFloat = 8

    /// The slot's own top and bottom padding, which the goal line has to step over to meet the bars.
    private let slotPadding: CGFloat = 8

    /// The tallest thing the chart must fit — the goal, or an overachieving day, whichever is
    /// larger, so a day above the goal is drawn above the line rather than clipped to it.
    private var scale: Int {
        max(manager.dailyGoal, DaySummary.best(of: manager.history), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            title
                .padding(.horizontal, 20)

            days

            figures
                .padding(.horizontal, 20)

            // The honest disclosure of a real limitation: `dailyGoal` is one scalar overwritten in
            // place, so nothing in either store records what the goal *was* on a past day. Every
            // bar is therefore measured against the goal as it stands right now, and moving the
            // goal in Settings re-judges the whole week. Said out loud rather than hidden — and now
            // read aloud as well, where the card's old single element used to swallow it.
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
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
        // The same density/elevation pair as this screen's empty state — sibling panes on one
        // screen share one (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, 28)
    }

    private var title: some View {
        Text(String(format: strings.localizedString(forKey: "Last %1$d days", value: nil, table: nil), DataManager.historyWindow))
            .font(.callout.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            // The card's summary, spoken once: the average and the best ride on its title as a
            // value, and the figures row that draws them is hidden below.
            .accessibilityValue(String(format: strings.localizedString(forKey: "Average %1$d millilitres. Best %2$d millilitres.", value: nil, table: nil), DaySummary.average(of: manager.history), DaySummary.best(of: manager.history)))
    }

    // MARK: Days

    private var days: some View {
        HStack(spacing: 0) {
            ForEach(manager.history, id: \.dayOrdinal) { day in
                dayButton(for: day)
            }
        }
        // The row claims its own height, as the bars' fixed frame did before they became buttons.
        // The card sits above a `List` and is squeezed at the large text sizes; a slot whose frame
        // could give way shrank under its content, and at `AccessibilityXXXL` the bars rose through
        // the title while the weekday letters sank into the figures.
        .fixedSize(horizontal: false, vertical: true)
        .overlay(alignment: .top) { goalLine }
        // Once per change, not perpetual, so it is deliberately **not** gated on Reduce Motion —
        // that setting is aimed at sustained motion, and the resting frame here is the design
        // (rule `65-accessibility`).
        .animation(.smooth(duration: 0.45), value: manager.history)
        .animation(.smooth(duration: 0.3), value: shown)
    }

    private func dayButton(for day: DaySummary) -> some View {
        let isShown = day.dayOrdinal == shown

        return Button {
            select(day.dayOrdinal)
        } label: {
            VStack(spacing: 8) {
                bar(for: day)
                    .frame(height: barHeight)
                    .padding(.horizontal, barInset)

                // Formatted from the environment locale, which the app injects from the in-app
                // language picker alongside `\.strings` — never `Locale.current`, or a Russian
                // user who chose English would still read Russian weekdays (rule `70-privacy`).
                Text(day.date, format: .dateTime.weekday(.narrow))
                    // A **ratio** of the bar it annotates, never its own text style. The bar is
                    // capped and a text style is not, so the two cross over at the accessibility
                    // sizes and the label overtakes the figure — this codebase has shipped that
                    // inversion once already (rule `65-accessibility`).
                    .font(.system(size: barHeight * 0.14, weight: isShown ? .bold : .medium))
                    // 0.72 measures 5.70:1 on the sampled pane, and 5.43:1 re-measured off a render
                    // of the full-width day row (2026-10-07, pane sRGB (0.208, 0.296, 0.444)). 0.60
                    // lands on **exactly** 4.50:1 — the floor itself, with no margin for the aurora
                    // drifting a shade lighter under it, which it does continuously. The shown day's
                    // is full white, and measures 7.4:1 inside its rim.
                    .foregroundStyle(.white.opacity(isShown ? 1 : 0.72))
                    .lineLimit(1)
            }
            .padding(.vertical, slotPadding)
            // The whole slot is the target, never just the bar (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
                // The shown day's lit rim. Present for every day at zero opacity rather than
                // inserted for one, so moving the selection animates a colour instead of a layer
                // (rule `50-views`). A rim and a weight change, never colour alone
                // (rule `65-accessibility`). Measured off a render, the 0.55 stroke reads 4.15:1
                // against the pane beside it, sRGB (0.188, 0.277, 0.390) — over the 3:1 floor
                // for a non-text mark.
                Capsule()
                    .fill(.white.opacity(isShown ? 0.08 : 0))
                    .strokeBorder(.white.opacity(isShown ? 0.55 : 0), lineWidth: 1)
                    .padding(.horizontal, 3)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name(of: day))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), day.total))
        .accessibilityAddTraits(isShown ? [.isSelected] : [])
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

    /// One line across all seven bars at the goal's height. Drawn over the buttons and outside the
    /// hit test, so a tap on the line still lands on the day beneath it.
    private var goalLine: some View {
        Rectangle()
            .fill(.white.opacity(0.45))
            .frame(height: 1)
            .padding(.horizontal, barInset)
            .offset(y: slotPadding + barHeight * (1 - min(Double(manager.dailyGoal) / Double(scale), 1)))
            .allowsHitTesting(false)
    }

    /// What VoiceOver calls a day: "Today", or its weekday in full. Seven consecutive days hold
    /// seven different weekdays, so the name alone is unique in the window.
    private func name(of day: DaySummary) -> Text {
        guard day.dayOrdinal != manager.history.last?.dayOrdinal else { return Text("Today", bundle: strings) }
        return Text(day.date.formatted(.dateTime.weekday(.wide).locale(locale)))
    }

    /// Average and best, side by side while they fit and stacked when they do not.
    ///
    /// Two strings rather than one, and a `ViewThatFits` rather than a wrap. As a single
    /// `"Average %1$d ml · Best %2$d ml"` it truncated outright at `AccessibilityXXXL` — the two
    /// figures the card exists to show, cut off — and once allowed to wrap it broke after the
    /// separator, leaving a line beginning "· Best 8050 ml". Letting the row become a column is
    /// the shape rule `65-accessibility` asks for when scaled content overflows, and two keys also
    /// give a translator two independent phrases instead of one word order.
    ///
    /// Hidden from VoiceOver: the title already speaks both figures as its value.
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
        .accessibilityHidden(true)
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

// MARK: - The sheet

/// What the serving sheet was opened for — its `.sheet(item:)` selection, and the only place a
/// ``WaterLog`` sits in `@State` (rule `50-views`).
private enum ServingEditor: Identifiable, Hashable {

    /// A new serving, the wheel opening on this instant.
    case adding(at: Date)

    /// An existing serving.
    case editing(WaterLog)

    var id: Self { self }
}

/// Adds a serving, or corrects one's amount and time.
///
/// Deliberately the same lockup as `GoalSetupView`'s goal card — one glass pane, a hero readout
/// with a ratio-sized unit, an `Aurora.cyan` slider — because every pane in this product is lit by
/// the same light, and a second layout for "pick a number in millilitres" would be a second one.
/// The time is a wheel inside the same pane: one pane asks how much and when.
private struct ServingSheet: View {

    let editor: ServingEditor

    /// What the wheel offers — ``DataManager/correctionRange()``, the week up to now.
    let range: ClosedRange<Date>

    /// Hands the saved serving's time back, so History can show the day it landed on.
    let saved: (Date) -> Void

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.dismiss) private var dismiss

    /// The amount under the finger, as an `Int` for the same reason every other volume here is
    /// one. The `Double` a `Slider` demands lives only inside ``sliderValue``.
    @State private var amount: Int

    /// The instant on the wheel.
    @State private var when: Date

    /// Bumped when the serving is saved, so the haptic fires on the tap rather than on any later
    /// change to the model.
    @State private var commits = 0

    /// The amount the sheet opened on, which is what the slider's bounds widen to contain.
    private let openingAmount: Int

    @ScaledMetric(relativeTo: .largeTitle) private var readoutSize: CGFloat = 52

    init(editor: ServingEditor, range: ClosedRange<Date>, startingAmount: Int, saved: @escaping (Date) -> Void) {
        self.editor = editor
        self.range = range
        self.saved = saved

        let opening: (amount: Int, when: Date)
        switch editor {
        case .adding(let instant): opening = (startingAmount, instant)
        case .editing(let log): opening = (log.amount, log.timestamp)
        }
        openingAmount = opening.amount
        _amount = State(initialValue: opening.amount)
        _when = State(initialValue: opening.when)
    }

    private var bounds: ClosedRange<Int> { HistoryView.sliderBounds(forAmount: openingAmount) }

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
        // Full height only: the wheel does not fit the half-height detent on a small phone.
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sensoryFeedback(Haptics.pour, trigger: commits)
    }

    private var title: some View {
        Group {
            switch editor {
            case .adding: Text("Add a serving", bundle: strings)
            case .editing: Text("Edit serving", bundle: strings)
            }
        }
        .font(.title2.weight(.bold))
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
    }

    private var card: some View {
        VStack(spacing: 24) {
            readout
                .padding(.horizontal, 24)

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
            .padding(.horizontal, 24)

            // Day, hour and minute on one wheel, bounded by the week and by now, so neither a day
            // the screen cannot show nor a time that has not happened can be picked. It formats
            // through the environment locale the app injects with `\.strings` (rule `70-privacy`).
            //
            // The wheel alone runs the card's full width, without the 24-pt inset. Its natural
            // width is more than that inset leaves, and a view that will not shrink widens
            // everything above it: the first build pushed the card and both buttons past the
            // screen's right edge. `minWidth: 0` is what stops it reporting more than it is
            // offered.
            //
            // **Its neighbouring rows fall under the text floor, and that is recorded rather than
            // hidden.** Measured off a render, the row being set reads 5.47:1 against its band. UIKit
            // draws the rows around it in a dimmed grey that assumes a near-black backdrop and that
            // no public API recolours; on this pane they measure 2.4–2.8:1 against the 4.5:1 rule
            // `65-accessibility` sets. Accepted by the owner on 2026-10-07 as the system control's
            // own styling — `docs/AI_CONTEXT.md` known issue #59.
            DatePicker(selection: $when, in: range, displayedComponents: [.date, .hourAndMinute]) {
                Text("When", bundle: strings)
            }
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .padding(.vertical, 30)
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
                    // Two buttons share the row, so each label has half of it. At
                    // `AccessibilityXXXL` *Cancel* ran past its capsule's edge (known issue #60), and
                    // Uzbek's *Bekor qilish* is twice as long; the label shrinks to fit instead, and
                    // keeps clear of the capsule's curved ends. 0.4, because 0.5 with the clearance
                    // would have truncated the Uzbek rather than shrunk it.
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())

            Button {
                // One call. The model clamps, skips a write that changes nothing, recomputes the
                // total from the logs and rings the widget doorbell exactly once — none of which
                // is this view's business to repeat (rule `20-state`).
                switch editor {
                case .adding:
                    manager.addLog(amount: amount, at: when)
                case .editing(let log):
                    manager.updateLog(log, newAmount: amount, timestamp: when)
                }
                saved(when)
                commits += 1
                dismiss()
            } label: {
                Text("Save", bundle: strings)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
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
        rescheduleReminders: { _ in },
        // The production default reaches a real `WCSession`; same reasoning as above.
        publishWrist: { _ in }
    )
}

#Preview("With servings") {
    let manager = previewManager(named: "preview.waterbuddy.history")

    // Pinned to the start of the day rather than offset from `now`, so the sample does not fall
    // out of "today" when the canvas happens to run after midnight. Two days back as well, so the
    // card has a past day to pick.
    let start = Calendar.waterBuddyDay.startOfDay(for: .now)
    manager.addLog(amount: 250, at: start.addingTimeInterval(8 * 3_600))
    manager.addLog(amount: 500, at: start.addingTimeInterval(12 * 3_600 + 1_800))
    manager.addLog(amount: 250, at: start.addingTimeInterval(15 * 3_600))
    manager.addLog(amount: 150, at: start.addingTimeInterval(17 * 3_600 + 600))
    if let earlier = Calendar.waterBuddyDay.date(byAdding: .day, value: -2, to: start) {
        manager.addLog(amount: 500, at: earlier.addingTimeInterval(9 * 3_600))
        manager.addLog(amount: 750, at: earlier.addingTimeInterval(14 * 3_600))
    }

    return HistoryView().environment(manager)
}

#Preview("Nothing logged") {
    HistoryView().environment(previewManager(named: "preview.waterbuddy.history.empty"))
}
