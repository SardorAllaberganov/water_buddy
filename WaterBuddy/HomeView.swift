//
//  HomeView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import StoreKit
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
    /// ``WelcomeView/goalRange`` still are — they are what a screen *offers* — and the editor in
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

    /// How the date under the title is written: the weekday and the month spelled out.
    nonisolated static let dateFormat = Date.FormatStyle.dateTime.weekday(.wide).day().month(.wide)

    /// The least the date under the title may be drawn at, as a share of its own size — further
    /// than its neighbours may shrink, because it is the longest line a header draws.
    ///
    /// **Measured against the widest date there is.** At `0.6` the date was cut short on a
    /// 375 pt phone at the largest text size — *Воскресенье, 11 октя…*. `0.5` held for that
    /// day and not for every day: *Понедельник, 28 сентября* is 665.9 pt wide in the header's
    /// second line at that size and needs 0.491 of it to fit the 327 pt between the margins
    /// (`theWidestDateFitsTheNarrowestPhoneAtTheLargestTextSize`). At this floor the line is
    /// still drawn larger there than at the ordinary size: 24 pt against 17.
    nonisolated static let dateScaleFloor: CGFloat = 0.45

    /// Ceilings for the quick-add discs, so one vessel cannot fill the screen at the
    /// accessibility sizes. The row scrolls sideways before a disc gives up its size.
    nonisolated static let sideDiscCeiling: CGFloat = 92
    nonisolated static let glassDiscCeiling: CGFloat = 120

    /// The column's margins. ``HomeColumn`` is told the visible height less the top and bottom
    /// of these, so the two cannot drift apart. The top and the sides are every tab's
    /// (``ScreenMetrics``), which is what stands the title in one place on all three.
    nonisolated static let columnPadding = EdgeInsets(
        top: ScreenMetrics.topInset,
        leading: ScreenMetrics.margin,
        bottom: 20,
        trailing: ScreenMetrics.margin
    )

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
    /// size. Those figures were taken under the app's own bar, before every tab shared a
    /// header; under Apple's taller bar they have not been taken again.
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    /// Whether Home is the page shown, and not the one sliding out after a change of tab.
    @Environment(\.pageIsShown) private var pageIsShown
    /// StoreKit's rating request — one of StoreKit's two uses in the product (rule `70-privacy`).
    @Environment(\.requestReview) private var requestReview

    /// Bumped on every pour. Drives the haptic, so a daily rollover cannot fire one.
    @State private var pours = 0
    /// The drops on their way from a disc to the vessel: one a pour, gone when it lands. None
    /// under Reduce Motion (``PourDrop``).
    @State private var flights: [PourFlight] = []
    /// Bumped as a drop lands. Drives the vessel's swell.
    @State private var landings = 0
    /// How many times each vessel has been poured from this screen, by slot. Drives that disc's
    /// own bounce, so only the one that was pressed answers.
    @State private var poured: [String: Int] = [:]
    /// Bumped when a pour is taken back.
    @State private var undos = 0
    /// Bumped when the streak goes up. Drives the flame's bounce, so a count that drops — the
    /// pour that reached the goal, taken back — does not play it.
    @State private var streakRises = 0
    /// Bumped each time the goal is crossed **upward**, and used as the confetti's seed as well as
    /// its trigger — so two celebrations in one day are two different bursts, not a replay.
    @State private var goalBursts = 0
    /// Bumped when a pour **on this screen** takes today across the goal — and only then. A crossing
    /// `refresh()` picks up as the app comes forward is right after launch, which is no time to ask
    /// for a rating (spec D5). Keys the wait before the request (``askForARating(after:)``).
    @State private var goalPours = 0
    /// The crossing whose rating request is still waiting; `nil` once its pause has ended, whatever
    /// came of it, or as soon as Home stops being the page shown or the app stops being active
    /// (plan P2).
    @State private var ratingWait: Int?
    /// When water last landed. The waves read this to slosh and settle.
    @State private var lastPour = Date.distantPast
    /// The pour this screen can take back. Presentation state: it lives with the screen, and the
    /// screen ends it when it disappears — so leaving the tab ends the offer.
    @State private var undoOffer: UndoOffer?
    /// Whether this screen has arrived — set a few frames after it is built (``Arrival``).
    @State private var arrived = false

    /// Real magnitudes, never a unitless `1`: `@ScaledMetric` resolves through `UIFontMetrics`,
    /// which rounds to the nearest third of a point (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .largeTitle) private var scaledVessel: CGFloat = 300
    @ScaledMetric(relativeTo: .title3) private var scaledSideDisc: CGFloat = 68
    @ScaledMetric(relativeTo: .title3) private var scaledGlassDisc: CGFloat = 88

    var body: some View {
        // No backdrop of its own: the three tabs share the one `RootTabView` stands, which holds
        // still while the pages slide over it.
        //
        // The app's idiom for a screen that can outgrow the display — a reader for the visible
        // height, and a scroll view that only bounces when there is something to scroll — with
        // ``HomeColumn`` where the other screens have a `VStack`, because this column has a part
        // that must shrink before anything scrolls.
        GeometryReader { proxy in
            ScrollView {
                HomeColumn(
                    height: proxy.size.height - Self.columnPadding.top - Self.columnPadding.bottom,
                    vessel: Self.vesselRange(scaled: scaledVessel)
                ) {
                    // When the app opens, everything under the header settles in; a page that
                    // slides in is whole as it comes (``Arrival``).
                    header
                    vessel.arrives(arrived, order: 0)
                    status.arrives(arrived, order: 1)
                    quickAddRow.arrives(arrived, order: 2)
                }
                .padding(Self.columnPadding)
                .frame(maxWidth: .infinity)
                // Over the column and inside the scroll view, so a drop is drawn where the disc
                // and the vessel are and scrolls with them.
                .overlayPreferenceValue(PourPlaces.self) { places in
                    drops(between: places)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            // The vessel floats 44 pt of shadow and throws confetti past its rim; a scroll view
            // clips to its bounds, and both would be sliced off square
            // (rule `60-design-system`).
            .scrollClipDisabled()
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
        .task(id: goalPours) { await askForARating(after: goalPours) }
        // Leaving the app ends the offer, as leaving the tab does. Under VoiceOver an offer has no
        // deadline, and one made in the morning would otherwise still be standing in the
        // afternoon. Only the background: Control Center or a notification pulled over the screen
        // is not leaving it.
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { undoOffer = nil }
            // Anything that takes the app out of `.active` ends a rating's wait — Control Center
            // too, which the offer survives: the request would otherwise meet the user on their
            // way back.
            if phase != .active { ratingWait = nil }
        }
        // A change of tab ends it at the turn. The page stays in the tree while it slides out, so
        // the wait's own task is not cancelled until the slide has ended — and a request asked in
        // that time lands on the page sliding in (``EnvironmentValues/pageIsShown``).
        .onChange(of: pageIsShown) { _, shown in
            if !shown { ratingWait = nil }
        }
        .onChange(of: manager.streak) { was, now in
            if now > was { streakRises += 1 }
        }
        .onAppear { manager.refresh() }
        // Leaving the tab ends the offer, and nothing here has to say so: a page is rebuilt when
        // its tab is shown, and its state with it (`testAnUndoOfferDoesNotOutliveItsScreen`).
        // The one page that is not is one returned to before it had finished sliding out — it
        // never left, and its offer is still its own.
        .tracksArrival($arrived)
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
    /// **The date stands under the title**, as History's total does, so *Today* is in one place
    /// on both (``ScreenHeader``, `testTheTitleHoldsItsPlaceOnEveryTab`). It was drawn above the
    /// title until the two screens were first compared. There it also has the row's whole width:
    /// beside the chip it was cut short at the largest text size — *Sunday, 11 O…* — on the one
    /// line that says which day this is.
    private var header: some View {
        ScreenHeader {
            Text("Today", bundle: strings)
                .accessibilityValue(spokenDate)
                .accessibilityAddTraits(.isHeader)
        } detail: {
            if let today = manager.history.last?.date {
                Text(today, format: Self.dateFormat)
                    // Further than its neighbours may shrink (``dateScaleFloor``).
                    .minimumScaleFactor(Self.dateScaleFloor)
                    .accessibilityHidden(true)
            }
        } accessory: {
            streakChip
                // The chip arrives on the first day of a streak, and lands; its count rolls on
                // the same change. On the chip and not on the screen (see ``status``).
                .animation(Motion.land, value: manager.streak)
        }
    }

    /// The month spelled out, which is how the drawn date already reads.
    private var spokenDate: Text {
        guard let today = manager.history.last?.date else { return Text(verbatim: "") }
        return Text(today.formatted(Self.dateFormat.locale(locale)))
    }

    /// A flame, a count and its noun: the days in a row the goal was reached — *12 days*. Absent at
    /// zero.
    ///
    /// **The noun yields before the title does.** It shares a line with *Today* — *Сегодня* — and the
    /// title has the line first (``ScreenHeader``). Where the whole chip does not fit beside it, the
    /// chip draws the count alone rather than *12 д…*; it speaks the noun at every size
    /// (spec 2026-10-16 §3.4, rule `65-accessibility`).
    ///
    /// `.frosted` like the discs, and `.resting` where they are `.raised`: it is a label, and
    /// sitting lower is what keeps it from reading as something to press.
    @ViewBuilder
    private var streakChip: some View {
        if manager.streak > 0 {
            // Each candidate at its own width, so the fit is decided on the whole chip.
            ViewThatFits(in: .horizontal) {
                streakCapsule(Text(streakDays))
                streakCapsule(Text(manager.streak, format: .number))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Day streak", bundle: strings))
            .accessibilityValue(Text(streakDays))
            // The first day of a streak: the chip arrives small and lands at its size.
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    /// *12 days*, *12 дней*, *12 kun*.
    private var streakDays: String {
        strings.localized("%1$d days", manager.streak, locale: locale)
    }

    private func streakCapsule(_ count: Text) -> some View {
        HStack(spacing: 6) {
            Image(systemName: Self.streakSymbol)
                .foregroundStyle(Aurora.cyan)
                // Once, when the count goes up. The first day of a streak is the chip itself
                // arriving, and plays no bounce.
                .symbolEffect(.bounce, value: streakRises)
            count
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
        .fixedSize()
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
            // It takes the drop: a swell as each one lands.
            .swells(on: landings)
            // On the vessel, not on the screen. The celebration belongs to the thing that just
            // filled up, and an `overlay` does not clip, so the pieces still travel past the rim.
            .overlay { ConfettiOverlay(burst: goalBursts) }
        }
        // Where a drop is going. Reported in layout, so the rise the vessel arrives with does
        // not move the target.
        .anchorPreference(key: PourPlaces.self, value: .center) { [.vessel: $0] }
    }

    /// The drops in flight, each from the disc it was poured from to the vessel.
    ///
    /// A drop whose disc or vessel has no place — neither can happen while both are on screen —
    /// is not drawn, and is taken off the list by the next landing or by the screen going.
    private func drops(between places: [PourPlace: Anchor<CGPoint>]) -> some View {
        GeometryReader { proxy in
            ForEach(flights) { flight in
                if let disc = places[.disc(flight.slot)], let vessel = places[.vessel] {
                    PourDrop(start: proxy[disc], end: proxy[vessel]) {
                        land(flight)
                    }
                    // It is there at the disc and gone into the vessel: the drop fades itself
                    // as it lands, and needs no fade of SwiftUI's on the way in or out.
                    .transition(.identity)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// A drop has reached the vessel: the surface surges, the vessel swells, and the drop and
    /// any that left before it are done with.
    private func land(_ flight: PourFlight) {
        flights.removeAll { $0.id <= flight.id }
        landings += 1
        lastPour = Date()
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
                // The capsule is a thing that arrives, so it lands (``Motion/land``). **Here,
                // and not on the screen.** At the screen's root the spring also carried
                // whatever else changed in the same update — at the large text sizes the
                // stacked capsule is taller than the line it replaces, and the quick-add row
                // bounced under the finger that had just pressed it.
                //
                // It was on `.smooth` for one build, because rule `60-design-system` names one
                // spring; the owner, holding that build, asked for more life, and the rule's
                // wording is proposed in the stage's spec.
                .animation(Motion.land, value: standingOffer)
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
            : strings.localized("%1$d millilitres to go", manager.remaining, locale: locale)
    }

    @ViewBuilder
    private var quietLine: some View {
        if let offer = standingOffer {
            undoCapsule(offer)
                // It arrives small and lands at its size, a little past it and back: something
                // that has just been put down.
                .transition(.scale(scale: 0.8).combined(with: .opacity))
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
            Text(strings.localized(key, date.formatted(.dateTime.hour().minute().locale(locale)), locale: locale))
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
        .accessibilityValue(strings.localized("%1$d millilitres", offer.amount, locale: locale))
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
            // Where this vessel's drop leaves from.
            .anchorPreference(key: PourPlaces.self, value: .center) { [.disc(serving.id): $0] }
            .accessibilityLabel(strings.localized("%1$@, add %2$d millilitres", serving.name(in: strings), serving.amount, locale: locale))

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
            // Once per pour, on the disc that was pressed: feedback under a finger, like the
            // recoil beside it, so it has no Reduce Motion branch (rule `65-accessibility`).
            .symbolEffect(.bounce, value: poured[serving.id, default: 0])
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
        let wasReached = manager.hasReachedGoal
        let id = manager.addLog(amount: serving.amount)
        undoOffer = id.map { UndoOffer(id: $0, amount: serving.amount) }
        pours += 1
        poured[serving.id, default: 0] += 1
        // Two reads around the one call, not a second call: the pour that reached the goal is the
        // one moment a rating may be asked for.
        if !wasReached, manager.hasReachedGoal {
            goalPours += 1
            ratingWait = goalPours
        }
        // A drop for a pour that was logged, and none under Reduce Motion: it is travel across
        // the screen (rule `65-accessibility`). The serving is in the store already; the drop
        // only shows where it went.
        if id != nil, !reduceMotion {
            // The surface surges when the drop lands (``land(_:)``), not now: water that was
            // already sloshing before anything reached it gave the drop nothing to do, and the
            // waves, half died down by then, jumped back to full as it arrived.
            flights.append(PourFlight(id: pours, slot: serving.id))
        } else {
            lastPour = Date()
        }
    }

    // MARK: - Rating

    /// Asks iOS for a rating once the confetti of the pour that reached the goal has landed — if the
    /// model says this is the moment (rule `70-privacy`, *StoreKit, for the review request and for
    /// Premium*).
    ///
    /// Keyed on ``goalPours``, so the next crossing starts the wait again. After the pause it asks
    /// only if the wait still stands — Home stayed the page shown and the app stayed active, either
    /// of which clears ``ratingWait`` the moment it changes — and today is still at the goal, so an
    /// *Undo* inside the pause asks nothing. The task's own cancellation is not relied on: a page
    /// that is left stays in the tree until its slide has ended, and so does this task. The model
    /// then decides and records in one call, and StoreKit decides whether anything shows.
    private func askForARating(after crossing: Int) async {
        guard crossing > 0, ReviewPrompt.isEnabledHere else { return }
        do { try await Task.sleep(for: ReviewPrompt.pause) } catch { return }
        // Re-checked after the sleep, as `expire(_:)` does (rule `43-concurrency`).
        guard ratingWait == crossing else { return }
        ratingWait = nil
        guard manager.hasReachedGoal,
              manager.claimReviewRequest(version: ReviewPrompt.version)
        else { return }
        requestReview()
    }
}

/// One drop in flight: which pour it is, and which disc it left.
nonisolated private struct PourFlight: Identifiable, Equatable {
    let id: Int
    let slot: String
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
/// 300 pt and the screen scrolled, where 214 pt fitted under the app's own bar. (Under Apple's,
/// which stands taller, and every tab's header, that phone's vessel is at its 200 pt floor with
/// the row whole above the bar — rendered on iOS 26.5.) And where the stack was merely short of
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
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.scenePhase) private var scenePhase

    /// When the water's latest movement began, and where the surface stood then. Changed together,
    /// in one `onChange`, and read by the clock instead of `lastPour`: a frame drawn between the pour
    /// and the change still has the old pair, which stands the surface in the same place.
    @State private var motionStart = Date.distantPast
    @State private var restingPhase = 0.0

    /// Whether the water is moving, and so whether the clock runs at all.
    @State private var moving = false

    var body: some View {
        ZStack {
            water
            readabilityScrim
            // Above the scrim, under the readout, so the readout keeps both (rule
            // `60-design-system`, *Water*). Glass decoration: gone under Reduce Transparency.
            if !reduceTransparency { highlight }
            readout
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        .background {
            if !reduceTransparency { depth }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(strings.localized("%1$d percent. %2$d of %3$d millilitres.", percentage, volume, goal, locale: locale))
    }

    // MARK: Water

    @ViewBuilder
    private var water: some View {
        if reduceMotion {
            // Reduce Motion drops the travel altogether. The level still animates when it changes.
            waves(phase: 0, slosh: 0)
        } else {
            // The clock runs only while the water moves after a pour, and never while the app is
            // not active — behind Control Center, the app switcher, a system alert. Between pours
            // the water is still and costs nothing per frame (``WaterMotion``).
            TimelineView(.animation(minimumInterval: nil, paused: !moving || scenePhase != .active)) { context in
                waves(
                    phase: WaterMotion.phase(at: context.date, since: motionStart, base: restingPhase),
                    slosh: slosh(at: context.date)
                )
            }
            .onChange(of: lastPour) { _, pour in
                restingPhase = WaterMotion.base(after: restingPhase, from: motionStart, to: pour)
                motionStart = pour
            }
            .task(id: lastPour) {
                // Runs the clock for what is left of the movement, then stops it. A newer pour
                // cancels this one and starts its own, so only the latest pour's settling stops it.
                let left = WaterMotion.remaining(at: .now, since: lastPour)
                moving = left > 0
                guard left > 0 else { return }
                try? await Task.sleep(for: .seconds(left))
                guard !Task.isCancelled else { return }
                moving = false
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
        // It lands: past its mark and back, where it used to glide. The wave clamps the level
        // it draws, so an overshoot at the brim or the bottom stops at the glass.
        .animation(Motion.water, value: level)
    }

    /// How agitated the surface is, decaying after a pour — over the same window the water moves.
    private func slosh(at date: Date) -> Double {
        let elapsed = date.timeIntervalSince(lastPour)
        guard elapsed >= 0, elapsed < WaterMotion.settling else { return 0 }
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

    // MARK: Depth

    /// The canvas's vessel, a 300 pt board (`Main.dc.html`), turned into ratios of the diameter: a
    /// glow beneath it — `rgba(0,200,255,.36)`, not an `Aurora` colour, so `Aurora.cyan` stands in —
    /// 36 pt in from each side, 64 pt tall, 30 pt below the foot, blurred 10; a halo, a 10 pt ring of
    /// white at 0.05 just outside the rim; and a highlight, 128 × 62 pt at (30, 20), turned −28°.
    private enum Depth {
        static let glowWidth = 0.76
        static let glowHeight = 0.21
        static let glowOpacity = 0.36
        static let glowBlur = 0.033
        static let haloWidth = 0.033
        static let haloOpacity = 0.05
        static let highlightSize = CGSize(width: 0.427, height: 0.207)
        static let highlightOrigin = CGPoint(x: 0.10, y: 0.067)
        static let highlightAngle = -28.0
        static let highlightOpacity = 0.4
    }

    /// The glow beneath and the halo, behind the glass.
    private var depth: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [Aurora.cyan.opacity(Depth.glowOpacity), Aurora.cyan.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter * Depth.glowWidth / 2
                ))
                .frame(width: diameter * Depth.glowWidth, height: diameter * Depth.glowHeight)
                .blur(radius: diameter * Depth.glowBlur)
                // The canvas's glow is centred just above the vessel's foot.
                .offset(y: diameter * 0.5)

            Circle()
                .strokeBorder(.white.opacity(Depth.haloOpacity), lineWidth: diameter * Depth.haloWidth)
                .frame(width: diameter * (1 + 2 * Depth.haloWidth), height: diameter * (1 + 2 * Depth.haloWidth))
        }
        .allowsHitTesting(false)
    }

    /// The light on the glass, top left.
    private var highlight: some View {
        Ellipse()
            .fill(RadialGradient(
                colors: [.white.opacity(Depth.highlightOpacity), .white.opacity(0)],
                center: UnitPoint(x: 0.4, y: 0.4),
                startRadius: 0,
                endRadius: diameter * Depth.highlightSize.width * 0.35
            ))
            .frame(width: diameter * Depth.highlightSize.width, height: diameter * Depth.highlightSize.height)
            .rotationEffect(.degrees(Depth.highlightAngle))
            .position(
                x: diameter * (Depth.highlightOrigin.x + Depth.highlightSize.width / 2),
                y: diameter * (Depth.highlightOrigin.y + Depth.highlightSize.height / 2)
            )
            .allowsHitTesting(false)
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

    // The backdrop is `RootTabView`'s in the app; alone on the canvas the screen stands on one.
    return HomeView().background { AuroraBackground() }.environment(manager)
}
