//
//  HomeView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftData
import SwiftUI

/// What Home offers to take back: the one pour just made from this screen.
///
/// A value at file scope, and `nonisolated`, so `HomeLayoutTests` can read it off the main actor
/// (rule `43-concurrency`). It holds the row's **id**, never the row: a `WaterLog` may sit in a
/// view's state only as a sheet's selection (rule `50-views`).
nonisolated struct UndoOffer: Equatable, Sendable {

    /// The serving ``DataManager/addLog(amount:at:)`` returned. Two pours of one amount are two
    /// offers, which is what lets an older pour's timer tell that it has been replaced.
    let id: UUID

    /// Millilitres, for the line that says what would be taken back.
    let amount: Int

    /// How long an offer stands: long enough to notice a mis-tap, short enough that the line it
    /// replaces is not hidden for long.
    static let window: Duration = .seconds(8)

    /// How long this offer stands, or `nil` when it does not time out.
    ///
    /// **VoiceOver gets no deadline.** Eight seconds is a sighted glance; finding a button that
    /// has just appeared, by swiping, is not. The next pour or leaving the screen still ends it.
    static func lifetime(voiceOverRunning: Bool) -> Duration? {
        voiceOverRunning ? nil : window
    }
}

struct HomeView: View {

    /// One entry in the quick-add row — a vessel the user recognises, and what it holds.
    ///
    /// **The amounts are user data now and live on the model; the names, glyphs and order stay
    /// here.** That split is what is left of the old ruling, and the half that survives is still
    /// the important half: `DataManager` is compiled into the widget extension, so anything put on
    /// it ships into a binary that mostly does not read it. Three glyph names and two localisation
    /// keys genuinely never cross, so they stayed. The three *amounts* had to, because the widget's
    /// one button now draws and logs the middle one — which is the entire point of the feature.
    ///
    /// What this type is no longer is a **menu**. ``HistoryView/servingRange`` and
    /// ``GoalSetupView/goalRange`` still are — they are what a screen *offers* — and the editor in
    /// `SettingsView` offers exactly that range. But these three numbers are now a stored
    /// preference, and rule `20-state` makes `DataManager` the only thing allowed to persist one.
    struct Serving: Identifiable, Hashable {
        /// The **untranslated key** spoken by VoiceOver; the glyph is what says "cup" on screen.
        ///
        /// A key rather than a resolved string, because `servings` is a `static let` evaluated once
        /// and the user can change the language at any time — a name resolved here would be frozen
        /// at whatever the app launched in. ``name(in:)`` resolves it at render.
        let nameKey: String
        /// Millilitres, as `Int`, like every volume in this product.
        let amount: Int
        /// An SF Symbol name. `HomeServingTests.everyServingSymbolResolves` proves it resolves,
        /// because an unknown symbol draws **nothing at all** — no glyph, no warning, no failed
        /// build, and nothing else in the gate can see it.
        let symbol: String
        /// Whether this is the Glass — the slot every one-tap door logs
        /// (``DataManager/usualSlot``), and so the one Home draws as its main action.
        let isUsual: Bool

        func name(in bundle: Bundle) -> String {
            bundle.localizedString(forKey: nameKey, value: nameKey, table: nil)
        }

        /// The **slot**, not the amount.
        ///
        /// This was `amount`, which was safe only while the three were compile-time constants
        /// chosen to be distinct. The user can now set two vessels to the same number, and a
        /// colliding `id` in the row's `ForEach` makes SwiftUI drop or merge a row, route a tap to
        /// the wrong button and mis-target `PressStyle`'s recoil — silently, with at most a debug
        /// warning, and invisibly to every test in the gate.
        ///
        /// The slot is also what the stored triple's index means and what "the middle vessel" names
        /// for the widget, so identifying by it keeps all three in agreement.
        var id: String { nameKey }
    }

    /// The vessels the row draws: the fixed slots, wearing the user's amounts.
    ///
    /// **Takes the amounts rather than the `DataManager` that holds them**, which is what keeps it
    /// a pure function and safely `nonisolated`. Taking the model would mean reaching a
    /// `@MainActor` property from a `nonisolated` context, and the only way to do that without an
    /// `await` is `MainActor.assumeIsolated`, which *traps* when the assumption is wrong — a
    /// `precondition` in all but name, and rule `75-diagnostics` records that this codebase has
    /// zero of those. The caller is a `body`, which is already on the main actor, so it simply
    /// reads `manager.servings` and hands the array over; that read is also what registers the
    /// observation which redraws the row after an edit.
    ///
    /// `zip` truncates to the shorter side, so a mismatch between slots and amounts silently
    /// shortens the row rather than trapping — and `everySlotIsNamedAndDrawn` asserts the two
    /// counts agree so the mismatch cannot arrive unnoticed.
    nonisolated static func servings(amounts: [Int]) -> [Serving] {
        zip(vesselSlots, amounts).enumerated().map { index, pair in
            Serving(
                nameKey: pair.0.nameKey,
                amount: pair.1,
                symbol: pair.0.symbol,
                isUsual: index == DataManager.usualSlot
            )
        }
    }

