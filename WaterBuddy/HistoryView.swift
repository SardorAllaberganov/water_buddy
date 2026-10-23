//
//  HistoryView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftData
import SwiftUI

/// One serving on the strip of the day.
///
/// A value at file scope, and `nonisolated`, so `HistoryLayoutTests` can read it off the main
/// actor (rule `43-concurrency`). Both figures are drawing fractions — the one place a `Double`
/// may stand for anything in this product.
nonisolated struct StripBar: Equatable, Sendable, Identifiable {

    /// The serving's own id, so a bar keeps its identity when a neighbour is added or removed.
    let id: UUID

    /// Where it stands across the day: `0` at the midnight that opens it, `1` at the one that
    /// closes it.
    let position: Double

    /// How tall it stands, as a fraction of the plot.
    let height: Double
}

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
    /// accepts — the same split ``WelcomeView/goalRange`` draws, for the same reason.
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
    /// `vessels` are the sheet's three shortcuts. A tap on one sets the amount to that vessel's,
    /// and a slider that could not show it would be handed a value outside its own range — so the
    /// bounds contain them too. They are the user's to edit and normally sit inside
    /// ``servingRange``; a hand-edited suite can put one outside it.
    ///
    /// `max(1, …)` keeps the range well-formed even for a value the store should never hold, so a
    /// corrupt row opens an editor rather than trapping on an invalid `ClosedRange`.
    static func sliderBounds(forAmount amount: Int, vessels: [Int] = []) -> ClosedRange<Int> {
        let offered = ([amount] + vessels).map { max(1, $0) }
        let least = offered.min() ?? servingRange.lowerBound
        let most = offered.max() ?? servingRange.upperBound
        return min(servingRange.lowerBound, least)...max(servingRange.upperBound, most)
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

    /// The hours the strip labels: the morning, noon and the evening. Its two ends are midnight
    /// and need no label.
    nonisolated static let stripHours = [6, 12, 18]

    /// The shortest a bar is drawn, as a fraction of the plot. A sip still has to be seen.
    nonisolated static let stripFloor = 0.12

    /// The strip's bars: one per serving, left to right through the day, each as tall as its
    /// amount is of the largest thing on the scale.
    ///
    /// **The scale is the larger of the day's largest serving and the largest current vessel.**
    /// Against the day's own largest alone, a day of nothing but Cups would draw every bar at full
    /// height and read as a day of large drinks. The seeded log — one row carrying a whole day's
    /// total (rule `25-shared-storage`) — is larger than any vessel, and sets the scale itself.
    ///
    /// Takes each serving's position rather than its instant, and the vessels rather than the
    /// model that holds them, which is what keeps it pure and `nonisolated`: where an instant
    /// falls in a day is the model's answer, on the model's calendar (rule `30-rollover`).
    nonisolated static func stripBars(
        for servings: [(id: UUID, amount: Int, position: Double)],
        vessels: [Int]
    ) -> [StripBar] {
        let scale = max(1, servings.map(\.amount).max() ?? 0, vessels.max() ?? 0)

        return servings
            .sorted { $0.position < $1.position }
            .map { serving in
                StripBar(
                    id: serving.id,
                    position: min(max(serving.position, 0), 1),
                    height: min(max(Double(max(serving.amount, 0)) / Double(scale), stripFloor), 1)
                )
            }
    }

    /// The vessel a serving of `amount` is drawn as: one of the current three whose amount it
    /// equals, or `nil`.
    ///
    /// **An inference, and drawn as one.** A log stores an amount and nothing else, so the name is
    /// a guess from today's vessels: it is shown, never spoken, and it changes when the vessels
    /// do. The Glass is checked first — it is what the widget, Siri, the Control Center control
    /// and the watch all log, so when two vessels hold one amount it is the likelier source.
    nonisolated static func vessel(forAmount amount: Int, amounts: [Int]) -> HomeView.Serving? {
        let row = HomeView.servings(amounts: amounts)
        return row.first { $0.isUsual && $0.amount == amount } ?? row.first { $0.amount == amount }
    }

    /// The screen's side margin — the one every tab shares (``ScreenMetrics``). The week card's
    /// seven day buttons are budgeted inside it and the row's own inset
    /// (``dayRowInset(across:count:)``): exactly 44 pt each on the narrowest supported iPhone
    /// (`sevenDaysClearTheTapFloorOnTheNarrowestPhone`).
    nonisolated static let margin = ScreenMetrics.margin

    /// Where the shown day's marker stands in a row `width` wide that `count` days share
    /// evenly: at the leading edge of the slot of the day at `index`.
    nonisolated static func markerOffset(ofDay index: Int, among count: Int, across width: CGFloat) -> CGFloat {
        CGFloat(index) * width / CGFloat(max(count, 1))
    }

    /// The tap floor a day on the week card may never fall under (rule `65-accessibility`).
    nonisolated static let dayTapFloor: CGFloat = 44

    /// How far the week card's row of days stands in from the card: 16 pt — which, with each bar's
    /// own 4, puts the outer tracks 20 pt from the card's edge, where the canvas's padding puts
    /// them — or as much of it as the width affords. The inset gives way, never the days.
    ///
    /// On a 375-pt iPhone the card is 327 pt wide; the canvas's full 16 left each day 42.1 pt, under
    /// the floor (stage 3c's final review), so there the row stands 9.5 pt in and each day is
    /// exactly 44. From a 390-pt phone up the full 16 fits.
    nonisolated static func dayRowInset(across width: CGFloat, count: Int) -> CGFloat {
        let spare = (width - CGFloat(max(count, 1)) * dayTapFloor) / 2
        return min(16, max(0, spare))
    }

    /// One day's slot on the week card: the card's width, less ``dayRowInset(across:count:)`` on
    /// each side, shared evenly.
    nonisolated static func daySlot(across width: CGFloat, count: Int) -> CGFloat {
        (width - 2 * dayRowInset(across: width, count: count)) / CGFloat(max(count, 1))
    }

    /// Whether History draws its *Week · Month* switch (spec `2026-10-22-month-view-design.md` §3.1):
    /// never while the first StoreKit read is outstanding, so a holder never sees a locked month flash;
    /// always for a holder, who keeps the month even where the paywall is not offered; for a free user
    /// only where it is, so the locked month always has a paywall to open.
    nonisolated static func offersMonth(status: PremiumAccess.Status?, offered: Bool) -> Bool {
        guard let status else { return false }
        return status.isPremium || offered
    }

    /// The month's days laid into weeks of seven, `nil` where a week runs past either end: the 1st
    /// under its own weekday, counted from the locale's first (§3.3). The entries index
    /// ``MonthHistory/days``. `weekdayOfFirst` comes from the model's calendar, `firstWeekday` from the
    /// app's locale (``firstWeekday(in:)``) — a view holds no calendar of its own (rule `30-rollover`).
    nonisolated static func monthGrid(dayCount: Int, weekdayOfFirst: Int, firstWeekday: Int) -> [[Int?]] {
        guard dayCount > 0 else { return [] }
        let leading = ((weekdayOfFirst - firstWeekday) % 7 + 7) % 7
        var cells: [Int?] = Array(repeating: nil, count: leading) + (0..<dayCount).map { Optional($0) }
        cells += Array(repeating: nil, count: (7 - cells.count % 7) % 7)
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<($0 + 7)]) }
    }

    /// The locale's first weekday, `1` for Sunday: Sunday under US English, Monday under Russian and
    /// Uzbek, and the user's own *First Day of Week* under *Follow device*, which `firstDayOfWeek`
    /// honours. Never `Calendar.waterBuddyDay`'s, which is fixed to `en_US_POSIX` (§3.3).
    nonisolated static func firstWeekday(in locale: Locale) -> Int {
        let week: [Locale.Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return (week.firstIndex(of: locale.firstDayOfWeek) ?? 0) + 1
    }

    /// The grid's weekday letters in the locale's own script, from its first weekday.
    nonisolated static func weekdayLetters(in locale: Locale) -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        let letters = calendar.veryShortStandaloneWeekdaySymbols
        let first = firstWeekday(in: locale)
        return (0..<7).map { letters[(first - 1 + $0) % 7] }
    }

    /// Millilitres as litres to one decimal, through `Decimal` — never a `Double`, which may only be a
    /// drawing fraction (rule `20-state`) — in the app's locale: *62.6*, *62,6* (§3.5).
    nonisolated static func litres(_ millilitres: Int, locale: Locale) -> String {
        (Decimal(millilitres) / 1_000).formatted(.number.precision(.fractionLength(1)).locale(locale))
    }

    /// The locale's weekend as weekday numbers, `1` for Sunday — what the month's patterns split the
    /// week at (spec `2026-10-23-patterns-design.md` §3.4).
    ///
    /// Asked of a Gregorian calendar under the locale, as ``weekdayLetters(in:)`` is, never of
    /// `Calendar.waterBuddyDay`, which is fixed to `en_US_POSIX` and would call every weekend Saturday
    /// and Sunday — Friday and Saturday in Saudi Arabia under *Follow device*, Sunday alone in India.
    /// One known week is walked: 4 January 2026 is a Sunday.
    nonisolated static func weekend(in locale: Locale) -> Set<Int> {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        guard let sunday = calendar.date(from: DateComponents(year: 2026, month: 1, day: 4, hour: 12)) else { return [1, 7] }
        return Set((0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: sunday), calendar.isDateInWeekend(day) else { return nil }
            return calendar.component(.weekday, from: day)
        })
    }

    /// Where the bar of `hour` stands across the patterns' chart: `0` for midnight's, `1` for 23:00's —
    /// the strip's model of a plot, a bar's leading edge at its fraction of the travel, and the axis's
    /// labels centred under the bars of the hours they name.
    nonisolated static func hourPosition(_ hour: Int) -> Double {
        Double(min(max(hour, 0), 23)) / 23
    }

    /// Each hour's bar as a fraction of the plot (spec §3.3): its water against the busiest hour's, a
    /// sip held at ``stripFloor`` so it is still seen, an hour with no water at nothing.
    nonisolated static func hourBars(_ hourly: [Int]) -> [Double] {
        let busiest = hourly.max() ?? 0
        guard busiest > 0 else { return hourly.map { _ in 0 } }
        return hourly.map { water in
            water > 0 ? min(max(Double(water) / Double(busiest), stripFloor), 1) : 0
        }
    }

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(PremiumStore.self) private var premium

    /// The day the week card picked, as an ordinal — `nil` for today. Presentation state, which is
    /// the only kind a view owns (rule `50-views`); leaving the tab resets it to today, when the
    /// screen disappears.
    @State private var selectedDay: Int?

    /// What the serving sheet is open for. Presentation state too — the servings themselves live on
    /// the model.
    @State private var editor: ServingEditor?

    /// Whether this screen has arrived — set a few frames after it is built (``Arrival``).
    @State private var arrived = false

    /// Bumped when a day is picked, and when a serving is swiped away: each haptic fires on the
    /// user's own action, never on a change to the model (rule `60-design-system`).
    @State private var picks = 0
    @State private var removals = 0

    /// Week or Month — presentation state, Week whenever the page is built (spec
    /// `2026-10-22-month-view-design.md` §3.2). Which month is shown is the model's
    /// (``DataManager/showMonth(_:)``): History holds no month of its own and does no month arithmetic
    /// (rule `30-rollover`).
    @State private var mode = HistoryMode.week

    /// The month's opened day, as an ordinal — `nil` for none (§3.4).
    @State private var openedDay: Int?

    /// The paywall, while the locked month has it open — its `.sheet(item:)` selection (rule `50-views`).
    @State private var paywall: PaywallView.Entry?

    /// Bumped by the user's own taps on the switch and on a month's arrows, as ``picks`` is by a day
    /// (rule `60-design-system`).
    @State private var switches = 0
    @State private var steps = 0

    /// The `+`'s diameter, a real magnitude scaled with the header's own text (rule
    /// `65-accessibility`), bounded at its use site.
    @ScaledMetric(relativeTo: .title2) private var addButtonSize: CGFloat = 44

    var body: some View {
        // No backdrop of its own: the three tabs share the one `RootTabView` stands, which holds
        // still while the pages slide over it.
        //
        // One list, and everything on the screen is a row of it. The header and the week card
        // stood fixed above a list of servings until a second card arrived: with both fixed, a
        // small phone had no room left for the rows the cards describe.
        List {
            header
                // Every tab's inset, less the point this list itself stands off the safe area.
                .historyRow(top: ScreenMetrics.topInset - 1, bottom: 10)

            // Under the header, in both modes, so it never moves under the finger (spec §3.2).
            if drawsSwitch {
                ModeSwitch(mode: mode, locked: !holdsPremium) { choose($0) }
                    .arrives(arrived, order: 0)
                    .historyRow(top: 0, bottom: 8)
            }

            if showsMonth {
                monthRows
            } else {
                weekRows
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        // Scoped to the value that actually changed — never a bare `withAnimation` around a model
        // mutation. Identity, not amount: an edit redraws its own row and must not slide the list.
        .animation(.smooth(duration: 0.35), value: shownLogs.map(\.id))
        // The opened day comes and goes, and Month's rows with the mode (spec §3.8).
        .animation(.smooth(duration: 0.35), value: openedDay)
        .animation(.smooth(duration: 0.35), value: showsMonth)
        // One point clear of the status bar, and it is not spacing. A scroll view whose top edge
        // meets the safe area's draws its content on up under the status bar; with nothing fixed
        // above the list any more, the rows ran under the clock and the battery — *15:26*
        // printed across *250 ml*. A list that stops short of that edge is clipped at its own,
        // as it always was under the header that used to stand here.
        .padding(.top, 1)
        // Its rows recede as they scroll past its top and the foot of the screen
        // (``ScrollDepth``).
        .scrollDepthContainer()
        // No `.preferredColorScheme` and no `.presentationDragIndicator` here any more: this is a
        // tab, not a sheet. There is nothing to drag down, and the dark-appearance preference is
        // declared once on `RootTabView`, which owns the hosting controller both tabs share.
        // Another process may have logged while this one was away, and the day may have turned.
        // `refresh()` re-derives the rows as well as the total, so both arrive together.
        .onAppear {
            // A page is built in Week mode: a month a previous visit left the model reading is let go
            // before the refresh would read it again (plan M13).
            if !showsMonth { manager.showMonth(nil) }
            manager.refresh()
        }
        // The pager keeps a page it has left for the length of its slide, and gives the same page
        // back, state and all, to a tab tapped again inside it (`RootTabView.page(_:)`). So History
        // lets go of a month when the page is removed, not at the turn: at the turn it emptied the
        // month on the page sliding away, and a quick return found Month on an empty card (the final
        // review's I1 and I2; the owner's ruling of 2026-10-23, amending spec §3.8 and plan M13).
        .onDisappear { manager.showMonth(nil) }
        // Premium bought, or refunded, with Month on screen: the month is read, or let go.
        .onChange(of: holdsPremium) { _, holds in
            guard mode == .month else { return }
            openedDay = nil
            manager.showMonth(holds ? manager.thisMonth : nil)
        }
        // Leaving the tab returns the screen to today, and nothing here has to say so: a page
        // is rebuilt each time it is shown (`testHistoryReturnsToTodayWhenItsTabIsLeft`). A
        // sheet over this screen does not rebuild it, so the day a serving was just saved to
        // stays shown.
        .tracksArrival($arrived)
        // A tick for a day picked, a light tap for a serving taken away.
        .sensoryFeedback(Haptics.select, trigger: picks)
        .sensoryFeedback(Haptics.remove, trigger: removals)
        .sensoryFeedback(Haptics.select, trigger: switches)
        .sensoryFeedback(Haptics.select, trigger: steps)
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
        .sheet(item: $paywall) { entry in PaywallView(entry: entry) }
    }

    /// Week mode — History as it was before the month: the week card, then the shown day's strip and
    /// servings, or its empty state (spec §3.2).
    @ViewBuilder
    private var weekRows: some View {
        // Drawn only once there is a past to show. A fresh install would otherwise open on
        // seven empty bars, which reads as a broken chart rather than as a new account — and
        // this is the one screen guaranteed to render its empty state for every new user.
        // Note the condition is `history`, not `todaysLogs`: the morning after a rollover,
        // today is empty and the week is exactly what the user wants to see.
        if hasSomethingToShow {
            HistoryCard(
                shown: shownPastDay?.dayOrdinal ?? manager.history.last?.dayOrdinal,
                arrived: arrived
            ) { ordinal in
                let picked = Self.selection(forDay: ordinal, in: manager.history)
                // A tick for a choice, and none for a tap on the day already shown.
                if picked != selectedDay { picks += 1 }
                selectedDay = picked
            }
            // Were History the page the app opens on, everything under the header would
            // settle in; a page that slides in is whole as it comes (``Arrival``).
            .arrives(arrived, order: 0)
            .historyRow()
        }

        if shownLogs.isEmpty {
            emptyState
                .arrives(arrived, order: 1)
                .historyRow(top: 22)
        } else {
            // Today's strip also marks the next reminder; a past day has none to mark.
            DayStrip(
                logs: shownLogs,
                day: shownPastDay?.dayOrdinal ?? manager.history.last?.dayOrdinal,
                marksReminder: shownPastDay == nil,
                arrived: arrived
            )
                .arrives(arrived, order: 1)
                .historyRow()

            servings
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
        // Month mode's header is today's (spec §3.2); the week's selection waits for Week.
        guard !showsMonth,
              let day = Self.shownDay(selected: hasSomethingToShow ? selectedDay : nil, in: manager.history),
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

    /// Whether the switch is drawn (``offersMonth(status:offered:)``).
    private var drawsSwitch: Bool {
        Self.offersMonth(status: premium.state.status, offered: PaywallView.isOfferedHere)
    }

    /// Whether the user holds Premium — `false` while the first read is outstanding.
    private var holdsPremium: Bool {
        premium.state.status?.isPremium == true
    }

    /// Whether Month mode is on screen. With no switch drawn History is the week, whatever ``mode`` holds.
    private var showsMonth: Bool {
        drawsSwitch && mode == .month
    }

    /// The month's opened day, while the shown month holds it and it can be opened.
    private var openedMonthDay: MonthHistory.Day? {
        manager.month?.days.first { $0.summary.dayOrdinal == openedDay && $0.canOpen }
    }

    /// Month mode: for a holder the month, the day opened in it, the month's figures and its patterns;
    /// for a free user the locked month (spec §3.2).
    @ViewBuilder
    private var monthRows: some View {
        if holdsPremium {
            MonthCard(month: manager.month, opened: openedDay, open: { open($0) }, move: { move(to: $0) })
                .historyRow()

            if let day = openedMonthDay {
                OpenedDayHeading(day: day)
                    .historyRow(top: 14, bottom: 2)

                // A day with nothing logged draws its heading alone (plan M12).
                let logs = manager.monthLogs[day.summary.dayOrdinal] ?? []
                if !logs.isEmpty {
                    DayStrip(logs: logs, day: day.summary.dayOrdinal, marksReminder: false, arrived: arrived)
                        .historyRow()

                    // Read-only, for every day (spec §3.4): no sheet, no swipe.
                    ForEach(logs, id: \.id) { log in
                        ServingRow(log: log, vessel: Self.vessel(forAmount: log.amount, amounts: manager.servings), edit: nil)
                            .historyRow(top: 5, bottom: 5, sides: Self.margin)
                    }
                }
            }

            if let month = manager.month, month.daysCounted > 0 {
                MonthFigures(month: month)
                    .historyRow(top: 8)
            }

            // The month's patterns, or the line that says what they wait for; a month never read
            // draws neither (spec `2026-10-23-patterns-design.md` §3.2).
            if let month = manager.month {
                PatternsHeading()
                    .historyRow(top: 14, bottom: 2)

                if let patterns = month.patterns {
                    HoursChart(patterns: patterns)
                        .historyRow()
                    // The week split at the app's locale's weekend, as the grid starts on its first
                    // day (spec §3.4).
                    WeekSplit(split: patterns.split(weekend: Self.weekend(in: locale)))
                        .historyRow()
                    UsualTimes(patterns: patterns)
                        .historyRow(bottom: 24)
                } else {
                    PatternsPending()
                        .historyRow(bottom: 24)
                }
            }
        } else {
            LockedMonth { paywall = .history } back: { choose(.week) }
                .historyRow(bottom: 24)
        }
    }

    /// The switch: Week, or Month — this month on the model's own clock, for a holder alone; a free
    /// user's Month asks for nothing (spec §3.6).
    private func choose(_ chosen: HistoryMode) {
        guard chosen != mode else { return }
        switches += 1
        mode = chosen
        openedDay = nil
        manager.showMonth(chosen == .month && holdsPremium ? manager.thisMonth : nil)
    }

    /// An arrow: the month it names, which the shown month says exists.
    private func move(to month: Int?) {
        guard let month else { return }
        steps += 1
        openedDay = nil
        manager.showMonth(month)
    }

    /// A day on the month: opened, or closed when it is the one open (spec §3.4).
    private func open(_ ordinal: Int) {
        picks += 1
        openedDay = openedDay == ordinal ? nil : ordinal
    }

    // MARK: - Header

    /// The shown day, its total against the goal, and the `+`.
    ///
    /// **One heading, not two stops** — and the title itself is that heading, with the total as
    /// its value and the drawn figure hidden, as Home's is. A wrapper built with
    /// `.accessibilityElement(children: .ignore)` reads the same to VoiceOver and leaves the title
    /// inside it as a second element for anything that walks the tree.
    ///
    /// The first row of the list, so it scrolls away with it: nothing on this screen is fixed.
    ///
    /// **The `+` shares the title's line, and the total has the row's whole width** — every
    /// tab's header (``ScreenHeader``). With the `+` beside both lines, the total was left a
    /// column too narrow for it at the largest text size and was cut short: *7 150 из 2 000…*, on
    /// the line that says how much.
    private var header: some View {
        ScreenHeader {
            dayTitle
        } detail: {
            // Both figures come off the model. The list adds up to this number, and a `body`
            // that computed it for itself is how the two start disagreeing
            // (rule `10-architecture`). Grouped by the app's locale, like Home's.
            Text(strings.figure("%1$@ of %2$@ ml", shownTotal, manager.dailyGoal, locale: locale))
                .fontDesign(.rounded)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(shownTotal)))
                .accessibilityHidden(true)
        } accessory: {
            // No settings gear here any more. It lived in this header while Settings was a
            // sheet, and it became the bar's third tab: one screen of preferences reached
            // through *another* screen's header is a route a user finds once and then hunts
            // for. Two routes to one destination is what the tab bar replaced, not something
            // it joins — `testSettingsIsReachableFromHomeAsATab` asserts exactly one control
            // is labelled Settings. The `+` that sits here now is the *only* route to the
            // serving sheet.
            addButton
        }
        .padding(.horizontal, Self.margin)
        .animation(.smooth(duration: 0.5), value: shownTotal)
    }

    /// The shown day's name. Whichever form is drawn, one text of it is the screen's heading
    /// (``heading(_:)``).
    ///
    /// **At an accessibility text size a past day takes two lines: the weekday, then the date.**
    /// On one line beside the `+` it was cut at those sizes — *Saturday, 10 O…*, and in Russian
    /// *Понедельник…* with the date gone altogether — on the line that says which day is shown.
    /// Two texts, one to a line, and not one text given two lines: a text that may wrap breaks a
    /// word that does not fit before it shrinks it (rule `65-accessibility`). At the ordinary
    /// sizes the one line stays, so the cards under the header do not move as the days are
    /// tapped.
    @ViewBuilder
    private var dayTitle: some View {
        if let day = shownPastDay {
            // Formatted through the environment locale, which the app injects from the in-app
            // language picker alongside `\.strings` — never `Locale.current` (rule `70-privacy`).
            // Formatting a label is the one use `DaySummary.date` exists for.
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 0) {
                        heading(Text(day.date, format: .dateTime.weekday(.wide)))

                        // Drawn, and spoken by the line above it, whose label is the whole day.
                        Text(day.date, format: .dateTime.day().month(.abbreviated))
                            .accessibilityHidden(true)
                    }
                } else {
                    heading(Text(day.date, format: .dateTime.weekday(.wide).day().month(.abbreviated)))
                }
            }
            // Further than its neighbours may shrink: a day's name is the longest word this
            // header draws. Measured, 0.6 was nearly spent twice — *Понедельник* alone was
            // drawn at 0.67 of its size at the largest text size on a 402 pt phone, and
            // *Понедельник, 5 окт.* on one line at 0.615 at the largest ordinary size on a
            // 375 pt one — and a narrower phone, or a date of two digits, asks for more.
            .minimumScaleFactor(0.5)
        } else {
            heading(Text("Today", bundle: strings))
        }
    }

    /// Makes `title` the screen's one heading: the shown day spelled out, its total against the
    /// goal as the value, the header trait.
    private func heading(_ title: Text) -> some View {
        title
            .accessibilityLabel(spokenDay)
            .accessibilityValue(strings.localized("%1$d of %2$d millilitres", shownTotal, manager.dailyGoal, locale: locale))
            .accessibilityAddTraits(.isHeader)
    }

    /// The header's spoken name — the month spelled out, which reads better aloud than the
    /// abbreviation drawn above it.
    private var spokenDay: Text {
        guard let day = shownPastDay else { return Text("Today", bundle: strings) }
        return Text(day.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale)))
    }

    /// Adds a serving to the day on screen.
    ///
    /// At the right of the header rather than under the servings, which is where it was first
    /// sketched: at the foot of the list it would be a whole day's servings away from where the
    /// screen opens, and this is the one route to the sheet (rule `50-views`). The header is the
    /// list's first row now, so the `+` scrolls away with it and comes back at the top. The
    /// vessels' own recipe — a `.frosted`, `.raised`, pressable circle — because it belongs to
    /// the same family of controls: the ways water enters.
    private var addButton: some View {
        let diameter = min(max(addButtonSize, 44), 56)

        return Button {
            editor = .adding(at: manager.suggestedTime(onDay: shownPastDay?.dayOrdinal))
        } label: {
            Image(systemName: "plus")
                // A ratio of the circle it sits in, never its own text style, so it cannot grow
                // through the edge (rule `65-accessibility`). On the circle's glass, measured off
                // renders at the worst frame of a minute of the aurora: 15.62:1 on iOS 26.5,
                // 12.08:1 on iOS 27.0 and 6.55:1 on the hand-made pane, read on iOS 18.6.
                .font(.system(size: diameter * 0.4, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: diameter, height: diameter)
                .liquidGlass(in: Circle(), density: .frosted, elevation: .raised, interactive: true)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(Text("Add a serving", bundle: strings))
    }

    // MARK: - The servings

    /// The shown day's servings, newest first — rows of the screen's one list.
    private var servings: some View {
        ForEach(shownLogs, id: \.id) { log in
            ServingRow(
                log: log,
                // The amounts are read here, in a `body`, which is what registers the observation
                // that renames a row after the vessels are edited.
                vessel: Self.vessel(forAmount: log.amount, amounts: manager.servings)
            ) { editor = .editing(log) }
            .arrives(arrived, order: 2)
            // The pane is the row.
            .historyRow(top: 5, bottom: 5, sides: Self.margin)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                // The model deletes the row *and* recomputes the total; the doorbell is
                // rung by the setter, not from here (rule `20-state`).
                Button(role: .destructive) {
                    manager.deleteLog(log)
                    removals += 1
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
                // into today. Read off one render of each system before stage 3c, not a sweep of
                // the aurora: on Apple's glass the title was 13.3:1 and this line 7.4:1 on iOS
                // 26.5, 12.4:1 and 6.8:1 on iOS 27.0; on the hand-made pane, iOS 18.6, 5.4:1 and
                // **3.8:1, under the 4.5:1 floor** (#85). **Not re-measured on stage 3c's panes.**
                // Today's empty state, the same card and the same white 0.7, read 5.25 (iOS 27.0),
                // 6.86 (26.5) and 5.43 (18.6) at rest on them (`docs/DESIGN.md`, *The look,
                // measured*).
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
        .padding(.horizontal, Self.margin)
        .accessibilityElement(children: .combine)
    }
}

private extension View {

    /// One row of History's list, with the list's own surfaces cleared: a `List`'s background
    /// and separators would draw a second surface behind glass that is already lit
    /// (rule `60-design-system`).
    ///
    /// `sides` is zero for the header and the cards, which carry the screen's margin themselves —
    /// the week card's day row is budgeted against it — and the margin for a serving.
    ///
    /// Every row recedes as it scrolls past the top or the foot of the list (``ScrollDepth``),
    /// the header included: it is a row like the rest and leaves like them.
    func historyRow(top: CGFloat = 8, bottom: CGFloat = 8, sides: CGFloat = 0) -> some View {
        scrollDepth()
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: top, leading: sides, bottom: bottom, trailing: sides))
    }
}

// MARK: - The week

/// The last ``DataManager/historyWindow`` days as bars, with the average, the best day and the
/// days the goal was met — and the control that picks which day the rows below show.
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
/// **A day that reached the goal is cyan and one that did not is white — and never by colour
/// alone.** Rule `65-accessibility` forbids a tint being the only carrier of state, and it is
/// not: a met bar also stands at or above the reference line, and the card counts the met days
/// in words. Every bar shared one fill until the redesign, on the argument that a second hue was
/// a second unmeasured contrast figure; both are measured now (`docs/DESIGN.md`).
///
/// **Each day is a button, and the day row takes no more inset than its days can spare.** The
/// canvas pads the card 20 pt, so its outer tracks stand 20 pt from the edge; here the row stands
/// 16 pt in and each bar 4 more. Seven slots must still clear the 44-pt floor
/// rule `65-accessibility` sets, and on the narrowest supported iPhone (a 327-pt card) the full 16
/// left them at 42.1 pt. So the inset is ``HistoryView/dayRowInset(across:count:)`` — 16 where it
/// fits, 9.5 on a 375-pt phone, where each day is exactly 44 — laid out by ``DayRow``. That is
/// the width ``DataManager/historyWindow``'s DocC budgeted, and why the title, the figures and the
/// disclosure keep their own 20-pt inset while the bars sit ``barInset`` in from their own slots.
///
/// **VoiceOver hears a summary and seven days**, no longer one element: the title carries the
/// average, the best and the days met as its value, each day is exactly one button marked selected
/// when it is the one shown, and the disclosure is read as itself. The bars, weekday letters and
/// figures are carried by those and draw nothing of their own into the tree.
private struct HistoryCard: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The day the list below is showing — outlined here, and announced as selected.
    let shown: Int?

    /// Whether the screen has arrived (``Arrival``).
    let arrived: Bool

    /// Hands the tapped day back to the screen, which owns the selection (rule `50-views`).
    let select: (Int) -> Void

    /// The bars stand at nothing until the screen has arrived, and grow from the baseline as it
    /// does. Under Reduce Motion they are simply there: growing is travel, and that setting is
    /// what turns travel off (rule `65-accessibility`).
    private var grown: Bool { arrived || reduceMotion }

    /// A real magnitude, never a unitless `1` that is then multiplied — `UIFontMetrics` rounds to
    /// the nearest third of a point, which would quantise twelve Dynamic Type categories into
    /// three (rule `65-accessibility`). Capped at the use site: this is a decorative dimension, and
    /// an uncapped one would push the serving list off the screen at the accessibility sizes.
    @ScaledMetric(relativeTo: .footnote) private var scaledBarHeight: CGFloat = 84

    private var barHeight: CGFloat { min(scaledBarHeight, 118) }

    /// How far each bar sits in from the sides of its day's slot: 8 pt between neighbouring tracks,
    /// the canvas's gap.
    private let barInset: CGFloat = 4

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
                // 0.88, the canvas's own value (stage 3c). It was 0.70, and 0.55 before that: on the
                // hand-made pane white 0.55 read 4.06:1. **Measured, not derived** — the pane is a
                // material over a moving aurora, so its composite cannot be computed from a token.
                // Measured on stage 3c's panes in `docs/DESIGN.md`, *The look, measured*.
                .foregroundStyle(.white.opacity(0.88))
                // No line limit, and `fixedSize` so it claims the height it needs: a `Text` gives
                // up lines before it pushes back. The card was once squeezed between a fixed
                // header and the list of servings, and with `.lineLimit(2)` this read "Measured
                // against your cur…" at `AccessibilityXXXL`; a disclosure that is itself
                // truncated discloses nothing. The card is a row of that list now and takes the
                // height it asks for, and this stays as the statement of what it must never lose.
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
        // The same density/elevation pair as this screen's strip and its empty state — sibling
        // panes on one screen share one (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
    }

    private var title: some View {
        Text(strings.localized("Last %1$d days", DataManager.historyWindow, locale: locale))
            .font(.callout.weight(.semibold))
            // Two lines before a word is cut. On one, at the largest text size in Russian, the
            // title read *Последние 7 дн…* — and the card is a row of the list now, with the
            // height to give.
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
            // The card's summary, spoken once: the average, the best and the days the goal was met
            // ride on its title as a value, and the figures that draw them are hidden below.
            // Spoken grouped, as the figures are drawn (rule `50-views`).
            .accessibilityValue(strings.localized(
                "Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.",
                DaySummary.average(of: manager.history),
                DaySummary.best(of: manager.history),
                DaySummary.daysMet(in: manager.history, goal: manager.dailyGoal),
                manager.history.count,
                locale: locale
            ))
    }

    // MARK: Days

    private var days: some View {
        // The row's inset is decided from its own width, so it is a layout and not a padding.
        DayRow {
            ForEach(manager.history, id: \.dayOrdinal) { day in
                dayButton(for: day)
            }
        }
        // The row claims its own height, as the bars' fixed frame did before they became buttons.
        // While the card stood above the list and was squeezed at the large text sizes, a slot
        // whose frame could give way shrank under its content, and at `AccessibilityXXXL` the bars
        // rose through the title while the weekday letters sank into the figures.
        .fixedSize(horizontal: false, vertical: true)
        .backgroundPreferenceValue(LetterCentres.self) { centres in disc(over: centres) }
        .overlay(alignment: .top) { goalLine }
        .overlay { ring }
        // Once per change, not perpetual, so it is deliberately **not** gated on Reduce Motion —
        // that setting is aimed at sustained motion, and the resting frame here is the design
        // (rule `65-accessibility`).
        .animation(.smooth(duration: 0.45), value: manager.history)
        .animation(.smooth(duration: 0.3), value: shown)
        // Once, as the screen arrives, a moment after the card that carries them.
        .animation(.smooth(duration: 0.5).delay(Arrival.delay(order: 1)), value: grown)
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
                    .font(.system(size: barHeight * 0.14, weight: isShown ? .heavy : .semibold))
                    // Full white, as the canvas drew them; the shown day's in `Aurora.top` on its
                    // white disc (``disc(over:)``), heavier than the rest — never colour alone
                    // (rule `65-accessibility`). Measured on stage 3c's panes in `docs/DESIGN.md`,
                    // *The look, measured*; the shown pair is derived by
                    // `theShownDaysLetterReadsOnItsDisc`.
                    .foregroundStyle(isShown ? Aurora.top : Color.white)
                    .lineLimit(1)
                    .anchorPreference(key: LetterCentres.self, value: .center) { [day.dayOrdinal: $0] }
            }
            .padding(.vertical, slotPadding)
            // The whole slot is the target, never just the bar (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: 44)
            // The shown day's ring and disc are not drawn here: each is one mark for the whole row,
            // moved from day to day (``ring``, ``disc(over:)``).
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name(of: day))
        .accessibilityValue(strings.localized("%1$d millilitres", day.total, locale: locale))
        .accessibilityAddTraits(isShown ? [.isSelected] : [])
    }

    private func bar(for day: DaySummary) -> some View {
        let fraction = min(Double(day.total) / Double(scale), 1)

        let shape = RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous)

        return ZStack(alignment: .bottom) {
            // The canvas's track: the day's whole height, faint, so a short bar reads as a short
            // day and not as a short slot.
            shape
                .fill(.white.opacity(0.10))

            // Cyan for a day that reached the goal, white for one that did not — one fill whose
            // colour changes, so a day that crosses the goal animates a colour and not a layer
            // (rule `50-views`). **Colour is not the only carrier**: a met bar also stands at or
            // above the goal line (rule `65-accessibility`).
            //
            // Solid `Aurora.cyan`, **not** a `Aurora.blue` → `Aurora.cyan` gradient, and the
            // reason is a measurement rather than taste. Pure `Aurora.blue` composites to
            // **2.72:1** against this pane — under the 3:1 non-text floor — so the foot of every
            // bar failed, and a nearly-empty day is drawn almost entirely in that end. Sampling a
            // *rendered* bar gave a reassuring 3.33:1, but that is the average of the whole
            // gradient, not its endpoint: the figure was real and measured the wrong thing.
            //
            // Against the ground beside the bar — the gap between tracks and the track above it —
            // at the worst frame of a minute of the aurora, on stage 3c's panes: cyan reads 3.44:1
            // on iOS 27.0, 4.57:1 on iOS 26.5 and 3.38:1 on iOS 18.6, over the 3:1 floor; today's
            // white bar against its track 7.00:1 on iOS 27.0 (`docs/DESIGN.md`, *The look,
            // measured*). On iOS 18.6 cyan read 2.78:1 before stage 3c darkened the hand-made pane
            // (#85).
            shape
                .fill(day.reached(manager.dailyGoal) ? Aurora.cyan : Color.white)
                // A day with nothing logged still draws a sliver, so the bar reads as an empty day
                // rather than as a missing one. The series is zero-filled for the same reason.
                .frame(height: grown ? max(barHeight * fraction, day.total > 0 ? 6 : 2) : 0)
        }
    }

    /// The shown day's ring: one, round its track, moved to the day that is shown.
    ///
    /// The canvas's selection, with stage 3b's travel kept: it is always there — at zero opacity
    /// when no day in the window is shown — so what animates is a place and not a layer
    /// (rule `50-views`), and it lands (``Motion/land``). Drawn over the row, so it lies on the
    /// track rather than under it. A ring, a disc and a weight, never colour alone
    /// (rule `65-accessibility`).
    private var ring: some View {
        GeometryReader { proxy in
            let count = manager.history.count
            let index = manager.history.firstIndex { $0.dayOrdinal == shown }
            // The same inset and slots ``DayRow`` lays the days out in.
            let inset = HistoryView.dayRowInset(across: proxy.size.width, count: count)
            let slot = HistoryView.daySlot(across: proxy.size.width, count: count)

            RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous)
                .strokeBorder(
                    .white.opacity(index == nil ? 0 : LiquidGlass.Selection.ringOpacity),
                    lineWidth: LiquidGlass.Selection.ringWidth
                )
                .frame(width: max(slot - barInset * 2, 0), height: barHeight)
                .offset(
                    x: inset + HistoryView.markerOffset(ofDay: index ?? 0, among: count, across: proxy.size.width - 2 * inset) + barInset,
                    y: slotPadding
                )
                .animation(Motion.land, value: index)
        }
        .allowsHitTesting(false)
    }

    /// The white disc behind the shown day's letter, placed on the letter itself.
    ///
    /// Centred from the letter's own anchor rather than computed from the slot: a line of text has
    /// no height the layout states, and a disc a point off its letter reads as a mistake. Twice
    /// the letter's size, as the canvas's 26 pt disc is to its 13 pt letter, so the two scale
    /// together with the capped bar at every text size. Present at zero opacity when no day in
    /// the window is shown; travels with ``Motion/land``.
    private func disc(over centres: [Int: Anchor<CGPoint>]) -> some View {
        GeometryReader { proxy in
            let shownCentre = shown.flatMap { centres[$0] }
            let restingCentre = manager.history.first.flatMap { centres[$0.dayOrdinal] }
            let centre = (shownCentre ?? restingCentre).map { proxy[$0] } ?? .zero
            let size = barHeight * 0.28

            Circle()
                .fill(LiquidGlass.Selection.discFill.opacity(shownCentre == nil ? 0 : 1))
                .frame(width: size, height: size)
                .position(centre)
                .animation(Motion.land, value: shown)
        }
        .allowsHitTesting(false)
    }

    /// One line across all seven bars at the goal's height. Drawn over the buttons and outside the
    /// hit test, so a tap on the line still lands on the day beneath it.
    private var goalLine: some View {
        GeometryReader { proxy in
            GoalLine()
                // The canvas's dashed rule, 1.5 pt at white 0.62. A rule has a 3:1 floor: 3.67:1 at
                // its worst frame on iOS 27.0 at the tint, 3.71:1 on iOS 18.6's pane
                // (`docs/DESIGN.md`, *The look, measured*). The canvas says only "dashed"; 4.5 on 3
                // is ours.
                .stroke(.white.opacity(0.62), style: StrokeStyle(lineWidth: 1.5, dash: [4.5, 3]))
                .frame(height: 1.5)
                // From the first track's edge to the last's: the row's inset and the bars' own.
                .padding(.horizontal, HistoryView.dayRowInset(across: proxy.size.width, count: manager.history.count) + barInset)
                .offset(y: slotPadding + barHeight * (1 - min(Double(manager.dailyGoal) / Double(scale), 1)))
        }
        .allowsHitTesting(false)
    }

    /// What VoiceOver calls a day: "Today", or its weekday in full. Seven consecutive days hold
    /// seven different weekdays, so the name alone is unique in the window.
    private func name(of day: DaySummary) -> Text {
        guard day.dayOrdinal != manager.history.last?.dayOrdinal else { return Text("Today", bundle: strings) }
        return Text(day.date.formatted(.dateTime.weekday(.wide).locale(locale)))
    }

    /// *Average*, *Best day* and *Goal met*: three figures over their labels, side by side while
    /// they fit and one above the other when they do not.
    ///
    /// A figure and its label are two strings, and the layout is chosen with `ViewThatFits`
    /// rather than left to wrap. As one line — `"Average %1$d ml · Best %2$d ml"` — the old pair
    /// truncated outright at `AccessibilityXXXL`, the figures the card exists to show cut off, and
    /// once allowed to wrap it broke after the separator. Letting the columns become rows is the
    /// shape rule `65-accessibility` asks for when scaled content overflows.
    ///
    /// **Three layouts, and the first that fits at its own size is drawn**: three columns; then
    /// three rows, a label and its figure on a line; then each label over its figure. The chooser
    /// is offered the card's whole width and picks among whole layouts (`tasks/lessons.md`,
    /// 2026-10-11). With only the first two, the rows were what was left at `AccessibilityXXXL`,
    /// and a figure was shrunk as far as it would go and then cut — *2 592…* where the card means
    /// *2 592 ml*. Only the last layout may shrink, and it has a line to itself to do it on.
    ///
    /// Every figure is grouped by the app's locale, like Home's. Hidden from VoiceOver: the title
    /// already speaks all three as its value.
    private var figures: some View {
        let stats: [(figure: String, label: LocalizedStringKey)] = [
            (strings.figure("%1$@ ml", DaySummary.average(of: manager.history), locale: locale), "Average"),
            (strings.figure("%1$@ ml", DaySummary.best(of: manager.history), locale: locale), "Best day"),
            (
                strings.figure(
                    "%1$@ of %2$@",
                    DaySummary.daysMet(in: manager.history, goal: manager.dailyGoal),
                    manager.history.count,
                    locale: locale
                ),
                "Goal met"
            ),
        ]

        return ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(stats.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 2) {
                        figure(stats[index].figure)
                        label(stats[index].label)
                    }
                    .fixedSize()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(stats.indices, id: \.self) { index in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        label(stats[index].label)
                        Spacer(minLength: 8)
                        figure(stats[index].figure)
                    }
                }
            }
            // Enough to absorb a rounding shortfall of a fraction of a point, which would
            // otherwise drop a letter; never enough to be the way a line is made to fit.
            .minimumScaleFactor(0.95)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(stats.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 2) {
                        label(stats[index].label)
                        figure(stats[index].figure)
                    }
                }
            }
            .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
        .accessibilityHidden(true)
    }

    private func figure(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.bold))
            .fontDesign(.rounded)
            .monospacedDigit()
    }

    private func label(_ key: LocalizedStringKey) -> some View {
        Text(key, bundle: strings)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white.opacity(0.9))
    }
}