    // MARK: Sizes

    /// The vessel never grows past this, whatever the text size: at 340 pt it is already most of
    /// the narrowest phone's width.
    nonisolated static let vesselCeiling: CGFloat = 340

    /// The vessel never shrinks below this. Under it the line inside the vessel is too small to
    /// read, and a screen that is short of room scrolls instead.
    nonisolated static let vesselFloor: CGFloat = 200

    /// Ceilings for the quick-add discs, so one vessel cannot fill the screen at the
    /// accessibility sizes. The row scrolls sideways before a disc gives up its size.
    nonisolated static let sideDiscCeiling: CGFloat = 92
    nonisolated static let glassDiscCeiling: CGFloat = 120

    /// The column's margins. ``HomeColumn`` is told the visible height less the top and bottom
    /// of these, so the two cannot drift apart.
    nonisolated static let columnPadding = EdgeInsets(top: 8, leading: 24, bottom: 20, trailing: 24)

    /// The diameters the vessel may take: its scaled design size at most, less when the screen is
    /// short of room, and never under the floor.
    ///
    /// **Large text raises the ceiling and never the floor: the vessel gives way before the
    /// quick-add row does.** Larger type makes everything else in the column taller, which is a
    /// shorter screen by another name, and the row is the screen's one action. A floor that rose
    /// with the text size — two thirds of the scaled size — was built and drawn: on a
    /// 402 x 874 pt phone it put the vessels' names under the tab bar from the second accessibility
    /// size and left 42 pt of each disc showing at the largest, where this floor keeps the whole
    /// row on screen up to the fourth and the discs, without their captions, at the fifth. The
    /// cost is the line inside the vessel, a ratio of it: 11 pt at the floor, whatever the text
    /// size.
    nonisolated static func vesselRange(scaled: CGFloat) -> ClosedRange<CGFloat> {
        let ceiling = min(scaled, vesselCeiling)
        return min(vesselFloor, ceiling)...ceiling
    }