/// The week card's seven days: equal slots across the card, inside
/// ``HistoryView/dayRowInset(across:count:)``.
///
/// A layout rather than a padding because the inset is decided from the row's own width — the
/// full 16 pt where the card affords it, less where seven 44-pt days would not fit — and a
/// layout is handed that width without a measuring pass.
private struct DayRow: Layout {

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let slot = HistoryView.daySlot(across: width, count: subviews.count)
        let height = subviews.map { $0.sizeThatFits(ProposedViewSize(width: slot, height: nil)).height }.max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let inset = HistoryView.dayRowInset(across: bounds.width, count: subviews.count)
        let slot = HistoryView.daySlot(across: bounds.width, count: subviews.count)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + inset + CGFloat(index) * slot, y: bounds.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: slot, height: bounds.height)
            )
        }
    }
}

/// A horizontal rule through the middle of its frame, for the week card's dashed goal line.
private struct GoalLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

/// Where each day's letter stands in the week card, keyed by its day ordinal — so the shown day's
/// disc is centred on the letter it sits behind, wherever the layout put it.
private struct LetterCentres: PreferenceKey {

    static let defaultValue: [Int: Anchor<CGPoint>] = [:]

    static func reduce(value: inout [Int: Anchor<CGPoint>], nextValue: () -> [Int: Anchor<CGPoint>]) {
        value.merge(nextValue()) { _, later in later }
    }
}

// MARK: - The month

/// Week or Month — History's two modes (spec `2026-10-22-month-view-design.md` §3.2).
private enum HistoryMode {
    case week, month
}

/// History's own measures for the month.
private enum MonthStyle {
    /// The primary buttons' 56 (rule `65-accessibility`), as the paywall's and the Premium card's are.
    static let buttonHeight: CGFloat = 56

    /// The locked month's drawn month as the board draws it (*Step 2 — Month, free user*): a title bar
    /// and its weeks, at the top of a pane taller than the card centred on it, so the month shows round
    /// the card — at the month card's own spacing and height it hid behind it (the walk's W1).
    static let drawnTitleBar = CGSize(width: 150, height: 18)
    static let drawnWeekSpacing: CGFloat = 12
    static let lockedHeight: CGFloat = 392
}

/// *Week · Month*: two buttons on one frosted capsule, the shown one marked as a selected slot is —
/// `LiquidGlass.Selection`'s fill and rim, never solid white, which would read as the primary surface
/// the locked month's *See Premium* is (spec §3.8, rule `60-design-system`).
///
/// For a free user Month carries a lock, drawn and not spoken: its value says *Premium* (spec §3.9).
private struct ModeSwitch: View {

    @Environment(\.strings) private var strings

    let mode: HistoryMode
    let locked: Bool
    let choose: (HistoryMode) -> Void