    /// The vessel's diameter: what the rest of the column leaves of the visible height, held
    /// inside `range`. Below the floor it stops shrinking, and the column outgrows the screen.
    nonisolated static func vesselDiameter(available: CGFloat, others: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(available - others, range.lowerBound), range.upperBound)
    }

    /// A quick-add disc's diameter: scaled with type, held between the 44 pt floor rule
    /// `65-accessibility` sets and its ceiling.
    nonisolated static func discDiameter(scaled: CGFloat, ceiling: CGFloat) -> CGFloat {
        min(max(scaled, 44), ceiling)
    }

    /// The SF Symbols Home draws beside its own text. `everyHomeGlyphResolves` proves each one,
    /// because an unknown symbol draws nothing at all.
    nonisolated static let streakSymbol = "flame.fill"
    nonisolated static let reminderSymbol = "bell.fill"
    nonisolated static let lastDrinkSymbol = "clock"
    nonisolated static let undoSymbol = "arrow.uturn.backward"
    nonisolated static let glyphs = [streakSymbol, reminderSymbol, lastDrinkSymbol, undoSymbol]

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverRunning
    @Environment(\.scenePhase) private var scenePhase

    /// Bumped on every pour. Drives the haptic, so a daily rollover cannot fire one.
    @State private var pours = 0
    /// Bumped when a pour is taken back.
    @State private var undos = 0
    /// Bumped each time the goal is crossed **upward**, and used as the confetti's seed as well as
    /// its trigger — so two celebrations in one day are two different bursts, not a replay.
    @State private var goalBursts = 0
    /// When water last landed. The waves read this to slosh and settle.
    @State private var lastPour = Date.distantPast
    /// The pour this screen can take back. Presentation state: it lives and dies with the view,
    /// which `RootTabView` rebuilds on every tab change — so leaving the tab ends the offer.
    @State private var undoOffer: UndoOffer?

    /// Real magnitudes, never a unitless `1`: `@ScaledMetric` resolves through `UIFontMetrics`,
    /// which rounds to the nearest third of a point (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .largeTitle) private var scaledVessel: CGFloat = 300
    @ScaledMetric(relativeTo: .title3) private var scaledSideDisc: CGFloat = 68
    @ScaledMetric(relativeTo: .title3) private var scaledGlassDisc: CGFloat = 88

    var body: some View {
        ZStack {
            AuroraBackground()

            // The app's idiom for a screen that can outgrow the display — a reader for the visible
            // height, and a scroll view that only bounces when there is something to scroll —
            // with ``HomeColumn`` where the other screens have a `VStack`, because this column
            // has a part that must shrink before anything scrolls.
            GeometryReader { proxy in
                ScrollView {
                    HomeColumn(
                        height: proxy.size.height - Self.columnPadding.top - Self.columnPadding.bottom,
                        vessel: Self.vesselRange(scaled: scaledVessel)
                    ) {
                        header
                        vessel
                        status
                        quickAddRow
                    }
                    .padding(Self.columnPadding)
                    .frame(maxWidth: .infinity)
                }
                .scrollBounceBehavior(.basedOnSize)
                // The vessel floats 44 pt of shadow and throws confetti past its rim; a scroll
                // view clips to its bounds, and both would be sliced off square
                // (rule `60-design-system`).
                .scrollClipDisabled()
            }
        }
        // The dark-appearance ruling lives on `RootTabView`: one hosting controller, one place to
        // declare the preference.
        .sensoryFeedback(Haptics.pour, trigger: pours)
        .sensoryFeedback(Haptics.confirm, trigger: undos)
        .sensoryFeedback(trigger: manager.hasReachedGoal) { wasReached, isReached in
            // Only on the way up — crossing back down is a new day or an Undo, not an achievement.
            isReached && !wasReached ? Haptics.goalReached : nil
        }
        // Same edge, a second consumer. `sensoryFeedback`'s closure cannot mutate state, so the
        // burst counter is bumped here rather than folded into the modifier above.
        .onChange(of: manager.hasReachedGoal) { wasReached, isReached in
            if isReached && !wasReached { goalBursts += 1 }
        }
        .task(id: undoClock) { await expire(undoClock) }
        // Leaving the app ends the offer, as leaving the tab does. Under VoiceOver an offer has no
        // deadline, and one made in the morning would otherwise still be standing in the
        // afternoon. Only the background: Control Center or a notification pulled over the screen
        // is not leaving it.
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { undoOffer = nil }
        }
        .animation(.smooth(duration: 0.3), value: standingOffer)
        .animation(.smooth(duration: 0.3), value: manager.streak)
        .onAppear { manager.refresh() }
    }

    private var percentage: Int {
        Int((manager.progressUnclamped * 100).rounded())
    }

    // MARK: - Header

    /// The day, the title, and the streak.
    ///
    /// The date is **the model's today** — the start of the last day in ``DataManager/history``,
    /// which the model republishes when the day turns — not a `Date()` read here, which would
    /// keep showing yesterday on a screen left open across midnight. Formatting a label is the
    /// one use `DaySummary.date` exists for.
    ///
    /// **One heading, not a date and a title read as two stops** — and the title itself is that
    /// heading, with the date as its value and the drawn date hidden. A wrapper built with
    /// `.accessibilityElement(children: .ignore)` reads the same to VoiceOver, but it leaves the
    /// title inside it as a second element named *Today* for anything that walks the tree, which
    /// is how `testHomeIsHeadedTodayOnce` first failed.
    ///
    /// The date has the row's whole width and the chip shares the title's line. With the chip
    /// beside both, the date was left a column too narrow for it at the largest text size and was
    /// cut short — *Sunday, 11 O…* — on the one line that says which day this is.
    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let today = manager.history.last?.date {
                Text(today, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.subheadline.weight(.semibold))
                    // Further than its neighbours may shrink: at 0.6 the date was still cut
                    // short — *Воскресенье, 11 октя…* — on a 375 pt phone at the largest text
                    // size, and half of that size is still larger than the ordinary one.
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(.white.opacity(0.92))
                    .legibleOnBackdrop()
                    .accessibilityHidden(true)
            }

            HStack(spacing: 12) {
                Text("Today", bundle: strings)
                    .font(.largeTitle.weight(.bold))
                    // First call on the row's width, and rigid in height. The title may shrink
                    // when a long word at a large text size truly does not fit beside the chip,
                    // and for nothing else: left to the stack, it was drawn at 72 % on every day
                    // with a streak (`testTheTitleKeepsItsSizeBesideTheStreak`).
                    .layoutPriority(1)
                    .fixedSize(horizontal: false, vertical: true)
                    // On the two texts and not on the stack: the chip is a pane, and a shadow on
                    // the stack would be cast by it as well.
                    .legibleOnBackdrop()
                    .accessibilityValue(spokenDate)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                streakChip
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(.white)
    }

    /// The month spelled out, which is how the drawn date already reads.
    private var spokenDate: Text {
        guard let today = manager.history.last?.date else { return Text(verbatim: "") }
        return Text(today.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale)))
    }

    /// A flame and a count: the days in a row the goal was reached. Absent at zero.
    ///
    /// **No noun.** "12 days" needs plural forms in English and Russian that this app's string
    /// path cannot produce yet (known issue #40), so the glyph says what the number counts and
    /// VoiceOver is given the words.
    ///
    /// `.frosted` like the discs, and `.resting` where they are `.raised`: it is a label, and
    /// sitting lower is what keeps it from reading as something to press.
    @ViewBuilder
    private var streakChip: some View {
        if manager.streak > 0 {
            HStack(spacing: 6) {
                Image(systemName: Self.streakSymbol)
                    .foregroundStyle(Aurora.cyan)
                Text(manager.streak, format: .number)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(manager.streak)))
            }
            .font(.subheadline.weight(.bold))
            .fontDesign(.rounded)
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.leading, 10)
            .padding(.trailing, 14)
            // Nothing at the ordinary sizes, where the 36 pt floor is taller than the line and
            // this together. At the accessibility sizes the line is the taller, and without it
            // the flame stood past the capsule's edge.
            .padding(.vertical, 6)
            .frame(minHeight: 36)
            .liquidGlass(in: Capsule(), density: .frosted, elevation: .resting)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Day streak", bundle: strings))
            .accessibilityValue(Text(manager.streak, format: .number))
            .transition(.opacity)
        }
    }

    // MARK: - Vessel

    /// The vessel, as large as the screen allows.
    ///
    /// ``HomeColumn`` decides its size — what the header, the status and the row leave, between
    /// ``vesselRange(scaled:)``'s floor and ceiling — and the reader tells the vessel what it
    /// got. It needs the number: its waves and its readout are ratios of it.
    private var vessel: some View {
        GeometryReader { slot in
            WaterVessel(
                level: manager.progress,
                percentage: percentage,
                volume: manager.currentWater,
                goal: manager.dailyGoal,
                diameter: min(slot.size.width, slot.size.height),
                lastPour: lastPour
            )
            // On the vessel, not on the screen. The celebration belongs to the thing that just
            // filled up, and an `overlay` does not clip, so the pieces still travel past the rim.
            .overlay { ConfettiOverlay(burst: goalBursts) }
        }
    }

    // MARK: - Status

    /// What is left, and under it one quiet line — or, straight after a pour, the way to take it
    /// back.
    private var status: some View {
        VStack(spacing: 8) {
            Text(statusText)
                .font(.title2.weight(.bold))
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .legibleOnBackdrop()
                .contentTransition(.numericText(value: Double(manager.remaining)))
                .animation(.smooth(duration: 0.5), value: manager.remaining)
                // The figure is drawn grouped and spoken as a number of millilitres.
                .accessibilityLabel(spokenStatus)

            quietLine
                // One height for both of its states at the ordinary text sizes, so the row below
                // does not jump when Undo arrives and leaves.
                .frame(minHeight: 44)
        }
    }

    private var statusText: String {
        manager.hasReachedGoal
            ? strings.localizedString(forKey: "Goal reached", value: nil, table: nil)
            : strings.figure("%1$@ ml to go", manager.remaining, locale: locale)
    }

    private var spokenStatus: String {
        manager.hasReachedGoal
            ? strings.localizedString(forKey: "Goal reached", value: nil, table: nil)
            : String(format: strings.localizedString(forKey: "%1$d millilitres to go", value: nil, table: nil), manager.remaining)
    }

    @ViewBuilder
    private var quietLine: some View {
        if let offer = standingOffer {
            undoCapsule(offer)
                .transition(.opacity)
        } else {
            // Re-read every minute: a reminder that has passed stops being "next", and nothing
            // else would say so on a screen nobody is touching.
            TimelineView(.everyMinute) { _ in
                let next = manager.nextReminder
                let last = manager.lastDrink
                // Nothing to say is nothing drawn — not an empty element for VoiceOver to land on.
                if next != nil || last != nil {
                    times(next: next, last: last)
                }
            }
            .transition(.opacity)
        }
    }

    /// *Next reminder* and *Last drink*, whichever apply. Side by side when they fit, stacked
    /// when they do not — in Russian they do not, on any phone.
    private func times(next: Date?, last: Date?) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                timeItems(next: next, last: last, divided: true)
            }
            .lineLimit(1)
            // At its own size or not at all (see ``undoLine(amountKey:_:)``).
            .fixedSize()

            // The fallback, for a long language or large type: one above the other, each free to
            // shrink and then to wrap. A time cut short — *Last drink 0…* — says nothing.
            VStack(spacing: 4) {
                timeItems(next: next, last: last, divided: false)
            }
            .lineLimit(2)
            .minimumScaleFactor(0.6)
            .multilineTextAlignment(.center)
        }
        // The row's whole width, so the choice made when this is placed is the one made when it
        // was sized (see ``undoCapsule(_:)``).
        .frame(maxWidth: .infinity)
        .font(.footnote.weight(.medium))
        // Full white, where the canvas drew 0.88: dimmed, this line read 4.18:1 over the aurora's
        // brightest frame, and it is the smallest text on the screen. Its quietness is its size
        // and its weight.
        .foregroundStyle(.white)
        .legibleOnBackdrop()
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func timeItems(next: Date?, last: Date?, divided: Bool) -> some View {
        if let next {
            timeItem(Self.reminderSymbol, key: "Next reminder %1$@", at: next)
        }
        if divided, next != nil, last != nil {
            Circle()
                .fill(.white.opacity(0.7))
                .frame(width: 3, height: 3)
                .accessibilityHidden(true)
        }
        if let last {
            timeItem(Self.lastDrinkSymbol, key: "Last drink %1$@", at: last)
        }
    }

    /// One time, in the phone's own 12- or 24-hour form under the app's locale — the spelling
    /// History's rows use.
    private func timeItem(_ symbol: String, key: String, at date: Date) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: symbol)
                .accessibilityHidden(true)
            Text(String(
                format: strings.localizedString(forKey: key, value: nil, table: nil),
                date.formatted(.dateTime.hour().minute().locale(locale))
            ))
        }
    }

    // MARK: - Undo

    /// The offer, while the row it names is still one of today's.
    ///
    /// The model is asked rather than trusted from memory: the day can turn, and the row can be
    /// deleted, while an offer stands. An offer whose row has gone is not drawn.
    private var standingOffer: UndoOffer? {
        guard let undoOffer, manager.todaysLogs.contains(where: { $0.id == undoOffer.id }) else { return nil }
        return undoOffer
    }

    /// What the expiry task is keyed on: a new pour, or VoiceOver starting or stopping, restarts
    /// it; nothing else does.
    private var undoClock: UndoClock {
        UndoClock(offer: undoOffer, lifetime: UndoOffer.lifetime(voiceOverRunning: voiceOverRunning))
    }

    private func expire(_ clock: UndoClock) async {
        guard let offer = clock.offer, let lifetime = clock.lifetime else { return }
        do { try await Task.sleep(for: lifetime) } catch { return }
        // Re-checked after the sleep: an older pour's timer must not clear a newer pour's offer
        // (rule `43-concurrency`).
        if undoOffer == offer { undoOffer = nil }
    }

    /// *Added 250 ml · Undo*, as one control.
    ///
    /// The whole capsule is the button: the amount beside the word is what makes it safe to
    /// press. `.raised` and pressable like the discs, because it sits among them and is pressed
    /// the same way — and `.opaque` where they are `.frosted`, because it is the one pane on this
    /// screen that carries a line of text (rule `60-design-system`: density follows what the pane
    /// carries). On Apple's glass the two densities are one material; on the hand-made stack
    /// `.frosted` left *Added 250 ml* at 4.48:1 where the pane's highlight crosses it.
    /// Its label is the one word it draws; the amount is its value.
    ///
    /// **Three forms, and the first that fits at its own size is drawn — nothing is shrunk onto
    /// one line.** *Added 250 ml | Undo*; then *250 ml | Undo*, which keeps the capsule one line
    /// tall, so the row under it stays where the finger left it; then the two parts one above the
    /// other, each free to shrink and to wrap, as the quiet line's fallback is. Shrunk onto one
    /// line at the largest text size the amount was cut short — *Added 25…* — and the amount is
    /// the half that says what would be taken back
    /// (`testUndoDrawsItsAmountWholeAtTheLargestTextSize`).
    ///
    /// **The choice is among three buttons, never among three labels inside one, and it is made
    /// in the row's whole width.** Drawn without either, the capsule was sized as one form and
    /// drew another — the stacked form in a capsule one line tall: at three text sizes of three
    /// with the choice inside the button's label, and at one of five with it straight in the
    /// column. That is what `ViewThatFits` would do if it chose again when it was placed, inside
    /// only the size it had asked for; the cause was not shown, the remedy was. With the frame
    /// offering the row's width, every size drew the form it had been sized as.
    private func undoCapsule(_ offer: UndoOffer) -> some View {
        ViewThatFits(in: .horizontal) {
            undoButton(offer) {
                undoLine(amountKey: "Added %1$@ ml", offer)
            }
            undoButton(offer) {
                undoLine(amountKey: "%1$@ ml", offer)
            }
            undoButton(offer) {
                VStack(spacing: 2) {
                    undoAmount(key: "Added %1$@ ml", offer)
                        .lineLimit(2)
                    // One word: it shrinks before it is broken across two lines, which is what
                    // two lines allowed — *Отме* over *нить*.
                    undoWord
                        .lineLimit(1)
                }
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func undoButton(_ offer: UndoOffer, @ViewBuilder label: () -> some View) -> some View {
        Button {
            manager.undoLog(id: offer.id)
            undoOffer = nil
            undos += 1
        } label: {
            label()
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .frame(minHeight: 44)
                .liquidGlass(in: Capsule(), density: .opaque, elevation: .raised, interactive: true)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(Text("Undo", bundle: strings))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), offer.amount))
    }

    /// The capsule on one line: the amount, a hairline, the word.
    ///
    /// At its own size or not at all, which is what `fixedSize` says. Without it *Undo* was drawn
    /// *U…* at three text sizes, in a capsule that had been sized for the whole word: a line of
    /// text offered even a little less than it needs does not shrink by the difference, it drops
    /// letters. (A shortfall of a fraction of a point, when a button places its label in a
    /// rounded size, is the likely cause and was not measured.)
    private func undoLine(amountKey: String, _ offer: UndoOffer) -> some View {
        HStack(spacing: 10) {
            undoAmount(key: amountKey, offer)
            Capsule()
                .fill(.white.opacity(0.4))
                .frame(width: 1, height: 16)
            undoWord
        }
        .lineLimit(1)
        .fixedSize()
    }

    private func undoAmount(key: String, _ offer: UndoOffer) -> some View {
        Text(strings.figure(key, offer.amount, locale: locale))
            .font(.subheadline.weight(.medium))
    }

    private var undoWord: some View {
        HStack(spacing: 6) {
            Image(systemName: Self.undoSymbol)
                .foregroundStyle(Aurora.cyan)
            Text("Undo", bundle: strings)
        }
        .font(.subheadline.weight(.bold))
    }

    // MARK: - Quick add

    private var sideDisc: CGFloat {
        Self.discDiameter(scaled: scaledSideDisc, ceiling: Self.sideDiscCeiling)
    }

    private var glassDisc: CGFloat {
        Self.discDiameter(scaled: scaledGlassDisc, ceiling: Self.glassDiscCeiling)
    }

    /// The three vessels, side by side under the water.
    ///
    /// **The horizontal scroll is a Dynamic Type escape hatch, not a carousel** — so it is reached
    /// through `ViewThatFits` rather than being the row itself. Three discs fit every iPhone at
    /// the default text sizes; at the accessibility sizes the scaled discs and their captions
    /// overflow, and scrolling is what lets them keep their size instead of being squeezed under
    /// the 44 pt floor (rule `65-accessibility`).
    ///
    /// A bare `ScrollView` is wrong here, for a reason a green suite cannot show: a scroll view's
    /// content aligns to its leading edge, so at the sizes where the row fits — nearly always —
    /// the three would sit against the left margin. `ViewThatFits` gives the common case a plain,
    /// self-centring `HStack` and keeps the scroll for the case that needs it.
    private var quickAddRow: some View {
        ViewThatFits(in: .horizontal) {
            vesselRow
            ScrollView(.horizontal) {
                vesselRow
            }
            .scrollIndicators(.hidden)
            // `.raised` throws a 28 pt shadow, more than any sane padding would reserve.
            .scrollClipDisabled()
        }
    }

    /// Factored out because ``quickAddRow`` builds it **twice**.
    ///
    /// **The Glass is ranked above the other two.** It used to be one of three equal choices, on
    /// the argument that ranking one "would be a claim about the user's glass that this app
    /// cannot make". The app now makes that claim everywhere else: slot 1 is what the widget,
    /// Siri, the Control Center control and the watch all log. So it is the screen's one primary
    /// surface, and Cup and Bottle are glass beside it (spec §5.2, decision D4).
    ///
    /// Aligned at the bottom, so the three captions share a line and the larger disc rises above
    /// its neighbours rather than pushing its caption below theirs.
    private var vesselRow: some View {
        HStack(alignment: .bottom, spacing: 24) {
            ForEach(Self.servings(amounts: manager.servings)) { serving in
                servingButton(serving)
            }
        }
        .padding(.vertical, 8)
        // The two glass discs are siblings a few points apart: one container, one sample of the
        // aurora (rule `60-design-system`).
        .glassGroup()
    }

    /// One vessel: the glyph on its disc, then its amount, then its name.
    ///
    /// The label goes on the `Button` itself rather than on an enclosing
    /// `.accessibilityElement(children: .ignore)`, which **adds** a stop when what it wraps is a
    /// control (`tasks/lessons.md`). Both captions are hidden: the label already says the name and
    /// the amount.
    private func servingButton(_ serving: Serving) -> some View {
        VStack(spacing: 8) {
            Button {
                pour(serving)
            } label: {
                disc(serving)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(String(format: strings.localizedString(forKey: "%1$@, add %2$d millilitres", value: nil, table: nil), serving.name(in: strings), serving.amount))

            VStack(spacing: 1) {
                Text(strings.figure("%1$@ ml", serving.amount, locale: locale))
                    // Ratios of the disc they annotate, never text styles of their own: the disc
                    // is capped and a text style is not, so the two cross over at the
                    // accessibility sizes (rule `65-accessibility`). 0.22 x 68 pt is 15 pt.
                    .font(.system(size: sideDisc * 0.22, weight: serving.isUsual ? .heavy : .bold, design: .rounded))
                    .monospacedDigit()
                // Full white for all three. Dimmed to 0.92, the Bottle's name read 4.24:1 over the
                // magenta light; the Glass is set apart by its disc and its heavier figure.
                Text(serving.name(in: strings))
                    .font(.system(size: sideDisc * 0.18, weight: .semibold))
            }
            .foregroundStyle(.white)
            .lineLimit(1)
            .legibleOnBackdrop()
            .accessibilityHidden(true)
        }
    }

    /// The disc: the primary surface for the Glass, glass for the other two.
    ///
    /// The branch is on the slot, which never changes for a button, so nothing is rebuilt. The
    /// primary surface colours its own content — a glyph that set `.white` there would be white
    /// on white.
    @ViewBuilder
    private func disc(_ serving: Serving) -> some View {
        let diameter = serving.isUsual ? glassDisc : sideDisc
        let glyph = Image(systemName: serving.symbol)
            // A ratio of the disc it sits in, never its own text style, so it cannot grow through
            // the edge at the accessibility sizes (rule `65-accessibility`).
            .font(.system(size: diameter * 0.4, weight: .semibold))
            .frame(width: diameter, height: diameter)

        if serving.isUsual {
            glyph.primarySurface(in: Circle())
        } else {
            glyph
                .foregroundStyle(.white)
                .liquidGlass(in: Circle(), density: .frosted, elevation: .raised, interactive: true)
        }
    }

    /// One call into the model, and the offer to take it back (rule `50-views`).
    private func pour(_ serving: Serving) {
        let id = manager.addLog(amount: serving.amount)
        undoOffer = id.map { UndoOffer(id: $0, amount: serving.amount) }
        pours += 1
        lastPour = Date()
    }
}

/// What Home's expiry task is keyed on.
nonisolated private struct UndoClock: Equatable {
    let offer: UndoOffer?
    let lifetime: Duration?
}

// MARK: - The column

/// Home's column: the header, the status and the quick-add row at their own heights, and the
/// vessel — its second child — given what is left.
///
/// A `VStack` cannot do this inside a `ScrollView`, and both ways it fails were drawn before this
/// replaced one. A scroll view asks its content for its *ideal* height, the vessel's ideal is its
/// largest, and the column simply grew past the screen: on a 375 x 667 pt phone the vessel was
/// 300 pt and the screen scrolled, where 214 pt fits. And where the stack was merely short of
/// room it squeezed whatever could shrink — a line of text with a `minimumScaleFactor` — before
/// the vessel: on an iPhone 16 the status line was drawn at 72 %
/// (`testTheStatusLineIsNeverSqueezedToMakeRoomForTheVessel`).
///
/// So the arithmetic is said outright. Every other child is measured at its own height, the
/// vessel takes ``HomeView/vesselDiameter(available:others:range:)``, and any height still spare
/// is split above the vessel and above the row. The column is exactly as tall as the screen until
/// even the smallest vessel does not fit; then it grows, and the screen scrolls.
private struct HomeColumn: Layout {

    /// The visible height to fill.
    var height: CGFloat

    /// The diameters the vessel may take.
    var vessel: ClosedRange<CGFloat>

    /// Which child is the vessel.
    private static let vesselIndex = 1

    /// The least air above the vessel, between it and the status, and above the row.
    private static let gapAboveVessel: CGFloat = 16
    private static let gapBelowVessel: CGFloat = 24
    private static let gapAboveRow: CGFloat = 20
    private static var gaps: CGFloat { gapAboveVessel + gapBelowVessel + gapAboveRow }

    /// Each child's height, the vessel's diameter among them, and the height left over.
    private func arrangement(width: CGFloat, _ subviews: Subviews) -> (heights: [CGFloat], spare: CGFloat) {
        var heights = subviews.map { $0.sizeThatFits(ProposedViewSize(width: width, height: nil)).height }
        guard heights.indices.contains(Self.vesselIndex) else { return (heights, 0) }

        heights[Self.vesselIndex] = 0
        let others = heights.reduce(0, +) + Self.gaps
        let diameter = min(HomeView.vesselDiameter(available: height, others: others, range: vessel), width)
        heights[Self.vesselIndex] = diameter
        return (heights, max(0, height - others - diameter))
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let plan = arrangement(width: width, subviews)
        return CGSize(width: width, height: plan.heights.reduce(0, +) + Self.gaps + plan.spare)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let plan = arrangement(width: bounds.width, subviews)
        var y = bounds.minY

        for (index, subview) in subviews.enumerated() {
            switch index {
            case Self.vesselIndex: y += Self.gapAboveVessel + plan.spare / 2
            case Self.vesselIndex + 1: y += Self.gapBelowVessel
            case Self.vesselIndex + 2: y += Self.gapAboveRow + plan.spare / 2
            default: break
            }
            let height = plan.heights[index]
            let width = index == Self.vesselIndex ? height : bounds.width
            subview.place(
                at: CGPoint(x: bounds.midX, y: y),
                anchor: .top,
                proposal: ProposedViewSize(width: width, height: height)
            )
            y += height
        }
    }
}

// MARK: - Vessel

private struct WaterVessel: View {

    let level: Double
    let percentage: Int
    let volume: Int
    let goal: Int
    let diameter: CGFloat
    let lastPour: Date

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            water
            readabilityScrim
            readout
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), percentage, volume, goal))
    }

    // MARK: Water

    @ViewBuilder
    private var water: some View {
        if reduceMotion {
            // Reduce Motion is aimed squarely at exactly this: a loop that never stops. The
            // level still animates when it changes; only the perpetual travel is dropped.
            waves(phase: 0, slosh: 0)
        } else {
            TimelineView(.animation) { context in
                let seconds = context.date.timeIntervalSinceReferenceDate
                waves(phase: seconds * 1.1, slosh: slosh(at: context.date))
            }
        }
    }

    private func waves(phase: Double, slosh: Double) -> some View {
        WaterSurface(
            level: level,
            phase: phase,
            amplitude: diameter * 0.018 + diameter * 0.05 * slosh
        )
        .clipShape(Circle())
        // Inset so the water sits in a well and can never cover the vessel's lit rim.
        .padding(10)
        .animation(.smooth(duration: 0.9), value: level)
    }

    /// How agitated the surface is, decaying after a pour.
    private func slosh(at date: Date) -> Double {
        let elapsed = date.timeIntervalSince(lastPour)
        guard elapsed >= 0, elapsed < 5 else { return 0 }
        return exp(-elapsed * 1.5)
    }

    // MARK: Readout

    /// See ``WaterReadabilityScrim`` for why this is here rather than being tuned away.
    private var readabilityScrim: some View {
        WaterReadabilityScrim(diameter: diameter)
    }

    /// The percentage and, under it, today's water against the goal.
    ///
    /// Sized as ratios of the vessel — which is itself scaled with the text size and bounded by
    /// the screen — never with text styles of their own, so the readout cannot grow through the
    /// rim at the accessibility sizes (rule `65-accessibility`). 0.28 x 300 pt is 84 pt.
    private var readout: some View {
        VStack(spacing: diameter * 0.02) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(percentage, format: .number)
                    .font(.system(size: diameter * 0.28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(percentage)))
                // Full white, like the figure it belongs to: at 0.88 it read 2.98:1 over a full
                // vessel, where the scrim has all but run out.
                Text("%")
                    .font(.system(size: diameter * 0.1, weight: .bold, design: .rounded))
            }

            Text(strings.figure("%1$@ of %2$@ ml", volume, goal, locale: locale))
                .font(.system(size: diameter * 0.057, weight: .bold, design: .rounded))
                .monospacedDigit()
                // The smallest text in the vessel and the furthest from the scrim's centre, so it
                // carries a halo of its own as well as the readout's.
                .legibleOnBackdrop()
        }
        // An over-full vessel reads four digits. Bound the readout to the circle and let it
        // shrink instead of running through the rim.
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: diameter * 0.78)
        .foregroundStyle(.white)
        // Two shadows, as the widget's readout has. The scrim behind this is radial and centred,
        // so it is nearly gone by the time it reaches the "%" and the line under the figure; the
        // tight second shadow is a halo that travels with the glyphs, whatever they land on.
        .shadow(color: .black.opacity(0.3), radius: 10, y: 2)
        .shadow(color: .black.opacity(0.45), radius: 2)
        .animation(.smooth(duration: 0.5), value: percentage)
    }
}

private extension View {

    /// For text that sits straight on the aurora, with no pane under it.
    ///
    /// The aurora's lights swing under this text, and at their brightest white alone falls short
    /// of 4.5:1 — the Bottle's caption read 4.2:1 over the magenta light. These are the widget
    /// readout's two shadows (rule `65-accessibility`: "a contrast threshold, not taste"): a soft
    /// one for depth, and a tight one that is a local halo and goes wherever the glyphs go.
    /// Measured beside the glyphs, off a sweep of the aurora (`docs/DESIGN.md`).
    func legibleOnBackdrop() -> some View {
        shadow(color: .black.opacity(0.3), radius: 6, y: 1)
            .shadow(color: .black.opacity(0.45), radius: 2)
    }
}

// MARK: - Preview

#Preview {
    // A throwaway suite *and* an in-memory store, so previewing — and tapping + in the canvas —
    // never writes into the real store.
    //
    // The container is the half that is easy to miss, and this preview was missing it: omitting
    // `modelContainer:` resolves `DataManager.sharedModelContainer`, which is the **live App Group
    // `WaterBuddy.store`**, so every canvas rebuild wrote a real 1,150 ml row into the user's own
    // data. Same defaulted-dependency trap that once pointed all 74 tests at live storage
    // (`tasks/lessons.md`), and rule `50-views` forbids it outright.
    let defaults = UserDefaults(suiteName: "preview.waterbuddy.home")!
    defaults.removePersistentDomain(forName: "preview.waterbuddy.home")

    let manager = DataManager(
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
    manager.addWater(amount: 1_150)

    return HomeView().environment(manager)
}