    var body: some View {
        HStack(spacing: 4) {
            segment(.week, Text("Week", bundle: strings))
            segment(.month, Text("Month", bundle: strings))
        }
        .padding(3)
        // The screen's own pair: sibling panes on one screen share one (rule `60-design-system`).
        .liquidGlass(in: Capsule(), density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
    }

    private func segment(_ choice: HistoryMode, _ title: Text) -> some View {
        let isSelected = choice == mode
        let isLocked = choice == .month && locked

        return Button {
            choose(choice)
        } label: {
            HStack(spacing: 6) {
                title
                if isLocked {
                    Image(systemName: "lock.fill")
                        .imageScale(.small)
                        .accessibilityHidden(true)
                }
            }
            .font(.subheadline.weight(isSelected ? .bold : .semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            // The whole half is the target (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
            .background {
                Capsule()
                    .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
                    .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
                    .animation(Motion.land, value: isSelected)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityValue(isLocked ? Text("Premium", bundle: strings) : Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

/// The month as rings: ‹, its name, ›; the weekday letters; a ring a day; the legend and the
/// disclosure (spec §3.3).
///
/// **The days are laid out by ``DayRow``, a week to a row** — the week card's own slots, seven of which
/// clear the 44-pt floor on the narrowest supported iPhone (`everyDayClearsTheTapFloor(across:)`).
///
/// **Every mark is the model's answer** — counted, openable, met, today, the arc
/// (``MonthHistory/Day``): nothing is judged against the goal here (rule `50-views`). A met ring is
/// closed as well as cyan, never colour alone (rule `65-accessibility`).
///
/// **VoiceOver hears a summary and a button a day**: the month's name as a heading, the days on goal
/// its value; each day that can be opened one button, its date the label, its total against the goal
/// the value, selected when it is open. The quiet days, the letters and the legend are hidden.
private struct MonthCard: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// The month on screen, or `nil` before its first read has answered.
    let month: MonthHistory?

    /// The opened day's ordinal, marked and announced as selected.
    let opened: Int?

    let open: (Int) -> Void
    let move: (Int?) -> Void

    /// A ring's diameter: a real magnitude scaled with the text, capped at its use site inside the
    /// 44-pt slot with room for the opened day's ring round it (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .body) private var scaledRing: CGFloat = 34

    private var ring: CGFloat { min(scaledRing, 36) }

    /// The arc's width, a ratio of the ring.
    private var arc: CGFloat { ring * 0.1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let month {
                titleRow(month)
                    .padding(.horizontal, 8)
                letters
                weeks(month)
                legend
                    .padding(.horizontal, 20)
                Text("Measured against your current goal", bundle: strings)
                    .font(.caption2)
                    // The week card's value, measured on its pane (`docs/DESIGN.md`, *The look,
                    // measured*); measured on this one in the walk.
                    .foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
            } else {
                // Before the first read answers: the quiet form — no title, no arrow, no ring, no
                // figure (spec §3.3).
                DrawnMonth(pattern: false)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        // The week card's pair (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
        .animation(.smooth(duration: 0.3), value: month)
    }

    private func titleRow(_ month: MonthHistory) -> some View {
        HStack(spacing: 8) {
            arrow(to: month.earlier, systemName: "chevron.left")
            Spacer(minLength: 0)
            if let first = month.days.first {
                // Formatted in the app's language, never keyed (spec §3.11).
                Text(first.summary.date, format: .dateTime.month(.wide).year())
                    .font(.headline.weight(.bold))
                    // Two lines at the accessibility sizes, as a past day's heading is, rather than cut
                    // between the arrows: on one it drew *October 2…* (the walk's L1).
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityValue(strings.localized("%1$d of %2$d days on goal", month.daysMet, month.daysCounted, locale: locale))
            }
            Spacer(minLength: 0)
            arrow(to: month.later, systemName: "chevron.right")
        }
    }

    /// ‹ or ›: a chevron with a 44-pt target, labelled with the month it goes to (plan M8). At a bound
    /// it is drawn quieter, does nothing, and VoiceOver does not stop on it — there is no month to name.
    private func arrow(to neighbour: MonthHistory.Neighbour?, systemName: String) -> some View {
        Button {
            move(neighbour?.firstDay)
        } label: {
            Image(systemName: systemName)
                // A ratio of its target, never a text style of its own (rule `65-accessibility`).
                .font(.system(size: HistoryView.dayTapFloor * 0.4, weight: .semibold))
                .frame(width: HistoryView.dayTapFloor, height: HistoryView.dayTapFloor)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .disabled(neighbour == nil)
        .opacity(neighbour == nil ? 0.35 : 1)
        .accessibilityLabel(Text(neighbour?.start.formatted(.dateTime.month(.wide).year().locale(locale)) ?? ""))
        .accessibilityHidden(neighbour == nil)
    }

    /// The weekday letters, from the app's language's first weekday. Hidden: each day speaks its date.
    private var letters: some View {
        DayRow {
            ForEach(Array(HistoryView.weekdayLetters(in: locale).enumerated()), id: \.offset) { _, letter in
                Text(letter)
                    .font(.system(size: ring * 0.34, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityHidden(true)
    }

    private func weeks(_ month: MonthHistory) -> some View {
        let grid = HistoryView.monthGrid(
            dayCount: month.days.count,
            weekdayOfFirst: month.weekdayOfFirst,
            firstWeekday: HistoryView.firstWeekday(in: locale)
        )
        return VStack(spacing: 4) {
            ForEach(grid.indices, id: \.self) { week in
                DayRow {
                    ForEach(0..<7, id: \.self) { weekday in
                        cell(grid[week][weekday].map { month.days[$0] })
                    }
                }
                // As the week card's row: its slots claim their height (`tasks/lessons.md`).
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func cell(_ day: MonthHistory.Day?) -> some View {
        if let day, day.canOpen {
            dayButton(day)
        } else if let day {
            quietDay(day)
        } else {
            Color.clear
                .frame(height: HistoryView.dayTapFloor)
                .accessibilityHidden(true)
        }
    }

    private func dayButton(_ day: MonthHistory.Day) -> some View {
        let ordinal = day.summary.dayOrdinal
        let isOpened = ordinal == opened

        return Button {
            open(ordinal)
        } label: {
            ZStack {
                // The track, then the day's arc over it from twelve o'clock, both inside the ring.
                Circle()
                    .inset(by: arc / 2)
                    .stroke(.white.opacity(0.14), lineWidth: arc)
                Circle()
                    .inset(by: arc / 2)
                    .trim(from: 0, to: day.fraction)
                    .stroke(day.isMet ? Aurora.cyan : Color.white, style: StrokeStyle(lineWidth: arc, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                // The opened day's ring and disc, at zero opacity on every other day, so what animates
                // is a mark and not a layer (rule `60-design-system`, plan M7).
                Circle()
                    .strokeBorder(.white.opacity(isOpened ? LiquidGlass.Selection.ringOpacity : 0), lineWidth: LiquidGlass.Selection.ringWidth)
                    .padding(-3)
                Circle()
                    .fill(LiquidGlass.Selection.discFill.opacity(isOpened ? 1 : 0))
                    .padding(arc + 2)
                Text(day.summary.date, format: .dateTime.day())
                    // A ratio of the ring, never a text style of its own (rule `65-accessibility`).
                    .font(.system(size: ring * 0.38, weight: isOpened || day.isToday ? .heavy : .semibold, design: .rounded))
                    .monospacedDigit()
                    // `Aurora.top` on the white disc, as the week card's shown letter is
                    // (`theShownDaysLetterReadsOnItsDisc`).
                    .foregroundStyle(isOpened ? Aurora.top : Color.white)
            }
            .frame(width: ring, height: ring)
            .animation(Motion.land, value: isOpened)
            .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name(of: day))
        .accessibilityValue(strings.localized("%1$d of %2$d millilitres", day.summary.total, manager.dailyGoal, locale: locale))
        .accessibilityAddTraits(isOpened ? [.isSelected] : [])
    }

    /// A day that cannot be opened — still to come, or before the first serving: a faint disc and its
    /// number, not a button (spec §3.3). Its white is the empty state's 0.7 until the walk measures it
    /// on this pane (plan M9).
    private func quietDay(_ day: MonthHistory.Day) -> some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.06))
            Text(day.summary.date, format: .dateTime.day())
                .font(.system(size: ring * 0.38, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(width: ring, height: ring)
        .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
        .accessibilityHidden(true)
    }

    /// *Goal met* and *Part of it*, each beside its mark — side by side while they fit, one above the
    /// other where they do not. Hidden: every day speaks its own figures.
    private var legend: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 18) {
                legendItem(Text("Goal met", bundle: strings), colour: Aurora.cyan, fraction: 1)
                legendItem(Text("Part of it", bundle: strings), colour: .white, fraction: 0.6)
            }
            .fixedSize()
            VStack(alignment: .leading, spacing: 6) {
                legendItem(Text("Goal met", bundle: strings), colour: Aurora.cyan, fraction: 1)
                legendItem(Text("Part of it", bundle: strings), colour: .white, fraction: 0.6)
            }
        }
        .font(.caption)
        .foregroundStyle(.white.opacity(0.9))
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private func legendItem(_ title: Text, colour: Color, fraction: Double) -> some View {
        let mark = ring * 0.34

        return HStack(spacing: 6) {
            ZStack {
                Circle()
                    .inset(by: mark * 0.125)
                    .stroke(.white.opacity(0.14), lineWidth: mark * 0.25)
                Circle()
                    .inset(by: mark * 0.125)
                    .trim(from: 0, to: fraction)
                    .stroke(colour, style: StrokeStyle(lineWidth: mark * 0.25, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: mark, height: mark)
            title
        }
    }

    /// What VoiceOver calls a day: *Today*, or its date spelled out.
    private func name(of day: MonthHistory.Day) -> Text {
        guard !day.isToday else { return Text("Today", bundle: strings) }
        return Text(day.summary.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale)))
    }
}

/// The month's opened day: its name and its total against the goal, a heading on the aurora above its
/// strip and its servings (spec §3.4, plan M6) — one element, as History's own heading is.
private struct OpenedDayHeading: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let day: MonthHistory.Day

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Group {
                if day.isToday {
                    Text("Today", bundle: strings)
                } else {
                    Text(day.summary.date, format: .dateTime.weekday(.wide).day().month(.wide))
                }
            }
            .font(.title3.weight(.bold))
            // Two lines before a word is cut: a day's name is the longest word this screen draws.
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .legibleOnBackdrop()
            .accessibilityAddTraits(.isHeader)
            .accessibilityValue(strings.localized("%1$d of %2$d millilitres", day.summary.total, manager.dailyGoal, locale: locale))

            Text(strings.figure("%1$@ of %2$@ ml", day.summary.total, manager.dailyGoal, locale: locale))
                .font(.subheadline.weight(.semibold))
                .fontDesign(.rounded)
                .monospacedDigit()
                .legibleOnBackdrop()
                .accessibilityHidden(true)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, HistoryView.margin)
    }
}

/// The month's figures: *Days on goal*, *Best streak* and *This month* as tiles — three across where
/// they fit, a column where they do not — then the average and the change (spec §3.5, §3.9). Drawn
/// only for a month with a counted day.
private struct MonthFigures: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let month: MonthHistory

    var body: some View {
        VStack(spacing: 10) {
            // Offered the row's whole width; it chooses among whole layouts (`tasks/lessons.md`).
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 10) { tiles(fixed: true) }
                VStack(spacing: 10) { tiles(fixed: false) }
            }
            .frame(maxWidth: .infinity)

            if let average = month.average {
                averageLine(average)
            }
        }
        .padding(.horizontal, HistoryView.margin)
    }

    @ViewBuilder
    private func tiles(fixed: Bool) -> some View {
        tile(
            strings.figure("%1$@/%2$@", month.daysMet, month.daysCounted, locale: locale),
            label: Text("Days on goal", bundle: strings),
            spoken: strings.localized("%1$d of %2$d days", month.daysMet, month.daysCounted, locale: locale),
            fixed: fixed
        )
        tile(
            strings.localized("%1$d days", month.bestRun, locale: locale),
            label: Text("Best streak", bundle: strings),
            spoken: strings.localized("%1$d days", month.bestRun, locale: locale),
            fixed: fixed
        )
        // Litres drawn, millilitres spoken, as the sliders speak them (spec §3.9).
        tile(
            strings.localized("%1$@ L", HistoryView.litres(month.total, locale: locale), locale: locale),
            label: Text("This month", bundle: strings),
            spoken: strings.localized("%1$d millilitres", month.total, locale: locale),
            fixed: fixed
        )
    }

    private func tile(_ figure: String, label: Text, spoken: String, fixed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(figure)
                .font(.title3.weight(.bold))
                .fontDesign(.rounded)
                .monospacedDigit()
            label
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .lineLimit(1)
        // At its own size across the row; in the column, with a line to itself, it may shrink.
        .minimumScaleFactor(fixed ? 1 : 0.6)
        .fixedSize(horizontal: fixed, vertical: false)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .foregroundStyle(.white)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(spoken)
    }

    private func averageLine(_ average: Int) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(strings.figure("Average %1$@ ml a day", average, locale: locale))
                    .font(.subheadline.weight(.bold))
                if let change = month.change {
                    Text(drawnChange(change))
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            if let change = month.change {
                Image(systemName: change > 0 ? "arrow.up.right" : change < 0 ? "arrow.down.right" : "equal")
                    .font(.body.weight(.semibold))
                    // A glyph on dark glass, read at 3:1 in the walk (`tasks/lessons.md`, 2026-10-22).
                    .foregroundStyle(Aurora.cyan)
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(strings.localized("Average %1$d millilitres a day", average, locale: locale))
        .accessibilityValue(month.change.map(spokenChange) ?? "")
    }

    /// Names no month: Russian would need it in the prepositional case, which Foundation does not
    /// produce (spec §3.11).
    private func drawnChange(_ change: Int) -> String {
        if change > 0 { return strings.figure("Up %1$@ ml on the month before", change, locale: locale) }
        if change < 0 { return strings.figure("Down %1$@ ml on the month before", -change, locale: locale) }
        return strings.localizedString(forKey: "The same as the month before", value: nil, table: nil)
    }

    private func spokenChange(_ change: Int) -> String {
        if change > 0 { return strings.localized("Up %1$d millilitres on the month before", change, locale: locale) }
        if change < 0 { return strings.localized("Down %1$d millilitres on the month before", -change, locale: locale) }
        return strings.localizedString(forKey: "The same as the month before", value: nil, table: nil)
    }
}

// MARK: - The month's patterns

/// *Patterns*, and the days they come from, on the aurora above their panes — the opened day's kind of
/// heading, one element (spec `2026-10-23-patterns-design.md` §3.2, §3.8). The line names no month:
/// Russian would need it in a case Foundation cannot give (`tasks/lessons.md`, 2026-10-22).
private struct PatternsHeading: View {

    @Environment(\.strings) private var strings

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Patterns", bundle: strings)
                .font(.title3.weight(.bold))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
                .accessibilityValue(Text("From this month's finished days", bundle: strings))

            Text("From this month's finished days", bundle: strings)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .legibleOnBackdrop()
                .accessibilityHidden(true)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, HistoryView.margin)
    }
}

/// *When you drink*: a bar an hour across the whole day, the busiest in `Aurora.cyan`, on the day
/// strip's axis — so the month's hours and a day's servings read alike (spec §3.2, §3.3).
///
/// **One element**: the title, its value the busiest hour. The bars and the axis are hidden.
private struct HoursChart: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let patterns: MonthPatterns

    /// The strip's measures, capped at its use site (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .footnote) private var scaledPlotHeight: CGFloat = 64

    private var plotHeight: CGFloat { min(scaledPlotHeight, 92) }

    private let barWidth: CGFloat = 8

    private var bars: [Double] { HistoryView.hourBars(patterns.hourly) }

    /// *Most around 13:00*, through the phone's own 12- or 24-hour form under the app's locale.
    private var busiest: String {
        strings.localized(
            "Most around %1$@",
            patterns.busiestHourAt.formatted(.dateTime.hour().minute().locale(locale)),
            locale: locale
        )
    }

    /// The strip's labelled hours, as instants on the month's 1st — the model's answer, on its calendar.
    private var labels: [(hour: Int, at: Date)] {
        HistoryView.stripHours.compactMap { hour in
            manager.hours([hour], onDayOf: patterns.busiestHourAt).first.map { (hour, $0) }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading

            VStack(spacing: 6) {
                plot
                axis
            }
            .accessibilityHidden(true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        // The week card's pair: sibling panes on one screen share one (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
    }

    /// The title, and the busiest hour trailing it — under it where the two do not fit on one line.
    private var heading: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                title
                    .fixedSize()
                Spacer(minLength: 0)
                busiestLine
                    .fixedSize()
            }
            VStack(alignment: .leading, spacing: 4) {
                title
                busiestLine
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var title: some View {
        Text("When you drink", bundle: strings)
            .font(.callout.weight(.semibold))
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityValue(busiest)
            .accessibilityAddTraits(.isHeader)
    }

    /// In the board's cyan, the busiest bar's colour. Hidden: the title speaks it.
    private var busiestLine: some View {
        Text(busiest)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Aurora.cyan)
            .accessibilityHidden(true)
    }

    private var plot: some View {
        GeometryReader { proxy in
            let travel = max(proxy.size.width - barWidth, 0)

            ZStack(alignment: .bottomLeading) {
                // The ground the bars stand on, as the strip's.
                Capsule()
                    .fill(.white.opacity(0.3))
                    .frame(height: 1)

                // Every hour's bar is always there, an hour with no water at no height, so another
                // month grows and shrinks the bars rather than inserting them (rule `50-views`).
                ForEach(bars.indices, id: \.self) { hour in
                    Capsule()
                        .fill(hour == patterns.busiestHour ? Aurora.cyan : Color.white.opacity(0.7))
                        .frame(width: barWidth, height: bars[hour] > 0 ? max(proxy.size.height * bars[hour], barWidth) : 0)
                        .offset(x: travel * HistoryView.hourPosition(hour))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomLeading)
        }
        .frame(height: plotHeight)
        .animation(.smooth(duration: 0.45), value: bars)
    }

    private var axis: some View {
        GeometryReader { proxy in
            let travel = max(proxy.size.width - barWidth, 0)

            ForEach(labels, id: \.hour) { label in
                Text(label.at, format: .dateTime.hour())
                    // A ratio of the plot it annotates, as the strip's (rule `65-accessibility`).
                    .font(.system(size: plotHeight * 0.18, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize()
                    .position(x: travel * HistoryView.hourPosition(label.hour) + barWidth / 2, y: proxy.size.height / 2)
            }
        }
        .frame(height: plotHeight * 0.24)
    }
}

/// *Weekdays* and *Weekends*: each its average day, and a bar against the goal's tick at its end —
/// `Aurora.cyan` when the average reaches the goal and white when it does not, the week card's
/// meaning, and never colour alone: a met bar reaches the tick (spec §3.2, §3.4).
///
/// **Each row one element**: its name, its average in millilitres.
private struct WeekSplit: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let split: MonthPatterns.Split

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let weekdays = split.weekdays {
                row(Text("Weekdays", bundle: strings), weekdays)
            }
            if let weekends = split.weekends {
                row(Text("Weekends", bundle: strings), weekends)
            }

            Text("Measured against your current goal", bundle: strings)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
    }

    private func row(_ name: Text, _ side: MonthPatterns.Side) -> some View {
        let figure = Text(strings.figure("%1$@ ml a day", side.average, locale: locale))
            .font(.subheadline.weight(.bold))
            .fontDesign(.rounded)
            .monospacedDigit()

        return VStack(alignment: .leading, spacing: 8) {
            // Offered the row's whole width; it chooses among whole layouts (`tasks/lessons.md`).
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    name.font(.subheadline.weight(.semibold)).fixedSize()
                    Spacer(minLength: 0)
                    figure.fixedSize()
                }
                VStack(alignment: .leading, spacing: 2) {
                    name.font(.subheadline.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
                    figure
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            bar(side)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(name)
        .accessibilityValue(strings.localized("%1$d millilitres a day", side.average, locale: locale))
    }

    /// The average against the goal: the week card's track and its goal line's rule, at the bar's end.
    ///
    /// The week's own shape for a track and a bar inside a pane (rule `60-design-system`). The fill is
    /// always there, at no width for a side with no water, so its length and colour animate rather
    /// than a layer coming and going (rule `50-views`).
    private func bar(_ side: MonthPatterns.Side) -> some View {
        let shape = RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous)

        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                shape
                    .fill(.white.opacity(0.10))
                shape
                    .fill(side.isMet ? Aurora.cyan : Color.white)
                    .frame(width: side.fraction > 0 ? max(proxy.size.width * side.fraction, proxy.size.height) : 0)
            }
            .overlay(alignment: .trailing) {
                Capsule()
                    .fill(.white.opacity(0.62))
                    .frame(width: 1.5, height: proxy.size.height + 8)
            }
        }
        .frame(height: 10)
        .animation(.smooth(duration: 0.45), value: side)
    }
}

/// *First drink, usually* and *Last drink, usually*: the month's figures' tiles — across where they
/// fit, a column where they do not (spec §3.2, §3.5).
private struct UsualTimes: View {

    @Environment(\.strings) private var strings

    let patterns: MonthPatterns

    var body: some View {
        // Offered the row's whole width; it chooses among whole layouts (`tasks/lessons.md`).
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 10) { tiles(fixed: true) }
            VStack(spacing: 10) { tiles(fixed: false) }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, HistoryView.margin)
    }

    @ViewBuilder
    private func tiles(fixed: Bool) -> some View {
        tile(patterns.firstDrinkAt, label: Text("First drink, usually", bundle: strings), fixed: fixed)
        tile(patterns.lastDrinkAt, label: Text("Last drink, usually", bundle: strings), fixed: fixed)
    }

    private func tile(_ time: Date, label: Text, fixed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // The phone's own 12- or 24-hour form, as every time here.
            Text(time, format: .dateTime.hour().minute())
                .font(.title3.weight(.bold))
                .fontDesign(.rounded)
                .monospacedDigit()
            label
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .lineLimit(1)
        .minimumScaleFactor(fixed ? 1 : 0.6)
        .fixedSize(horizontal: fixed, vertical: false)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .foregroundStyle(.white)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(Text(time, format: .dateTime.hour().minute()))
    }
}

/// A month with fewer than seven days of water: one line, so the section says what patterns need rather
/// than vanishing — true of a month still filling and of a finished one that never will (spec §3.2).
private struct PatternsPending: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    var body: some View {
        // *Need*, not *appear after*: a finished month with fewer days will never have them (the final
        // review's M4).
        Text(strings.localized("Patterns need %1$d days of water", MonthPatterns.minimumDays, locale: locale))
            .font(.subheadline)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .liquidGlass(density: .frosted, elevation: .raised)
            .padding(.horizontal, HistoryView.margin)
    }
}

/// What a free user meets in Month: a drawn month — not theirs, and never read (spec §3.6) — blurred
/// under a card that offers Premium, and the promise under it.
private struct LockedMonth: View {

    @Environment(\.strings) private var strings

    let open: () -> Void
    let back: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            card
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: MonthStyle.lockedHeight)
                // Behind the card and sized by it, so it stands round the card at every text size.
                .background {
                    VStack(spacing: 14) {
                        // Where a month's name would stand — drawn, never read.
                        Capsule()
                            .fill(.white.opacity(0.28))
                            .frame(width: MonthStyle.drawnTitleBar.width, height: MonthStyle.drawnTitleBar.height)
                        DrawnMonth(pattern: true, weekSpacing: MonthStyle.drawnWeekSpacing)
                    }
                        .blur(radius: 5)
                        .opacity(0.75)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .liquidGlass(density: .frosted, elevation: .raised)
                        .accessibilityHidden(true)
                }
            promise
        }
        .padding(.horizontal, HistoryView.margin)
    }

    private var card: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar")
                // White, as the Settings card's glyph is: cyan read 2.88:1 there (step 1's walk, R4).
                .font(.title2.weight(.semibold))
                .accessibilityHidden(true)
            Text("Your whole month at a glance", bundle: strings)
                .font(.title3.weight(.bold))
                .accessibilityAddTraits(.isHeader)
            Text("Every day you have logged is kept. Premium shows it as months, with your patterns and a recap.", bundle: strings)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
            Button(action: open) {
                // The surface sets its label's colour (rule `60-design-system`).
                Text("See Premium", bundle: strings)
                    .font(.body.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: MonthStyle.buttonHeight)
                    .primarySurface(in: Capsule())
            }
            .buttonStyle(PressStyle())
            .padding(.top, 6)
            Button(action: back) {
                Text("Back to this week", bundle: strings)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        // Sentence-length text, on `.frosted` (rule `60-design-system`), and Premium's mark.
        .liquidGlass(density: .frosted, elevation: .raised)
        .premiumRim()
    }

    private var promise: some View {
        HStack(alignment: .top, spacing: 12) {
            // White, step 1's ruling R4 for the paywall's check.
            Image(systemName: "checkmark")
                .font(.body.weight(.semibold))
                .accessibilityHidden(true)
            Text("The week, today and every serving stay free. Nothing you logged is ever hidden or deleted.", bundle: strings)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .combine)
    }
}

/// A month drawn, not read: five weeks of rings, with no number, date or name (spec §3.3, §3.6) — the
/// locked month's backdrop, `pattern` cyan and white as a month of water would be, and a month's quiet
/// form before its first read, every ring empty. No pane of its own; its callers hide it from VoiceOver.
private struct DrawnMonth: View {

    let pattern: Bool

    /// The gap between weeks: the month card's 4 for its quiet form, so it stands at the card's height;
    /// more under the locked month's card, so the month shows round it.
    var weekSpacing: CGFloat = 4

    @ScaledMetric(relativeTo: .body) private var scaledRing: CGFloat = 34

    private var ring: CGFloat { min(scaledRing, 36) }

    var body: some View {
        VStack(spacing: weekSpacing) {
            ForEach(0..<5, id: \.self) { week in
                DayRow {
                    ForEach(0..<7, id: \.self) { weekday in
                        Circle()
                            .inset(by: ring * 0.05)
                            .stroke(colour(at: week * 7 + weekday), lineWidth: ring * 0.1)
                            .frame(width: ring, height: ring)
                            .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// The board's drawn month (*Step 2 — Month, free user*): the third and seventh of every nine days
    /// short of the goal, the last week still to come.
    private func colour(at index: Int) -> Color {
        guard pattern, index < 28 else { return .white.opacity(0.10) }
        return [2, 6].contains(index % 9) ? .white.opacity(0.45) : Aurora.cyan
    }
}

// MARK: - The day

/// When the shown day's servings were poured: one bar each, across the whole day.
///
/// **Midnight to midnight**, not the waking hours the canvas drew: a drink at 00:30 has to
/// appear. A bar's place is a fraction of that day's real length, asked of the model — a view
/// holds no calendar (rule `30-rollover`) — so a 23- or 25-hour day draws correctly and an hour's
/// label stands where a serving poured on that hour stands.
///
/// **VoiceOver hears the title, as a heading, with the count of servings as its value, and nothing
/// else.** The bars repeat the rows under this card, each of which speaks its own amount and time;
/// the reminder's mark repeats Home's line; the drawn count repeats the heading's value
/// (rule `65-accessibility`). That each is silent is the design, unverified with VoiceOver: XCUITest
/// lists hidden text in this list's rows (`docs/AI_CONTEXT.md` known issue #139).
private struct DayStrip: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// The shown day's servings.
    let logs: [WaterLog]

    /// Which day these servings are from, as its ordinal. When it changes, the bars start again
    /// from the baseline.
    let day: Int?

    /// Whether to mark the next reminder — today only.
    let marksReminder: Bool

    /// Whether the screen has arrived (``Arrival``).
    let arrived: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The day whose bars have been let grow. A turn behind ``day`` whenever that changes,
    /// which is the moment the bars stand at nothing.
    @State private var raised: Int?

    /// As the week card's bars: nothing until the screen has arrived, then grown from the
    /// baseline — and again each time another day is picked, so the strip is seen to be redrawn
    /// for that day and not merely to have changed. Simply there under Reduce Motion.
    private var grown: Bool { reduceMotion || (arrived && raised == day) }

    /// A real magnitude, capped at its use site (rule `65-accessibility`): a decorative
    /// dimension that grew with the text would push the servings off the screen.
    @ScaledMetric(relativeTo: .footnote) private var scaledPlotHeight: CGFloat = 64

    private var plotHeight: CGFloat { min(scaledPlotHeight, 92) }

    /// A bar's width. The plot's travel is its own width less this, so the first and the last
    /// minute of the day both draw inside it.
    private let barWidth: CGFloat = 8

    private var bars: [StripBar] {
        HistoryView.stripBars(
            for: logs.map { (id: $0.id, amount: $0.amount, position: manager.dayFraction(of: $0.timestamp)) },
            vessels: manager.servings
        )
    }

    /// The labelled hours, as instants on the shown day. Any of its servings names the day.
    private var hours: [Date] {
        guard let anchor = logs.first?.timestamp else { return [] }
        return manager.hours(HistoryView.stripHours, onDayOf: anchor)
    }

    /// *When you drank*, and how many times. The count trails the heading, and moves under it where the
    /// two do not fit on one line at the text size in use (spec 2026-10-16 §3.5).
    private var heading: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                title
                    .fixedSize()
                Spacer(minLength: 0)
                count
                    .fixedSize()
            }
            VStack(alignment: .leading, spacing: 4) {
                title
                count
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var title: some View {
        Text("When you drank", bundle: strings)
            .font(.callout.weight(.semibold))
            // Two lines before a word is cut, as the week card's title has.
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityValue(servings)
            .accessibilityAddTraits(.isHeader)
    }

    /// In the week card's label style, white at 0.9 on this pane — the pair the strip's hour labels
    /// measure (`docs/DESIGN.md`, *Strip: hour label*). Hidden: the heading speaks it.
    private var count: some View {
        Text(servings)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white.opacity(0.9))
            .accessibilityHidden(true)
    }

    /// *5 servings*, *5 порций*, *5 porsiya*. The rows the bars are drawn from; the card is drawn
    /// only for a day that has one (`HistoryView`'s `if shownLogs.isEmpty`), so never *0*.
    private var servings: String {
        strings.localized("%1$d servings", logs.count, locale: locale)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading

            VStack(spacing: 6) {
                plot
                axis
            }
            .accessibilityHidden(true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        // The week card's pair: sibling panes on one screen share one (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
    }

    private var plot: some View {
        GeometryReader { proxy in
            let travel = max(proxy.size.width - barWidth, 0)

            ZStack(alignment: .bottomLeading) {
                // The ground the bars stand on.
                Capsule()
                    .fill(.white.opacity(0.3))
                    .frame(height: 1)

                ForEach(bars) { bar in
                    Capsule()
                        .fill(Aurora.cyan)
                        // A dark hairline round each bar. Two drinks inside forty minutes
                        // overlap on a plot this wide, and without an edge they are one wide bar.
                        .overlay { Capsule().strokeBorder(.black.opacity(0.45), lineWidth: 1) }
                        .frame(width: barWidth, height: grown ? max(proxy.size.height * bar.height, barWidth) : 0)
                        .offset(x: travel * bar.position)
                }

                reminderMark(travel: travel, height: proxy.size.height)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomLeading)
        }
        .frame(height: plotHeight)
        .animation(.smooth(duration: 0.45), value: bars)
        // As the screen arrives, a moment after the card that carries them, and each time
        // another day is picked. Only the way up is this curve's: the day being left has other
        // bars, which fade out on the line above while the new day's grow.
        .animation(grown ? .smooth(duration: 0.5).delay(Arrival.delay(order: 2)) : nil, value: grown)
        // A turn after the day changes, so one frame is drawn with the new day's bars at
        // nothing and there is something to grow from.
        .task(id: day) { raised = day }
    }

    /// The next reminder, as a white rule under a bell — told from a serving by its shape as well
    /// as its colour. Re-read every minute, as Home's line is: a reminder that has passed stops
    /// being "next", and nothing else would say so on a screen nobody is touching.
    @ViewBuilder
    private func reminderMark(travel: CGFloat, height: CGFloat) -> some View {
        if marksReminder {
            TimelineView(.everyMinute) { _ in
                if let next = manager.nextReminder {
                    VStack(spacing: 2) {
                        Image(systemName: HomeView.reminderSymbol)
                            // A ratio of the plot it sits in, never its own text style.
                            .font(.system(size: height * 0.19, weight: .semibold))
                        Capsule()
                            .frame(width: 1.5, height: height * 0.5)
                    }
                    .foregroundStyle(.white)
                    .frame(width: barWidth)
                    .offset(x: travel * manager.dayFraction(of: next))
                }
            }
        }
    }

    private var axis: some View {
        GeometryReader { proxy in
            let travel = max(proxy.size.width - barWidth, 0)

            ForEach(hours, id: \.self) { hour in
                // The phone's own 12- or 24-hour form under the app's locale, as every time here.
                Text(hour, format: .dateTime.hour())
                    // A ratio of the plot it annotates, never a text style of its own
                    // (rule `65-accessibility`). 0.18 × 64 pt is 11.5 pt.
                    .font(.system(size: plotHeight * 0.18, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize()
                    .position(x: travel * manager.dayFraction(of: hour) + barWidth / 2, y: proxy.size.height / 2)
            }
        }
        .frame(height: plotHeight * 0.24)
    }
}

// MARK: - A serving

/// One logged serving: a frosted capsule carrying its glyph, its amount, the vessel it is drawn
/// as when there is one, and the time it landed.
///
/// Private because it has exactly one consumer. `AuroraBackground` and `PressStyle` earned their
/// own files only when a second screen wanted them.
private struct ServingRow: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let log: WaterLog

    /// The vessel this amount is drawn as, or `nil` — ``HistoryView/vessel(forAmount:amounts:)``.
    let vessel: HomeView.Serving?

    /// `nil` in Month mode, whose rows are read-only (spec §3.4).
    let edit: (() -> Void)?

    /// The glyph's disc, a real magnitude scaled with the row's own text and capped at its use
    /// site (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .body) private var scaledDisc: CGFloat = 36

    private var disc: CGFloat { min(scaledDisc, 52) }

    /// **Two layouts, and the first that fits at its own size is drawn**: the time beside the
    /// amount, or under it. The choice is among two whole rows, in the list's whole width
    /// (`tasks/lessons.md`, 2026-10-11).
    ///
    /// Squeezed onto one line at the large text sizes, the amount and the time were each offered
    /// half of what the glyph left. The time fitted in its half; the amount was shrunk as far as
    /// it would go and then cut — *100…* for *100 мл* — and even where it fitted it was drawn
    /// smaller than the time beside it. The amount is the row; the time gives way.
    var body: some View {
        ViewThatFits(in: .horizontal) {
            row(stacked: false)
            row(stacked: true)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func row(stacked: Bool) -> some View {
        if let edit {
            Button(action: edit) { pane(stacked: stacked) }
                .buttonStyle(PressStyle())
                // One serving, one stop. The swipe action reaches VoiceOver on its own, as a rotor action.
                //
                // The label goes on the **button**, not on an `.accessibilityElement(children: .ignore)`
                // wrapper around it. That is the idiom the vessel uses, and it is wrong here: the vessel
                // wraps plain drawing, while this wraps a *control*, which VoiceOver surfaces
                // regardless. The wrapper became a second element above it and every serving was
                // announced twice — "250 millilitres, 21:22", then "250 ml, 21:22, button". Only the real
                // accessibility tree shows that; no unit test in this project can see one.
                .accessibilityLabel(strings.localized("%1$d millilitres", log.amount, locale: locale))
                .accessibilityValue(log.timestamp.formatted(date: .omitted, time: .shortened))
                .accessibilityHint(Text("Edits this serving", bundle: strings))
        } else {
            // Month mode's row: the same pane, drawn, and no control to wrap — so here the wrapper is
            // the right idiom, one element speaking what the button would (spec §3.9).
            pane(stacked: stacked)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(strings.localized("%1$d millilitres", log.amount, locale: locale))
                .accessibilityValue(log.timestamp.formatted(date: .omitted, time: .shortened))
        }
    }

    private func pane(stacked: Bool) -> some View {
        HStack(spacing: 14) {
            // The vessel's glyph when the amount is one of the current three; the drop
            // otherwise.
            Image(systemName: vessel?.symbol ?? "drop.fill")
                // A ratio of the disc it sits in, never its own text style.
                .font(.system(size: disc * 0.44, weight: .semibold))
                // White on the canvas's cyan wash. The canvas's glyph was cyan, and a cyan
                // glyph on a cyan wash read 2.46–2.79:1 against the 3:1 floor for a non-text
                // mark at every wash tried — the wash lightens its own ground, and the sheen
                // lands on the row's top left, where the glyph sits. White on the 0.16 wash
                // read 4.42–5.30 swept (`docs/DESIGN.md`, *The look, measured*). The canvas's
                // wash is not an `Aurora` colour; `Aurora.cyan` stands in.
                .foregroundStyle(.white)
                .frame(width: disc, height: disc)
                .background(Circle().fill(Aurora.cyan.opacity(0.16)))
                .accessibilityHidden(true)

            if stacked {
                // The last layout, so the one that may shrink: each line has the row's
                // whole width to do it in.
                VStack(alignment: .leading, spacing: 1) {
                    amount
                    name
                    time
                }
                .minimumScaleFactor(0.6)

                Spacer(minLength: 0)
            } else {
                // At their own size or not at all.
                VStack(alignment: .leading, spacing: 1) {
                    amount
                    name
                }
                .fixedSize()

                Spacer(minLength: 8)

                time
                    .fixedSize()
            }
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .padding(.leading, 12)
        .padding(.trailing, 20)
        .padding(.vertical, 10)
        // WidgetKit's 44pt floor is a widget rule, but a list row is a control here too, and a
        // `minHeight` lets it grow with Dynamic Type instead of clipping.
        .frame(minHeight: 56)
        // Pressable only where it is a button.
        .liquidGlass(in: Capsule(), density: .frosted, elevation: .resting, interactive: edit != nil)
    }

    private var amount: some View {
        Text(strings.figure("%1$@ ml", log.amount, locale: locale))
            .font(.body.weight(.bold))
            .fontDesign(.rounded)
            .monospacedDigit()
    }

    /// Drawn, never spoken: the name is an inference from today's vessels.
    @ViewBuilder
    private var name: some View {
        if let vessel {
            Text(vessel.name(in: strings))
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    /// Rendered through the phone's own 12/24-hour setting rather than a fixed pattern: "14:32"
    /// on a 24-hour device, "2:32 PM" on a 12-hour one. Forcing HH:mm would override a preference
    /// the user actually chose.
    private var time: some View {
        Text(log.timestamp, format: .dateTime.hour().minute())
            .font(.subheadline.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(.white.opacity(0.94))
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
/// Deliberately the same lockup as the welcome's goal card — one glass pane, a hero readout
/// with a ratio-sized unit, an `Aurora.cyan` slider — because every pane in this product is lit by
/// the same light, and a second layout for "pick a number in millilitres" would be a second one.
/// Under the slider sit the three vessels, as one-tap amounts; the time is a wheel inside the same
/// pane: one pane asks how much and when.
private struct ServingSheet: View {

    let editor: ServingEditor

    /// What the wheel offers — ``DataManager/correctionRange()``, the week up to now.
    let range: ClosedRange<Date>

    /// Hands the saved serving's time back, so History can show the day it landed on.
    let saved: (Date) -> Void

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
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

    /// A shortcut's type: a real magnitude scaled with the text (rule `65-accessibility`), and
    /// capped where it is used.
    @ScaledMetric(relativeTo: .subheadline) private var scaledShortcut: CGFloat = 15

    private var shortcutSize: CGFloat { min(scaledShortcut, 30) }

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

    /// Wide enough for the serving the sheet opened on and for each of the three shortcuts.
    private var bounds: ClosedRange<Int> {
        HistoryView.sliderBounds(forAmount: openingAmount, vessels: manager.servings)
    }

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
        // A tick for each step of the slider and for a vessel picked. The amount under the
        // finger is the sheet's own state and no model value (rule `60-design-system`).
        .sensoryFeedback(Haptics.select, trigger: amount)
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

            // The slider, the shortcuts and the wheel sit close: the shortcuts belong to the
            // slider they set, and the wheel brings its own air in the faded rows above the one
            // being set. Spaced as the readout is, the three shortcuts pushed *Save* half off the
            // foot of a 375 × 667 pt phone at the ordinary text size.
            VStack(spacing: 8) {
                amountControls
                wheel
            }
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .liquidGlass(density: .frosted, elevation: .floating)
    }

    @ViewBuilder
    private var amountControls: some View {
        Slider(
            value: sliderValue,
            in: Double(bounds.lowerBound)...Double(bounds.upperBound),
            step: Double(HistoryView.servingStep)
        )
        .tint(Aurora.cyan)
        // A `Slider`'s stock VoiceOver value is a percentage of its range, which here would
        // announce "21%" for 250 ml — a number that appears nowhere in the product.
        .accessibilityLabel(Text("Serving amount", bundle: strings))
        .accessibilityValue(strings.localized("%1$d millilitres", amount, locale: locale))
        .padding(.horizontal, 24)

        shortcuts
    }

    /// Day, hour and minute on one wheel, bounded by the week and by now, so neither a day the
    /// screen cannot show nor a time that has not happened can be picked. It formats through the
    /// environment locale the app injects with `\.strings` (rule `70-privacy`).
    ///
    /// The wheel alone runs the card's full width, without the 24-pt inset. Its natural width is
    /// more than that inset leaves, and a view that will not shrink widens everything above it:
    /// the first build pushed the card and both buttons past the screen's right edge.
    /// `minWidth: 0` is what stops it reporting more than it is offered.
    ///
    /// **Its neighbouring rows fall under the text floor, and that is recorded rather than
    /// hidden.** Measured off a render, the row being set reads 5.47:1 against its band. UIKit
    /// draws the rows around it in a dimmed grey that assumes a near-black backdrop and that no
    /// public API recolours; on this pane they measure 2.4–2.8:1 against the 4.5:1 rule
    /// `65-accessibility` sets. Accepted by the owner on 2026-10-07 as the system control's own
    /// styling — `docs/AI_CONTEXT.md` known issue #59.
    private var wheel: some View {
        DatePicker(selection: $when, in: range, displayedComponents: [.date, .hourAndMinute]) {
            Text("When", bundle: strings)
        }
        .datePickerStyle(.wheel)
        .labelsHidden()
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    /// The three vessels as one-tap amounts, under the slider they set.
    ///
    /// **Selected with the selection tokens, not with the white the canvas drew**: a screen
    /// carries one primary surface, and *Save* is it (rule `60-design-system`). The fill and the
    /// rim are present at zero opacity when unselected, so moving the selection animates a colour
    /// and not a layer (rule `50-views`) — and selection is never colour alone: the rim, the
    /// weight and the `.isSelected` trait all carry it (rule `65-accessibility`).
    ///
    /// Two vessels that hold one amount are both selected, which is the truth.
    ///
    /// **Two layouts, and the first that fits at its own size is drawn**: a glyph beside its
    /// figure, or the glyph over it. The choice is among whole rows of buttons, in the card's
    /// whole width (`tasks/lessons.md`, 2026-10-11). Shrunk onto one line at `AccessibilityXXXL`,
    /// the three glyphs grew with the text and the figures went — a cup with no number, a mug
    /// and a *2*, a bottle and an ellipsis — and the figure is what the button sets.
    private var shortcuts: some View {
        ViewThatFits(in: .horizontal) {
            shortcutRow(stacked: false)
            shortcutRow(stacked: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .animation(.smooth(duration: 0.3), value: amount)
    }

    private func shortcutRow(stacked: Bool) -> some View {
        HStack(spacing: 8) {
            ForEach(HomeView.servings(amounts: manager.servings)) { serving in
                shortcut(serving, stacked: stacked)
            }
        }
    }

    private func shortcut(_ serving: HomeView.Serving, stacked: Bool) -> some View {
        let isSelected = amount == serving.amount
        let glyph = Image(systemName: serving.symbol)
        let figure = Text(serving.amount, format: .number)
            .monospacedDigit()

        return Button {
            amount = serving.amount
        } label: {
            Group {
                if stacked {
                    // The last layout, so the one that may shrink: a four-digit amount at the
                    // cap is a little wider than its slot.
                    VStack(spacing: 2) {
                        glyph
                        figure.minimumScaleFactor(0.6)
                    }
                    .padding(.vertical, 6)
                } else {
                    // At its own size or not at all.
                    HStack(spacing: 6) {
                        glyph
                        figure
                    }
                    .fixedSize()
                }
            }
            // One size for the glyph and the figure, capped: an SF Symbol set in a text style
            // grows with it without limit, and three of these share a row.
            .font(.system(size: shortcutSize, weight: isSelected ? .bold : .semibold, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, 8)
            // The whole slot is the target, never just the glyph (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
                Capsule()
                    .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
                    .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
                    // The lozenge lands on the vessel that was picked: from a little small, past
                    // its size and back. The colour beside it still changes on `.smooth`.
                    .scaleEffect(isSelected ? 1 : 0.9)
                    .animation(Motion.land, value: isSelected)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // The glyph is what says "cup" on screen; the name is what says it aloud, and the amount
        // is the value.
        .accessibilityLabel(Text(verbatim: serving.name(in: strings)))
        .accessibilityValue(strings.localized("%1$d millilitres", serving.amount, locale: locale))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
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
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    // The sheet's main action, on the primary surface like *Get Started*
                    // (rule `60-design-system`). *Cancel* beside it stays glass.
                    .primarySurface(in: Capsule())
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

    // The backdrop is `RootTabView`'s in the app; alone on the canvas the screen stands on one.
    return HistoryView()
        .background { AuroraBackground() }
        .environment(manager)
        .environment(PremiumStore(source: .silent()))
}

#Preview("Nothing logged") {
    HistoryView()
        .background { AuroraBackground() }
        .environment(previewManager(named: "preview.waterbuddy.history.empty"))
        .environment(PremiumStore(source: .silent()))
}

#Preview("Month, held") {
    let manager = previewManager(named: "preview.waterbuddy.history.month")

    // Pinned to the start of the day, as the other previews are; twenty days back, every fourth short.
    let start = Calendar.waterBuddyDay.startOfDay(for: .now)
    for offset in 1...20 {
        if let day = Calendar.waterBuddyDay.date(byAdding: .day, value: -offset, to: start) {
            manager.addLog(amount: offset % 4 == 0 ? 1_500 : 2_600, at: day.addingTimeInterval(10 * 3_600))
        }
    }

    // A source that holds the lifetime purchase and reaches no store (rule `85-testing`).
    var source = PremiumStore.Source.silent()
    source.entitlements = { [PremiumAccess.Entitlement(productID: PremiumAccess.lifetimeID, expires: nil, revoked: nil)] }

    return HistoryView()
        .background { AuroraBackground() }
        .environment(manager)
        .environment(PremiumStore(source: source))
}
